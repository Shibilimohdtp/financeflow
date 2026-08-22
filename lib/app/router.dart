import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/budgets/budgets_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/savings_goals/savings_goals_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/add_edit_transaction_sheet.dart';
import '../features/transactions/transaction_detail_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../models/transaction.dart';

final currentNavIndexProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddEditTransactionSheet(),
    );
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

    final screens = [
      DashboardScreen(
        onAddTransaction: () => _openAddTransactionSheet(context),
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
        onAddTransaction: () => _openAddTransactionSheet(context),
      ),
      const BudgetsScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shell_add_transaction_fab',
        onPressed: () => _openAddTransactionSheet(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(currentNavIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(Icons.more_horiz_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
