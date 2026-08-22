import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
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
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  DateTime _date = DateTime.now();
  Account? _selectedAccount;

  String? _amountError;
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

  Future<void> _submit() async {
    setState(() {
      _amountError = null;
    });

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter a contribution amount greater than zero.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

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
              'Added contribution of ${CurrencyFormatter.format(amount)} to "${widget.goal.name}".',
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save contribution: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Contribution', style: theme.textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                  children: [
                    Text(
                      'Contributing towards "${widget.goal.name}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // Amount
                    FfAmountField(
                      controller: _amountController,
                      errorText: _amountError,
                      autoFocus: true,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Date'),
                      subtitle: Text(DateFormat('dd MMMM yyyy').format(_date)),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _date = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // Optional Source Account
                    Text(
                      'Source Account (Optional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceMd,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusMd,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Account?>(
                          isExpanded: true,
                          value: _selectedAccount,
                          items: [
                            const DropdownMenuItem<Account?>(
                              value: null,
                              child: Text('Unlinked / Cash'),
                            ),
                            ...accounts.map((acc) {
                              return DropdownMenuItem<Account?>(
                                value: acc,
                                child: Text(acc.name),
                              );
                            }),
                          ],
                          onChanged: (acc) {
                            setState(() {
                              _selectedAccount = acc;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText: 'e.g. Monthly salary transfer, bonus',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // Submit Button
                    FfButton(
                      label: 'Save Contribution',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
