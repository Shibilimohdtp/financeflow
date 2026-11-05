import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/loan.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../alerts/alerts_inbox_screen.dart';
import '../budgets/budgets_controller.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../loans/loan_detail_screen.dart';
import '../loans/loans_screen.dart';
import '../savings_goals/savings_goals_controller.dart';
import '../settings/settings_controller.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../transactions/add_edit_transaction_screen.dart';
import 'dashboard_controller.dart';
import 'insights_controller.dart';
import 'widgets/account_summary_strip.dart';
import 'widgets/actionable_items_section.dart';
import 'widgets/budget_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_loans_overview.dart';
import 'widgets/home_period_selector.dart';
import 'widgets/home_quick_actions.dart';
import 'widgets/home_recent_transactions.dart';
import 'widgets/local_insights_card.dart';
import 'widgets/savings_goals_overview_card.dart';
import 'widgets/top_categories_card.dart';
import 'widgets/total_balance_hero.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onViewAllTransactions;
  final VoidCallback onManageAccounts;
  final VoidCallback onAddAccount;
  final VoidCallback? onOpenBudgets;
  final VoidCallback? onOpenSavingsGoals;
  final VoidCallback? onOpenAnalytics;
  final ValueChanged<Transaction> onOpenTransactionDetail;
  final VoidCallback? onOpenLoans;
  final VoidCallback? onOpenSubscriptions;
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.onAddTransaction,
    required this.onViewAllTransactions,
    required this.onManageAccounts,
    required this.onAddAccount,
    this.onOpenBudgets,
    this.onOpenSavingsGoals,
    this.onOpenAnalytics,
    required this.onOpenTransactionDetail,
    this.onOpenLoans,
    this.onOpenSubscriptions,
    this.onOpenAlerts,
    this.onOpenSettings,
  });

  void _openTransfer(BuildContext context) {
    AddEditTransactionScreen.push(context);
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;
    final pendingCount = ref.watch(pendingReviewCountProvider);
    final unreadAlerts = ref.watch(unreadAlertsCountProvider);

    // Reactive Providers
    final totalBalanceAsync = ref.watch(totalNetWorthProvider);
    final accountsAsync = ref.watch(accountsWithBalancesProvider);
    final cashFlowAsync = ref.watch(monthlyCashFlowProvider);
    final cashFlowChartAsync = ref.watch(dashboardCashFlowChartProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final selectedPeriod = ref.watch(selectedDashboardPeriodProvider);
    final trendMetric = ref.watch(periodComparisonProvider);
    final topCategoriesAsync = ref.watch(topSpendingCategoriesProvider);
    final overallBudgetAsync = ref.watch(overallBudgetSummaryProvider);
    final activeBudgetsAsync = ref.watch(budgetSummariesProvider);
    final overallGoalAsync = ref.watch(overallSavingsGoalSummaryProvider);
    final insightsAsync = ref.watch(dashboardInsightsProvider);

    // Loans & Subscriptions Data
    final allLoans = ref.watch(allLoansStreamProvider).valueOrNull ?? const [];
    final activeLoans =
        allLoans.where((l) => l.status == LoanStatus.active).toList();
    final totalOutstanding = activeLoans.fold<double>(
      0.0,
      (s, l) => s + l.outstandingPrincipal,
    );
    final totalMonthlyEmi = activeLoans.fold<double>(
      0.0,
      (s, l) => s + l.emiAmount,
    );
    final upcomingLoans =
        activeLoans
            .where((l) => l.isDueSoon(daysThreshold: 7) || l.daysUntilDue() < 0)
            .toList()
          ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    final allSubscriptions =
        ref.watch(allSubscriptionsStreamProvider).valueOrNull ?? const [];
    final activeSubscriptions =
        allSubscriptions
            .where((s) => s.status == SubscriptionStatus.active)
            .toList();
    final upcomingRenewals =
        activeSubscriptions.where((s) => s.isDueSoon(daysThreshold: 7)).toList()
          ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));

    final activeAlerts =
        ref.watch(activeAlertsStreamProvider).valueOrNull ?? const [];

    final accounts = accountsAsync.valueOrNull ?? const [];
    final activeAccountsCount = accounts.where((a) => !a.isArchived).length;
    final totalBalance = totalBalanceAsync.valueOrNull ?? 0.0;
    final overBudgetCount =
        overallBudgetAsync.valueOrNull?.overBudgetCount ?? 0;
    final activeBudgetsList = activeBudgetsAsync.valueOrNull;

    return Scaffold(
      appBar: HomeHeader(
        unreadAlerts: unreadAlerts,
        onOpenAlerts:
            onOpenAlerts ?? () => _push(context, const AlertsInboxScreen()),
        onOpenSettings: onOpenSettings,
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(dashboardTransactionsProvider);
          ref.invalidate(dashboardPreviousTransactionsProvider);
          ref.invalidate(monthTransactionsProvider);
          ref.invalidate(monthlyCashFlowProvider);
          ref.invalidate(previousPeriodCashFlowProvider);
          ref.invalidate(dashboardCashFlowChartProvider);
          ref.invalidate(accountsWithBalancesProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(topSpendingCategoriesProvider);
          ref.invalidate(overallBudgetSummaryProvider);
          ref.invalidate(budgetSummariesProvider);
          ref.invalidate(overallSavingsGoalSummaryProvider);
          ref.invalidate(dashboardInsightsProvider);
          ref.invalidate(allLoansStreamProvider);
          ref.invalidate(allSubscriptionsStreamProvider);
          ref.invalidate(activeAlertsStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: StillwaterTokens.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Main Balance Hero Card (Primary Command Anchor)
              TotalBalanceHero(
                totalBalance: totalBalance,
                activeAccountsCount: activeAccountsCount,
                isPrivacyBlur: isPrivacyBlur,
                onToggleBlur: () {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPrivacyBlurEnabled(!isPrivacyBlur);
                },
                onManageAccounts: onManageAccounts,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 2. Period Selector (This Week, This Month, Last Month, This Year, Custom)
              HomePeriodSelector(
                selectedPeriod: selectedPeriod,
                onSelected: (chosen) async {
                  if (chosen == DashboardPeriod.custom) {
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
                      ref.read(dashboardCustomRangeProvider.notifier).state = (
                        start: picked.start,
                        end: picked.end,
                      );
                      ref.read(selectedDashboardPeriodProvider.notifier).state =
                          chosen;
                    }
                  } else {
                    ref.read(selectedDashboardPeriodProvider.notifier).state =
                        chosen;
                  }
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 3. Quick Actions Widget
              HomeQuickActions(
                onAddTransaction: onAddTransaction,
                onTransfer: () => _openTransfer(context),
                onManageAccounts: onManageAccounts,
                onOpenBudgets: onOpenBudgets,
                onOpenLoans:
                    onOpenLoans ?? () => _push(context, const LoansScreen()),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 4. Actionable & Upcoming Items
              ActionableItemsSection(
                pendingReviewCount: pendingCount,
                upcomingLoans: upcomingLoans,
                upcomingSubscriptions: upcomingRenewals,
                overBudgetCount: overBudgetCount,
                activeAlerts: activeAlerts,
                isPrivacyBlur: isPrivacyBlur,
                onOpenNeedsReview:
                    () => _push(context, const NeedsReviewScreen()),
                onOpenLoanDetail: (loan) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoanDetailScreen(loan: loan),
                    ),
                  );
                },
                onOpenLoans:
                    onOpenLoans ?? () => _push(context, const LoansScreen()),
                onOpenSubscriptions:
                    onOpenSubscriptions ??
                    () => _push(context, const SubscriptionsScreen()),
                onOpenBudgets: onOpenBudgets ?? () {},
                onOpenAlerts:
                    onOpenAlerts ??
                    () => _push(context, const AlertsInboxScreen()),
              ),

              if (pendingCount > 0 ||
                  upcomingLoans.isNotEmpty ||
                  upcomingRenewals.isNotEmpty ||
                  overBudgetCount > 0)
                const SizedBox(height: StillwaterTokens.spaceLg),

              // 5. Cash Flow & Visualization Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: cashFlowAsync.when(
                  data:
                      (cashFlow) => CashFlowCard(
                        cashFlow: cashFlow,
                        trendMetric: trendMetric,
                        month: selectedMonth,
                        periodLabel: selectedPeriod.label,
                        chartItems: cashFlowChartAsync.valueOrNull,
                        isPrivacyBlur: isPrivacyBlur,
                        onToggleBlur: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setPrivacyBlurEnabled(!isPrivacyBlur);
                        },
                        onPreviousMonth: () {
                          final prev = DateTime(
                            selectedMonth.year,
                            selectedMonth.month - 1,
                            1,
                          );
                          ref
                              .read(selectedDashboardMonthProvider.notifier)
                              .state = prev;
                        },
                        onNextMonth: () {
                          final next = DateTime(
                            selectedMonth.year,
                            selectedMonth.month + 1,
                            1,
                          );
                          ref
                              .read(selectedDashboardMonthProvider.notifier)
                              .state = next;
                        },
                        onPickMonth: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedMonth,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            ref
                                .read(selectedDashboardMonthProvider.notifier)
                                .state = picked;
                          }
                        },
                        onOpenAnalytics: onOpenAnalytics,
                      ),
                  loading:
                      () => FfSkeletonLoader(
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusXl,
                            ),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: StillwaterTokens.borderWidthHairline,
                            ),
                          ),
                          padding: const EdgeInsets.all(
                            StillwaterTokens.spaceLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              FfSkeletonBlock(width: 100, height: 12),
                              SizedBox(height: StillwaterTokens.spaceSm),
                              FfSkeletonBlock(width: 140, height: 28),
                              SizedBox(height: StillwaterTokens.spaceMd),
                              Row(
                                children: [
                                  Expanded(child: FfSkeletonBlock(height: 40)),
                                  SizedBox(width: StillwaterTokens.spaceSm),
                                  Expanded(child: FfSkeletonBlock(height: 40)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  error:
                      (e, _) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceMd,
                          vertical: StillwaterTokens.spaceSm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusLg,
                          ),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: StillwaterTokens.borderWidthHairline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Expanded(
                              child: Text(
                                'Could not load cash flow data',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 6. Accounts & Wallets Overview
              accountsAsync.when(
                data:
                    (accountsList) => AccountSummaryStrip(
                      accounts: accountsList,
                      isPrivacyBlur: isPrivacyBlur,
                      onManageAccounts: onManageAccounts,
                      onAddAccount: onAddAccount,
                    ),
                loading:
                    () => FfSkeletonLoader(
                      child: SizedBox(
                        height: 112,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceLg,
                          ),
                          child: Row(
                            children: const [
                              FfSkeletonBlock(
                                width: 176,
                                height: 112,
                                borderRadius: 16,
                              ),
                              SizedBox(width: StillwaterTokens.spaceSm),
                              FfSkeletonBlock(
                                width: 176,
                                height: 112,
                                borderRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                error: (e, _) => const SizedBox.shrink(),
              ),

              // 7. Budgets & Spending Overview
              overallBudgetAsync.when(
                data: (budgetSummary) {
                  if (budgetSummary.totalBudgeted <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceLg,
                    ),
                    child: BudgetOverviewCard(
                      totalBudgeted: budgetSummary.totalBudgeted,
                      totalSpent: budgetSummary.totalSpent,
                      totalRemaining: budgetSummary.totalRemaining,
                      overBudgetCount: budgetSummary.overBudgetCount,
                      activeBudgets: activeBudgetsList,
                      isPrivacyBlur: isPrivacyBlur,
                      onViewBudgets: onOpenBudgets ?? () {},
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 8. Loans & EMIs Overview
              if (activeLoans.isNotEmpty) ...[
                const SizedBox(height: StillwaterTokens.spaceLg),
                HomeLoansOverview(
                  activeLoans: activeLoans,
                  totalOutstanding: totalOutstanding,
                  totalMonthlyEmi: totalMonthlyEmi,
                  isPrivacyBlur: isPrivacyBlur,
                  onViewLoans:
                      onOpenLoans ?? () => _push(context, const LoansScreen()),
                  onOpenLoanDetail: (loan) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoanDetailScreen(loan: loan),
                      ),
                    );
                  },
                ),
              ],

              // 9. Savings Goals Overview
              overallGoalAsync.when(
                data: (goalSummary) {
                  if (goalSummary.totalTarget <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceLg,
                    ),
                    child: SavingsGoalsOverviewCard(
                      totalTarget: goalSummary.totalTarget,
                      totalSaved: goalSummary.totalSaved,
                      totalRemaining: goalSummary.totalRemaining,
                      completedCount: goalSummary.completedCount,
                      totalGoals: goalSummary.totalGoals,
                      isPrivacyBlur: isPrivacyBlur,
                      onViewGoals: onOpenSavingsGoals ?? () {},
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 10. Top Spending Categories
              topCategoriesAsync.when(
                data: (topCats) {
                  if (topCats.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceLg,
                    ),
                    child: TopCategoriesCard(
                      categories: topCats,
                      isPrivacyBlur: isPrivacyBlur,
                      onExploreMore: onOpenAnalytics ?? () {},
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 11. Local On-Device Insights
              insightsAsync.when(
                data: (insights) {
                  if (insights.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceLg,
                    ),
                    child: LocalInsightsCard(insights: insights),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 12. Recent Transactions List
              recentTxAsync.when(
                data:
                    (transactions) => HomeRecentTransactions(
                      transactions: transactions,
                      isPrivacyBlur: isPrivacyBlur,
                      onViewAll: onViewAllTransactions,
                      onAddTransaction: onAddTransaction,
                      onOpenDetail: onOpenTransactionDetail,
                    ),
                loading:
                    () => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceLg,
                      ),
                      child: FfSkeletonLoader(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusLg,
                            ),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: StillwaterTokens.borderWidthHairline,
                            ),
                          ),
                          child: Column(
                            children: const [
                              FfTransactionSkeletonRow(),
                              Divider(height: 1),
                              FfTransactionSkeletonRow(),
                              Divider(height: 1),
                              FfTransactionSkeletonRow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                error:
                    (e, _) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceLg,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusLg,
                          ),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: StillwaterTokens.borderWidthHairline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Expanded(
                              child: Text(
                                'Could not load transactions',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // 13. Reassuring Offline Status Badge Footer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Flexible(
                        child: Text(
                          'On-device & private — offline first.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          ),
        ),
      ),
    );
  }
}
