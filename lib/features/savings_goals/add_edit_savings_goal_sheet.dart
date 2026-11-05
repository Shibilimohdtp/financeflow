import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/account.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import 'savings_goals_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_pickers.dart';

class AddEditSavingsGoalSheet extends ConsumerStatefulWidget {
  final SavingsGoal? initialGoal;

  const AddEditSavingsGoalSheet({super.key, this.initialGoal});

  @override
  ConsumerState<AddEditSavingsGoalSheet> createState() =>
      _AddEditSavingsGoalSheetState();
}

class _AddEditSavingsGoalSheetState
    extends ConsumerState<AddEditSavingsGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late DateTime _targetDate;
  Account? _selectedAccount;
  bool _showAdvanced = false;
  bool _isSubmitting = false;

  bool get isEditing => widget.initialGoal != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGoal;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text:
          initial != null
              ? (initial.targetAmount.truncateToDouble() == initial.targetAmount
                  ? initial.targetAmount.toInt().toString()
                  : initial.targetAmount.toString())
              : '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _targetDate =
        initial?.targetDate ?? DateTime.now().add(const Duration(days: 180));
    _showAdvanced =
        initial != null &&
        ((initial.notes?.isNotEmpty ?? false) ||
            initial.linkedAccountId != null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final picked = await pickFfDate(
      context,
      initialDate: _targetDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      FfToast.show(
        context,
        tone: FfToastTone.warning,
        message: 'Please enter a valid target amount.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final goal = SavingsGoal(
        id: widget.initialGoal?.id ?? const Uuid().v4(),
        name: name,
        targetAmount: amount,
        targetDate: _targetDate,
        linkedAccountId:
            _selectedAccount?.id ?? widget.initialGoal?.linkedAccountId,
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
        FfToast.show(
          context,
          message:
              isEditing
                  ? 'Savings goal updated.'
                  : 'Savings goal created on-device.',
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        FfToast.show(
          context,
          tone: FfToastTone.error,
          message: 'Could not save goal: $e',
        );
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
                title: isEditing ? 'Edit Savings Goal' : 'Create Savings Goal',
                subtitle: 'Track savings progress on-device',
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
                        // Goal Name
                        _SectionLabel(label: 'Goal Name'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Emergency Fund, Japan Trip, Vehicle',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter goal name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Target Amount
                        _SectionLabel(label: 'Target Amount'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '100000',
                            prefixText: '${CurrencyFormatter.currencySymbol} ',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter target amount';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Target Date
                        _SectionLabel(label: 'Target Date'),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        InkWell(
                          onTap: _selectTargetDate,
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
                              DateFormat('dd MMMM yyyy').format(_targetDate),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceLg),

                        // Optional Details toggle
                        InkWell(
                          onTap:
                              () => setState(
                                () => _showAdvanced = !_showAdvanced,
                              ),
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusMd,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: StillwaterTokens.spaceXs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _showAdvanced
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: StillwaterTokens.spaceXs),
                                Text(
                                  _showAdvanced
                                      ? 'Hide optional fields'
                                      : 'Dedicated Account & Notes (Optional)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showAdvanced) ...[
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          // Dedicated Target Account
                          accountsAsync.when(
                            data: (accounts) {
                              final activeAccounts =
                                  accounts.where((a) => !a.isArchived).toList();
                              return DropdownButtonFormField<Account>(
                                value: _selectedAccount,
                                decoration: InputDecoration(
                                  labelText: 'Dedicated Savings Account',
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
                                    child: Text('No dedicated account'),
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

                          const SizedBox(height: StillwaterTokens.spaceMd),

                          // Notes
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText: 'e.g. Set aside 10% bonus each quarter',
                            ),
                          ),
                        ],
                        const SizedBox(height: StillwaterTokens.spaceMd),
                      ],
                    ),
                  ),
                ),
              ),
              FfSheetFooter(
                secondaryLabel: 'Cancel',
                primaryLabel: isEditing ? 'Save Changes' : 'Create Goal',
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
