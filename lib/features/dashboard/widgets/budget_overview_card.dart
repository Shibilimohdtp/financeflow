import 'package:flutter/material.dart';
import '../../../models/budget.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff_tone.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../theme/ff.dart';

class BudgetOverviewCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;
  final int overBudgetCount;
  final List<BudgetSummary>? activeBudgets;
  final bool isPrivacyBlur;
  final VoidCallback onViewBudgets;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overBudgetCount,
    this.activeBudgets,
    this.isPrivacyBlur = false,
    required this.onViewBudgets,
  });

  @override
  Widget build(BuildContext context) {
    final finColors = context.ff.color;

    if (totalBudgeted <= 0) return const SizedBox.shrink();

    final percentage =
        totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 0.0;
    final isExceeded = totalSpent > totalBudgeted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Budgets & Spending',
                  style: context.ff.text.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onViewBudgets,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Monthly budgets status hidden'
                    : isExceeded
                    ? 'Budget exceeded by ${totalSpent - totalBudgeted}'
                    : 'Budget remaining: $totalRemaining out of $totalBudgeted',
            child: Material(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              child: InkWell(
                borderRadius: BorderRadius.circular(FfRadius.lg),
                onTap: onViewBudgets,
                child: Container(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(FfRadius.lg),
                    border: Border.all(
                      color: context.ff.color.borderSubtle,
                      width: FfBorderWidth.hairline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(FfSpace.x2s),
                                decoration: BoxDecoration(
                                  color: (isExceeded
                                          ? finColors.moneyExpense
                                          : context.ff.color.actionPrimary)
                                      .withValues(alpha: FfTint.subtle.alpha),
                                  borderRadius: BorderRadius.circular(
                                    FfRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.pie_chart_outline_rounded,
                                  color:
                                      isExceeded
                                          ? finColors.moneyExpense
                                          : context.ff.color.actionPrimary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: FfSpace.sm),
                              Text(
                                isExceeded
                                    ? 'Over planned budget'
                                    : 'Remaining budget',
                                style: context.ff.text.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isExceeded
                                          ? finColors.moneyExpense
                                          : context.ff.color.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}% used',
                            style: context.ff.text.labelSm.copyWith(
                              color:
                                  isExceeded
                                      ? finColors.moneyExpense
                                      : context.ff.color.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FfSpace.sm),
                      FfProgressBar(
                        value: percentage,
                        color:
                            isExceeded
                                ? finColors.moneyExpense
                                : context.ff.color.actionPrimary,
                        size: FfProgressSize.md,
                      ),
                      const SizedBox(height: FfSpace.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Spent: ',
                                style: context.ff.text.bodySm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              FfAmountText(
                                amount: totalSpent,
                                size: FfAmountSize.sm,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                tone: FfTone.neutral,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Limit: ',
                                style: context.ff.text.bodySm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              FfAmountText(
                                amount: totalBudgeted,
                                size: FfAmountSize.sm,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                tone: FfTone.neutral,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Optional Individual Active Budgets Breakdown
                      if (activeBudgets != null &&
                          activeBudgets!.isNotEmpty) ...[
                        const SizedBox(height: FfSpace.sm),
                        const FfDivider(),
                        const SizedBox(height: FfSpace.sm),
                        ...activeBudgets!.take(3).map((summary) {
                          final pct = summary.percentageUsed.clamp(0.0, 1.0);
                          final isOver = summary.isExceeded;
                          final isNear = summary.isApproachingThreshold;
                          final barColor =
                              isOver
                                  ? finColors.moneyExpense
                                  : isNear
                                  ? context.ff.color.statusWarning
                                  : context.ff.color.actionPrimary;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: FfSpace.x3s,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (summary.budget.categoryIcon !=
                                        null) ...[
                                      FfCategoryTile(
                                        iconIdentifier:
                                            summary.budget.categoryIcon!,
                                        colorTokenIdentifier:
                                            summary.budget.categoryColor ??
                                            'blue',
                                        size: 24,
                                      ),
                                      const SizedBox(width: FfSpace.xs),
                                    ],
                                    Expanded(
                                      child: Text(
                                        summary.budget.name,
                                        style: context.ff.text.bodySm.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    FfAmountText(
                                      amount: summary.amountSpent,
                                      size: FfAmountSize.sm,
                                      isBlurred: isPrivacyBlur,
                                      showSign: false,
                                    ),
                                    Text(
                                      ' / ',
                                      style: context.ff.text.bodySm.copyWith(
                                        color: context.ff.color.secondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                    FfAmountText(
                                      amount: summary.budget.amountLimit,
                                      size: FfAmountSize.sm,
                                      isBlurred: isPrivacyBlur,
                                      showSign: false,
                                      tone: FfTone.neutral,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: FfSpace.x3s),
                                FfProgressBar(
                                  value: pct,
                                  color: barColor,
                                  size: FfProgressSize.sm,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
