import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/stillwater_typography.dart';

/// A 3x2 grid card showing all key summary metrics from [AnalyticsReport].
class AnalyticsMetricsHero extends StatelessWidget {
  final AnalyticsReport report;

  const AnalyticsMetricsHero({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    final savingsColor = report.netSavings >= 0
        ? finColors.savings
        : finColors.expense;
    final savingsRateColor = report.savingsRate >= 0.2
        ? finColors.savings
        : report.savingsRate >= 0.05
            ? theme.colorScheme.primary
            : finColors.expense;

    return FfCard(
      variant: FfCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Total Inflow',
                  value: CurrencyFormatter.formatINR(report.totalIncome),
                  color: finColors.income,
                  trendPct: report.incomeChangePercentage,
                  isIncome: true,
                ),
              ),
              Container(width: 1, height: 48, color: theme.dividerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: StillwaterTokens.spaceMd),
                  child: _MetricBlock(
                    label: 'Total Outflow',
                    value: CurrencyFormatter.formatINR(report.totalExpense),
                    color: finColors.expense,
                    trendPct: report.expenseChangePercentage,
                    isIncome: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            color: theme.dividerColor,
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Net Savings',
                  value: CurrencyFormatter.formatINR(report.netSavings),
                  color: savingsColor,
                ),
              ),
              Container(width: 1, height: 48, color: theme.dividerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: StillwaterTokens.spaceMd),
                  child: _MetricBlock(
                    label: 'Savings Rate',
                    value: '${(report.savingsRate * 100).toStringAsFixed(0)}%',
                    color: savingsRateColor,
                    badgeText: _savingsRateBadgeText(report.savingsRate),
                    badgePositive: report.savingsRate >= 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            color: theme.dividerColor,
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Avg Transaction',
                  value: CurrencyFormatter.formatINR(
                    report.averageTransactionAmount,
                  ),
                ),
              ),
              Container(width: 1, height: 48, color: theme.dividerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: StillwaterTokens.spaceMd),
                  child: _MetricBlock(
                    label: 'Transactions',
                    value: '${report.transactionCount}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _savingsRateBadgeText(double rate) {
    if (rate >= 0.3) return 'Excellent';
    if (rate >= 0.2) return 'Good';
    if (rate >= 0.1) return 'Fair';
    if (rate > 0) return 'Low';
    return null;
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final double? trendPct;
  final bool isIncome;
  final String? badgeText;
  final bool badgePositive;

  const _MetricBlock({
    required this.label,
    required this.value,
    this.color,
    this.trendPct,
    this.isIncome = false,
    this.badgeText,
    this.badgePositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trendPct != null) ...[
              const SizedBox(width: StillwaterTokens.space3Xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                      ? finColors.savings.withValues(alpha: 0.1)
                      : finColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPct! >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 9,
                      color: (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                          ? finColors.savings
                          : finColors.expense,
                    ),
                    Text(
                      '${trendPct!.abs().toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                            ? finColors.savings
                            : finColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (badgeText != null && trendPct == null) ...[
              const SizedBox(width: StillwaterTokens.space3Xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: badgePositive
                      ? finColors.savings.withValues(alpha: 0.12)
                      : finColors.expense.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: badgePositive ? finColors.savings : finColors.expense,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: StillwaterTokens.space2Xs),
        Text(
          value,
          style: StillwaterTypography.numMd(
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
