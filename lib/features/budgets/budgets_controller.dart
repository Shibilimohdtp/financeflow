import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/budget.dart';
import '../../repositories/budget_repository.dart';
import '../../services/budget_calculator.dart';
import '../dashboard/dashboard_controller.dart';
import '../transactions/transactions_controller.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return IsarBudgetRepository();
});

final allBudgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchAllBudgets();
});

final activeBudgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchActiveBudgets();
});

final selectedBudgetPeriodFilterProvider = StateProvider<BudgetPeriod?>(
  (ref) => null,
);

/// Computed summaries for all active budgets using current month's transactions
final budgetSummariesProvider = Provider<AsyncValue<List<BudgetSummary>>>((
  ref,
) {
  final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
  final allTxAsync = ref.watch(filteredTransactionsProvider);
  final selectedMonth = ref.watch(selectedDashboardMonthProvider);
  final periodFilter = ref.watch(selectedBudgetPeriodFilterProvider);

  return budgetsAsync.when(
    data: (budgets) {
      return allTxAsync.when(
        data: (transactions) {
          var filteredBudgets = budgets;
          if (periodFilter != null) {
            filteredBudgets =
                filteredBudgets.where((b) => b.period == periodFilter).toList();
          }

          final summaries =
              filteredBudgets.map((b) {
                return BudgetCalculator.calculateSummary(
                  b,
                  transactions,
                  referenceDate: selectedMonth,
                );
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

/// Overall total budget status across active budgets
final overallBudgetSummaryProvider = Provider<
  AsyncValue<
    ({
      double totalBudgeted,
      double totalSpent,
      double totalRemaining,
      int overBudgetCount,
    })
  >
>((ref) {
  final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
  final allTxAsync = ref.watch(filteredTransactionsProvider);
  final selectedMonth = ref.watch(selectedDashboardMonthProvider);

  return budgetsAsync.when(
    data: (budgets) {
      return allTxAsync.when(
        data: (transactions) {
          final summary = BudgetCalculator.calculateOverallSummary(
            budgets,
            transactions,
            referenceDate: selectedMonth,
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

final budgetsControllerProvider =
    StateNotifierProvider<BudgetsController, AsyncValue<void>>((ref) {
      return BudgetsController(ref.watch(budgetRepositoryProvider), ref);
    });

class BudgetsController extends StateNotifier<AsyncValue<void>> {
  final BudgetRepository _repository;
  final Ref _ref;

  BudgetsController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> saveBudget(Budget budget) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveBudget(budget);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> archiveBudget(String id, bool isArchived) async {
    state = const AsyncValue.loading();
    try {
      await _repository.archiveBudget(id, isArchived);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBudget(id);
      state = const AsyncValue.data(null);
      _invalidateDependent();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidateDependent() {
    _ref.invalidate(activeBudgetsStreamProvider);
    _ref.invalidate(allBudgetsStreamProvider);
    _ref.invalidate(budgetSummariesProvider);
    _ref.invalidate(overallBudgetSummaryProvider);
  }
}
