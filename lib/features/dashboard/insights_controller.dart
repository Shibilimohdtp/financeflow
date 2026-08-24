import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_contribution.dart';
import '../../models/insight.dart';
import '../../models/transaction.dart';
import '../../services/insight_engine.dart';
import '../budgets/budgets_controller.dart';
import '../savings_goals/savings_goals_controller.dart';
import '../settings/settings_controller.dart';
import 'dashboard_controller.dart';

/// Persisted dismissal state for generated dashboard insights.
///
/// The previous implementation used an in-memory StateProvider, which meant
/// every app restart recreated every insight. The settings repository is the
/// existing singleton local store, so it is also safe across device restarts.
final dismissedInsightIdsProvider =
    StateNotifierProvider<DismissedInsightIdsController, Set<String>>(
      (ref) => DismissedInsightIdsController(ref),
    );

class DismissedInsightIdsController extends StateNotifier<Set<String>> {
  DismissedInsightIdsController(this._ref) : super(const {}) {
    _load();
  }

  final Ref _ref;
  final Set<String> _pendingDismissals = {};
  Future<void> _persistQueue = Future<void>.value();

  Future<void> _load() async {
    final settings = await _ref.read(settingsRepositoryProvider).getSettings();
    if (!mounted) return;
    state = {...settings.dismissedInsightIds, ..._pendingDismissals};
  }

  Future<void> dismiss(String insightId) async {
    if (state.contains(insightId)) return;
    _pendingDismissals.add(insightId);
    state = {...state, insightId};

    _persistQueue = _persistQueue.then((_) async {
      final repository = _ref.read(settingsRepositoryProvider);
      final settings = await repository.getSettings();
      final pending = Set<String>.from(_pendingDismissals);
      final ids =
          {...settings.dismissedInsightIds, ...pending}.toList()..sort();
      await repository.updateSettings(
        settings.copyWith(dismissedInsightIds: ids),
      );
      _pendingDismissals.removeAll(pending);
    });
    await _persistQueue;
  }
}

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
