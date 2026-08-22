import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../services/analytics_calculator.dart';
import '../../shared/widgets/charts/ff_bar_chart.dart';
import '../../shared/widgets/charts/ff_donut_chart.dart';
import '../../shared/widgets/charts/ff_spending_heatmap.dart';
import '../../shared/widgets/charts/ff_trend_line_chart.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../transactions/transactions_controller.dart';
import 'analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final selectedRange = ref.watch(selectedAnalyticsTimeRangeProvider);
    final reportAsync = ref.watch(analyticsReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Trends'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(filteredTransactionsProvider);
          ref.invalidate(analyticsReportProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceLg,
            vertical: StillwaterTokens.spaceMd,
          ),
          children: [
            // 1. Time-Range Selector Chips
            SegmentedButton<AnalyticsTimeRange>(
              segments: const [
                ButtonSegment(
                  value: AnalyticsTimeRange.week,
                  label: Text('Week'),
                ),
                ButtonSegment(
                  value: AnalyticsTimeRange.month,
                  label: Text('Month'),
                ),
                ButtonSegment(
                  value: AnalyticsTimeRange.year,
                  label: Text('Year'),
                ),
                ButtonSegment(
                  value: AnalyticsTimeRange.custom,
                  label: Text('Custom'),
                ),
              ],
              selected: {selectedRange},
              onSelectionChanged: (set) async {
                final chosen = set.first;
                if (chosen == AnalyticsTimeRange.custom) {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDateRange: DateTimeRange(
                      start: DateTime(now.year, now.month, 1),
                      end: now,
                    ),
                  );
                  if (picked != null) {
                    ref
                        .read(analyticsCustomDateRangeProvider.notifier)
                        .state = (start: picked.start, end: picked.end);
                    ref
                        .read(selectedAnalyticsTimeRangeProvider.notifier)
                        .state = chosen;
                  }
                } else {
                  ref.read(selectedAnalyticsTimeRangeProvider.notifier).state =
                      chosen;
                }
              },
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            reportAsync.when(
              data: (report) {
                if (report.transactionCount == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceXl,
                    ),
                    child: FfCard(
                      child: FfEmptyState(
                        icon: Icons.insights_rounded,
                        title: 'No transaction data for this period',
                        description:
                            'Add expenses or switch time ranges to see category breakdowns and spending trends.',
                      ),
                    ),
                  );
                }

                // Prepare Bar Chart items (Income vs Expense)
                final barItems =
                    report.timeSeries.map((p) {
                      return BarChartItem(
                        label: p.label,
                        value: p.expense,
                        secondaryValue: p.income > 0 ? p.income : null,
                        color: finColors.expense,
                        secondaryColor: finColors.income,
                      );
                    }).toList();

                // Prepare Donut Chart slices
                final donutSlices =
                    report.categoryBreakdown.map((c) {
                      return DonutSlice(
                        label: c.categoryName,
                        value: c.amount,
                        colorToken: c.categoryColor,
                      );
                    }).toList();

                // Prepare Trend Points
                final trendPoints =
                    report.timeSeries.map((p) {
                      return TrendPoint(
                        label: p.label,
                        value: p.expense,
                        date: p.date,
                      );
                    }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Metrics Card
                    FfCard(
                      variant: FfCardVariant.elevated,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MetricItem(
                                label: 'Total Inflow',
                                value: CurrencyFormatter.format(
                                  report.totalIncome,
                                ),
                                color: finColors.income,
                              ),
                              _MetricItem(
                                label: 'Total Outflow',
                                value: CurrencyFormatter.format(
                                  report.totalExpense,
                                ),
                                color: finColors.expense,
                              ),
                            ],
                          ),
                          const Divider(height: StillwaterTokens.spaceXl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MetricItem(
                                label: 'Net Savings',
                                value: CurrencyFormatter.format(
                                  report.netSavings,
                                ),
                                color:
                                    report.netSavings >= 0
                                        ? finColors.income
                                        : finColors.expense,
                              ),
                              _MetricItem(
                                label: 'Savings Rate',
                                value:
                                    '${(report.savingsRate * 100).toStringAsFixed(0)}%',
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                          const Divider(height: StillwaterTokens.spaceXl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MetricItem(
                                label: 'Avg Transaction',
                                value: CurrencyFormatter.format(
                                  report.averageTransactionAmount,
                                ),
                              ),
                              _MetricItem(
                                label: 'Total Transactions',
                                value: '${report.transactionCount}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 1. Spending & Income Trend Bar Chart
                    Text(
                      'Cash Flow Activity',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    FfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: finColors.expense,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.space2Xs),
                              Text('Expense', style: theme.textTheme.bodySmall),
                              const SizedBox(width: StillwaterTokens.spaceMd),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: finColors.income,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.space2Xs),
                              Text('Income', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: StillwaterTokens.spaceMd),
                          FfBarChart(
                            items: barItems,
                            height: 180,
                            semanticsSummary:
                                'Cash flow activity chart for selected period.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 2. Category Breakdown Donut Chart & List
                    Text(
                      'Category Breakdown',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    FfCard(
                      child: Column(
                        children: [
                          FfDonutChart(
                            slices: donutSlices,
                            centerLabel: 'Expenses',
                            size: 190,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceLg),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: report.categoryBreakdown.length,
                            separatorBuilder: (ctx, i) => const Divider(),
                            itemBuilder: (ctx, i) {
                              final cat = report.categoryBreakdown[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: FfCategoryTile(
                                  iconIdentifier: cat.categoryIcon,
                                  colorTokenIdentifier: cat.categoryColor,
                                ),
                                title: Text(
                                  cat.categoryName,
                                  style: theme.textTheme.titleSmall,
                                ),
                                subtitle: Text(
                                  '${cat.transactionCount} payments',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(cat.amount),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${(cat.percentage * 100).toStringAsFixed(1)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 3. Spending Pace Trend Line Chart
                    Text('Spending Pace', style: theme.textTheme.titleMedium),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    FfCard(
                      child: FfTrendLineChart(
                        points: trendPoints,
                        height: 160,
                        lineColor: finColors.expense,
                        semanticsSummary: 'Daily spending pace line chart.',
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 4. Day-of-Week Spending Heatmap
                    Text(
                      'Weekday Spending Distribution',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    FfCard(
                      child: FfSpendingHeatmap(
                        days: report.dayOfWeekBreakdown,
                        semanticsSummary:
                            'Spending intensity across days of week.',
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceXl),

                    // 5. Top Merchants List
                    if (report.topMerchants.isNotEmpty) ...[
                      Text(
                        'Top Payees & Merchants',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      FfCard(
                        padding: EdgeInsets.zero,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.topMerchants.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (ctx, i) {
                            final merch = report.topMerchants[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceMd,
                                vertical: StillwaterTokens.space2Xs,
                              ),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                merch.normalizedMerchant,
                                style: theme.textTheme.titleSmall,
                              ),
                              subtitle: Text(
                                '${merch.transactionCount} transactions',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Text(
                                CurrencyFormatter.format(merch.totalAmount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.space4Xl),
                  ],
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (e, _) =>
                      Center(child: Text('Could not calculate analytics: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: StillwaterTokens.space3Xs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
