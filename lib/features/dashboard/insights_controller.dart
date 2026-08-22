import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_contribution.dart';
import '../../models/insight.dart';
import '../../models/transaction.dart';
import '../../services/insight_engine.dart';
import '../budgets/budgets_controller.dart';
import '../savings_goals/savings_goals_controller.dart';
import '../settings/settings_controller.dart';
import 'dashboard_controller.dart';

final dismissedInsightIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Transactions for the month preceding the selected dashboard month
final previousMonthTransactionsProvider = StreamProvider<List<Transaction>>((
  ref,
) {
  final currentMonth = ref.watch(selectedDashboardMonthProvider);
  final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactionsByMonth(prevMonth);
});

/// Reactive offline generated insights for dashboard
final dashboardInsightsProvider = Provider<AsyncValue<List<Insight>>>((ref) {
  final currentMonthTxAsync = ref.watch(monthTransactionsProvider);
  final prevMonthTxAsync = ref.watch(previousMonthTransactionsProvider);
  final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
  final goalsAsync = ref.watch(allSavingsGoalsStreamProvider);
  final contribsAsync = ref.watch(allGoalContributionsStreamProvider);
  final dismissedIds = ref.watch(dismissedInsightIdsProvider);
  final selectedMonth = ref.watch(selectedDashboardMonthProvider);

  return currentMonthTxAsync.when(
    data: (currTxs) {
      return prevMonthTxAsync.when(
        data: (prevTxs) {
          return budgetsAsync.when(
            data: (budgets) {
              return goalsAsync.when(
                data: (goals) {
                  return contribsAsync.when(
                    data: (contribs) {
                      final Map<String, List<GoalContribution>> map = {};
                      for (final c in contribs) {
                        map.putIfAbsent(c.goalId, () => []).add(c);
                      }

                      final insights = InsightEngine.generateInsights(
                        currentMonthTransactions: currTxs,
                        previousMonthTransactions: prevTxs,
                        activeBudgets: budgets,
                        activeGoals: goals,
                        contributionsByGoal: map,
                        dismissedInsightIds: dismissedIds,
                        referenceDate: selectedMonth,
                      );

                      return AsyncValue.data(insights);
                    },
                    loading: () => const AsyncValue.loading(),
                    error: (e, st) => AsyncValue.error(e, st),
                  );
                },
                loading: () => const AsyncValue.loading(),
                error: (e, st) => AsyncValue.error(e, st),
              );
            },
            loading: () => const AsyncValue.loading(),
            error: (e, st) => AsyncValue.error(e, st),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
