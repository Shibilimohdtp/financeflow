import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
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

  @override
  void initState() {
    super.initState();
    final init = widget.initialSubscription;
    _merchantController = TextEditingController(text: init?.merchant ?? '');
    _amountController = TextEditingController(
      text: init != null ? init.amount.toStringAsFixed(2) : '',
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

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
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

    final controller = ref.read(subscriptionsControllerProvider.notifier);

    if (widget.initialSubscription != null) {
      final updated = widget.initialSubscription!.copyWith(
        merchant: merchant,
        amount: amount,
        billingFrequency: _frequency,
        nextRenewalDate: _nextRenewalDate,
        accountId: _selectedAccountId,
        reminderDaysBefore: _reminderDays,
        isReminderEnabled: _isReminderEnabled,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
      await controller.updateSubscription(updated);
    } else {
      await controller.addSubscription(
        merchant: merchant,
        amount: amount,
        billingFrequency: _frequency,
        nextRenewalDate: _nextRenewalDate,
        accountId: _selectedAccountId,
        reminderDaysBefore: _reminderDays,
        isReminderEnabled: _isReminderEnabled,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      FfSnackbar.show(
        context,
        message:
            widget.initialSubscription != null
                ? 'Subscription updated.'
                : 'Subscription added.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(allAccountsStreamProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: StillwaterTokens.spaceLg,
        right: StillwaterTokens.spaceLg,
        top: StillwaterTokens.spaceLg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialSubscription != null
                        ? 'Edit Subscription'
                        : 'Add Subscription',
                    style: theme.textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),

              // Service / Merchant Name
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Service / Merchant Name',
                  hintText: 'e.g. Netflix, Spotify, iCloud',
                  prefixIcon: Icon(Icons.subscriptions_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Amount Field
              FfAmountField(
                controller: _amountController,
                labelText: 'Amount (₹)',
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Billing Frequency Dropdown
              DropdownButtonFormField<SubscriptionFrequency>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Billing Frequency',
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items:
                    SubscriptionFrequency.values.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f.displayName),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _frequency = val);
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // Next Renewal Date Picker Tile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.event_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Next Renewal Date'),
                subtitle: Text(DateFormatter.formatFullDate(_nextRenewalDate)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _selectDate,
              ),

              const Divider(),

              // Account Selector
              DropdownButtonFormField<String?>(
                value: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Payment Account (Optional)',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None / Any Account'),
                  ),
                  ...accounts.map(
                    (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              // Reminder Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Renewal Reminder'),
                subtitle: Text(
                  _isReminderEnabled
                      ? 'Remind $_reminderDays day(s) before renewal'
                      : 'Disabled',
                ),
                value: _isReminderEnabled,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => setState(() => _isReminderEnabled = val),
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g. Shared family plan',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: StillwaterTokens.spaceXl),

              // Save Button
              FfButton(
                label:
                    widget.initialSubscription != null
                        ? 'Save Changes'
                        : 'Add Subscription',
                onPressed: _save,
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
