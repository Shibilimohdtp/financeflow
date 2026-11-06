import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/period/period.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/budgets/budget_board.dart';
import '../../services/budgets/budget_engine.dart';
import '../../services/budgets/budget_insights.dart';
import '../../services/budgets/budget_ledger.dart';
import '../../services/budgets/budget_setup_suggester.dart';
import '../../services/budgets/committed_bills.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'budgets_controller.dart';

/// "Now" for the Plan tab, read once per provider build. Tests override it.
/// Like Home, a screen left open across midnight keeps the old day until it
/// rebuilds (`docs/architecture/periods.md`).
final planNowProvider = Provider<DateTime>((ref) => DateTime.now());

/// The period the Plan tab shows: a week, month or year (never a custom
/// range or a single day, which budgets don't have). Starts on this month.
final planPeriodProvider = StateProvider<Period>(
  (ref) => Period.containing(PeriodUnit.month, ref.read(planNowProvider)),
);

/// Every transaction, indexed once for budget arithmetic. Rebuilt only when
/// the ledger changes, never per widget.
final budgetLedgerProvider = Provider<AsyncValue<BudgetLedger>>((ref) {
  return ref
      .watch(allTransactionsStreamProvider)
      .whenData(BudgetLedger.fromTransactions);
});

/// Active budgets with their group worked out from the category (groups are
/// not stored until the persistence slice): seed categories go to
/// Essentials or Lifestyle, custom categories to Other.
final planBudgetsProvider = Provider<AsyncValue<List<Budget>>>((ref) {
  return ref
      .watch(activeBudgetsStreamProvider)
      .whenData(
        (budgets) => [
          for (final b in budgets)
            b.copyWith(group: BudgetSetupSuggester.groupFor(b.categoryId)),
        ],
      );
});

final budgetEngineProvider = Provider<AsyncValue<BudgetEngine>>((ref) {
  return ref
      .watch(budgetLedgerProvider)
      .whenData((ledger) => BudgetEngine(ledger: ledger));
});

/// The Bills & EMIs line for the viewed period: tracked subscriptions and
/// loans, matched to payments only through their typed links.
final planBillsProvider = Provider<CommittedBills?>((ref) {
  final period = ref.watch(planPeriodProvider);
  final ledger = ref.watch(budgetLedgerProvider).valueOrNull;
  if (ledger == null) return null;
  final subscriptions =
      ref.watch(allSubscriptionsStreamProvider).valueOrNull ?? const [];
  final loans = ref.watch(allLoansStreamProvider).valueOrNull ?? const [];
  return CommittedBills.forPeriod(
    period: period,
    ledger: ledger,
    subscriptions: subscriptions,
    loans: loans,
  );
});

/// The Plan tab's numbers for the viewed period.
final budgetBoardProvider = Provider<AsyncValue<BudgetBoard>>((ref) {
  final period = ref.watch(planPeriodProvider);
  final now = ref.watch(planNowProvider);
  final bills = ref.watch(planBillsProvider);
  final engine = ref.watch(budgetEngineProvider);
  final budgets = ref.watch(planBudgetsProvider);
  if (engine.hasError) return AsyncValue.error(engine.error!, engine.stackTrace!);
  if (budgets.hasError) {
    return AsyncValue.error(budgets.error!, budgets.stackTrace!);
  }
  final e = engine.valueOrNull;
  final b = budgets.valueOrNull;
  if (e == null || b == null) return const AsyncValue.loading();
  return AsyncValue.data(
    BudgetBoard.compute(
      engine: e,
      budgets: b,
      period: period,
      now: now,
      bills: bills,
    ),
  );
});

enum PlanInsightKind { raise, runOut, lower, closedWithinPlan }

/// The one suggestion the Plan tab shows, with what its button does.
class PlanInsight {
  final PlanInsightKind kind;
  final BudgetPeriodResult? result;
  final BudgetInsight? insight;

  const PlanInsight(this.kind, {this.result, this.insight});

  BudgetSuggestion? get suggestion => insight?.suggestion;
}

/// Picks the single most useful thing to say about the viewed period: raise
/// a budget that keeps going over; warn when a budget will run out; lower a
/// budget that is never used; or note a closed period that stayed within
/// plan. Null when there is nothing worth saying.
final planInsightProvider = Provider<PlanInsight?>((ref) {
  final board = ref.watch(budgetBoardProvider).valueOrNull;
  final engine = ref.watch(budgetEngineProvider).valueOrNull;
  final now = ref.watch(planNowProvider);
  if (board == null || engine == null || board.results.isEmpty) return null;

  BudgetInsight insightFor(BudgetPeriodResult r) =>
      BudgetInsight.compute(engine, r.budget, r.period, now: now);

  for (final r in board.results.where((r) => r.status != BudgetStatus.onTrack)) {
    final i = insightFor(r);
    if (i.suggestion?.kind == BudgetSuggestionKind.raise) {
      return PlanInsight(PlanInsightKind.raise, result: r, insight: i);
    }
  }
  for (final r in board.results) {
    if (r.status == BudgetStatus.atRisk && r.runOutDate != null) {
      return PlanInsight(PlanInsightKind.runOut, result: r);
    }
  }
  for (final r in board.results) {
    final i = insightFor(r);
    final kind = i.suggestion?.kind;
    if (kind == BudgetSuggestionKind.raise) {
      return PlanInsight(PlanInsightKind.raise, result: r, insight: i);
    }
    if (kind == BudgetSuggestionKind.lower) {
      return PlanInsight(PlanInsightKind.lower, result: r, insight: i);
    }
  }
  if (board.closedWithinPlan) {
    return const PlanInsight(PlanInsightKind.closedWithinPlan);
  }
  return null;
});

/// Categories that can still get a budget: active, usable for spending and
/// not already budgeted.
final unbudgetedCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
  final budgeted = <String>{
    for (final b
        in ref.watch(activeBudgetsStreamProvider).valueOrNull ?? <Budget>[])
      ...b.categoryIds,
  };
  return [
    for (final c in categories)
      if (!c.isArchived &&
          c.typeCompatibility.contains('expense') &&
          !budgeted.contains(c.id))
        c,
  ];
});

/// Monthly budgets suggested from the last three full months of spending.
final budgetSetupSuggestionProvider = Provider<BudgetSetupSuggestion?>((ref) {
  final ledger = ref.watch(budgetLedgerProvider).valueOrNull;
  if (ledger == null) return null;
  return BudgetSetupSuggester.suggest(
    ledger: ledger,
    eligibleCategoryIds: ref.watch(unbudgetedCategoriesProvider).map((c) => c.id),
    now: ref.watch(planNowProvider),
  );
});
