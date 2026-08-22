import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/savings_goal.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import 'savings_goals_controller.dart';

class AddEditSavingsGoalSheet extends ConsumerStatefulWidget {
  final SavingsGoal? initialGoal;

  const AddEditSavingsGoalSheet({super.key, this.initialGoal});

  @override
  ConsumerState<AddEditSavingsGoalSheet> createState() =>
      _AddEditSavingsGoalSheetState();
}

class _AddEditSavingsGoalSheetState
    extends ConsumerState<AddEditSavingsGoalSheet> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  DateTime _targetDate = DateTime.now().add(
    const Duration(days: 180),
  ); // default 6 months
  Account? _selectedAccount;

  String? _nameError;
  String? _amountError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGoal;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text:
          initial != null
              ? initial.targetAmount.toStringAsFixed(
                initial.targetAmount.truncateToDouble() == initial.targetAmount
                    ? 0
                    : 2,
              )
              : '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _targetDate =
        initial?.targetDate ?? DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = null;
      _amountError = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Goal name is required.';
      });
      return;
    }

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Please enter a target amount greater than zero.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: widget.initialGoal?.id ?? const Uuid().v4(),
        name: name,
        targetAmount: amount,
        targetDate: _targetDate,
        linkedAccountId: _selectedAccount?.id,
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        isCompleted: widget.initialGoal?.isCompleted ?? false,
        createdAt: widget.initialGoal?.createdAt ?? now,
        updatedAt: now,
      );

      await ref.read(savingsGoalsControllerProvider.notifier).saveGoal(goal);

      if (mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(
          context,
          message:
              widget.initialGoal != null
                  ? 'Goal updated on this device.'
                  : 'Goal created on this device.',
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        FfSnackbar.show(context, message: 'Could not save goal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    if (_selectedAccount == null &&
        widget.initialGoal?.linkedAccountId != null) {
      _selectedAccount =
          accounts
              .where((a) => a.id == widget.initialGoal!.linkedAccountId)
              .firstOrNull;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                    Text(
                      widget.initialGoal != null
                          ? 'Edit Savings Goal'
                          : 'New Savings Goal',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form fields
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                  children: [
                    // Target Amount Field
                    FfAmountField(
                      controller: _amountController,
                      errorText: _amountError,
                      autoFocus: widget.initialGoal == null,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Goal Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Goal Name *',
                        hintText: 'e.g. Emergency Fund, New Laptop, Vacation',
                        errorText: _nameError,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // Target Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Target Date'),
                      subtitle: Text(
                        DateFormat('dd MMMM yyyy').format(_targetDate),
                      ),
                      trailing: const Icon(Icons.edit_calendar_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2040),
                        );
                        if (picked != null) {
                          setState(() {
                            _targetDate = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    // Optional Linked Account
                    Text(
                      'Linked Account (Optional)',
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
                              child: Text('None (General Goal)'),
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

                    // Notes Field
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add details or motivation for this goal',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // Save Button
                    FfButton(
                      label:
                          widget.initialGoal != null
                              ? 'Save Changes'
                              : 'Create Goal',
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
