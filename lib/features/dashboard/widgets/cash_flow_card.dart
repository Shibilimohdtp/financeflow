import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/charts/ff_bar_chart.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../dashboard_controller.dart';

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
    final ff = context.ff;
    final c = ff.color;
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
      child: FfCard(
        density: FfDensity.comfortable,
        padding: const EdgeInsets.all(FfSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Section Title and Analytics CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cash Flow', style: ff.text.title),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        displayPeriod,
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onPreviousMonth != null || onNextMonth != null) ...[
                  if (onPreviousMonth != null)
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      tooltip: 'Previous period',
                      visualDensity: VisualDensity.compact,
                      onPressed: onPreviousMonth,
                    ),
                  if (onNextMonth != null)
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      tooltip: 'Next period',
                      visualDensity: VisualDensity.compact,
                      onPressed: onNextMonth,
                    ),
                ],
                if (onOpenAnalytics != null)
                  TextButton(
                    onPressed: onOpenAnalytics,
                    style: TextButton.styleFrom(
                      foregroundColor: c.textSecondary,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.xs,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Analytics',
                          style: ff.text.label.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(width: FfSpace.x3s),
                        const Icon(Icons.arrow_outward_rounded, size: 14),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: FfSpace.md),

            // Net Savings Hero Metric
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Savings',
                  style: ff.text.labelSm.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FfSpace.x3s),
                FfAmountText(
                  amount: cashFlow.netSavings,
                  size: FfAmountSize.lg,
                  style: FfAmountStyle.split,
                  isBlurred: isPrivacyBlur,
                  tone:
                      cashFlow.isPositiveSavings
                          ? FfTone.savings
                          : FfTone.expense,
                  showSign: true,
                ),
              ],
            ),

            if (trendMetric?.hasPreviousData == true && !isPrivacyBlur) ...[
              const SizedBox(height: FfSpace.xs),
              Text(
                trendMetric!.expenseChangePct == 0
                    ? 'Spending unchanged vs previous period'
                    : 'Spending ${trendMetric!.expenseChangePct < 0 ? 'down' : 'up'} ${trendMetric!.expenseChangePct.abs().toStringAsFixed(1)}% vs previous period',
                style: ff.text.bodySm.copyWith(color: c.textSecondary),
              ),
            ],

            const SizedBox(height: FfSpace.md),
            const FfDivider(),
            const SizedBox(height: FfSpace.md),

            // Income and Expense Two-Column Cards
            Row(
              children: [
                // Income Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: c.tint(c.moneyIncome, FfTint.faint),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: c.tint(c.moneyIncome, FfTint.subtle),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                size: 12,
                                color: c.moneyIncome,
                              ),
                            ),
                            const SizedBox(width: FfSpace.xs),
                            Flexible(
                              child: Text(
                                'Income',
                                style: ff.text.labelSm.copyWith(
                                  color: c.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FfSpace.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: FfAmountText(
                            amount: cashFlow.totalIncome,
                            type: TransactionType.income,
                            size: FfAmountSize.md,
                            style: FfAmountStyle.inline,
                            isBlurred: isPrivacyBlur,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: FfSpace.sm),

                // Expense Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: c.tint(c.moneyExpense, FfTint.faint),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: c.tint(c.moneyExpense, FfTint.subtle),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 12,
                                color: c.moneyExpense,
                              ),
                            ),
                            const SizedBox(width: FfSpace.xs),
                            Flexible(
                              child: Text(
                                'Expenses',
                                style: ff.text.labelSm.copyWith(
                                  color: c.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FfSpace.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: FfAmountText(
                            amount: cashFlow.totalExpense,
                            type: TransactionType.expense,
                            size: FfAmountSize.md,
                            style: FfAmountStyle.inline,
                            isBlurred: isPrivacyBlur,
                          ),
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
                    style: ff.text.labelSm.copyWith(color: c.textSecondary),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.moneyExpense,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: FfSpace.x2s),
                          Text(
                            'Expenses',
                            style: ff.text.labelSm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.moneyIncome,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: FfSpace.x2s),
                          Text(
                            'Income',
                            style: ff.text.labelSm.copyWith(
                              color: c.textSecondary,
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
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Text(
                        'No transactions recorded for this period.',
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
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
