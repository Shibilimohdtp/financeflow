import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';

class BudgetOverviewCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;
  final int overBudgetCount;
  final VoidCallback onViewBudgets;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overBudgetCount,
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
              Text('Monthly Budgets', style: theme.textTheme.titleMedium),
              TextButton(onPressed: onViewBudgets, child: const Text('Manage')),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          InkWell(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            onTap: onViewBudgets,
            child: FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            color:
                                isExceeded
                                    ? finColors.expense
                                    : theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceXs),
                          Text(
                            isExceeded
                                ? '${CurrencyFormatter.format(totalSpent - totalBudgeted)} over planned budget'
                                : '${CurrencyFormatter.format(totalRemaining)} remaining',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color:
                                  isExceeded
                                      ? finColors.expense
                                      : finColors.income,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(percentage * 100).toStringAsFixed(0)}% used',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
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
                      Text(
                        'Spent: ${CurrencyFormatter.format(totalSpent)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        'Limit: ${CurrencyFormatter.format(totalBudgeted)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
