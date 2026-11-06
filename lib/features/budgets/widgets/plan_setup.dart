import 'package:flutter/material.dart';

import '../../../models/budget.dart';
import '../../../models/category.dart';
import '../../../services/budgets/budget_setup_suggester.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../budget_format.dart';

/// The Plan tab before any budget exists. With enough history it offers a
/// starting plan built from what the person actually spent (median of the
/// last three months, rounded up to a friendly figure), every row ticked and
/// editable later, plus the 50/30/20 rule as a guide only. Without history
/// it explains what a plan does and offers "Add budget".
class PlanSetup extends StatefulWidget {
  const PlanSetup({
    super.key,
    required this.suggestion,
    required this.categories,
    required this.monthlyBillsMinor,
    required this.isPrivacyBlur,
    required this.onCreate,
    required this.onAddBudget,
  });

  final BudgetSetupSuggestion? suggestion;

  /// Categories by id, for names and icons.
  final Map<String, Category> categories;

  /// Tracked subscriptions and EMIs this month; they count as needs in the
  /// guide.
  final int monthlyBillsMinor;
  final bool isPrivacyBlur;
  final Future<void> Function(List<SuggestedBudget> picked) onCreate;
  final VoidCallback onAddBudget;

  @override
  State<PlanSetup> createState() => _PlanSetupState();
}

class _PlanSetupState extends State<PlanSetup> {
  late final Set<String> _picked = {for (final b in _suggested) b.categoryId};
  bool _saving = false;

  List<SuggestedBudget> get _suggested => [
    for (final b in widget.suggestion?.budgets ?? const <SuggestedBudget>[])
      if (widget.categories.containsKey(b.categoryId)) b,
  ];

