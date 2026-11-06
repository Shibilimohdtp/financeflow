import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_pickers.dart';
import '../../shared/widgets/ff_select.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
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
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _amountController.text =
          amount.truncateToDouble() == amount
              ? amount.toInt().toString()
              : amount.toString();
    });
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
    final depositAmount =
        CurrencyFormatter.parse(_amountController.text) ?? 0.0;

    // Watch live goal contributions to show projected %
    final contributionsAsync = ref.watch(
      goalContributionsForGoalProvider(widget.goal.id),
    );
    final currentSaved =
        contributionsAsync.value?.fold<double>(0.0, (s, c) => s + c.amount) ??
        0.0;
    final newTotal = currentSaved + depositAmount;
    final currentPct =
        widget.goal.targetAmount > 0
            ? (currentSaved / widget.goal.targetAmount * 100).clamp(0, 100)
            : 100.0;
    final projectedPct =
        widget.goal.targetAmount > 0
            ? (newTotal / widget.goal.targetAmount * 100).clamp(0, 100)
            : 100.0;

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
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: FfSpace.sm),

                  // ── Consequence / Projection Line ────────────────────────
                  FfConsequenceLine(
                    text:
                        depositAmount > 0
                            ? 'Reaches ${projectedPct.toStringAsFixed(0)}% of target (+${(projectedPct - currentPct).toStringAsFixed(0)}%)'
                            : 'Currently at ${currentPct.toStringAsFixed(0)}% of ${CurrencyFormatter.formatAmount(widget.goal.targetAmount)}',
                    icon: Icons.trending_up_rounded,
                    tone: FfTone.savings,
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Deposit Amount ────────────────────────────────────────
                  Text(
                    'Deposit amount',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfAmountField(
                    controller: _amountController,
                    hint: '5,000',
                    autofocus: true,
                  ),

                  const SizedBox(height: FfSpace.sm),

                  // ── Quick Amount Presets ──────────────────────────────────
                  Wrap(
                    spacing: FfSpace.xs,
                    runSpacing: FfSpace.xs,
                    children: [
                      FfChip(
                        label: '+₹1,000',
                        isSelected: false,
                        onSelected: () => _setAmount(depositAmount + 1000),
                      ),
                      FfChip(
                        label: '+₹5,000',
                        isSelected: false,
                        onSelected: () => _setAmount(depositAmount + 5000),
                      ),
                      FfChip(
                        label: '+₹10,000',
                        isSelected: false,
                        onSelected: () => _setAmount(depositAmount + 10000),
                      ),
                      if (widget.goal.targetAmount > currentSaved)
                        FfChip(
                          label:
                              'Remaining (${CurrencyFormatter.formatAmount(widget.goal.targetAmount - currentSaved)})',
                          isSelected: false,
                          onSelected:
                              () => _setAmount(
                                widget.goal.targetAmount - currentSaved,
                              ),
                        ),
                    ],
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Date ──────────────────────────────────────────────────
                  Text(
                    'Deposit date',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  Wrap(
                    spacing: FfSpace.xs,
                    runSpacing: FfSpace.xs,
                    children: [
                      FfChip(
                        label: 'Today',
                        isSelected: DateUtils.isSameDay(_date, DateTime.now()),
                        onSelected:
                            () => setState(() => _date = DateTime.now()),
                      ),
                      FfChip(
                        label: 'Yesterday',
                        isSelected: DateUtils.isSameDay(
                          _date,
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                        onSelected:
                            () => setState(
                              () =>
                                  _date = DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                            ),
                      ),
                      FfChip(
                        label: DateFormatter.formatShortDate(_date),
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                        ),
                        isSelected:
                            !DateUtils.isSameDay(_date, DateTime.now()) &&
                            !DateUtils.isSameDay(
                              _date,
                              DateTime.now().subtract(const Duration(days: 1)),
                            ),
                        onSelected: _selectDate,
                      ),
                    ],
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Source Account ────────────────────────────────────────
                  Text(
                    'Source account (optional)',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                            child: Text('Direct / Cash deposit'),
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

                  // ── Notes ─────────────────────────────────────────────────
                  FfTextField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    hint: 'e.g. Monthly salary savings transfer',
                  ),

                  const SizedBox(height: FfSpace.xl),
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
