import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_icon_tile.dart';
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
import 'savings_goals_screen.dart';

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

  static const List<({String name, double amount, int months, IconData icon})>
  _templates = [
    (
      name: 'Emergency Fund',
      amount: 100000,
      months: 6,
      icon: Icons.shield_outlined,
    ),
    (
      name: 'Trip / Vacation',
      amount: 50000,
      months: 3,
      icon: Icons.flight_takeoff_rounded,
    ),
    (
      name: 'Gadget / Tech',
      amount: 80000,
      months: 6,
      icon: Icons.laptop_mac_rounded,
    ),
    (
      name: 'Vehicle',
      amount: 200000,
      months: 12,
      icon: Icons.directions_car_filled_outlined,
    ),
    (
      name: 'Home / Living',
      amount: 500000,
      months: 24,
      icon: Icons.home_outlined,
    ),
    (
      name: 'Education',
      amount: 300000,
      months: 12,
      icon: Icons.school_outlined,
    ),
  ];

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

    _amountController.addListener(_onFormChange);
    _nameController.addListener(_onFormChange);
  }

  void _onFormChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFormChange);
    _nameController.removeListener(_onFormChange);
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyTemplate(
    ({String name, double amount, int months, IconData icon}) template,
  ) {
    HapticFeedback.selectionClick();
    setState(() {
      _nameController.text = template.name;
      _amountController.text = template.amount.toInt().toString();
      _targetDate = DateTime.now().add(Duration(days: template.months * 30));
    });
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

  void _setDatePreset(int months) {
    HapticFeedback.selectionClick();
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: months * 30));
    });
  }

  String _computeConsequence() {
    final amount = CurrencyFormatter.parse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      return 'Enter a target amount to preview required monthly savings.';
    }
    final days = math.max(1, _targetDate.difference(DateTime.now()).inDays);
    final months = math.max(1.0, days / 30.4375);
    final monthly = amount / months;

    return '${CurrencyFormatter.formatAmount(monthly)} a month gets you there by ${DateFormatter.formatShortDate(_targetDate)}.';
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
    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final currentAmount =
        CurrencyFormatter.parse(_amountController.text) ?? 0.0;
    final currentName =
        _nameController.text.trim().isEmpty
            ? 'New Goal'
            : _nameController.text.trim();
    final icon = SavingsGoalsScreen.getGoalIcon(currentName);

    return FfSheet(
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit Savings Goal' : 'Create Savings Goal',
          subtitle: 'Targeted on-device savings',
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

                  // ── Mini Live Preview Card ───────────────────────────────
                  FfCard(
                    variant: FfCardVariant.tinted,
                    tone: FfTone.savings,
                    child: Row(
                      children: [
                        FfIconTile(icon: icon, tone: FfTone.savings),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentName,
                                style: context.ff.text.titleSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Due ${DateFormatter.formatShortDate(_targetDate)}',
                                style: context.ff.text.bodySm,
                              ),
                            ],
                          ),
                        ),
                        FfAmountText(
                          amount: currentAmount,
                          size: FfAmountSize.md,
                          style: FfAmountStyle.split,
                          tone: FfTone.neutral,
                          showSign: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Quick Templates ───────────────────────────────────────
                  if (!isEditing) ...[
                    Text(
                      'Templates',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _templates.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(width: FfSpace.xs),
                        itemBuilder: (context, i) {
                          final t = _templates[i];
                          return FfChip(
                            label: t.name,
                            leading: Icon(t.icon, size: 14),
                            isSelected: _nameController.text.trim() == t.name,
                            onSelected: () => _applyTemplate(t),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: FfSpace.lg),
                  ],

                  // ── Goal Name ─────────────────────────────────────────────
                  Text(
                    'Goal name',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfTextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    hint: 'e.g. MacBook Pro, Japan Trip, Emergency Fund',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter goal name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Target Amount ─────────────────────────────────────────
                  Text(
                    'Target amount',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.xs),
                  FfAmountField(
                    controller: _amountController,
                    hint: '1,00,000',
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Target Date & Quick Chips ─────────────────────────────
                  Text(
                    'Target timeline',
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
                        label: '3 months',
                        isSelected: false,
                        onSelected: () => _setDatePreset(3),
                      ),
                      FfChip(
                        label: '6 months',
                        isSelected: false,
                        onSelected: () => _setDatePreset(6),
                      ),
                      FfChip(
                        label: '1 year',
                        isSelected: false,
                        onSelected: () => _setDatePreset(12),
                      ),
                      FfChip(
                        label: '2 years',
                        isSelected: false,
                        onSelected: () => _setDatePreset(24),
                      ),
                      FfChip(
                        label: DateFormatter.formatShortDate(_targetDate),
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                        ),
                        isSelected: true,
                        onSelected: _selectTargetDate,
                      ),
                    ],
                  ),

                  const SizedBox(height: FfSpace.md),

                  // ── Live Consequence Line ────────────────────────────────
                  FfConsequenceLine(
                    text: _computeConsequence(),
                    icon: Icons.savings_outlined,
                    tone: FfTone.savings,
                  ),

                  const SizedBox(height: FfSpace.lg),

                  // ── Advanced / Optional Details ──────────────────────────
                  InkWell(
                    onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvanced
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: context.ff.color.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Text(
                            _showAdvanced
                                ? 'Hide optional account and notes'
                                : 'Dedicated account & notes (optional)',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.actionPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAdvanced) ...[
                    const SizedBox(height: FfSpace.sm),
                    accountsAsync.when(
                      data: (accounts) {
                        final activeAccounts =
                            accounts.where((a) => !a.isArchived).toList();
                        return FfSelect<Account>(
                          value: _selectedAccount,
                          label: 'Dedicated Savings Account',
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
                              (val) => setState(() => _selectedAccount = val),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: FfSpace.md),
                    FfTextField(
                      controller: _notesController,
                      maxLines: 2,
                      label: 'Notes',
                      hint: 'e.g. Set aside 10% bonus each quarter',
                    ),
                  ],

                  const SizedBox(height: FfSpace.xl),
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
    );
  }
}