  @override
  Widget build(BuildContext context) {
    final suggested = _suggested;
    if (suggested.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.x2l,
        ),
        child: FfEmptyState(
          icon: Icons.pie_chart_outline_rounded,
          title: 'Plan your spending',
          description:
              'Give the categories you spend on most a limit for the month. '
              'You will see what is safe to spend each day. Bills and EMIs '
              'are tracked on their own.',
          actionLabel: 'Add budget',
          onAction: widget.onAddBudget,
        ),
      );
    }

    final picked = suggested.where((b) => _picked.contains(b.categoryId));
    final months = widget.suggestion!.monthsWithData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FfSpace.pageMargin,
            FfSpace.md,
            FfSpace.pageMargin,
            FfSpace.lg,
          ),
          child: FfEmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Start with a plan from your spending',
            description:
                'These limits come from what you usually spent over the last '
                '${months == 1 ? 'month' : '$months months'}, rounded up. '
                'Untick anything you don\'t want; you can change any of '
                'them later.',
          ),
        ),
        FfSectionHeader(
          title: 'Suggested budgets',
          padding: const EdgeInsetsDirectional.fromSTEB(
            FfSpace.pageMargin,
            0,
            FfSpace.pageMargin,
            FfSpace.xs,
          ),
          trailing: Text(
            '${_picked.length} of ${suggested.length}',
            style: context.ff.text.label,
          ),
        ),
        FfGroupedContainer(
          margin: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          dividerInset: FfRowLeading.tile,
          children: [
            for (final b in suggested)
              FfRow.checkbox(
                key: ValueKey('setup-${b.categoryId}'),
                leading: FfCategoryTile(
                  iconIdentifier:
                      widget.categories[b.categoryId]!.iconIdentifier,
                  colorTokenIdentifier:
                      widget.categories[b.categoryId]!.colorTokenIdentifier,
                ),
                title: widget.categories[b.categoryId]!.name,
                subtitle: _rowSubtitle(b),
                detail:
                    widget.isPrivacyBlur
                        ? '••••'
                        : BudgetFormat.money(b.suggestedMinor),
                checked: _picked.contains(b.categoryId),
                onChanged:
                    _saving
                        ? null
                        : (v) => setState(
                          () =>
                              v
                                  ? _picked.add(b.categoryId)
                                  : _picked.remove(b.categoryId),
                        ),
              ),
          ],
        ),
        const SizedBox(height: FfSpace.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          child: _SetupSummary(
            picked: picked.toList(),
            incomeMinor: widget.suggestion!.estimatedMonthlyIncomeMinor,
            billsMinor: widget.monthlyBillsMinor,
            isPrivacyBlur: widget.isPrivacyBlur,
          ),
        ),
        const SizedBox(height: FfSpace.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FfButton(
                key: const ValueKey('setup-create'),
                label:
                    _picked.length == 1
                        ? 'Create 1 budget'
                        : 'Create ${_picked.length} budgets',
                isLoading: _saving,
                onPressed:
                    _picked.isEmpty || _saving
                        ? null
                        : () async {
                          setState(() => _saving = true);
                          try {
                            await widget.onCreate(picked.toList());
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
              ),
              const SizedBox(height: FfSpace.xs),
              FfButton(
                label: 'Start from scratch',
                variant: FfButtonVariant.text,
                onPressed: _saving ? null : widget.onAddBudget,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _rowSubtitle(SuggestedBudget b) {
    final group = b.group.label;
    if (widget.isPrivacyBlur) return group;
    return 'Usually ${BudgetFormat.money(b.medianMinor)} · $group';
  }
}

/// The picked plan's total and, when income is known, how it splits into
/// needs and wants next to the 50/30/20 guide. Bills count as needs.
class _SetupSummary extends StatelessWidget {
  const _SetupSummary({
    required this.picked,
    required this.incomeMinor,
    required this.billsMinor,
    required this.isPrivacyBlur,
  });

  final List<SuggestedBudget> picked;
  final int? incomeMinor;
  final int billsMinor;
  final bool isPrivacyBlur;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    int sum(BudgetGroup g) => picked
        .where((b) => b.group == g)
        .fold<int>(0, (s, b) => s + b.suggestedMinor);
    final total = picked.fold<int>(0, (s, b) => s + b.suggestedMinor);
    final income = incomeMinor;
    final split =
        income == null
            ? null
            : PlanSplit(
              incomeMinor: income,
              essentialsMinor: sum(BudgetGroup.essentials),
              lifestyleMinor: sum(BudgetGroup.lifestyle),
              otherMinor: sum(BudgetGroup.other),
              billsMinor: billsMinor,
              savingsMinor: 0,
            );
    String pct(double share) => '${BudgetFormat.percent(share)}%';

    return FfCard(
      key: const ValueKey('setup-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfStatTile(
            label: 'Monthly plan',
            value: FfAmountText(
              amount: BudgetFormat.major(total),
              size: FfAmountSize.lg,
              tone: FfTone.neutral,
              showSign: false,
              isBlurred: isPrivacyBlur,
            ),
            caption:
                billsMinor > 0 && !isPrivacyBlur
                    ? 'Plus ${BudgetFormat.money(billsMinor)} of bills and '
                        'EMIs, tracked on their own'
                    : null,
          ),
          if (split != null) ...[
            const SizedBox(height: FfSpace.md),
            const FfDivider(),
            const SizedBox(height: FfSpace.md),
            Text(
              isPrivacyBlur
                  ? 'Share of your usual income'
                  : 'Share of your usual income of '
                      '${BudgetFormat.money(split.incomeMinor)}',
              style: ff.text.label,
            ),
            const SizedBox(height: FfSpace.xs),
            FfHeroFigures([
              FfHeroFigure('Needs', pct(split.needsShare)),
              FfHeroFigure('Wants', pct(split.wantsShare)),
              FfHeroFigure(
                split.unplannedMinor >= 0 ? 'Not planned' : 'Over income',
                pct(split.unplannedMinor.abs() / split.incomeMinor),
              ),
            ]),
            const SizedBox(height: FfSpace.sm),
            Text(
              'A common guide is about 50% for needs, 30% for wants and 20% '
              'for saving. It is a guide, not a rule.',
              style: ff.text.label,
            ),
          ],
        ],
      ),
    );
  }
}
