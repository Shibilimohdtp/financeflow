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
import '../../shared/widgets/ff_amount_hero.dart';
import '../../shared/widgets/ff_chip.dart';
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
      _amountController.text = FfAmountField.formatInput(amount);
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

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final isToday = DateUtils.isSameDay(_date, DateTime.now());
    final isYesterday = DateUtils.isSameDay(_date, yesterday);
    final remaining = widget.goal.targetAmount - currentSaved;

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: 'Add money',
          subtitle: 'Towards ${widget.goal.name}',
        ),
        Flexible(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: FfSheetBody.standardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Amount first (archetype A) ───────────────────────────
                  FfSheetGroup(
                    children: [
                      FfAmountHero(
                        controller: _amountController,
                        tone: FfTone.savings,
                        label: 'Amount',
                        autofocus: true,
                        groupDigits: true,
                        consequenceIcon: Icons.trending_up_rounded,
                        consequence:
                            depositAmount > 0
                                ? 'Reaches ${projectedPct.toStringAsFixed(0)}% of the target (+${(projectedPct - currentPct).toStringAsFixed(0)}%)'
                                : 'At ${currentPct.toStringAsFixed(0)}% of ${CurrencyFormatter.formatAmount(widget.goal.targetAmount)}',
                      ),
                      Wrap(
                        spacing: FfChipTokens.gap,
                        runSpacing: FfChipTokens.gap,
                        children: [
                          for (final step in const [1000.0, 5000.0, 10000.0])
                            FfChip(
                              label:
                                  '+ ${CurrencyFormatter.formatAmount(step)}',
                              isSelected: false,
                              onSelected:
                                  () => _setAmount(depositAmount + step),
                            ),
                          if (remaining > 0)
                            FfChip(
                              label:
                                  'What is left (${CurrencyFormatter.formatAmount(remaining)})',
                              isSelected: false,
                              onSelected: () => _setAmount(remaining),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // ── Date ─────────────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Date',
                    children: [
                      Wrap(
                        spacing: FfChipTokens.gap,
                        runSpacing: FfChipTokens.gap,
                        children: [
                          FfChip(
                            label: 'Today',
                            isSelected: isToday,
                            onSelected:
                                () => setState(() => _date = DateTime.now()),
                          ),
                          FfChip(
                            label: 'Yesterday',
                            isSelected: isYesterday,
                            onSelected: () => setState(() => _date = yesterday),
                          ),
                          FfChip(
                            label: DateFormatter.formatShortDate(_date),
                            leading: const Icon(
                              Icons.calendar_today_outlined,
                              size: FfIconSize.sm,
                            ),
                            isSelected: !isToday && !isYesterday,
                            onSelected: _selectDate,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ── From and note ────────────────────────────────────────
                  FfSheetGroup(
                    last: true,
                    children: [
                      accountsAsync.when(
                        data: (accounts) {
                          final activeAccounts =
                              accounts.where((a) => !a.isArchived).toList();
                          return FfSelect<Account>(
                            value: _selectedAccount,
                            label: 'From account (optional)',
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Direct / Cash deposit'),
                              ),
                              ...activeAccounts.map(
                                (a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(a.name),
                                ),
                              ),
                            ],
                            onChanged:
                                (val) => setState(() => _selectedAccount = val),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      FfTextField(
                        controller: _notesController,
                        label: 'Notes (optional)',
                        hint: 'e.g. Monthly salary transfer',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: 'Add money',
          isPrimaryLoading: _isSubmitting,
          onPrimaryPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}
