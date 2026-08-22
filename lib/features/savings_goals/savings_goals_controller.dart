import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../repositories/savings_goal_repository.dart';
import '../../services/savings_goal_calculator.dart';

final savingsGoalRepositoryProvider = Provider<SavingsGoalRepository>((ref) {
  return IsarSavingsGoalRepository();
});

final allSavingsGoalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final repo = ref.watch(savingsGoalRepositoryProvider);
  return repo.watchAllGoals();
});

final allGoalContributionsStreamProvider =
    StreamProvider<List<GoalContribution>>((ref) {
      final repo = ref.watch(savingsGoalRepositoryProvider);
      return repo.watchAllContributions();
    });

final goalContributionsForGoalProvider =
    StreamProvider.family<List<GoalContribution>, String>((ref, goalId) {
      final repo = ref.watch(savingsGoalRepositoryProvider);
      return repo.watchContributionsForGoal(goalId);
    });

/// Computed summaries for all savings goals
final savingsGoalSummariesProvider =
    Provider<AsyncValue<List<SavingsGoalSummary>>>((ref) {
      final goalsAsync = ref.watch(allSavingsGoalsStreamProvider);
      final contributionsAsync = ref.watch(allGoalContributionsStreamProvider);

      return goalsAsync.when(
        data: (goals) {
          return contributionsAsync.when(
            data: (contributions) {
              final Map<String, List<GoalContribution>> map = {};
              for (final c in contributions) {
                map.putIfAbsent(c.goalId, () => []).add(c);
              }

              final summaries =
                  goals.map((g) {
                    final contribs = map[g.id] ?? const [];
                    return SavingsGoalCalculator.calculateSummary(g, contribs);
                  }).toList();

              return AsyncValue.data(summaries);
            },
            loading: () => const AsyncValue.loading(),
            error: (e, st) => AsyncValue.error(e, st),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    });

/// Overall total savings target vs saved
final overallSavingsGoalSummaryProvider = Provider<
  AsyncValue<
    ({
      double totalTarget,
      double totalSaved,
      double totalRemaining,
      int completedCount,
      int totalGoals,
    })
  >
>((ref) {
  final goalsAsync = ref.watch(allSavingsGoalsStreamProvider);
  final contributionsAsync = ref.watch(allGoalContributionsStreamProvider);

  return goalsAsync.when(
    data: (goals) {
      return contributionsAsync.when(
        data: (contributions) {
          final Map<String, List<GoalContribution>> map = {};
          for (final c in contributions) {
            map.putIfAbsent(c.goalId, () => []).add(c);
          }

          final summary = SavingsGoalCalculator.calculateOverallSummary(
            goals,
            map,
          );
          return AsyncValue.data(summary);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final savingsGoalsControllerProvider =
    StateNotifierProvider<SavingsGoalsController, AsyncValue<void>>((ref) {
      return SavingsGoalsController(
        ref.watch(savingsGoalRepositoryProvider),
        ref,
      );
    });

class SavingsGoalsController extends StateNotifier<AsyncValue<void>> {
  final SavingsGoalRepository _repository;
  final Ref _ref;

  SavingsGoalsController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> saveGoal(SavingsGoal goal) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveGoal(goal);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteGoal(id);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addContribution(GoalContribution contribution) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addContribution(contribution);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteContribution(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteContribution(id);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidateDependent() {
    _ref.invalidate(allSavingsGoalsStreamProvider);
    _ref.invalidate(allGoalContributionsStreamProvider);
    _ref.invalidate(savingsGoalSummariesProvider);
    _ref.invalidate(overallSavingsGoalSummaryProvider);
  }
}
