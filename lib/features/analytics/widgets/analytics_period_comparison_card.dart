import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../theme/stillwater_tokens.dart';

/// A card displaying human-readable period-vs-period comparison data.
///
/// Shows income and expense deltas versus the previous period in plain English,
/// using the same [FfGroupedContainer] style found on the Settings page.
class AnalyticsPeriodComparisonCard extends StatelessWidget {
  final AnalyticsReport report;

  const AnalyticsPeriodComparisonCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    final expPct = report.expenseChangePercentage;
    final incPct = report.incomeChangePercentage;
    final prevExp = report.previousPeriodExpense;
    final prevInc = report.previousPeriodIncome;

    // Only render if there is previous-period data available
    if (expPct == null && incPct == null) return const SizedBox.shrink();

    final periodLabel = _periodLabel(report.timeRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
          child: Text(
            'VS PREVIOUS $periodLabel'.toUpperCase(),
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
          children: [
            if (expPct != null)
              _ComparisonRow(
                icon: Icons.arrow_upward_rounded,
                iconColor: finColors.expense,
                label: 'Spending',
                currentValue: report.totalExpense,
                previousValue: prevExp,
                changePercentage: expPct,
                isPositiveWhenDown: true,
                theme: theme,
                finColors: finColors,
              ),
            if (incPct != null)
              _ComparisonRow(
                icon: Icons.arrow_downward_rounded,
                iconColor: finColors.income,
                label: 'Income',
                currentValue: report.totalIncome,
                previousValue: prevInc,
                changePercentage: incPct,
                isPositiveWhenDown: false,
                theme: theme,
                finColors: finColors,
              ),
          ],
        ),
      ],
    );
  }

  static String _periodLabel(AnalyticsTimeRange range) {
    switch (range) {
      case AnalyticsTimeRange.week:
        return 'week';
      case AnalyticsTimeRange.month:
        return 'month';
      case AnalyticsTimeRange.year:
        return 'year';
      case AnalyticsTimeRange.custom:
        return 'period';
    }
  }
}

class _ComparisonRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double currentValue;
  final double? previousValue;
  final double changePercentage;
  final bool isPositiveWhenDown;
  final ThemeData theme;
  final dynamic finColors;

  const _ComparisonRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.isPositiveWhenDown,
    required this.theme,
    required this.finColors,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = changePercentage > 0;
    final isGood = isPositiveWhenDown ? !isUp : isUp;
    final changeColor = isGood ? finColors.savings : finColors.expense;
    final changeText =
        isUp
            ? '↑ ${changePercentage.abs().toStringAsFixed(0)}% higher'
            : '↓ ${changePercentage.abs().toStringAsFixed(0)}% lower';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: StillwaterTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  changeText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatAmount(currentValue),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (previousValue != null) ...[
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  'was ${CurrencyFormatter.formatAmount(previousValue!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
