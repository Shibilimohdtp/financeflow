import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../../services/balance_calculator.dart';
import '../accounts/accounts_controller.dart';
import '../settings/settings_controller.dart';

// Selected Dashboard Month (defaults to DateTime.now())
final selectedDashboardMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Stream of transactions for the selected dashboard month
final monthTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(selectedDashboardMonthProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactionsByMonth(month);
});

// Monthly Cash Flow computed from real stored transactions
final monthlyCashFlowProvider = Provider<AsyncValue<MonthlyCashFlow>>((ref) {
  final monthTxAsync = ref.watch(monthTransactionsProvider);

  return monthTxAsync.when(
    data: (transactions) {
      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(transactions);
      return AsyncValue.data(cashFlow);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Top spending categories for the selected month
final topSpendingCategoriesProvider = Provider<
  AsyncValue<
    List<
      ({
        String categoryId,
        String name,
        String icon,
        String color,
        double amount,
        double percentage,
      })
    >
  >
>((ref) {
  final monthTxAsync = ref.watch(monthTransactionsProvider);

  return monthTxAsync.when(
    data: (transactions) {
      final expenses =
          transactions.where((t) => t.type == TransactionType.expense).toList();
      final totalExpense = expenses.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      final Map<
        String,
        ({String name, String icon, String color, double amount})
      >
      map = {};
      for (final tx in expenses) {
        final current =
            map[tx.categoryId] ??
            (
              name: tx.categoryName,
              icon: tx.categoryIcon,
              color: tx.categoryColor,
              amount: 0.0,
            );
        map[tx.categoryId] = (
          name: tx.categoryName,
          icon: tx.categoryIcon,
          color: tx.categoryColor,
          amount: current.amount + tx.amount,
        );
      }

      final sorted =
          map.entries.toList()
            ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

      final topList =
          sorted.take(4).map((e) {
            final pct =
                totalExpense > 0 ? (e.value.amount / totalExpense) : 0.0;
            return (
              categoryId: e.key,
              name: e.value.name,
              icon: e.value.icon,
              color: e.value.color,
              amount: e.value.amount,
              percentage: pct,
            );
          }).toList();

      return AsyncValue.data(topList);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Recent 5 Transactions stream for dashboard
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchRecentTransactions(limit: 5);
});

// Total Combined Balance across all active accounts
final totalNetWorthProvider = Provider<AsyncValue<double>>((ref) {
  final accountsAsync = ref.watch(accountsWithBalancesProvider);

  return accountsAsync.when(
    data: (accounts) {
      final total = BalanceCalculator.calculateTotalBalance(accounts);
      return AsyncValue.data(total);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
