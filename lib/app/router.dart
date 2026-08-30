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
import '../features/transactions/transactions_screen.dart';
import '../features/ingestion/needs_review_controller.dart';
import '../models/transaction.dart';
import '../repositories/alert_repository.dart';
import '../shared/widgets/stillwater_bottom_navigation_bar.dart';

final currentNavIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
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
      const AnalyticsScreen(),
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
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: StillwaterBottomNavigationBar(
          selectedIndex: currentIndex,
          pendingReviewCount: pendingCount,
          unreadAlertsCount: unreadAlerts,
          onDestinationSelected: (index) {
            ref.read(currentNavIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
