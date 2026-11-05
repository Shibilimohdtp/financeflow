import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_typography.dart';
import 'subscriptions_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../theme/ff.dart';

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        CurrencyFormatter.parse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid amount.',
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
        FfToast.show(
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
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not save subscription: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Subscription' : 'New Subscription',
          subtitle: 'Track recurring renewals locally on device',
        ),
        const FfDivider(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.md,
              FfSpace.lg,
              FfSpace.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Amount Hero Field ──────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.md,
                      vertical: FfSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: context.ff.color.surfaceCard,
                      borderRadius: BorderRadius.circular(FfRadius.lg),
                      border: Border.all(
                        color: context.ff.color.borderSubtle,
                        width: FfBorderWidth.hairline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECURRING AMOUNT',
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.secondary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: FfSpace.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              CurrencyFormatter.currencySymbol,
                              style: StillwaterTypography.numLg(
                                color: context.ff.color.actionPrimary,
                              ),
                            ),
                            const SizedBox(width: FfSpace.xs),
                            Expanded(
                              child: FfAmountField.bare(
                                controller: _amountController,
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

                  const SizedBox(height: FfSpace.md),

                  // ── 2. Service / Merchant Name ────────────────────
                  FfTextField(
                    controller: _merchantController,
                    label: 'Service or Merchant',
                    hint: 'e.g. Netflix, Spotify, iCloud, Gym',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter service name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 3. Billing Frequency Selector ─────────────────
                  Text(
                    'BILLING FREQUENCY',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.secondary,
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
                      setState(() => _frequency = val);
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 4. Next Renewal Date ──────────────────────────
                  InkWell(
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(FfSpace.md),
                      decoration: BoxDecoration(
                        color: context.ff.color.surfaceCard,
                        borderRadius: BorderRadius.circular(FfRadius.md),
                        border: Border.all(
                          color: context.ff.color.borderSubtle,
                          width: FfBorderWidth.hairline,
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
                                style: context.ff.text.bodySm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Text(
                                DateFormatter.formatShortDate(_nextRenewalDate),
                                style: context.ff.text.titleSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: context.ff.color.actionPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── 5. Linked Payment Account ─────────────────────
                  if (accounts.isNotEmpty) ...[
                    Text(
                      'LINKED PAYMENT ACCOUNT (OPTIONAL)',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    FfSelect<String?>(
                      value: _selectedAccountId,
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
                    const SizedBox(height: FfSpace.lg),
                  ],

                  // ── 6. Reminder Settings ──────────────────────────
                  FfRow.toggle(
                    title: 'Renewal Reminder',
                    subtitle: 'Notify before renewal charge happens',
                    value: _isReminderEnabled,
                    onChanged: (val) {
                      setState(() => _isReminderEnabled = val);
                    },
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── 7. Optional Notes ─────────────────────────────
                  FfTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    hint: 'Plan type, family tier, renewal terms',
                  ),

                  const SizedBox(height: FfSpace.md),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: isEditing ? 'Save Changes' : 'Create Subscription',
          isPrimaryLoading: _isSaving,
          onPrimaryPressed: _save,
        ),
      ],
    );
  }
}
