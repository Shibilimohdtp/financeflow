import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/subscription.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/merchant_normalization_service.dart';
import '../../services/subscription_service.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_banner.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_disclosure_row.dart';
import '../../shared/widgets/ff_field_label.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_suggestion_chips.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_subscription_preview_card.dart';
import '../../shared/widgets/ff_subscription_type_tiles.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'subscriptions_controller.dart';

/// The Add / Edit Subscription sheet: sheet archetype B (entity with a live
/// preview), on the shared skeleton.
///
/// Designed around what people need:
/// 1. Generic type tiles with smart merchant hints (no brand logos)
/// 2. Amount-first with live Geist 300 typography
/// 3. Renewal date by intention with fast presets
/// 4. Live dynamic consequence line computing annual pace
/// 5. Real-time squircle preview card matching list rows
/// 6. Soft non-blocking duplicate detection
/// 7. Progressive disclosure of reminder, account, and notes
class AddEditSubscriptionSheet extends ConsumerStatefulWidget {
  final Subscription? initialSubscription;
  final RecurringSubscriptionSuggestion? suggestion;

  const AddEditSubscriptionSheet({
    super.key,
    this.initialSubscription,
    this.suggestion,
  });

  @override
  ConsumerState<AddEditSubscriptionSheet> createState() =>
      _AddEditSubscriptionSheetState();
}

