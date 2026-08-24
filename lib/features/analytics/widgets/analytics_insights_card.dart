import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../theme/stillwater_tokens.dart';

/// Generates data-driven insight rows from an [AnalyticsReport].
///
/// Only renders when there is meaningful data. Uses the same
/// [FfGroupedContainer] group style as the Settings page for consistency.
class AnalyticsInsightsCard extends StatelessWidget {
  final AnalyticsReport report;

  const AnalyticsInsightsCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final insights = _generateInsights(report, context);

    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
          child: Text(
            'INSIGHTS',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: theme.colorScheme.secondary,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: StillwaterTokens.spaceXs),
        FfGroupedContainer(
          showDividers: true,
          children:
              insights
                  .map((ins) => _InsightRow(insight: ins, theme: theme))
                  .toList(),
        ),
      ],
    );
  }

  List<_InsightData> _generateInsights(
    AnalyticsReport report,
    BuildContext context,
  ) {
    final finColors = context.finColors;
    final insights = <_InsightData>[];

    // 1. Biggest spending category
    if (report.categoryBreakdown.isNotEmpty) {
      final top = report.categoryBreakdown.first;
      if (top.amount > 0) {
        final pct = (top.percentage * 100).toStringAsFixed(0);
        insights.add(
          _InsightData(
            icon: Icons.pie_chart_outline_rounded,
            iconColor: finColors.expense,
            title: '${top.categoryName} is your top spend',
            subtitle:
                '${CurrencyFormatter.formatINR(top.amount)} — $pct% of total expenses this period.',
          ),
        );
      }
    }

    // 2. Savings rate narrative
    if (report.totalIncome > 0) {
      final rate = report.savingsRate;
      String narrative;
      Color color;
      IconData icon;

      if (rate >= 0.3) {
        narrative =
            'Excellent savings rate of ${(rate * 100).toStringAsFixed(0)}%! You are building wealth effectively.';
        color = finColors.savings;
        icon = Icons.star_outline_rounded;
      } else if (rate >= 0.2) {
        narrative =
            'Good savings rate of ${(rate * 100).toStringAsFixed(0)}%. Financial experts recommend 20%+.';
        color = finColors.savings;
        icon = Icons.savings_outlined;
      } else if (rate >= 0.05) {
        narrative =
            'Savings rate is ${(rate * 100).toStringAsFixed(0)}%. Aim for 20%+ to build a stronger financial cushion.';
        color = context.theme.colorScheme.primary;
        icon = Icons.savings_outlined;
      } else if (rate > 0) {
        narrative =
            'Savings rate is only ${(rate * 100).toStringAsFixed(0)}%. Review expenses to save more this period.';
        color = finColors.expense;
        icon = Icons.warning_amber_rounded;
      } else {
        narrative =
            'Spending exceeded income this period. Review your budget to get back on track.';
        color = finColors.expense;
        icon = Icons.trending_down_rounded;
      }

      insights.add(
        _InsightData(
          icon: icon,
          iconColor: color,
          title: 'Savings rate',
          subtitle: narrative,
        ),
      );
    }

    // 3. Top payee / merchant
    if (report.topMerchants.isNotEmpty) {
      final topM = report.topMerchants.first;
      if (topM.totalAmount > 0 && topM.transactionCount >= 2) {
        insights.add(
          _InsightData(
            icon: Icons.store_outlined,
            iconColor: context.theme.colorScheme.secondary,
            title: '"${topM.normalizedMerchant}" is your most visited',
            subtitle:
                '${topM.transactionCount} transactions totalling ${CurrencyFormatter.formatINR(topM.totalAmount)}.',
          ),
        );
      }
    }

    // 4. Period comparison narrative
    final expPct = report.expenseChangePercentage;
    if (expPct != null && expPct.abs() >= 5) {
      final isUp = expPct > 0;
      insights.add(
        _InsightData(
          icon: isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          iconColor: isUp ? finColors.expense : finColors.savings,
          title:
              isUp
                  ? 'Spending is up ${expPct.abs().toStringAsFixed(0)}% vs last period'
                  : 'Spending is down ${expPct.abs().toStringAsFixed(0)}% vs last period',
          subtitle:
              isUp
                  ? 'Check your top categories for unexpected increases.'
                  : 'Great work — keep the momentum going!',
        ),
      );
    }

    return insights.take(3).toList(); // Limit to 3 most important insights
  }
}

class _InsightData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InsightData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}

class _InsightRow extends StatelessWidget {
  final _InsightData insight;
  final ThemeData theme;

  const _InsightRow({required this.insight, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: insight.iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
            ),
            child: Icon(insight.icon, size: 16, color: insight.iconColor),
          ),
          const SizedBox(width: StillwaterTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  insight.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 12,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
