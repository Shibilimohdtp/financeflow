import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/budget.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';

class BudgetInsightsCard extends StatelessWidget {
  final List<BudgetSummary> summaries;
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;

  const BudgetInsightsCard({
    super.key,
    required this.summaries,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty || totalBudgeted <= 0) {
      return const SizedBox.shrink();
    }

    final theme = context.theme;
    final finColors = context.finColors;
    final aiColors = context.aiColors;

    // Derive data-driven insights
    final exceededBudgets = summaries.where((s) => s.isExceeded).toList();
    final approachingBudgets =
        summaries.where((s) => s.isApproachingThreshold).toList();

    final maxDaysRemaining = summaries.fold<int>(
      0,
      (max, s) => s.daysRemaining > max ? s.daysRemaining : max,
    );
    final overallDailyAllowance =
        maxDaysRemaining > 0 && totalRemaining > 0
            ? totalRemaining / maxDaysRemaining
            : 0.0;

    final insights = <_BudgetInsightItem>[];

    // 1. Exceeded limit signal
    if (exceededBudgets.isNotEmpty) {
      final names = exceededBudgets.map((b) => b.budget.name).join(', ');
      insights.add(
        _BudgetInsightItem(
          icon: Icons.error_outline_rounded,
          iconColor: finColors.expense,
          title:
              '${exceededBudgets.length} ${exceededBudgets.length == 1 ? 'category exceeds' : 'categories exceed'} planned limit',
          subtitle:
              '$names ${exceededBudgets.length == 1 ? 'has' : 'have'} gone beyond the allocated budget for this period.',
        ),
      );
    }

    // 2. Approaching threshold signal
    if (approachingBudgets.isNotEmpty) {
      final first = approachingBudgets.first;
      insights.add(
        _BudgetInsightItem(
          icon: Icons.warning_amber_rounded,
          iconColor: theme.colorScheme.tertiary,
          title: '${first.budget.name} nearing limit',
          subtitle:
              '${(first.percentageUsed * 100).toStringAsFixed(0)}% used with ${CurrencyFormatter.formatINR(first.remainingAmount)} remaining across ${first.daysRemaining} days.',
        ),
      );
    }

    // 3. Daily spending guidance signal
    if (overallDailyAllowance > 0 && maxDaysRemaining > 0) {
      insights.add(
        _BudgetInsightItem(
          icon: Icons.speed_rounded,
          iconColor: theme.colorScheme.primary,
          title: 'Daily budget allowance',
          subtitle:
              'Spend under ${CurrencyFormatter.formatINR(overallDailyAllowance)}/day for the next $maxDaysRemaining days to finish the period within plan.',
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        _BudgetInsightItem(
          icon: Icons.savings_outlined,
          iconColor: finColors.income,
          title: 'All budgets healthy',
          subtitle:
              'Spending across all ${summaries.length} tracked categories is well within allocated boundaries.',
        ),
      );
    }

    return FfCard(
      variant: FfCardVariant.tinted,
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: aiColors.accent),
              const SizedBox(width: StillwaterTokens.spaceXs),
              Text(
                'BUDGET INTELLIGENCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: aiColors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          for (int i = 0; i < insights.length; i++) ...[
            if (i > 0) const SizedBox(height: StillwaterTokens.spaceSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: insights[i].iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusSm,
                    ),
                  ),
                  child: Icon(
                    insights[i].icon,
                    size: 16,
                    color: insights[i].iconColor,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insights[i].title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insights[i].subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetInsightItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _BudgetInsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
