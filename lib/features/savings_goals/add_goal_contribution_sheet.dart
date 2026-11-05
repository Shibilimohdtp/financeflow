import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import 'savings_goals_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_select.dart';
import '../../theme/ff.dart';

class AddGoalContributionSheet extends ConsumerStatefulWidget {
  final SavingsGoal goal;

  const AddGoalContributionSheet({super.key, required this.goal});

  @override
  ConsumerState<AddGoalContributionSheet> createState() =>
      _AddGoalContributionSheetState();
}

class _AddGoalContributionSheetState
    extends ConsumerState<AddGoalContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  DateTime _date = DateTime.now();
  Account? _selectedAccount;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid deposit amount.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final contribution = GoalContribution(
        id: const Uuid().v4(),
        goalId: widget.goal.id,
        amount: amount,
        date: _date,
        accountId: _selectedAccount?.id,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        createdAt: DateTime.now(),
      );

      await ref
          .read(savingsGoalsControllerProvider.notifier)
          .addContribution(contribution);

      if (mounted) {
        Navigator.of(context).pop();
        FfToast.show(
          context,
          message:
              'Added deposit of ${CurrencyFormatter.formatAmount(amount)} to "${widget.goal.name}".',
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not save contribution: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsStreamProvider);

    return FfSheet(
      children: [
        FfSheetHeader(
          title: 'Add Funds',
          subtitle: 'Contributing to "${widget.goal.name}"',
        ),
        const FfDivider(),

        // Form Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deposit Amount
                  _SectionLabel(label: 'Deposit Amount'),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _amountController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    hint: '5000',
                    prefixText: '${CurrencyFormatter.currencySymbol} ',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Date
                  _SectionLabel(label: 'Deposit Date'),
                  const SizedBox(height: FfSpace.xs),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.md,
                          vertical: FfSpace.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(FfRadius.md),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                      ),
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(_date),
                        style: context.ff.text.body,
                      ),
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Source Account
                  _SectionLabel(label: 'Source Account (Optional)'),
                  const SizedBox(height: FfSpace.xs),
                  accountsAsync.when(
                    data: (accounts) {
                      final activeAccounts =
                          accounts.where((a) => !a.isArchived).toList();
                      return FfSelect<Account>(
                        value: _selectedAccount,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Direct / Cash Deposit'),
                          ),
                          ...activeAccounts.map(
                            (a) =>
                                DropdownMenuItem(value: a, child: Text(a.name)),
                          ),
                        ],
                        onChanged:
                            (val) => setState(() => _selectedAccount = val),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // Notes
                  _SectionLabel(label: 'Notes (Optional)'),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _notesController,
                    hint: 'e.g. Monthly salary savings transfer',
                  ),

                  const SizedBox(height: FfSpace.md),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          secondaryLabel: 'Cancel',
          primaryLabel: 'Confirm Deposit',
          isPrimaryLoading: _isSubmitting,
          onPrimaryPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
