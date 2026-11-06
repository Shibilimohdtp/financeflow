import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/charts/ff_bar_chart.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_round_buttons.dart';
import '../../../shared/widgets/ff_skeleton_loader.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../dashboard_controller.dart';

/// Home's cash flow for the shared report period (the [FfPeriodBar] above it is
/// its title): one net figure, income and spending as signed tiles whose icons
/// double as the chart legend, the trend as a chip, and the period's bars.
/// The whole card opens Insights.
class CashFlowCard extends StatelessWidget {
  final MonthlyCashFlow cashFlow;
  final DateTime month;
  final String? periodLabel;
  final bool isPrivacyBlur;
  final VoidCallback? onOpenAnalytics;
  final List<BarChartItem>? chartItems;
  final PeriodComparisonMetric? trendMetric;

  /// Unused: amounts are shown and hidden from the balance hero. Kept until
  /// the dashboard stops passing it (DS-B12 wiring step).
  final VoidCallback? onToggleBlur;

  const CashFlowCard({
    super.key,
    required this.cashFlow,
    required this.month,
    this.periodLabel,
    required this.isPrivacyBlur,
    this.onToggleBlur,
    this.onOpenAnalytics,
    this.chartItems,
    this.trendMetric,
  });

  static bool _active(BarChartItem i) =>
      i.value > 0 || (i.secondaryValue ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final period = periodLabel ?? DateFormatter.formatMonthYear(month);
    final net = cashFlow.netSavings;
    final isNegative = net < 0;
    final hasActivity = cashFlow.totalIncome > 0 || cashFlow.totalExpense > 0;
    // A chart needs at least two points with money in them; one bar says
    // nothing the tiles don't.
    final items = chartItems ?? const <BarChartItem>[];
    final showChart = items.where(_active).length >= 2;
    final trend = trendMetric;
    final showTrend = trend != null && trend.hasPreviousData && !isPrivacyBlur;

    final spoken =
        isPrivacyBlur
            ? 'Cash flow for $period, amounts hidden'
            : 'Cash flow for $period: net '
                '${CurrencyFormatter.format(net, showSign: true)}, income '
                '${CurrencyFormatter.format(cashFlow.totalIncome)}, spending '
                '${CurrencyFormatter.format(cashFlow.totalExpense)}'
                '${showTrend ? '. ${_trendText(trend)}' : ''}';

    return Semantics(
      container: true,
      label: spoken,
      button: onOpenAnalytics != null,
      child: FfCard(
        key: const ValueKey('home-cash-flow'),
        density: FfDensity.comfortable,
        onTap: onOpenAnalytics,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net this period',
                          style: ff.text.label.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        FfAmountText(
                          amount: net,
                          size: FfAmountSize.lg,
                          style: FfAmountStyle.split,
                          isBlurred: isPrivacyBlur,
                          tone: isNegative ? FfTone.expense : FfTone.savings,
                          showSign: true,
                        ),
                      ],
                    ),
                  ),
                  if (onOpenAnalytics != null)
                    FfInkButton.open(
                      small: true,
                      tooltip: 'Open Insights',
                      onPressed: onOpenAnalytics,
                    ),
                ],
              ),
            ),
            if (isNegative && !isPrivacyBlur) ...[
              const SizedBox(height: FfSpace.x2s),
              Text(
                'More went out than came in',
                style: ff.text.bodySm.copyWith(color: c.textSecondary),
              ),
            ],
            if (showTrend) ...[
              const SizedBox(height: FfSpace.xs),
              FfBadge(
                label: _trendText(trend),
                icon:
                    trend.expenseChangePct < 0
                        ? Icons.trending_down_rounded
                        : trend.expenseChangePct > 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_flat_rounded,
                tone:
                    trend.expenseChangePct > 0
                        ? FfTone.warning
                        : trend.expenseChangePct < 0
                        ? FfTone.success
                        : FfTone.neutral,
              ),
            ],
            const SizedBox(height: FfSpace.md),
            ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FfStatTile(
                      label: 'Income',
                      icon: Icons.south_west_rounded,
                      tone: FfTone.income,
                      value: FfAmountText(
                        amount: cashFlow.totalIncome,
                        type: TransactionType.income,
                        size: FfAmountSize.md,
                        style: FfAmountStyle.inline,
                        showSign: true,
                        isBlurred: isPrivacyBlur,
                      ),
                    ),
                  ),
                  const SizedBox(width: FfSpace.md),
                  Expanded(
                    child: FfStatTile(
                      label: 'Spending',
                      icon: Icons.north_east_rounded,
                      tone: FfTone.expense,
                      value: FfAmountText(
                        amount: cashFlow.totalExpense,
                        type: TransactionType.expense,
                        size: FfAmountSize.md,
                        style: FfAmountStyle.inline,
                        showSign: true,
                        isBlurred: isPrivacyBlur,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showChart) ...[
              const SizedBox(height: FfSpace.md),
              // Hidden amounts: the bars' shape stays, their values do not.
              ExcludeSemantics(
                excluding: isPrivacyBlur,
                child: FfBarChart(
                  items: items,
                  height: FfCashFlowCardTokens.chartHeight,
                  primaryLabel: 'Spending',
                  secondaryLabel: 'Income',
                  showSelectionDetails: !isPrivacyBlur,
                  semanticsSummary: 'Income and spending for $period',
                ),
              ),
            ] else if (!hasActivity) ...[
              const SizedBox(height: FfSpace.md),
              Text(
                'No money in or out in this period yet.',
                style: ff.text.bodySm.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _trendText(PeriodComparisonMetric t) =>
      t.expenseChangePct == 0
          ? 'Spending unchanged vs previous period'
          : 'Spending ${t.expenseChangePct < 0 ? 'down' : 'up'} '
              '${t.expenseChangePct.abs().toStringAsFixed(1)}% vs previous period';
}

/// Loading shape of [CashFlowCard]: figure, two tiles and the chart block, so
/// the card does not jump when data arrives.
class CashFlowCardSkeleton extends StatelessWidget {
  const CashFlowCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const FfCard(
      density: FfDensity.comfortable,
      child: FfSkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FfSkeletonBlock(width: FfSpace.x4l * 2, height: FfSpace.sm),
            SizedBox(height: FfSpace.xs),
            FfSkeletonBlock(width: FfSpace.x4l * 3, height: FfSpace.x3l),
            SizedBox(height: FfSpace.md),
            Row(
              children: [
                Expanded(child: FfSkeletonBlock(height: FfSpace.x3l)),
                SizedBox(width: FfSpace.md),
                Expanded(child: FfSkeletonBlock(height: FfSpace.x3l)),
              ],
            ),
            SizedBox(height: FfSpace.md),
            FfSkeletonBlock(height: FfCashFlowCardTokens.chartHeight),
          ],
        ),
      ),
    );
  }
}
