import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/savings_goals/savings_goals_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/add_edit_transaction_screen.dart';
import '../features/transactions/transaction_detail_screen.dart';
import '../features/transactions/transactions_controller.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/ingestion/needs_review_controller.dart';
import '../models/transaction.dart';
import '../repositories/alert_repository.dart';
import '../services/notifications/notification_coordinator.dart';
import '../shared/widgets/ff_navigation.dart';

final currentNavIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    // The shell renders only after onboarding/unlock, so this is the first
    // point where a permission dialog makes sense to the user.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationCoordinatorProvider).ensurePermission();
    });
  }

  void _openAddTransactionScreen(BuildContext context) {
    AddEditTransactionScreen.push(context);
  }

  void _openTransactionDetail(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  void _openAccounts(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccountsScreen()));
  }

  void _openSavingsGoals(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final pendingCount = ref.watch(pendingReviewCountProvider);
    final unreadAlerts = ref.watch(unreadAlertsCountProvider);

    final screens = [
      DashboardScreen(
        onAddTransaction: () => _openAddTransactionScreen(context),
        onViewAllTransactions: () {
          ref.read(currentNavIndexProvider.notifier).state = 1;
        },
        onManageAccounts: () => _openAccounts(context),
        onAddAccount: () => _openAccounts(context),
        onOpenBudgets: () {
          ref.read(currentNavIndexProvider.notifier).state = 2;
        },
        onOpenAnalytics: () {
          ref.read(currentNavIndexProvider.notifier).state = 3;
        },
        onOpenSavingsGoals: () => _openSavingsGoals(context),
        onOpenTransactionDetail: (tx) => _openTransactionDetail(context, tx),
      ),
      TransactionsScreen(
        onOpenDetail: (tx) => _openTransactionDetail(context, tx),
        onAddTransaction: () => _openAddTransactionScreen(context),
      ),
      const BudgetsScreen(),
      AnalyticsScreen(
        onShowTransactions: (query) {
          ref.read(transactionQueryProvider.notifier).state = query;
          ref.read(currentNavIndexProvider.notifier).state = 1;
        },
      ),
      const SettingsScreen(),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex != 0) {
          ref.read(currentNavIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        extendBody: !FfDock.useBar(context),
        body: IndexedStack(index: currentIndex, children: screens),
        // The floating dock sits in the bottom bar slot (not over the body),
        // so every tab keeps its own scroll padding and FAB placement.
        bottomNavigationBar: FfDock(
          selectedIndex: currentIndex,
          onSelected: (index) {
            ref.read(currentNavIndexProvider.notifier).state = index;
          },
          items: [
            const FfDockItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
            ),
            FfDockItem(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              label: 'Money',
              badgeCount: pendingCount,
            ),
            const FfDockItem(
              icon: Icons.pie_chart_outline_rounded,
              selectedIcon: Icons.pie_chart_rounded,
              label: 'Plan',
            ),
            const FfDockItem(
              icon: Icons.insights_outlined,
              selectedIcon: Icons.insights_rounded,
              label: 'Insights',
            ),
            FfDockItem(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              showDot: unreadAlerts > 0,
            ),
          ],
        ),
      ),
    );
  }
}
