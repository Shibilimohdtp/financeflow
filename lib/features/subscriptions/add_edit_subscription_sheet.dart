import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/ff_switch_row.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'subscriptions_controller.dart';

class AddEditSubscriptionSheet extends ConsumerStatefulWidget {
  final Subscription? initialSubscription;

  const AddEditSubscriptionSheet({super.key, this.initialSubscription});

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
  late int _reminderDays;
  late bool _isReminderEnabled;
  bool _isSaving = false;

  bool get isEditing => widget.initialSubscription != null;

  @override
  void initState() {
    super.initState();
    final init = widget.initialSubscription;
    _merchantController = TextEditingController(text: init?.merchant ?? '');
    _amountController = TextEditingController(
      text:
          init != null
              ? (init.amount.truncateToDouble() == init.amount
                  ? init.amount.toInt().toString()
                  : init.amount.toString())
              : '',
    );
    _notesController = TextEditingController(text: init?.notes ?? '');

    _frequency = init?.billingFrequency ?? SubscriptionFrequency.monthly;
    _nextRenewalDate =
        init?.nextRenewalDate ?? DateTime.now().add(const Duration(days: 30));
    _selectedAccountId = init?.accountId;
    _reminderDays = init?.reminderDaysBefore ?? 1;
    _isReminderEnabled = init?.isReminderEnabled ?? true;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextRenewalDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _nextRenewalDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      FfSnackbar.show(context, message: 'Please enter a valid amount.');
      return;
    }

    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      FfSnackbar.show(
        context,
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
          category: widget.initialSubscription?.category ?? 'Subscriptions',
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
          category: 'Subscriptions',
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
        FfSnackbar.show(
          context,
          message:
              isEditing
                  ? 'Subscription updated.'
                  : 'Subscription plan created.',
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save subscription: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: isEditing ? 'Edit Subscription' : 'New Subscription',
                subtitle: 'Track recurring renewals locally on device',
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Amount Hero Field ──────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceMd,
                            vertical: StillwaterTokens.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusLg,
                            ),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: StillwaterTokens.borderWidthHairline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RECURRING AMOUNT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: StillwaterTokens.spaceXs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹',
                                    style: StillwaterTypography.numLg(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceXs,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _amountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      style: StillwaterTypography.numHero(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: StillwaterTypography.numHero(
                                          color: theme.colorScheme.outline,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter amount.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceMd),

                        // ── 2. Service / Merchant Name ────────────────────
                        TextFormField(
                          controller: _merchantController,
                          decoration: const InputDecoration(
                            labelText: 'Service or Merchant',
                            hintText: 'e.g. Netflix, Spotify, iCloud, Gym',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter service name.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // ── 3. Billing Frequency Selector ─────────────────
                        Text(
                          'BILLING FREQUENCY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: StillwaterTokens.spaceXs),
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
                            setState(() => _frequency = val);
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // ── 4. Next Renewal Date ──────────────────────────
                        InkWell(
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(
                              StillwaterTokens.spaceMd,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusMd,
                              ),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: StillwaterTokens.borderWidthHairline,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Renewal Date',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormatter.formatShortDate(
                                        _nextRenewalDate,
                                      ),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // ── 5. Linked Payment Account ─────────────────────
                        if (accounts.isNotEmpty) ...[
                          Text(
                            'LINKED PAYMENT ACCOUNT (OPTIONAL)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.spaceXs),
                          DropdownButtonFormField<String?>(
                            value: _selectedAccountId,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceMd,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None / Not linked'),
                              ),
                              ...accounts.map((a) {
                                return DropdownMenuItem(
                                  value: a.id,
                                  child: Text('${a.name} (${a.currency})'),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedAccountId = val);
                            },
                          ),
                          const SizedBox(height: StillwaterTokens.spaceLg),
                        ],

                        // ── 6. Reminder Settings ──────────────────────────
                        FfSwitchRow(
                          title: 'Renewal Reminder',
                          subtitle: 'Notify before renewal charge happens',
                          value: _isReminderEnabled,
                          onChanged: (val) {
                            setState(() => _isReminderEnabled = val);
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceMd),

                        // ── 7. Optional Notes ─────────────────────────────
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Plan type, family tier, renewal terms',
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceMd),
                      ],
                    ),
                  ),
                ),
              ),
              FfSheetFooter(
                primaryLabel:
                    isEditing ? 'Save Changes' : 'Create Subscription',
                isPrimaryLoading: _isSaving,
                onPrimaryPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
