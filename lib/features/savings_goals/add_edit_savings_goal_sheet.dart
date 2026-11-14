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
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_consequence_line.dart';
import '../../shared/widgets/ff_disclosure_row.dart';
import '../../shared/widgets/ff_entity_preview_card.dart';
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

  /// The timeline preset last chosen (months), or null for a picked date.
  int? _presetMonths;

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
              ? FfAmountField.formatInput(initial.targetAmount)
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
      _amountController.text = FfAmountField.formatInput(template.amount);
      _targetDate = DateTime.now().add(Duration(days: template.months * 30));
      _presetMonths = template.months;
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
      setState(() {
        _targetDate = picked;
        _presetMonths = null;
      });
    }
  }

  void _setDatePreset(int months) {
    HapticFeedback.selectionClick();
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: months * 30));
      _presetMonths = months;
    });
  }

  String _computeConsequence() {
    final amount = CurrencyFormatter.parse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      return 'Enter a target to see how much to set aside each month.';
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
            ? 'New goal'
            : _nameController.text.trim();
    final icon = SavingsGoalsScreen.getGoalIcon(currentName);

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSheetHeader(
          title: isEditing ? 'Edit savings goal' : 'New savings goal',
          subtitle: "Money you're setting aside for something",
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
                  // ── Live preview (archetype B) ───────────────────────────
                  FfEntityPreviewCard(
                    leading: FfEntityPreviewCard.disc(
                      context,
                      FfHeroTone.tide,
                      icon,
                    ),
                    title: currentName,
                    subtitle:
                        'By ${DateFormatter.formatShortDate(_targetDate)}',
                    figureCaption: 'Target',
                    figure: FfAmountText(
                      amount: currentAmount,
                      size: FfAmountSize.lg,
                      style: FfAmountStyle.split,
                      tone: FfTone.neutral,
                      showSign: false,
                    ),
                    semanticLabel:
                        'Preview: $currentName, target '
                        '${CurrencyFormatter.formatAmount(currentAmount)} by '
                        '${DateFormatter.formatShortDate(_targetDate)}',
                  ),
                  const SizedBox(height: FfSheetTokens.groupGap),

                  // ── Templates ────────────────────────────────────────────
                  if (!isEditing)
                    FfSheetGroup(
                      label: 'Start from',
                      children: [
                        Wrap(
                          spacing: FfChipTokens.gap,
                          runSpacing: FfChipTokens.gap,
                          children: [
                            for (final t in _templates)
                              FfChip(
                                label: t.name,
                                leading: Icon(t.icon, size: FfIconSize.sm),
                                isSelected:
                                    _nameController.text.trim() == t.name,
                                onSelected: () => _applyTemplate(t),
                              ),
                          ],
                        ),
                      ],
                    ),

                  // ── Name and target ──────────────────────────────────────
                  FfSheetGroup(
                    children: [
                      FfTextField(
                        controller: _nameController,
                        label: 'Goal name',
                        textCapitalization: TextCapitalization.words,
                        hint: 'e.g. Japan trip, Emergency fund',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter goal name';
                          }
                          return null;
                        },
                      ),
                      FfAmountField(
                        controller: _amountController,
                        label: 'Target amount',
                        size: FfAmountSize.md,
                        tone: FfTone.savings,
                        groupDigits: true,
                      ),
                    ],
                  ),

                  // ── Timeline ─────────────────────────────────────────────
                  FfSheetGroup(
                    label: 'Reach it in',
                    children: [
                      Wrap(
                        spacing: FfChipTokens.gap,
                        runSpacing: FfChipTokens.gap,
                        children: [
                          for (final (label, months) in const [
                            ('3 months', 3),
                            ('6 months', 6),
                            ('1 year', 12),
                            ('2 years', 24),
                          ])
                            FfChip(
                              label: label,
                              isSelected: _presetMonths == months,
                              onSelected: () => _setDatePreset(months),
                            ),
                          FfChip(
                            label: DateFormatter.formatShortDate(_targetDate),
                            leading: const Icon(
                              Icons.calendar_today_outlined,
                              size: FfIconSize.sm,
                            ),
                            isSelected: _presetMonths == null,
                            onSelected: _selectTargetDate,
                          ),
                        ],
                      ),
                      FfConsequenceLine(
                        text: _computeConsequence(),
                        icon: Icons.savings_outlined,
                        tone: FfTone.savings,
                      ),
                    ],
                  ),

                  // ── More details ─────────────────────────────────────────
                  FfDisclosureRow(
                    subtitle: 'Savings account and a note',
                    initiallyExpanded: _showAdvanced,
                    onExpansionChanged: (v) => _showAdvanced = v,
                    children: [
                      accountsAsync.when(
                        data: (accounts) {
                          final activeAccounts =
                              accounts.where((a) => !a.isArchived).toList();
                          return FfSelect<Account>(
                            value: _selectedAccount,
                            label: 'Savings account (optional)',
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
                      FfTextField(
                        controller: _notesController,
                        maxLines: 2,
                        label: 'Notes (optional)',
                        hint: 'e.g. Set aside 10% of each bonus',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        FfSheetFooter(
          primaryLabel: isEditing ? 'Save changes' : 'Create goal',
          isPrimaryLoading: _isSubmitting,
          onPrimaryPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}
