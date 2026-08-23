import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'savings_goals_controller.dart';

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
    final picked = await showDatePicker(
      context: context,
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
      FfSnackbar.show(context, message: 'Please enter a valid deposit amount.');
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
        FfSnackbar.show(
          context,
          message:
              'Added deposit of ${CurrencyFormatter.formatINR(amount)} to "${widget.goal.name}".',
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save contribution: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accountsAsync = ref.watch(allAccountsStreamProvider);

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
                title: 'Add Funds',
                subtitle: 'Contributing to "${widget.goal.name}"',
              ),
              const Divider(height: 1, thickness: 1),

              // Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Deposit Amount
                        _SectionLabel(label: 'Deposit Amount (₹)'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        TextFormField(
                          controller: _amountController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: '5000',
                            prefixText: '₹ ',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter amount';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Date
                        _SectionLabel(label: 'Deposit Date'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceMd,
                                vertical: StillwaterTokens.spaceSm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusMd,
                                ),
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                            ),
                            child: Text(
                              DateFormat('dd MMMM yyyy').format(_date),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Source Account
                        _SectionLabel(label: 'Source Account (Optional)'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        accountsAsync.when(
                          data: (accounts) {
                            final activeAccounts =
                                accounts.where((a) => !a.isArchived).toList();
                            return DropdownButtonFormField<Account>(
                              value: _selectedAccount,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: StillwaterTokens.spaceMd,
                                  vertical: StillwaterTokens.spaceSm,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusMd,
                                  ),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Direct / Cash Deposit'),
                                ),
                                ...activeAccounts.map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a.name),
                                  ),
                                ),
                              ],
                              onChanged:
                                  (val) =>
                                      setState(() => _selectedAccount = val),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Notes
                        _SectionLabel(label: 'Notes (Optional)'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Monthly salary savings transfer',
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceMd),
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
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
