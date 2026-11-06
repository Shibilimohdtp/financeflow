import 'package:flutter/material.dart';

import '../../../models/budget.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

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
    final ff = context.ff;
    final c = ff.color;

    if (totalBudgeted <= 0) return const SizedBox.shrink();

    final percentage =
        totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 0.0;
    final isExceeded = totalSpent > totalBudgeted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Budgets & Spending',
            padding: const EdgeInsets.only(bottom: FfSpace.xs),
            trailing: TextButton(
              onPressed: onViewBudgets,
              child: const Text('Manage'),
            ),
          ),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Monthly budgets status hidden'
                    : isExceeded
                    ? 'Budget exceeded by ${totalSpent - totalBudgeted}'
                    : 'Budget remaining: $totalRemaining out of $totalBudgeted',
            child: FfCard(
              density: FfDensity.comfortable,
              onTap: onViewBudgets,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FfIconTile(
                        icon: Icons.pie_chart_outline_rounded,
                        tone: isExceeded ? FfTone.expense : FfTone.primary,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExceeded
                                  ? 'Over planned budget'
                                  : 'Remaining budget',
                              style: ff.text.labelSm.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            FfAmountText(
                              amount:
                                  isExceeded
                                      ? (totalSpent - totalBudgeted)
                                      : totalRemaining,
                              size: FfAmountSize.lg,
                              style: FfAmountStyle.split,
                              tone:
                                  isExceeded ? FfTone.expense : FfTone.neutral,
                              showSign: isExceeded,
                              isBlurred: isPrivacyBlur,
                            ),
                          ],
                        ),
                      ),
                      FfBadge(
                        label:
                            isExceeded
                                ? 'Over limit'
                                : '${(percentage * 100).toStringAsFixed(0)}% used',
                        tone: isExceeded ? FfTone.expense : FfTone.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfProgressBar(
                    value: percentage,
                    tone: isExceeded ? FfTone.expense : FfTone.primary,
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
                            style: ff.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          FfAmountText(
                            amount: totalSpent,
                            size: FfAmountSize.sm,
                            style: FfAmountStyle.inline,
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
                            style: ff.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          FfAmountText(
                            amount: totalBudgeted,
                            size: FfAmountSize.sm,
                            style: FfAmountStyle.inline,
                            isBlurred: isPrivacyBlur,
                            showSign: false,
                            tone: FfTone.neutral,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (activeBudgets != null && activeBudgets!.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.sm),
                    const FfDivider(),
                    const SizedBox(height: FfSpace.sm),
                    for (final summary in activeBudgets!.take(3)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: FfSpace.x3s,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (summary.budget.categoryIcon != null) ...[
                                  FfCategoryTile(
                                    iconIdentifier:
                                        summary.budget.categoryIcon!,
                                    colorTokenIdentifier:
                                        summary.budget.categoryColor ?? 'blue',
                                    size: 24,
                                  ),
                                  const SizedBox(width: FfSpace.xs),
                                ],
                                Expanded(
                                  child: Text(
                                    summary.budget.name,
                                    style: ff.text.titleSm,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                FfAmountText(
                                  amount: summary.amountSpent,
                                  size: FfAmountSize.sm,
                                  style: FfAmountStyle.inline,
                                  isBlurred: isPrivacyBlur,
                                  showSign: false,
                                ),
                                Text(
                                  ' / ',
                                  style: ff.text.labelSm.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                                FfAmountText(
                                  amount: summary.budget.amountLimit,
                                  size: FfAmountSize.sm,
                                  style: FfAmountStyle.inline,
                                  isBlurred: isPrivacyBlur,
                                  showSign: false,
                                  tone: FfTone.neutral,
                                ),
                              ],
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            FfProgressBar(
                              value: summary.percentageUsed.clamp(0.0, 1.0),
                              tone:
                                  summary.isExceeded
                                      ? FfTone.expense
                                      : summary.isApproachingThreshold
                                      ? FfTone.warning
                                      : FfTone.primary,
                              size: FfProgressSize.sm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
