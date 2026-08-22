import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../repositories/alert_repository.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../alerts/alerts_inbox_screen.dart';
import '../budgets/budgets_controller.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../savings_goals/savings_goals_controller.dart';
import '../settings/settings_controller.dart';
import 'dashboard_controller.dart';
import 'insights_controller.dart';
import 'widgets/account_summary_strip.dart';
import 'widgets/budget_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/local_insights_card.dart';
import 'widgets/month_selector_header.dart';
import 'widgets/savings_goals_overview_card.dart';
import 'widgets/top_categories_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onViewAllTransactions;
  final VoidCallback onManageAccounts;
  final VoidCallback onAddAccount;
  final VoidCallback? onOpenBudgets;
  final VoidCallback? onOpenSavingsGoals;
  final VoidCallback? onOpenAnalytics;
  final ValueChanged<Transaction> onOpenTransactionDetail;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final settings = ref.watch(settingsStreamProvider).value;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;
    final pendingCount = ref.watch(pendingReviewCountProvider);

    final cashFlowAsync = ref.watch(monthlyCashFlowProvider);
    final accountsAsync = ref.watch(accountsWithBalancesProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final topCategoriesAsync = ref.watch(topSpendingCategoriesProvider);
    final overallBudgetAsync = ref.watch(overallBudgetSummaryProvider);
    final overallGoalAsync = ref.watch(overallSavingsGoalSummaryProvider);
    final insightsAsync = ref.watch(dashboardInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            Text('FinanceFlow', style: theme.textTheme.headlineMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(unreadAlertsCountProvider) > 0,
              label: Text('${ref.watch(unreadAlertsCountProvider)}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Alerts & Reminders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertsInboxScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
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
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: StillwaterTokens.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Month Selector Header
              MonthSelectorHeader(
                selectedMonth: selectedMonth,
                onMonthChanged: (newMonth) {
                  ref.read(selectedDashboardMonthProvider.notifier).state =
                      newMonth;
                },
              ),

              // Pending Review Alert Banner
              if (pendingCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  child: Material(
                    color: context.aiColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusSm,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NeedsReviewScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              color: context.aiColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Expanded(
                              child: Text(
                                '$pendingCount imported transactions need your review',
                                style: TextStyle(
                                  color: context.aiColors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.aiColors.accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              // 2. Monthly Cash Flow Hero Card
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
                      ),
                  loading:
                      () => const FfCard(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) =>
                          FfCard(child: Text('Could not load cash flow: $e')),
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 3. Local Insights Carousel
              insightsAsync.when(
                data: (insights) => LocalInsightsCard(insights: insights),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 4. Budget Overview Card
              overallBudgetAsync.when(
                data:
                    (budgetSummary) => BudgetOverviewCard(
                      totalBudgeted: budgetSummary.totalBudgeted,
                      totalSpent: budgetSummary.totalSpent,
                      totalRemaining: budgetSummary.totalRemaining,
                      overBudgetCount: budgetSummary.overBudgetCount,
                      onViewBudgets: onOpenBudgets ?? () {},
                    ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 5. Savings Goals Overview Card
              overallGoalAsync.when(
                data:
                    (goalSummary) => SavingsGoalsOverviewCard(
                      totalTarget: goalSummary.totalTarget,
                      totalSaved: goalSummary.totalSaved,
                      totalRemaining: goalSummary.totalRemaining,
                      completedCount: goalSummary.completedCount,
                      totalGoals: goalSummary.totalGoals,
                      onViewGoals: onOpenSavingsGoals ?? () {},
                    ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceMd),

              // 6. Top Spending Categories Card
              topCategoriesAsync.when(
                data:
                    (topCats) => TopCategoriesCard(
                      categories: topCats,
                      onExploreMore: onOpenAnalytics ?? () {},
                    ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 7. Accounts Summary Strip
              accountsAsync.when(
                data:
                    (accounts) => AccountSummaryStrip(
                      accounts: accounts,
                      isPrivacyBlur: isPrivacyBlur,
                      onManageAccounts: onManageAccounts,
                      onAddAccount: onAddAccount,
                    ),
                loading: () => const SizedBox(height: 104),
                error: (e, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 8. Recent Transactions Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium,
                    ),
                    TextButton(
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
                        vertical: StillwaterTokens.spaceMd,
                      ),
                      child: FfCard(
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
                    child: FfCard(
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceMd,
                              vertical: StillwaterTokens.space2Xs,
                            ),
                            leading: FfCategoryTile(
                              iconIdentifier: tx.categoryIcon,
                              colorTokenIdentifier: tx.categoryColor,
                            ),
                            title: Text(
                              tx.merchant,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  DateFormatter.formatTransactionDate(tx.date),
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: StillwaterTokens.spaceXs),
                                FfSourceBadge(
                                  source: tx.source,
                                  sourceName: tx.sourceName,
                                  isMerged: tx.mergedSources.length > 1,
                                ),
                              ],
                            ),
                            trailing: FfAmountText(
                              amount: tx.amount,
                              type: tx.type,
                              size: FfAmountSize.md,
                              isBlurred: isPrivacyBlur,
                              showSign: true,
                            ),
                            onTap: () => onOpenTransactionDetail(tx),
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

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 9. Reassuring Offline Status Badge
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Text(
                        'Offline — everything still works.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
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
