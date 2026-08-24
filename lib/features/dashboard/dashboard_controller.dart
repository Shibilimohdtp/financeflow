import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../../services/balance_calculator.dart';
import '../../shared/widgets/charts/ff_bar_chart.dart';
import '../accounts/accounts_controller.dart';
import '../settings/settings_controller.dart';

enum DashboardPeriod {
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  custom('Custom');

  final String label;
  const DashboardPeriod(this.label);
}

// Selected Dashboard Period mode
final selectedDashboardPeriodProvider = StateProvider<DashboardPeriod>((ref) {
  return DashboardPeriod.thisMonth;
});

// Selected Dashboard Month (defaults to DateTime.now() for backwards-compatibility and month browsing)
final selectedDashboardMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Custom date range for custom period
final dashboardCustomRangeProvider =
    StateProvider<({DateTime start, DateTime end})?>((ref) => null);

// Calculated Date Range for active dashboard period
final dashboardDateRangeProvider = Provider<({DateTime start, DateTime end})>((
  ref,
) {
  final period = ref.watch(selectedDashboardPeriodProvider);
  final selectedMonth = ref.watch(selectedDashboardMonthProvider);
  final custom = ref.watch(dashboardCustomRangeProvider);
  final now = DateTime.now();

  switch (period) {
    case DashboardPeriod.thisWeek:
      final weekday = now.weekday; // 1 = Monday, 7 = Sunday
      final start = DateTime(
        now.year,
        now.month,
        now.day - (weekday - 1),
        0,
        0,
        0,
      );
      final end = DateTime(
        start.year,
        start.month,
        start.day + 6,
        23,
        59,
        59,
        999,
      );
      return (start: start, end: end);

    case DashboardPeriod.thisMonth:
      final start = DateTime(
        selectedMonth.year,
        selectedMonth.month,
        1,
        0,
        0,
        0,
      );
      final end = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
      return (start: start, end: end);

    case DashboardPeriod.lastMonth:
      final prevMonth = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
      final end = DateTime(
        prevMonth.year,
        prevMonth.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
      return (start: prevMonth, end: end);

    case DashboardPeriod.thisYear:
      final start = DateTime(now.year, 1, 1, 0, 0, 0);
      final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
      return (start: start, end: end);

    case DashboardPeriod.custom:
      if (custom != null) {
        return custom;
      }
      final start = DateTime(now.year, now.month, 1, 0, 0, 0);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
      return (start: start, end: end);
  }
});

// Previous period range for period-over-period comparison
final dashboardPreviousDateRangeProvider = Provider<
  ({DateTime start, DateTime end})
>((ref) {
  final period = ref.watch(selectedDashboardPeriodProvider);
  final currentRange = ref.watch(dashboardDateRangeProvider);
  final now = DateTime.now();

  switch (period) {
    case DashboardPeriod.thisWeek:
      final start = currentRange.start.subtract(const Duration(days: 7));
      final end = currentRange.start.subtract(const Duration(milliseconds: 1));
      return (start: start, end: end);

    case DashboardPeriod.thisMonth:
      final selectedMonth = ref.watch(selectedDashboardMonthProvider);
      final prevMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
        1,
        0,
        0,
        0,
      );
      final end = DateTime(
        selectedMonth.year,
        selectedMonth.month,
        0,
        23,
        59,
        59,
        999,
      );
      return (start: prevMonth, end: end);

    case DashboardPeriod.lastMonth:
      final prevPrevMonth = DateTime(now.year, now.month - 2, 1, 0, 0, 0);
      final end = DateTime(now.year, now.month - 1, 0, 23, 59, 59, 999);
      return (start: prevPrevMonth, end: end);

    case DashboardPeriod.thisYear:
      final start = DateTime(now.year - 1, 1, 1, 0, 0, 0);
      final end = DateTime(now.year - 1, 12, 31, 23, 59, 59, 999);
      return (start: start, end: end);

    case DashboardPeriod.custom:
      final duration = currentRange.end.difference(currentRange.start);
      final start = currentRange.start.subtract(duration);
      final end = currentRange.start.subtract(const Duration(milliseconds: 1));
      return (start: start, end: end);
  }
});

// Stream of transactions for the selected dashboard period
final dashboardTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final range = ref.watch(dashboardDateRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchSearchAndFilterTransactions(
    startDate: range.start,
    endDate: range.end,
  );
});

// Stream of transactions for the previous period
final dashboardPreviousTransactionsProvider = StreamProvider<List<Transaction>>(
  (ref) {
    final range = ref.watch(dashboardPreviousDateRangeProvider);
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.watchSearchAndFilterTransactions(
      startDate: range.start,
      endDate: range.end,
    );
  },
);

// Backward-compatible alias for monthTransactionsProvider
final monthTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(dashboardTransactionsProvider.future).asStream();
});

