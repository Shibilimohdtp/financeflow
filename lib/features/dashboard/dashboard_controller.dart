import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/period/period.dart';
import '../../core/period/report_period_provider.dart';
import '../../models/transaction.dart';
import '../../services/balance_calculator.dart';
import '../../shared/widgets/charts/ff_bar_chart.dart';
import '../accounts/accounts_controller.dart';
import '../settings/settings_controller.dart';

// Selected Dashboard Month (defaults to DateTime.now() for backwards-compatibility and month browsing)
final selectedDashboardMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// The active home period: the shared report period, so Home and Insights
/// always agree.
final dashboardPeriodProvider = Provider<Period>(
  (ref) => ref.watch(reportPeriodProvider),
);

// Calculated Date Range for active dashboard period
final dashboardDateRangeProvider = Provider<({DateTime start, DateTime end})>((
  ref,
) {
  final period = ref.watch(dashboardPeriodProvider);
  return (start: period.start, end: period.endInclusive);
});

/// Comparison window for "vs previous period". A period in progress is
/// compared with the same number of elapsed days of the previous period.
final dashboardPreviousDateRangeProvider =
    Provider<({DateTime start, DateTime end})>((ref) {
      final previous =
          ref
              .watch(dashboardPeriodProvider)
              .comparison(DateTime.now())
              .previous;
      return (start: previous.start, end: previous.endInclusive);
    });

// Stream of transactions for the selected dashboard period
final dashboardTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final period = ref.watch(dashboardPeriodProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactionsBetween(period.start, period.endExclusive);
});

// Stream of transactions for the previous period
final dashboardPreviousTransactionsProvider = StreamProvider<List<Transaction>>(
  (ref) {
    final previous =
        ref.watch(dashboardPeriodProvider).comparison(DateTime.now()).previous;
    final repo = ref.watch(transactionRepositoryProvider);
    return repo.watchTransactionsBetween(previous.start, previous.endExclusive);
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
    final unit = ref.watch(dashboardPeriodProvider).unit;

    return txAsync.when(
      data: (transactions) {
        final List<BarChartItem> items = [];

        if (unit == PeriodUnit.year) {
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
                mExp += tx.consumptionExpenseAmount;
                mInc += tx.earnedIncomeAmount;
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
        } else if (unit == PeriodUnit.week) {
          // 7 daily points Mon-Sun
          const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          for (int d = 0; d < 7; d++) {
            final dayDate = DateTime(
              range.start.year,
              range.start.month,
              range.start.day + d,
            );
            double dExp = 0.0;
            double dInc = 0.0;
            for (final tx in transactions) {
              if (tx.date.year == dayDate.year &&
                  tx.date.month == dayDate.month &&
                  tx.date.day == dayDate.day) {
                dExp += tx.consumptionExpenseAmount;
                dInc += tx.earnedIncomeAmount;
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
          final totalDays = Period.custom(range.start, range.end).dayCount;
          if (totalDays <= 14) {
            for (int d = 0; d < totalDays; d++) {
              final dayDate = DateTime(
                range.start.year,
                range.start.month,
                range.start.day + d,
              );
              double dExp = 0.0;
              double dInc = 0.0;
              for (final tx in transactions) {
                if (tx.date.year == dayDate.year &&
                    tx.date.month == dayDate.month &&
                    tx.date.day == dayDate.day) {
                  dExp += tx.consumptionExpenseAmount;
                  dInc += tx.earnedIncomeAmount;
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
              final startD = DateTime(
                range.start.year,
                range.start.month,
                range.start.day + i,
              );
              final endD = DateTime(
                range.start.year,
                range.start.month,
                range.start.day + min(i + stepDays - 1, totalDays - 1),
              );
              double chunkExp = 0.0;
              double chunkInc = 0.0;
              for (final tx in transactions) {
                if (!tx.date.isBefore(startD) &&
                    tx.date.isBefore(
                      DateTime(endD.year, endD.month, endD.day + 1),
                    )) {
                  chunkExp += tx.consumptionExpenseAmount;
                  chunkInc += tx.earnedIncomeAmount;
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
