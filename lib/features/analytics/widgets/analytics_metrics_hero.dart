import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_typography.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff.dart';

/// A 3x2 grid card showing all key summary metrics from [AnalyticsReport].
class AnalyticsMetricsHero extends StatelessWidget {
  final AnalyticsReport report;

  const AnalyticsMetricsHero({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final finColors = context.ff.color;

    final savingsColor =
        report.netSavings >= 0
            ? finColors.moneySavings
            : finColors.moneyExpense;
    final savingsRateColor =
        report.savingsRate >= 0.2
            ? finColors.moneySavings
            : report.savingsRate >= 0.05
            ? context.ff.color.actionPrimary
            : finColors.moneyExpense;

    return FfCard(
      variant: FfCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Total Inflow',
                  value: CurrencyFormatter.formatAmount(report.totalIncome),
                  color: finColors.moneyIncome,
                  trendPct: report.incomeChangePercentage,
                  isIncome: true,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: context.ff.color.borderSubtle,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: FfSpace.md),
                  child: _MetricBlock(
                    label: 'Total Outflow',
                    value: CurrencyFormatter.formatAmount(report.totalExpense),
                    color: finColors.moneyExpense,
                    trendPct: report.expenseChangePercentage,
                    isIncome: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.md),
          const FfDivider(),
          const SizedBox(height: FfSpace.md),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Net Savings',
                  value: CurrencyFormatter.formatAmount(report.netSavings),
                  color: savingsColor,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: context.ff.color.borderSubtle,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: FfSpace.md),
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
          const SizedBox(height: FfSpace.md),
          const FfDivider(),
          const SizedBox(height: FfSpace.md),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Avg Transaction',
                  value: CurrencyFormatter.formatAmount(
                    report.averageTransactionAmount,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: context.ff.color.borderSubtle,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: FfSpace.md),
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
    final finColors = context.ff.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: context.ff.text.labelSm.copyWith(
                  color: context.ff.color.secondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trendPct != null) ...[
              const SizedBox(width: FfSpace.x3s),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.x2s,
                  vertical: FfSpace.x3s,
                ),
                decoration: BoxDecoration(
                  color:
                      (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                          ? finColors.moneySavings.withValues(
                            alpha: FfTint.subtle.alpha,
                          )
                          : finColors.moneyExpense.withValues(
                            alpha: FfTint.subtle.alpha,
                          ),
                  borderRadius: BorderRadius.circular(FfRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPct! >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 9,
                      color:
                          (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                              ? finColors.moneySavings
                              : finColors.moneyExpense,
                    ),
                    Text(
                      '${trendPct!.abs().toStringAsFixed(0)}%',
                      style: context.ff.text.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            (isIncome ? trendPct! >= 0 : trendPct! <= 0)
                                ? finColors.moneySavings
                                : finColors.moneyExpense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (badgeText != null && trendPct == null) ...[
              const SizedBox(width: FfSpace.x3s),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.x2s,
                  vertical: FfSpace.x3s,
                ),
                decoration: BoxDecoration(
                  color:
                      badgePositive
                          ? finColors.moneySavings.withValues(
                            alpha: FfTint.subtle.alpha,
                          )
                          : finColors.moneyExpense.withValues(
                            alpha: FfTint.subtle.alpha,
                          ),
                  borderRadius: BorderRadius.circular(FfRadius.sm),
                ),
                child: Text(
                  badgeText!,
                  style: context.ff.text.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        badgePositive
                            ? finColors.moneySavings
                            : finColors.moneyExpense,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: FfSpace.x2s),
        Text(
          value,
          style: StillwaterTypography.numMd(
            color: color ?? context.ff.color.textPrimary,
          ),
        ),
      ],
    );
  }
}
