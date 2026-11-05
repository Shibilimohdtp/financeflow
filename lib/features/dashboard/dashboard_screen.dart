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
import '../loans/loans_controller.dart';
import '../loans/loans_screen.dart';
import '../savings_goals/savings_goals_controller.dart';
import '../settings/settings_controller.dart';
import '../subscriptions/subscriptions_screen.dart';
import 'dashboard_controller.dart';
import 'widgets/actionable_items_section.dart';
import 'widgets/budget_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_loans_overview.dart';
import 'widgets/home_recent_transactions.dart';
import 'widgets/savings_goals_overview_card.dart';
import 'widgets/total_balance_hero.dart';
import '../../core/period/period_format.dart';
import '../../core/period/report_period_provider.dart';
import '../../shared/widgets/ff_period_bar.dart';

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
    final period = ref.watch(reportPeriodProvider);
    final trendMetric = ref.watch(periodComparisonProvider);
    final overallBudgetAsync = ref.watch(overallBudgetSummaryProvider);
    final activeBudgetsAsync = ref.watch(budgetSummariesProvider);
    final overallGoalAsync = ref.watch(overallSavingsGoalSummaryProvider);

    // Loans & Subscriptions Data
    final allLoans = ref.watch(allLoansStreamProvider).valueOrNull ?? const [];
    final activeLoans =
        allLoans.where((l) => l.status == LoanStatus.active).toList();
    final totalOutstanding = ref.watch(loansSummaryProvider).totalOutstanding;
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
      // Logging a transaction is the most common action, so it gets the
      // primary button rather than a row of shortcuts.
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_add_transaction',
        onPressed: onAddTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
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
          ref.invalidate(overallBudgetSummaryProvider);
          ref.invalidate(budgetSummariesProvider);
          ref.invalidate(overallSavingsGoalSummaryProvider);
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
                onAddAccount: onAddAccount,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 3. Actionable & Upcoming Items
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

              // 4. Period (shared with Insights) and its cash flow
              FfPeriodBar(
                period: period,
                onChanged: (p) {
                  if (p != null) {
                    ref.read(reportPeriodProvider.notifier).state = p;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: cashFlowAsync.when(
                  data:
                      (cashFlow) => CashFlowCard(
                        cashFlow: cashFlow,
                        trendMetric: trendMetric,
                        month: period.start,
                        periodLabel: periodLabel(period),
                        chartItems: cashFlowChartAsync.valueOrNull,
                        isPrivacyBlur: isPrivacyBlur,
                        onToggleBlur: () {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setPrivacyBlurEnabled(!isPrivacyBlur);
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

              // 5. Budgets & Spending Overview
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

              // 6. Loans & EMIs Overview
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

              // 7. Savings Goals Overview
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

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 8. Recent Transactions List
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
