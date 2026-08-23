import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../models/subscription.dart';
import '../../models/transaction.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_source_badge.dart';
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
import '../transactions/add_edit_transaction_sheet.dart';
import 'dashboard_controller.dart';
import 'insights_controller.dart';
import 'widgets/account_summary_strip.dart';
import 'widgets/actionable_items_section.dart';
import 'widgets/budget_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/home_loans_overview.dart';
import 'widgets/home_quick_actions.dart';
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _openTransfer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddEditTransactionSheet(),
    );
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
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final topCategoriesAsync = ref.watch(topSpendingCategoriesProvider);
    final overallBudgetAsync = ref.watch(overallBudgetSummaryProvider);
    final overallGoalAsync = ref.watch(overallSavingsGoalSummaryProvider);
    final insightsAsync = ref.watch(dashboardInsightsProvider);

    // Loans & Subscriptions Data (Safely guarded against uninitialized state)
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
    final monthlyCashFlow = cashFlowAsync.valueOrNull;
    final overBudgetCount =
        overallBudgetAsync.valueOrNull?.overBudgetCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: StillwaterTokens.spaceLg,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getGreeting(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'FinanceFlow',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadAlerts > 0,
              label: Text('$unreadAlerts'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Alerts & Reminders',
            visualDensity: VisualDensity.compact,
            onPressed:
                onOpenAlerts ?? () => _push(context, const AlertsInboxScreen()),
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(monthTransactionsProvider);
          ref.invalidate(monthlyCashFlowProvider);
          ref.invalidate(accountsWithBalancesProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(topSpendingCategoriesProvider);
          ref.invalidate(overallBudgetSummaryProvider);
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
              // 1. Total Balance Hero (Primary Visual Anchor)
              TotalBalanceHero(
                totalBalance: totalBalance,
                activeAccountsCount: activeAccountsCount,
                monthlyCashFlow: monthlyCashFlow,
                isPrivacyBlur: isPrivacyBlur,
                onToggleBlur: () {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setPrivacyBlurEnabled(!isPrivacyBlur);
                },
                onManageAccounts: onManageAccounts,
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 2. Quick Actions
              HomeQuickActions(
                onAddTransaction: onAddTransaction,
                onTransfer: () => _openTransfer(context),
                onManageAccounts: onManageAccounts,
                onOpenBudgets: onOpenBudgets,
                onOpenLoans:
                    onOpenLoans ?? () => _push(context, const LoansScreen()),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 3. Actionable & Upcoming Items (Unreviewed imports, upcoming EMIs, upcoming subscriptions, budget breaches)
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

              // 4. Cash Flow Summary
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: cashFlowAsync.when(
                  data:
                      (cashFlow) => CashFlowCard(
                        cashFlow: cashFlow,
                        month: selectedMonth,
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
                      () => Container(
                        height: 160,
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
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) => Container(
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
                        child: Text(
                          'Could not load cash flow: $e',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 5. Accounts Overview
              accountsAsync.when(
                data:
                    (accountsList) => AccountSummaryStrip(
                      accounts: accountsList,
                      isPrivacyBlur: isPrivacyBlur,
                      onManageAccounts: onManageAccounts,
                      onAddAccount: onAddAccount,
                    ),
                loading: () => const SizedBox(height: 108),
                error: (e, _) => const SizedBox.shrink(),
              ),

              // 6. Budgets & Spending
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
                      isPrivacyBlur: isPrivacyBlur,
                      onViewBudgets: onOpenBudgets ?? () {},
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 7. Loans & EMIs Overview
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

              // 8. Savings Goals Overview (if active)
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

              // 9. Top Spending Categories
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

              // 10. Local Insights
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

              // 11. Recent Transactions Preview
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onViewAllTransactions,
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceXs),

              recentTxAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceLg,
                        vertical: StillwaterTokens.spaceSm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
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
                        child: FfEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No transactions yet',
                          description:
                              'Add your first expense or income to start organizing your finances offline.',
                          actionLabel: 'Add Transaction',
                          onAction: onAddTransaction,
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceLg,
                    ),
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return InkWell(
                            onTap: () => onOpenTransactionDetail(tx),
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
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: StillwaterTokens.spaceXs,
                                            ),
                                            Flexible(
                                              child: FfSourceBadge(
                                                source: tx.source,
                                                sourceName: tx.sourceName,
                                                isMerged:
                                                    tx.mergedSources.length > 1,
                                              ),
                                            ),
                                          ],
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
                                    isBlurred: isPrivacyBlur,
                                    showSign: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                loading:
                    () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(StillwaterTokens.space2Xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                error:
                    (e, _) =>
                        Center(child: Text('Error loading transactions: $e')),
              ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // 12. Reassuring Offline Status Badge
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
