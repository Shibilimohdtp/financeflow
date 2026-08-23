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
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
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
          padding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceMd,
            StillwaterTokens.spaceLg,
            StillwaterTokens.space4Xl,
          ),
          children: [
            // ── 1. Time-Range Selector Pills ──────────────────────────
            FfSegmentedPill<AnalyticsTimeRange>(
              options: const [
                FfSegmentOption(value: AnalyticsTimeRange.week, label: 'Week'),
                FfSegmentOption(
                  value: AnalyticsTimeRange.month,
                  label: 'Month',
                ),
                FfSegmentOption(value: AnalyticsTimeRange.year, label: 'Year'),
                FfSegmentOption(
                  value: AnalyticsTimeRange.custom,
                  label: 'Custom',
                ),
              ],
              selectedValue: selectedRange,
              onSelected: (chosen) async {
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
                        title: 'No transactions in this period',
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
                    // ── 1. Summary Metrics Hero Card ─────────────────────────
                    FfCard(
                      variant: FfCardVariant.elevated,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MetricBlock(
                                  label: 'Total Inflow',
                                  value: CurrencyFormatter.formatINR(
                                    report.totalIncome,
                                  ),
                                  color: finColors.income,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.dividerColor,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: StillwaterTokens.spaceMd,
                                  ),
                                  child: _MetricBlock(
                                    label: 'Total Outflow',
                                    value: CurrencyFormatter.formatINR(
                                      report.totalExpense,
                                    ),
                                    color: finColors.expense,
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
                                  value: CurrencyFormatter.formatINR(
                                    report.netSavings,
                                  ),
                                  color:
                                      report.netSavings >= 0
                                          ? finColors.income
                                          : finColors.expense,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.dividerColor,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: StillwaterTokens.spaceMd,
                                  ),
                                  child: _MetricBlock(
                                    label: 'Savings Rate',
                                    value:
                                        '${(report.savingsRate * 100).toStringAsFixed(0)}%',
                                    color: theme.colorScheme.primary,
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
                              Container(
                                width: 1,
                                height: 40,
                                color: theme.dividerColor,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: StillwaterTokens.spaceMd,
                                  ),
                                  child: _MetricBlock(
                                    label: 'Transaction Count',
                                    value: '${report.transactionCount}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 2. Cash Flow Activity Bar Chart ───────────────────────
                    const FfSectionHeader(title: 'Cash Flow Activity'),
                    FfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _LegendPill(
                                label: 'Expense',
                                color: finColors.expense,
                              ),
                              const SizedBox(width: StillwaterTokens.spaceMd),
                              _LegendPill(
                                label: 'Income',
                                color: finColors.income,
                              ),
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

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 3. Category Breakdown ─────────────────────────────────
                    const FfSectionHeader(title: 'Category Breakdown'),
                    FfCard(
                      child: Column(
                        children: [
                          FfDonutChart(
                            slices: donutSlices,
                            centerLabel: 'Expenses',
                            size: 190,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceLg),
                          FfGroupedContainer(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerLow,
                            children:
                                report.categoryBreakdown.map((cat) {
                                  return FfListRow(
                                    leading: FfCategoryTile(
                                      iconIdentifier: cat.categoryIcon,
                                      colorTokenIdentifier: cat.categoryColor,
                                      size: 36,
                                    ),
                                    title: cat.categoryName,
                                    subtitle:
                                        '${cat.transactionCount} payments · ${(cat.percentage * 100).toStringAsFixed(1)}%',
                                    trailingText: CurrencyFormatter.formatINR(
                                      cat.amount,
                                    ),
                                    showChevron: false,
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 4. Spending Pace Trend Line Chart ─────────────────────
                    const FfSectionHeader(title: 'Spending Pace Over Time'),
                    FfCard(
                      child: FfTrendLineChart(
                        points: trendPoints,
                        height: 160,
                        lineColor: finColors.expense,
                        semanticsSummary: 'Daily spending pace line chart.',
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 5. Day-of-Week Spending Heatmap ───────────────────────
                    const FfSectionHeader(
                      title: 'Weekday Spending Distribution',
                    ),
                    FfCard(
                      child: FfSpendingHeatmap(
                        days: report.dayOfWeekBreakdown,
                        semanticsSummary:
                            'Spending intensity across days of week.',
                      ),
                    ),

                    // ── 6. Top Merchants List ─────────────────────────────────
                    if (report.topMerchants.isNotEmpty) ...[
                      const SizedBox(height: StillwaterTokens.space2Xl),
                      const FfSectionHeader(title: 'Top Payees & Merchants'),
                      FfGroupedContainer(
                        children:
                            report.topMerchants.map((merch) {
                              return FfListRow(
                                leading: Container(
                                  width: StillwaterTokens.iconTileSize,
                                  height: StillwaterTokens.iconTileSize,
                                  decoration: BoxDecoration(
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusSm,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.storefront_outlined,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                title: merch.normalizedMerchant,
                                subtitle:
                                    '${merch.transactionCount} transactions',
                                trailingText: CurrencyFormatter.formatINR(
                                  merch.totalAmount,
                                ),
                                showChevron: false,
                              );
                            }).toList(),
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

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricBlock({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
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

class _LegendPill extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: StillwaterTokens.spaceXs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