// Monthly Cash Flow computed from real stored transactions
final monthlyCashFlowProvider = Provider<AsyncValue<MonthlyCashFlow>>((ref) {
  final txAsync = ref.watch(dashboardTransactionsProvider);

  return txAsync.when(
    data: (transactions) {
      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(transactions);
      return AsyncValue.data(cashFlow);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Previous Period Cash Flow for trend comparisons
final previousPeriodCashFlowProvider = Provider<AsyncValue<MonthlyCashFlow>>((
  ref,
) {
  final txAsync = ref.watch(dashboardPreviousTransactionsProvider);
  return txAsync.when(
    data: (transactions) {
      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(transactions);
      return AsyncValue.data(cashFlow);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Period comparison summary metric (e.g. % change vs previous period)
class PeriodComparisonMetric {
  final double expenseChangePct;
  final double incomeChangePct;
  final bool hasPreviousData;

  const PeriodComparisonMetric({
    required this.expenseChangePct,
    required this.incomeChangePct,
    required this.hasPreviousData,
  });
}

final periodComparisonProvider = Provider<PeriodComparisonMetric>((ref) {
  final currFlow = ref.watch(monthlyCashFlowProvider).valueOrNull;
  final prevFlow = ref.watch(previousPeriodCashFlowProvider).valueOrNull;

  if (currFlow == null ||
      prevFlow == null ||
      (prevFlow.totalExpense == 0 && prevFlow.totalIncome == 0)) {
    return const PeriodComparisonMetric(
      expenseChangePct: 0.0,
      incomeChangePct: 0.0,
      hasPreviousData: false,
    );
  }

  final expPct =
      prevFlow.totalExpense > 0
          ? ((currFlow.totalExpense - prevFlow.totalExpense) /
                  prevFlow.totalExpense) *
              100.0
          : 0.0;
  final incPct =
      prevFlow.totalIncome > 0
          ? ((currFlow.totalIncome - prevFlow.totalIncome) /
                  prevFlow.totalIncome) *
              100.0
          : 0.0;

  return PeriodComparisonMetric(
    expenseChangePct: expPct,
    incomeChangePct: incPct,
    hasPreviousData: true,
  );
});

// Cash Flow Chart items for dashboard chart visualization
final dashboardCashFlowChartProvider = Provider<AsyncValue<List<BarChartItem>>>(
  (ref) {
    final txAsync = ref.watch(dashboardTransactionsProvider);
    final range = ref.watch(dashboardDateRangeProvider);
    final period = ref.watch(selectedDashboardPeriodProvider);

    return txAsync.when(
      data: (transactions) {
        final List<BarChartItem> items = [];

        if (period == DashboardPeriod.thisYear) {
          // 12 monthly points
          const monthLabels = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          for (int m = 1; m <= 12; m++) {
            double mExp = 0.0;
            double mInc = 0.0;
            for (final tx in transactions) {
              if (tx.date.year == range.start.year && tx.date.month == m) {
                if (tx.type == TransactionType.expense) mExp += tx.amount;
                if (tx.type == TransactionType.income) mInc += tx.amount;
              }
            }
            items.add(
              BarChartItem(
                label: monthLabels[m - 1],
                value: mExp,
                secondaryValue: mInc > 0 ? mInc : null,
              ),
            );
          }
        } else if (period == DashboardPeriod.thisWeek) {
          // 7 daily points Mon-Sun
          const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          for (int d = 0; d < 7; d++) {
            final dayDate = range.start.add(Duration(days: d));
            double dExp = 0.0;
            double dInc = 0.0;
            for (final tx in transactions) {
              if (tx.date.year == dayDate.year &&
                  tx.date.month == dayDate.month &&
                  tx.date.day == dayDate.day) {
                if (tx.type == TransactionType.expense) dExp += tx.amount;
                if (tx.type == TransactionType.income) dInc += tx.amount;
              }
            }
            items.add(
              BarChartItem(
                label: dayNames[d],
                value: dExp,
                secondaryValue: dInc > 0 ? dInc : null,
              ),
            );
          }
        } else {
          // Group by days or interval chunks
          final totalDays = range.end.difference(range.start).inDays + 1;
          if (totalDays <= 14) {
            for (int d = 0; d < totalDays; d++) {
              final dayDate = range.start.add(Duration(days: d));
              double dExp = 0.0;
              double dInc = 0.0;
              for (final tx in transactions) {
                if (tx.date.year == dayDate.year &&
                    tx.date.month == dayDate.month &&
                    tx.date.day == dayDate.day) {
                  if (tx.type == TransactionType.expense) dExp += tx.amount;
                  if (tx.type == TransactionType.income) dInc += tx.amount;
                }
              }
              items.add(
                BarChartItem(
                  label: '${dayDate.day}',
                  value: dExp,
                  secondaryValue: dInc > 0 ? dInc : null,
                ),
              );
            }
          } else {
            // Group into 5 intervals across the month / range
            final intervals = 5;
            final stepDays = max(1, (totalDays / intervals).ceil());
            for (int i = 0; i < totalDays; i += stepDays) {
              final startD = range.start.add(Duration(days: i));
              final endD = range.start.add(
                Duration(days: min(i + stepDays - 1, totalDays - 1)),
              );
              double chunkExp = 0.0;
              double chunkInc = 0.0;
              for (final tx in transactions) {
                if (!tx.date.isBefore(startD) &&
                    tx.date.isBefore(endD.add(const Duration(days: 1)))) {
                  if (tx.type == TransactionType.expense) chunkExp += tx.amount;
                  if (tx.type == TransactionType.income) chunkInc += tx.amount;
                }
              }
              items.add(
                BarChartItem(
                  label: '${startD.day}-${endD.day}',
                  value: chunkExp,
                  secondaryValue: chunkInc > 0 ? chunkInc : null,
                ),
              );
            }
          }
        }

        return AsyncValue.data(items);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    );
  },
);

// Top spending categories for the selected period
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
        int transactionCount,
      })
    >
  >
>((ref) {
  final txAsync = ref.watch(dashboardTransactionsProvider);

  return txAsync.when(
    data: (transactions) {
      final expenses =
          transactions.where((t) => t.type == TransactionType.expense).toList();
      final totalExpense = expenses.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      final Map<
        String,
        ({String name, String icon, String color, double amount, int count})
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
              count: 0,
            );
        map[tx.categoryId] = (
          name: tx.categoryName,
          icon: tx.categoryIcon,
          color: tx.categoryColor,
          amount: current.amount + tx.amount,
          count: current.count + 1,
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
              transactionCount: e.value.count,
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
