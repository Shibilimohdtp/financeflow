import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/budget.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../shared/widgets/ff_divider.dart';

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
    final theme = context.theme;
    final finColors = context.finColors;

    if (totalBudgeted <= 0) return const SizedBox.shrink();

    final percentage =
        totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 0.0;
    final isExceeded = totalSpent > totalBudgeted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Budgets & Spending',
                  style: theme.textTheme.titleSmall?.copyWith(
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
          const SizedBox(height: StillwaterTokens.spaceXs),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Monthly budgets status hidden'
                    : isExceeded
                    ? 'Budget exceeded by ${totalSpent - totalBudgeted}'
                    : 'Budget remaining: $totalRemaining out of $totalBudgeted',
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              child: InkWell(
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                onTap: onViewBudgets,
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusLg,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: StillwaterTokens.borderWidthHairline,
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
                                padding: const EdgeInsets.all(
                                  StillwaterTokens.space2Xs,
                                ),
                                decoration: BoxDecoration(
                                  color: (isExceeded
                                          ? finColors.expense
                                          : theme.colorScheme.primary)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.pie_chart_outline_rounded,
                                  color:
                                      isExceeded
                                          ? finColors.expense
                                          : theme.colorScheme.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceSm),
                              Text(
                                isExceeded
                                    ? 'Over planned budget'
                                    : 'Remaining budget',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isExceeded
                                          ? finColors.expense
                                          : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}% used',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  isExceeded
                                      ? finColors.expense
                                      : theme.colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color:
                              isExceeded
                                  ? finColors.expense
                                  : theme.colorScheme.primary,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Spent: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              FfAmountText(
                                amount: totalSpent,
                                size: FfAmountSize.sm,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                colorOverride: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Limit: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              FfAmountText(
                                amount: totalBudgeted,
                                size: FfAmountSize.sm,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                colorOverride: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Optional Individual Active Budgets Breakdown
                      if (activeBudgets != null &&
                          activeBudgets!.isNotEmpty) ...[
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        const FfDivider(),
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        ...activeBudgets!.take(3).map((summary) {
                          final pct = summary.percentageUsed.clamp(0.0, 1.0);
                          final isOver = summary.isExceeded;
                          final isNear = summary.isApproachingThreshold;
                          final barColor =
                              isOver
                                  ? finColors.expense
                                  : isNear
                                  ? context.statusColors.warning
                                  : theme.colorScheme.primary;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: StillwaterTokens.space3Xs,
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
                                      const SizedBox(
                                        width: StillwaterTokens.spaceXs,
                                      ),
                                    ],
                                    Expanded(
                                      child: Text(
                                        summary.budget.name,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
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
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            fontSize: 10,
                                          ),
                                    ),
                                    FfAmountText(
                                      amount: summary.budget.amountLimit,
                                      size: FfAmountSize.sm,
                                      isBlurred: isPrivacyBlur,
                                      showSign: false,
                                      colorOverride:
                                          theme.colorScheme.secondary,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: StillwaterTokens.space3Xs,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusFull,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    color: barColor,
                                    minHeight: 4,
                                  ),
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
