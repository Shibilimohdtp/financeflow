import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../core/period/period.dart';
import '../../core/period/report_period_provider.dart';
import '../../models/transaction.dart';
import '../../services/analytics_calculator.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_period_bar.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transaction_list_utils.dart';
import 'analytics_controller.dart';
import 'widgets/analytics_cash_flow_card.dart';
import 'widgets/analytics_metrics_hero.dart';
import 'widgets/expense_category_breakdown.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_row.dart';
import '../../theme/ff_tone.dart';
import '../../theme/ff.dart';

/// "Where did my money go" for the shared report period. Every category and
/// payee opens the Money tab filtered to exactly the transactions behind it.
class AnalyticsScreen extends ConsumerWidget {
  /// Opens the transaction list with a query; supplied by the app shell.
  final ValueChanged<TransactionQuery>? onShowTransactions;

  const AnalyticsScreen({super.key, this.onShowTransactions});

  void _openTransactionDetail(BuildContext context, Transaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(analyticsReportProvider);

    VoidCallback? show(TransactionQuery query) =>
        onShowTransactions == null ? null : () => onShowTransactions!(query);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Insights',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.lg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: context.ff.color.actionPrimary,
        onRefresh: () async => ref.invalidate(analyticsRawTransactionsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            FfSpace.lg,
            FfSpace.xs,
            FfSpace.lg,
            FfSpace.x4l,
          ),
          children: [
            FfPeriodBar(
              period: period,
              onChanged: (p) {
                if (p != null) {
                  ref.read(reportPeriodProvider.notifier).state = p;
                }
              },
            ),
            const SizedBox(height: FfSpace.sm),
            reportAsync.when(
              data:
                  (report) =>
                      report.totalExpense == 0 && report.totalIncome == 0
                          ? const FfCard(
                            child: FfEmptyState(
                              icon: Icons.insights_rounded,
                              title: 'No spending or income in this period',
                              description:
                                  'Pick another period, or add transactions to see where your money goes.',
                            ),
                          )
                          : _report(context, report, period, show),
              loading:
                  () => const Column(
                    children: [
                      FfMetricSkeletonCard(),
                      SizedBox(height: FfSpace.lg),
                      FfMetricSkeletonCard(),
                    ],
                  ),
              error:
                  (e, _) => const FfCard(
                    child: FfEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not calculate insights',
                      description: 'Pull down to refresh and try again.',
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _report(
    BuildContext context,
    AnalyticsReport report,
    Period period,
    VoidCallback? Function(TransactionQuery) show,
  ) {
    final categoryRows =
        report.categoryBreakdown
            .where((c) => c.categoryId != 'cat_other_grouped')
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. How much came in and went out, vs the same point last period.
        AnalyticsMetricsHero(report: report),
        const SizedBox(height: FfSpace.x2l),

        // 2. Trend through the period.
        const FfSectionHeader(title: 'Spending & income'),
        AnalyticsCashFlowCard(
          points: report.timeSeries,
          range: report.timeRange,
          start: report.startDate,
          end: report.endDate,
        ),

        // 3. Where it went.
        if (report.categoryBreakdown.isNotEmpty) ...[
          const SizedBox(height: FfSpace.x2l),
          const FfSectionHeader(title: 'Where your money went'),
          ExpenseCategoryBreakdown(
            categories: report.categoryBreakdown,
            onOpenCategory: (category) {
              final open =
                  category.categoryId == 'cat_other_grouped'
                      ? show(
                        TransactionQuery(
                          period: period,
                          kinds: const {TransactionKind.spending},
                        ),
                      )
                      : show(
                        TransactionQuery(
                          period: period,
                          categoryId: category.categoryId,
                          kinds: const {TransactionKind.spending},
                        ),
                      );
              open?.call();
            },
          ),
          if (categoryRows.length < report.categoryBreakdown.length)
            Padding(
              padding: const EdgeInsets.only(top: FfSpace.xs),
              child: Text(
                'Smaller categories are grouped as “Other”.',
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.textSecondary,
                ),
              ),
            ),
        ],

        // 4. Where it came from.
        if (report.incomeSources.isNotEmpty) ...[
          const SizedBox(height: FfSpace.x2l),
          const FfSectionHeader(title: 'Income'),
          FfGroupedContainer(
            children: [
              for (final src in report.incomeSources)
                FfRow(
                  leading: FfCategoryTile(
                    iconIdentifier: src.categoryIcon,
                    colorTokenIdentifier: src.categoryColor,
                    size: 36,
                  ),
                  title: src.categoryName,
                  subtitle:
                      '${src.transactionCount} · ${(src.percentage * 100).toStringAsFixed(0)}%',
                  detail: CurrencyFormatter.formatAmount(src.amount),
                  onTap: show(
                    TransactionQuery(
                      period: period,
                      categoryId: src.categoryId,
                      kinds: const {TransactionKind.income},
                    ),
                  ),
                  showChevron: onShowTransactions != null,
                ),
            ],
          ),
        ],

        // 5. Who it went to.
        if (report.topMerchants.isNotEmpty) ...[
          const SizedBox(height: FfSpace.x2l),
          const FfSectionHeader(title: 'Top payees'),
          FfGroupedContainer(
            children: [
              for (final merch in report.topMerchants.take(5))
                FfRow(
                  icon: Icons.storefront_outlined,
                  iconTone: FfTone.primary,
                  title: merch.normalizedMerchant,
                  subtitle:
                      merch.transactionCount == 1
                          ? '1 transaction'
                          : '${merch.transactionCount} transactions',
                  detail: CurrencyFormatter.formatAmount(merch.totalAmount),
                  onTap: show(
                    TransactionQuery(
                      period: period,
                      search: merch.normalizedMerchant,
                      kinds: const {TransactionKind.spending},
                    ),
                  ),
                  showChevron: onShowTransactions != null,
                ),
            ],
          ),
        ],

        // 6. The biggest single items.
        if (report.largestTransactions.isNotEmpty) ...[
          const SizedBox(height: FfSpace.x2l),
          const FfSectionHeader(title: 'Largest expenses'),
          FfGroupedContainer(
            children: [
              for (final tx in report.largestTransactions)
                FfRow(
                  leading: FfCategoryTile(
                    iconIdentifier: tx.categoryIcon,
                    colorTokenIdentifier: tx.categoryColor,
                    size: 36,
                  ),
                  title: tx.merchant,
                  subtitle: DateFormatter.formatTransactionDate(tx.date),
                  trailing: FfAmountText(
                    amount: -tx.consumptionExpenseAmount,
                    size: FfAmountSize.sm,
                    tone: FfTone.expense,
                  ),
                  onTap: () => _openTransactionDetail(context, tx),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
