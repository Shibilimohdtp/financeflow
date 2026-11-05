import 'package:flutter/material.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/charts/ff_bar_chart.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../dashboard_controller.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/ff.dart';

class CashFlowCard extends StatelessWidget {
  final MonthlyCashFlow cashFlow;
  final DateTime month;
  final String? periodLabel;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onPickMonth;
  final VoidCallback? onOpenAnalytics;
  final List<BarChartItem>? chartItems;
  final PeriodComparisonMetric? trendMetric;

  const CashFlowCard({
    super.key,
    required this.cashFlow,
    required this.month,
    this.periodLabel,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onPickMonth,
    this.onOpenAnalytics,
    this.chartItems,
    this.trendMetric,
  });

  @override
  Widget build(BuildContext context) {
    final finColors = context.ff.color;
    final displayPeriod = periodLabel ?? DateFormatter.formatMonthYear(month);

    final hasActivity =
        (chartItems != null &&
            chartItems!.any(
              (i) => i.value > 0 || (i.secondaryValue ?? 0) > 0,
            )) ||
        cashFlow.totalIncome > 0 ||
        cashFlow.totalExpense > 0;

    return Semantics(
      container: true,
      label:
          isPrivacyBlur
              ? 'Monthly cash flow hidden for privacy'
              : 'Cash flow for $displayPeriod: Net savings ${cashFlow.netSavings}, Income ${cashFlow.totalIncome}, Expenses ${cashFlow.totalExpense}',
      child: Container(
        padding: const EdgeInsets.all(FfSpace.lg),
        decoration: BoxDecoration(
          color: context.ff.color.surfaceCard,
          borderRadius: BorderRadius.circular(FfRadius.xl),
          border: Border.all(
            color: context.ff.color.borderSubtle,
            width: FfBorderWidth.hairline,
          ),
          boxShadow: [
            BoxShadow(
              color: context.ff.color.shadow.withValues(
                alpha: FfTint.whisper.alpha,
              ),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Period Title, Date Navigators, and Analytics CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onPickMonth,
                    borderRadius: BorderRadius.circular(FfRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: FfSpace.x3s,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayPeriod,
                              style: context.ff.text.title.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onPickMonth != null) ...[
                            const SizedBox(width: FfSpace.x3s),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: context.ff.color.secondary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onPreviousMonth != null)
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        tooltip: 'Previous period',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onPreviousMonth,
                      ),
                    if (onNextMonth != null)
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        tooltip: 'Next period',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onNextMonth,
                      ),
                    if (onOpenAnalytics != null)
                      TextButton(
                        onPressed: onOpenAnalytics,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Analytics'),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: FfSpace.md),

            // Net Savings Metric
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Savings',
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: FfSpace.x3s),
                FfAmountText(
                  amount: cashFlow.netSavings,
                  size: FfAmountSize.lg,
                  isBlurred: isPrivacyBlur,
                  tone:
                      cashFlow.isPositiveSavings
                          ? FfTone.savings
                          : FfTone.expense,
                  showSign: true,
                ),
              ],
            ),

            const SizedBox(height: FfSpace.md),
            const FfDivider(),
            const SizedBox(height: FfSpace.sm),

            if (trendMetric?.hasPreviousData == true && !isPrivacyBlur) ...[
              Text(
                trendMetric!.expenseChangePct == 0
                    ? 'Spending unchanged vs previous period'
                    : 'Spending ${trendMetric!.expenseChangePct < 0 ? 'down' : 'up'} ${trendMetric!.expenseChangePct.abs().toStringAsFixed(1)}% vs previous period',
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.textSecondary,
                ),
              ),
              const SizedBox(height: FfSpace.sm),
            ],

            // Income and Expense Two-Column Strip
            Row(
              children: [
                // Income Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.sm,
                      vertical: FfSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: finColors.moneyIncome.withValues(
                        alpha: FfTint.faint.alpha,
                      ),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color: finColors.moneyIncome.withValues(
                          alpha: FfTint.subtle.alpha,
                        ),
                        width: FfBorderWidth.hairline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 13,
                              color: finColors.moneyIncome,
                            ),
                            const SizedBox(width: FfSpace.x3s),
                            Flexible(
                              child: Text(
                                'Income',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        FfAmountText(
                          amount: cashFlow.totalIncome,
                          type: TransactionType.income,
                          size: FfAmountSize.md,
                          isBlurred: isPrivacyBlur,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: FfSpace.sm),

                // Expense Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.sm,
                      vertical: FfSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: finColors.moneyExpense.withValues(
                        alpha: FfTint.faint.alpha,
                      ),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color: finColors.moneyExpense.withValues(
                          alpha: FfTint.subtle.alpha,
                        ),
                        width: FfBorderWidth.hairline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 13,
                              color: finColors.moneyExpense,
                            ),
                            const SizedBox(width: FfSpace.x3s),
                            Flexible(
                              child: Text(
                                'Expenses',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        FfAmountText(
                          amount: cashFlow.totalExpense,
                          type: TransactionType.expense,
                          size: FfAmountSize.md,
                          isBlurred: isPrivacyBlur,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Chart Section
            if (chartItems != null &&
                chartItems!.isNotEmpty &&
                hasActivity) ...[
              const SizedBox(height: FfSpace.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity Breakdown',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: finColors.moneyExpense,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: FfSpace.x2s),
                          Text(
                            'Expenses',
                            style: context.ff.text.labelSm.copyWith(
                              color: context.ff.color.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: FfSpace.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: finColors.moneyIncome,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: FfSpace.x2s),
                          Text(
                            'Income',
                            style: context.ff.text.labelSm.copyWith(
                              color: context.ff.color.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.xs),
              FfBarChart(
                items: chartItems!,
                height: 124,
                semanticsSummary: 'Cash flow activity chart for $displayPeriod',
              ),
            ] else if (!hasActivity) ...[
              const SizedBox(height: FfSpace.lg),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 18,
                        color: context.ff.color.secondary.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Text(
                        'No transactions recorded for this period.',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
