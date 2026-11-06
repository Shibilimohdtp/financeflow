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
import '../../shared/widgets/ff_banner.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
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

/// The Stillwater Bloom Add / Edit Subscription sheet (Pattern E).
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
              ? (init.amount.truncateToDouble() == init.amount
                  ? init.amount.toInt().toString()
                  : init.amount.toString())
              : sug != null
              ? (sug.suggestedAmount.truncateToDouble() == sug.suggestedAmount
                  ? sug.suggestedAmount.toInt().toString()
                  : sug.suggestedAmount.toString())
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
      title: 'Delete Subscription?',
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
    return isEditing ? 'Save Changes' : 'Create Subscription';
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
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

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Subscription' : 'New Subscription',
          subtitle:
              isEditing
                  ? 'Update renewal cadence, account, or reminder'
                  : 'Track recurring renewals locally on device',
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.sm,
              FfSpace.lg,
              MediaQuery.of(context).viewInsets.bottom + FfSpace.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Live Preview Card ──────────────────────────
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

                  const SizedBox(height: FfSpace.md),

                  // ── 2. Generic Category Type Tiles ────────────────
                  Text(
                    'SERVICE KIND',
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfSubscriptionTypeTiles(
                    selectedType: _selectedType,
                    onChanged: (type) {
                      setState(() {
                        _selectedType = type;
                        _selectedCategory = type.defaultCategory;
                      });
                    },
                  ),

                  // Popular suggestions chips if selected type has them
                  if (_selectedType != null &&
                      _selectedType!.popularMerchants.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.xs),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _selectedType!.popularMerchants.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(width: FfSpace.x2s),
                        itemBuilder: (context, i) {
                          final merchantHint =
                              _selectedType!.popularMerchants[i];
                          final isCurrent =
                              _merchantController.text.trim().toLowerCase() ==
                              merchantHint.toLowerCase();
                          return FfChip(
                            label: merchantHint,
                            isSelected: isCurrent,
                            onSelected: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _merchantController.text = merchantHint;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: FfSpace.md),

                  // ── 3. Merchant / Service Name ────────────────────
                  FfTextField(
                    controller: _merchantController,
                    label: 'Service or Merchant Name',
                    hint: 'e.g. Netflix, Spotify, iCloud, Cult Fit, Airtel',
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter service name.';
                      }
                      return null;
                    },
                  ),

                  // Soft Duplicate Warning
                  if (duplicateSub != null) ...[
                    const SizedBox(height: FfSpace.xs),
                    FfBanner(
                      tone: FfBannerTone.warning,
                      title: 'Duplicate Plan Detected',
                      message:
                          'You already track an active subscription for "${duplicateSub.merchant}".',
                    ),
                  ],

                  const SizedBox(height: FfSpace.md),

                  // ── 4. Amount Hero Field ──────────────────────────
                  FfAmountField(
                    controller: _amountController,
                    label: 'Recurring Amount',
                    hint: '0',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter recurring amount.';
                      }
                      final parsed = CurrencyFormatter.parse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Please enter a valid amount.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 5. Cadence / Frequency Selector ───────────────
                  Text(
                    'BILLING CADENCE',
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
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

                  const SizedBox(height: FfSpace.md),

                  // ── 6. Renewal Date by Intention ──────────────────
                  Text(
                    'NEXT RENEWAL DATE',
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Wrap(
                    spacing: FfSpace.x2s,
                    runSpacing: FfSpace.x2s,
                    children: [
                      FfChip(
                        label: 'Today',
                        isSelected:
                            _nextRenewalDate
                                    .difference(DateTime.now())
                                    .inDays ==
                                0 &&
                            _nextRenewalDate.day == DateTime.now().day,
                        onSelected: () => _setDatePreset(0),
                      ),
                      FfChip(
                        label: 'Tomorrow',
                        isSelected:
                            _nextRenewalDate
                                    .difference(DateTime.now())
                                    .inDays ==
                                1 &&
                            _nextRenewalDate.day ==
                                DateTime.now().add(const Duration(days: 1)).day,
                        onSelected: () => _setDatePreset(1),
                      ),
                      FfChip(
                        label: 'In a week',
                        isSelected:
                            _nextRenewalDate
                                .difference(DateTime.now())
                                .inDays ==
                            7,
                        onSelected: () => _setDatePreset(7),
                      ),
                      FfChip(
                        label: 'Same date next month',
                        isSelected:
                            _nextRenewalDate.month ==
                            (DateTime.now().month % 12) + 1,
                        onSelected: _setNextMonthPreset,
                      ),
                      FfChip(
                        leading: const Icon(
                          Icons.calendar_month_outlined,
                          size: 14,
                        ),
                        label: DateFormatter.formatShortDate(_nextRenewalDate),
                        isSelected: false,
                        onSelected: _pickDate,
                      ),
                    ],
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 7. Dynamic Consequence Line ───────────────────
                  if (_currentAmount > 0) ...[
                    FfConsequenceLine(
                      text: _buildConsequenceText(),
                      icon: Icons.autorenew_rounded,
                      tone: FfTone.primary,
                    ),
                    const SizedBox(height: FfSpace.md),
                  ],

                  // ── 8. Progressive Disclosure Expander ────────────
                  InkWell(
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    onTap: () {
                      setState(() => _showAdvanced = !_showAdvanced);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvanced
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 20,
                            color: ff.color.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Expanded(
                            child: Text(
                              _showAdvanced
                                  ? 'Fewer options'
                                  : 'More options (Account, Reminder, Notes)',
                              style: ff.text.titleSm.copyWith(
                                color: ff.color.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAdvanced) ...[
                    const SizedBox(height: FfSpace.sm),

                    // Linked Payment Account
                    Text(
                      'PAYMENT ACCOUNT',
                      style: ff.text.labelSm.copyWith(
                        color: ff.color.textSecondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Wrap(
                      spacing: FfSpace.x2s,
                      runSpacing: FfSpace.x2s,
                      children: [
                        FfChip(
                          label: 'No linked account',
                          isSelected: _selectedAccountId == null,
                          onSelected: () {
                            setState(() => _selectedAccountId = null);
                          },
                        ),
                        for (final acc in accounts)
                          FfChip(
                            label: acc.name,
                            isSelected: _selectedAccountId == acc.id,
                            onSelected: () {
                              setState(() => _selectedAccountId = acc.id);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Renewal Reminder Setting
                    Text(
                      'RENEWAL REMINDER',
                      style: ff.text.labelSm.copyWith(
                        color: ff.color.textSecondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Wrap(
                      spacing: FfSpace.x2s,
                      runSpacing: FfSpace.x2s,
                      children: [
                        FfChip(
                          label: '1 day before',
                          isSelected: _isReminderEnabled && _reminderDays == 1,
                          onSelected: () {
                            setState(() {
                              _isReminderEnabled = true;
                              _reminderDays = 1;
                            });
                          },
                        ),
                        FfChip(
                          label: '3 days before',
                          isSelected: _isReminderEnabled && _reminderDays == 3,
                          onSelected: () {
                            setState(() {
                              _isReminderEnabled = true;
                              _reminderDays = 3;
                            });
                          },
                        ),
                        FfChip(
                          label: '7 days before',
                          isSelected: _isReminderEnabled && _reminderDays == 7,
                          onSelected: () {
                            setState(() {
                              _isReminderEnabled = true;
                              _reminderDays = 7;
                            });
                          },
                        ),
                        FfChip(
                          label: 'Disabled',
                          isSelected: !_isReminderEnabled,
                          onSelected: () {
                            setState(() => _isReminderEnabled = false);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: FfSpace.md),

                    // Notes
                    FfTextField(
                      controller: _notesController,
                      label: 'Notes (Optional)',
                      hint: 'Plan tier, family member, cancellation terms',
                    ),
                  ],

                  if (isEditing) ...[
                    const SizedBox(height: FfSpace.xl),
                    FfButton(
                      label: 'Delete Subscription',
                      variant: FfButtonVariant.destructive,
                      leadingIcon: const Icon(Icons.delete_outline_rounded),
                      onPressed: _delete,
                    ),
                  ],

                  const SizedBox(height: FfSpace.sm),
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
