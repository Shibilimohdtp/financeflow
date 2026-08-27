import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/transaction.dart';
import '../../services/analytics_calculator.dart';
import '../../shared/widgets/charts/ff_bar_chart.dart';
import '../../shared/widgets/charts/ff_donut_chart.dart';
import '../../shared/widgets/charts/ff_spending_heatmap.dart';
import '../../shared/widgets/charts/ff_trend_line_chart.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../theme/stillwater_tokens.dart';

import '../accounts/accounts_controller.dart';
import '../transactions/transaction_detail_screen.dart';
import 'analytics_controller.dart';
import 'widgets/analytics_insights_card.dart';
import 'widgets/analytics_metrics_hero.dart';
import 'widgets/analytics_period_comparison_card.dart';
import 'widgets/category_transactions_sheet.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  void _openCategoryTransactions(
    BuildContext context, {
    required CategorySpend category,
    required String periodLabel,
    required List<Transaction> transactions,
  }) {
    CategoryTransactionsSheet.show(
      context,
      categoryName: category.categoryName,
      categoryIcon: category.categoryIcon,
      categoryColor: category.categoryColor,
      totalAmount: category.amount,
      periodLabel: periodLabel,
      transactions: transactions,
    );
  }

  void _openTransactionDetail(BuildContext context, Transaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final selectedRange = ref.watch(selectedAnalyticsTimeRangeProvider);
    final selectedAccountId = ref.watch(selectedAnalyticsAccountIdProvider);
    final selectedTxType = ref.watch(selectedAnalyticsTypeProvider);
    final accountsAsync = ref.watch(rawAccountsStreamProvider);
    final reportAsync = ref.watch(analyticsReportProvider);

    final accounts = accountsAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Trends'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(analyticsRawTransactionsProvider);
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

            const SizedBox(height: StillwaterTokens.spaceSm),

            // ── Account & Type Filter Chips ───────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      selectedAccountId == null
                          ? 'All Accounts'
                          : accounts
                              .firstWhere(
                                (a) => a.id == selectedAccountId,
                                orElse: () => accounts.first,
                              )
                              .name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selectedAccountId != null,
                    onSelected: (selected) {
                      if (selectedAccountId != null) {
                        ref
                            .read(selectedAnalyticsAccountIdProvider.notifier)
                            .state = null;
                      } else if (accounts.isNotEmpty) {
                        _showAccountPicker(
                          context,
                          ref,
                          accounts,
                          selectedAccountId,
                        );
                      }
                    },
                    avatar:
                        selectedAccountId == null
                            ? const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 16,
                            )
                            : const Icon(Icons.check, size: 16),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  FilterChip(
                    label: Text(
                      selectedTxType == null
                          ? 'All Types'
                          : (selectedTxType == TransactionType.expense
                              ? 'Expenses only'
                              : 'Income only'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selectedTxType != null,
                    onSelected: (_) {
                      if (selectedTxType == null) {
                        ref.read(selectedAnalyticsTypeProvider.notifier).state =
                            TransactionType.expense;
                      } else if (selectedTxType == TransactionType.expense) {
                        ref.read(selectedAnalyticsTypeProvider.notifier).state =
                            TransactionType.income;
                      } else {
                        ref.read(selectedAnalyticsTypeProvider.notifier).state =
                            null;
                      }
                    },
                  ),
                ],
              ),
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
                    AnalyticsMetricsHero(report: report),

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 2. Cash Flow Activity Bar Chart ───────────────────────
                    const FfSectionHeader(title: 'Cash Flow Comparison'),
                    FfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _LegendPill(
                                label: 'Expenses',
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

                    // ── 3. Category Breakdown & Interactive Drill-down ────────
                    const FfSectionHeader(title: 'Expense Category Breakdown'),
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
                                  final txsForCat =
                                      report.categoryTransactions[cat
                                          .categoryId] ??
                                      [];
                                  return InkWell(
                                    onTap:
                                        () => _openCategoryTransactions(
                                          context,
                                          category: cat,
                                          periodLabel:
                                              selectedRange.displayName,
                                          transactions: txsForCat,
                                        ),
                                    child: FfListRow(
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
                                      showChevron: true,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // ── 4. Income Sources Breakdown (if any) ──────────────────
                    if (report.incomeSources.isNotEmpty) ...[
                      const SizedBox(height: StillwaterTokens.space2Xl),
                      const FfSectionHeader(title: 'Income Sources'),
                      FfGroupedContainer(
                        children:
                            report.incomeSources.map((src) {
                              return FfListRow(
                                leading: FfCategoryTile(
                                  iconIdentifier: src.categoryIcon,
                                  colorTokenIdentifier: src.categoryColor,
                                  size: 36,
                                ),
                                title: src.categoryName,
                                subtitle:
                                    '${src.transactionCount} deposits · ${(src.percentage * 100).toStringAsFixed(1)}%',
                                trailingText: CurrencyFormatter.formatINR(
                                  src.amount,
                                ),
                                showChevron: false,
                              );
                            }).toList(),
                      ),
                    ],

                    const SizedBox(height: StillwaterTokens.space2Xl),

                    // ── 5. Account & Payment Sources Analysis ─────────────────
                    if (report.accountBreakdown.isNotEmpty) ...[
                      const FfSectionHeader(title: 'Account & Source Activity'),
                      FfGroupedContainer(
                        children:
                            report.accountBreakdown.map((acc) {
                              final accountObj =
                                  accounts
                                      .where((a) => a.id == acc.accountId)
                                      .firstOrNull;
                              final accountName = accountObj?.name ?? 'Account';
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
                                  child: Icon(
                                    Icons.account_balance_outlined,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: accountName,
                                subtitle:
                                    '${acc.transactionCount} transactions · ${CurrencyFormatter.formatINR(acc.totalIncome)} in',
                                trailingText: CurrencyFormatter.formatINR(
                                  acc.totalExpense,
                                ),
                                showChevron: false,
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xl),
                    ],

                    // ── 6. Spending Pace Trend Line Chart ─────────────────────
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

                    // ── 7. Day-of-Week Spending Heatmap ───────────────────────
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

                    // ── 8. Largest Transactions ───────────────────────────────
                    if (report.largestTransactions.isNotEmpty) ...[
                      const SizedBox(height: StillwaterTokens.space2Xl),
                      const FfSectionHeader(
                        title: 'Largest Expenses in Period',
                      ),
                      FfGroupedContainer(
                        children:
                            report.largestTransactions.map((tx) {
                              return InkWell(
                                onTap:
                                    () => _openTransactionDetail(context, tx),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: StillwaterTokens.spaceMd,
                                    vertical: StillwaterTokens.spaceSm,
                                  ),
                                  child: Row(
                                    children: [
                                      FfCategoryTile(
                                        iconIdentifier: tx.categoryIcon,
                                        colorTokenIdentifier: tx.categoryColor,
                                        size: 36,
                                      ),
                                      const SizedBox(
                                        width: StillwaterTokens.spaceSm,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tx.merchant,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              height: StillwaterTokens.space3Xs,
                                            ),
                                            Text(
                                              DateFormatter.formatTransactionDate(
                                                tx.date,
                                              ),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontSize: 11,
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .secondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: StillwaterTokens.spaceSm,
                                      ),
                                      FfAmountText(
                                        amount: tx.amount,
                                        type: tx.type,
                                        size: FfAmountSize.md,
                                        showSign: true,
                                      ),
                                      const SizedBox(
                                        width: StillwaterTokens.space2Xs,
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: theme.colorScheme.outline,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    // ── 9. Top Payees & Merchants List ────────────────────────
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

                    // ── 10. Period Comparison card ─────────────────────────────
                    if (report.expenseChangePercentage != null ||
                        report.incomeChangePercentage != null) ...[
                      const SizedBox(height: StillwaterTokens.space2Xl),
                      const FfSectionHeader(title: 'Period Comparison'),
                      AnalyticsPeriodComparisonCard(report: report),
                    ],

                    // ── 11. Data-driven Insights ──────────────────────────────
                    const SizedBox(height: StillwaterTokens.space2Xl),
                    AnalyticsInsightsCard(report: report),

                    const SizedBox(height: StillwaterTokens.space4Xl),
                  ],
                );
              },
              loading:
                  () => Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceLg,
                    ),
                    child: Column(
                      children: const [
                        FfMetricSkeletonCard(),
                        SizedBox(height: StillwaterTokens.spaceLg),
                        FfMetricSkeletonCard(),
                      ],
                    ),
                  ),
              error:
                  (e, _) => FfCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceSm),
                        Text(
                          'Could not calculate analytics',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: StillwaterTokens.spaceXs),
                        Text(
                          'Pull down to refresh and try again.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> accounts,
    String? selectedAccountId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: StillwaterTokens.spaceMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('All Accounts'),
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    selected: selectedAccountId == null,
                    onTap: () {
                      ref
                          .read(selectedAnalyticsAccountIdProvider.notifier)
                          .state = null;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const Divider(),
                  ...accounts.map(
                    (a) => ListTile(
                      title: Text(a.name as String),
                      leading: const Icon(Icons.account_balance_outlined),
                      selected: selectedAccountId == a.id,
                      onTap: () {
                        ref
                            .read(selectedAnalyticsAccountIdProvider.notifier)
                            .state = a.id as String;
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