class _AddEditSubscriptionSheetState
    extends ConsumerState<AddEditSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchantController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late SubscriptionFrequency _frequency;
  late DateTime _nextRenewalDate;
  String? _selectedAccountId;
  String _selectedCategory = 'Subscriptions';
  SubscriptionCategoryType? _selectedType;
  late int _reminderDays;
  late bool _isReminderEnabled;
  bool _showAdvanced = false;
  bool _isSaving = false;

  bool get isEditing => widget.initialSubscription != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialSubscription;
    final sug = widget.suggestion;

    _merchantController = TextEditingController(
      text: init?.merchant ?? sug?.merchant ?? '',
    );
    _amountController = TextEditingController(
      text:
          init != null
              ? FfAmountField.formatInput(init.amount)
              : sug != null
              ? FfAmountField.formatInput(sug.suggestedAmount)
              : '',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _frequency =
        init?.billingFrequency ??
        sug?.suggestedFrequency ??
        SubscriptionFrequency.monthly;

    _nextRenewalDate =
        init?.nextRenewalDate ??
        sug?.nextRenewalDate ??
        DateTime.now().add(const Duration(days: 30));

    _selectedAccountId = init?.accountId ?? sug?.accountId;
    _selectedCategory = init?.category ?? sug?.category ?? 'Subscriptions';
    _reminderDays = init?.reminderDaysBefore ?? 1;
    _isReminderEnabled = init?.isReminderEnabled ?? true;

    _showAdvanced =
        init != null &&
        ((init.notes?.isNotEmpty ?? false) ||
            init.accountId != null ||
            !init.isReminderEnabled ||
            init.reminderDaysBefore != 1);

    // Infer category type from initial or suggestion
    _inferType();

    _merchantController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  void _inferType() {
    final name = _merchantController.text.toLowerCase();
    for (final type in SubscriptionCategoryType.values) {
      if (type.popularMerchants.any(
        (m) => name.contains(m.toLowerCase()) || m.toLowerCase().contains(name),
      )) {
        _selectedType = type;
        return;
      }
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _merchantController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    return CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
  }

  String _buildConsequenceText() {
    final amt = _currentAmount;
    final amtFormatted = CurrencyFormatter.formatAmount(amt);
    final dateFormatted = DateFormatter.formatShortDate(_nextRenewalDate);

    switch (_frequency) {
      case SubscriptionFrequency.weekly:
        final mo = amt * (52.0 / 12.0);
        final yr = amt * 52.0;
        return '$amtFormatted a week is ${CurrencyFormatter.formatAmount(mo)} a month (${CurrencyFormatter.formatAmount(yr)}/yr). Next payment $dateFormatted.';
      case SubscriptionFrequency.monthly:
        final yr = amt * 12.0;
        return '$amtFormatted a month is ${CurrencyFormatter.formatAmount(yr)} a year. Next payment $dateFormatted.';
      case SubscriptionFrequency.quarterly:
        final mo = amt / 3.0;
        final yr = amt * 4.0;
        return '$amtFormatted a quarter is ${CurrencyFormatter.formatAmount(mo)} a month (${CurrencyFormatter.formatAmount(yr)}/yr). Next payment $dateFormatted.';
      case SubscriptionFrequency.yearly:
        final mo = amt / 12.0;
        return '$amtFormatted a year is ${CurrencyFormatter.formatAmount(mo)} a month. Next payment $dateFormatted.';
      case SubscriptionFrequency.custom:
        return '$amtFormatted on a custom billing schedule. Next payment $dateFormatted.';
    }
  }

  Subscription? _checkDuplicate(List<Subscription> allSubs) {
    final currentText = _merchantController.text.trim();
    if (currentText.isEmpty) return null;

    final norm =
        MerchantNormalizationService.normalize(currentText).toLowerCase();
    for (final sub in allSubs) {
      if (isEditing && sub.id == widget.initialSubscription!.id) continue;
      if (sub.status == SubscriptionStatus.active &&
          sub.normalizedMerchant.toLowerCase() == norm) {
        return sub;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _nextRenewalDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _nextRenewalDate = picked);
    }
  }

  void _setDatePreset(int daysFromNow) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    setState(() {
      _nextRenewalDate = base.add(Duration(days: daysFromNow));
    });
  }

  void _setNextMonthPreset() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _nextRenewalDate = DateTime(now.year, now.month + 1, now.day);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _currentAmount;
    if (amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid recurring amount.',
      );
      return;
    }

    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter the service or merchant name.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final controller = ref.read(subscriptionsControllerProvider.notifier);

    try {
      if (isEditing) {
        final updated = widget.initialSubscription!.copyWith(
          merchant: merchant,
          amount: amount,
          billingFrequency: _frequency,
          nextRenewalDate: _nextRenewalDate,
          accountId: _selectedAccountId,
          category: _selectedCategory,
          reminderDaysBefore: _reminderDays,
          isReminderEnabled: _isReminderEnabled,
          notes:
              _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
        );
        await controller.updateSubscription(updated);
      } else {
        await controller.addSubscription(
          merchant: merchant,
          amount: amount,
          billingFrequency: _frequency,
          nextRenewalDate: _nextRenewalDate,
          accountId: _selectedAccountId,
          category: _selectedCategory,
          sourceTransactionId:
              widget.suggestion?.matchingTransactions.isNotEmpty ?? false
                  ? widget.suggestion!.matchingTransactions.last.id
                  : null,
          reminderDaysBefore: _reminderDays,
          isReminderEnabled: _isReminderEnabled,
          notes:
              _notesController.text.trim().isNotEmpty
                  ? _notesController.text.trim()
                  : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        FfToast.show(
          context,
          message:
              isEditing
                  ? 'Subscription updated.'
                  : 'Subscription tracked for $merchant.',
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not save subscription: $e',
        );
      }
    }
  }

  Future<void> _delete() async {
    if (!isEditing) return;
    final sub = widget.initialSubscription!;

    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete subscription?',
      message:
          'Are you sure you want to stop tracking "${sub.merchant}" on this device?',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && mounted) {
      await ref
          .read(subscriptionsControllerProvider.notifier)
          .deleteSubscription(sub.id);
      if (mounted) {
        Navigator.of(context).pop(); // close sheet
        FfToast.show(context, message: 'Subscription removed.');
      }
    }
  }

  String get _saveButtonLabel {
    if (_currentAmount <= 0) return 'Enter amount';
    if (_merchantController.text.trim().isEmpty) return 'Enter service name';
    return isEditing ? 'Save changes' : 'Create subscription';
  }

  /// Which renewal preset (if any) the chosen date matches.
  String? _renewalPreset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(
      _nextRenewalDate.year,
      _nextRenewalDate.month,
      _nextRenewalDate.day,
    );
    if (d == today) return 'today';
    if (d == today.add(const Duration(days: 1))) return 'tomorrow';
    if (d == today.add(const Duration(days: 7))) return 'week';
    if (d == DateTime(now.year, now.month + 1, now.day)) return 'month';
    return null;
  }

  /// More accounts than this pick from a list instead of chips.
  static const _maxAccountChips = 6;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];
    final allSubs = ref.watch(allSubscriptionsStreamProvider).value ?? [];

    Account? linkedAccount;
    if (_selectedAccountId != null) {
      for (final a in accounts) {
        if (a.id == _selectedAccountId) {
          linkedAccount = a;
          break;
        }
      }
    }

    final duplicateSub = _checkDuplicate(allSubs);
    final preset = _renewalPreset();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit subscription' : 'New subscription',
          subtitle: 'A payment that renews on a schedule',
        ),
        Flexible(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: FfSheetBody.standardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Live preview (archetype B) ───────────────────────────
                  FfSubscriptionPreviewCard(
                    merchant: _merchantController.text,
                    amount: _currentAmount,
                    frequency: _frequency,
                    category: _selectedCategory,
                    accountName: linkedAccount?.name,
                    nextRenewalDate: _nextRenewalDate,
                    status:
                        widget.initialSubscription?.status ??
                        SubscriptionStatus.active,
                  ),
                  const SizedBox(height: FfSheetTokens.groupGap),

                  // ── Kind, with quick service names ───────────────────────
                  FfSheetGroup(
                    label: 'Service kind',
                    children: [
                      FfSubscriptionTypeTiles(
                        selectedType: _selectedType,
                        onChanged: (type) {
                          setState(() {
                            _selectedType = type;
                            _selectedCategory = type.defaultCategory;
                          });
                        },
                      ),
                      if (_selectedType != null &&
                          _selectedType!.popularMerchants.isNotEmpty)
                        FfSuggestionChips<String>(
                          items: [
                            for (final m in _selectedType!.popularMerchants)
                              FfSuggestionChipItem(value: m, label: m),
                          ],
                          selectedValue:
                              _selectedType!.popularMerchants
                                  .where(
                                    (m) =>
                                        m.toLowerCase() ==
                                        _merchantController.text
                                            .trim()
                                            .toLowerCase(),
                                  )
                                  .firstOrNull,
                          onSelected: (m) {
                            HapticFeedback.selectionClick();
                            setState(() => _merchantController.text = m);
                          },
                        ),
                    ],
                  ),

                  // ── Name and amount ──────────────────────────────────────
                  FfSheetGroup(
                    children: [
                      FfTextField(
                        controller: _merchantController,
                        label: 'Service name',
                        hint: 'e.g. Netflix, Spotify, iCloud, Airtel',
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter service name.';
                          }
                          return null;
                        },
                      ),
                      if (duplicateSub != null)
                        FfBanner(
                          tone: FfBannerTone.warning,
                          title: 'Already tracked',
                          message:
                              'You already track an active subscription for "${duplicateSub.merchant}".',
                        ),
                      FfAmountField(
                        controller: _amountController,
                        label: 'Amount each time',
                        size: FfAmountSize.md,
                        groupDigits: true,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter recurring amount.';
                          }
                          final parsed = FfAmountField.parse(val);
                          if (parsed == null || parsed <= 0) {
                            return 'Please enter a valid amount.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  // ── Billing ──────────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Billed',
                    children: [
                      FfSegmentedPill<SubscriptionFrequency>(
                        options: const [
                          FfSegmentOption(
                            value: SubscriptionFrequency.monthly,
                            label: 'Monthly',
                          ),
                          FfSegmentOption(
                            value: SubscriptionFrequency.yearly,
                            label: 'Yearly',
                          ),
                          FfSegmentOption(
                            value: SubscriptionFrequency.quarterly,
                            label: 'Quarterly',
                          ),
                          FfSegmentOption(
                            value: SubscriptionFrequency.weekly,
                            label: 'Weekly',
                          ),
                        ],
                        selectedValue: _frequency,
                        onSelected: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _frequency = val);
                        },
                      ),
                    ],
                  ),

                  // ── Next renewal ─────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Next renewal',
                    children: [
                      Wrap(
                        spacing: FfChipTokens.gap,
                        runSpacing: FfChipTokens.gap,
                        children: [
                          FfChip(
                            label: 'Today',
                            isSelected: preset == 'today',
                            onSelected: () => _setDatePreset(0),
                          ),
                          FfChip(
                            label: 'Tomorrow',
                            isSelected: preset == 'tomorrow',
                            onSelected: () => _setDatePreset(1),
                          ),
                          FfChip(
                            label: 'In a week',
                            isSelected: preset == 'week',
                            onSelected: () => _setDatePreset(7),
                          ),
                          FfChip(
                            label: 'Same date next month',
                            isSelected: preset == 'month',
                            onSelected: _setNextMonthPreset,
                          ),
                          FfChip(
                            leading: const Icon(
                              Icons.calendar_month_outlined,
                              size: FfIconSize.sm,
                            ),
                            label: DateFormatter.formatShortDate(
                              _nextRenewalDate,
                            ),
                            isSelected: preset == null,
                            onSelected: _pickDate,
                          ),
                        ],
                      ),
                      if (_currentAmount > 0)
                        FfConsequenceLine(
                          text: _buildConsequenceText(),
                          icon: Icons.autorenew_rounded,
                          tone: FfTone.primary,
                        ),
                    ],
                  ),

                  // ── More details ─────────────────────────────────────────
                  FfDisclosureRow(
                    subtitle: 'Paying account, reminder and a note',
                    initiallyExpanded: _showAdvanced,
                    onExpansionChanged: (v) => _showAdvanced = v,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (accounts.length > _maxAccountChips)
                            FfSelect<String?>(
                              value: _selectedAccountId,
                              label: 'Paid from',
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No linked account'),
                                ),
                                for (final acc in accounts)
                                  DropdownMenuItem(
                                    value: acc.id,
                                    child: Text(acc.name),
                                  ),
                              ],
                              onChanged:
                                  (v) => setState(() => _selectedAccountId = v),
                            )
                          else ...[
                            const FfFieldLabel('Paid from'),
                            const SizedBox(height: FfSheetTokens.labelGap),
                            Wrap(
                              spacing: FfChipTokens.gap,
                              runSpacing: FfChipTokens.gap,
                              children: [
                                FfChip(
                                  label: 'No linked account',
                                  isSelected: _selectedAccountId == null,
                                  onSelected:
                                      () => setState(
                                        () => _selectedAccountId = null,
                                      ),
                                ),
                                for (final acc in accounts)
                                  FfChip(
                                    label: acc.name,
                                    isSelected: _selectedAccountId == acc.id,
                                    onSelected:
                                        () => setState(
                                          () => _selectedAccountId = acc.id,
                                        ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FfFieldLabel('Remind me'),
                          const SizedBox(height: FfSheetTokens.labelGap),
                          Wrap(
                            spacing: FfChipTokens.gap,
                            runSpacing: FfChipTokens.gap,
                            children: [
                              for (final days in const [1, 3, 7])
                                FfChip(
                                  label:
                                      '$days ${days == 1 ? 'day' : 'days'} before',
                                  isSelected:
                                      _isReminderEnabled &&
                                      _reminderDays == days,
                                  onSelected:
                                      () => setState(() {
                                        _isReminderEnabled = true;
                                        _reminderDays = days;
                                      }),
                                ),
                              FfChip(
                                label: 'Off',
                                isSelected: !_isReminderEnabled,
                                onSelected:
                                    () => setState(
                                      () => _isReminderEnabled = false,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      FfTextField(
                        controller: _notesController,
                        label: 'Notes (optional)',
                        hint: 'Plan tier, family member, cancellation terms',
                      ),
                    ],
                  ),

                  // ── Delete (edit only, end of the body) ──────────────────
                  if (isEditing) ...[
                    const SizedBox(height: FfSheetTokens.groupGap),
                    FfGroupedContainer(
                      children: [
                        FfRow(
                          title: 'Delete subscription',
                          icon: Icons.delete_outline_rounded,
                          destructive: true,
                          onTap: _delete,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: _saveButtonLabel,
          isPrimaryLoading: _isSaving,
          onPrimaryPressed:
              _currentAmount > 0 && _merchantController.text.trim().isNotEmpty
                  ? _save
                  : null,
        ),
      ],
    );
  }
}
