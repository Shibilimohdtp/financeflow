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
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_period_bar.dart';
import '../../shared/widgets/ff_page_header.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../financial_health/financial_health_screen.dart';
import '../settings/settings_controller.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transaction_list_utils.dart';
import 'analytics_controller.dart';
import 'widgets/analytics_cash_flow_card.dart';
import 'widgets/analytics_metrics_hero.dart';
import 'widgets/expense_category_breakdown.dart';

/// "Where did my money go" for the shared report period in Stillwater Bloom (Pattern A).
/// Sits on [FfAurora] with an [AnalyticsMetricsHero] dusk card, interactive cash flow,
/// category donut, ranked payees, and direct drill-downs into Money.
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

  void _openFinancialHealth(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FinancialHealthScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(analyticsReportProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;

    VoidCallback? show(TransactionQuery query) =>
        onShowTransactions == null ? null : () => onShowTransactions!(query);

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: context.ff.color.actionPrimary,
            onRefresh:
                () async => ref.invalidate(analyticsRawTransactionsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FfPageHeader(
                    title: 'Insights',
                    subtitle: 'Trends & cash flow',
                    actions: [
                      FfCircleButton(
                        icon:
                            isPrivacyBlur
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                        tooltip:
                            isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                        soft: true,
                        onPressed: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setPrivacyBlurEnabled(!isPrivacyBlur);
                        },
                      ),
                      FfCircleButton(
                        icon: Icons.health_and_safety_outlined,
                        tooltip: 'Financial health',
                        soft: true,
                        onPressed: () => _openFinancialHealth(context),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    FfSpace.pageMargin,
                    0,
                    FfSpace.pageMargin,
                    FfDock.insetOf(context) + FfSpace.x4l + FfSpace.x3l,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: FfSpace.xs),
                      FfPeriodBar(
                        period: period,
                        onChanged: (p) {
                          if (p != null) {
                            ref.read(reportPeriodProvider.notifier).state = p;
                          }
                        },
                      ),
                      const SizedBox(height: FfSpace.md),
                      reportAsync.when(
                        data:
                            (report) =>
                                report.totalExpense == 0 &&
                                        report.totalIncome == 0
                                    ? const FfCard(
                                      child: FfEmptyState(
                                        icon: Icons.insights_rounded,
                                        title:
                                            'No spending or income in this period',
                                        description:
                                            'Pick another period, or add transactions to see where your money goes.',
                                      ),
                                    )
                                    : _report(
                                      context,
                                      report,
                                      period,
                                      show,
                                      isPrivacyBlur,
                                    ),
                        loading:
                            () => const FfSkeletonLoader(
                              child: Column(
                                children: [
                                  FfSkeletonBlock(
                                    height: 190,
                                    borderRadius: FfRadius.x2l,
                                  ),
                                  SizedBox(height: FfSpace.md),
                                  FfSkeletonBlock(
                                    height: 68,
                                    borderRadius: FfRadius.lg,
                                  ),
                                  SizedBox(height: FfSpace.md),
                                  FfSkeletonBlock(
                                    height: 260,
                                    borderRadius: FfRadius.xl,
                                  ),
                                ],
                              ),
                            ),
                        error:
                            (e, _) => const FfCard(
                              child: FfEmptyState(
                                icon: Icons.error_outline_rounded,
                                title: 'Could not calculate insights',
                                description:
                                    'Pull down to refresh and try again.',
                              ),
                            ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _report(
    BuildContext context,
    AnalyticsReport report,
    Period period,
    VoidCallback? Function(TransactionQuery) show,
    bool isPrivacyBlur,
  ) {
    final categoryRows =
        report.categoryBreakdown
            .where((c) => c.categoryId != 'cat_other_grouped')
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Card: Net savings, Inflow, Outflow, Savings rate (Dusk tone)
        AnalyticsMetricsHero(
          report: report,
          isPrivacyBlur: isPrivacyBlur,
          onOpenHealth: () => _openFinancialHealth(context),
        ),
        const SizedBox(height: FfSpace.md),

        // 2. One Insight Card: Top observation with a CTA into Money
        _buildInsightCard(context, report, show, period),
        const SizedBox(height: FfSpace.xl),

        // 3. Cash flow: Spending & income trend
        const FfSectionHeader(title: 'Spending & income'),
        AnalyticsCashFlowCard(
          points: report.timeSeries,
          range: report.timeRange,
          start: report.startDate,
          end: report.endDate,
          isPrivacyBlur: isPrivacyBlur,
        ),

        // 4. Where it went (Donut + ranked category rows)
        if (report.categoryBreakdown.isNotEmpty) ...[
          const SizedBox(height: FfSpace.xl),
          const FfSectionHeader(title: 'Where your money went'),
          ExpenseCategoryBreakdown(
            categories: report.categoryBreakdown,
            isPrivacyBlur: isPrivacyBlur,
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

        // 5. Where it came from (Income sources)
        if (report.incomeSources.isNotEmpty) ...[
          const SizedBox(height: FfSpace.xl),
          const FfSectionHeader(title: 'Income sources'),
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
                  trailing: FfAmountText(
                    amount: src.amount,
                    size: FfAmountSize.sm,
                    tone: FfTone.income,
                    showSign: true,
                    isBlurred: isPrivacyBlur,
                  ),
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

        // 6. Top Payees
        if (report.topMerchants.isNotEmpty) ...[
          const SizedBox(height: FfSpace.xl),
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
                  trailing: FfAmountText(
                    amount: -merch.totalAmount,
                    size: FfAmountSize.sm,
                    tone: FfTone.expense,
                    isBlurred: isPrivacyBlur,
                  ),
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

        // 7. Largest individual expenses
        if (report.largestTransactions.isNotEmpty) ...[
          const SizedBox(height: FfSpace.xl),
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
                    isBlurred: isPrivacyBlur,
                  ),
                  onTap: () => _openTransactionDetail(context, tx),
                ),
            ],
          ),
        ],

        const SizedBox(height: FfSpace.xl),

        // 8. Privacy Guarantee Note
        FfCard(
          variant: FfCardVariant.tinted,
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.md,
            vertical: FfSpace.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 16,
                color: context.ff.color.statusSuccess,
              ),
              const SizedBox(width: FfSpace.xs),
              Expanded(
                child: Text(
                  'On-device analysis · All calculations run locally on your device.',
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    AnalyticsReport report,
    VoidCallback? Function(TransactionQuery) show,
    Period period,
  ) {
    final ff = context.ff;
    final String observation;
    final VoidCallback? cta;

    if (report.categoryBreakdown.isNotEmpty) {
      final topCat = report.categoryBreakdown.first;
      final share = (topCat.percentage * 100).toStringAsFixed(0);
      observation =
          '${topCat.categoryName} is your largest expense at ${CurrencyFormatter.formatAmount(topCat.amount)} ($share% of spending).';
      cta = show(
        TransactionQuery(
          period: period,
          categoryId: topCat.categoryId,
          kinds: const {TransactionKind.spending},
        ),
      );
    } else if (report.netSavings >= 0) {
      final rate = (report.savingsRate * 100).toStringAsFixed(0);
      observation =
          'Positive net cash flow of ${CurrencyFormatter.formatAmount(report.netSavings)} ($rate% savings rate).';
      cta = show(
        TransactionQuery(
          period: period,
          kinds: const {TransactionKind.spending},
        ),
      );
    } else {
      observation =
          'Spending exceeded income by ${CurrencyFormatter.formatAmount(-report.netSavings)} this period.';
      cta = show(
        TransactionQuery(
          period: period,
          kinds: const {TransactionKind.spending},
        ),
      );
    }

    return FfCard(
      variant: FfCardVariant.tinted,
      density: FfDensity.compact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FfIconTile(
            icon: Icons.lightbulb_outline_rounded,
            tone: FfTone.accent,
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Key insight',
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                  ),
                ),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  observation,
                  style: ff.text.bodySm.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (cta != null) ...[
            const SizedBox(width: FfSpace.xs),
            FfInkButton.open(
              onPressed: cta,
              tooltip: 'Review in Money',
              small: true,
            ),
          ],
        ],
      ),
    );
  }
}
