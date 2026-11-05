import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/services/budgets/budget_board.dart';
import 'package:financeflow/services/budgets/budget_engine.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

void main() {
  final nov = Period.containing(PeriodUnit.month, kNow);
  final engine = BudgetEngine(
    ledger: BudgetLedger.fromTransactions([
      tx(DateTime(2026, 11, 3), 6500), // dining, over its 6,000
      tx(DateTime(2026, 11, 4), 2000, category: 'cat_groceries'),
      tx(DateTime(2026, 11, 13), 300, category: 'cat_fuel'),
      tx(DateTime(2026, 10, 10), 3000), // October dining
    ]),
  );

  final dining = budget(group: BudgetGroup.lifestyle);
  final groceries = budget(
    id: 'b_groceries',
    categories: ['cat_groceries'],
    limit: 8000,
    group: BudgetGroup.essentials,
  );
  final weeklyFuel = budget(
    id: 'b_fuel',
    categories: ['cat_fuel'],
    limit: 1000,
    period: BudgetPeriod.weekly,
  );
  final yearlyTravel = budget(
    id: 'b_travel',
    categories: ['cat_travel'],
    limit: 50000,
    period: BudgetPeriod.yearly,
  );
  final archived = budget(id: 'b_old', archived: true, limit: 999);
  final all = [groceries, weeklyFuel, dining, yearlyTravel, archived];

  test('the month plan uses monthly budgets only, most urgent first', () {
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: all,
      period: nov,
      now: kNow,
    );
    expect(board.results.map((r) => r.budget.id), ['b_dining', 'b_groceries']);
    expect(board.otherCadence.map((r) => r.budget.id).toSet(), {
      'b_fuel',
      'b_travel',
    });
    expect(board.plannedMinor, 1400000);
    expect(board.spentMinor, 850000);
    // Dining's overspending does not eat into groceries' leftover.
    expect(board.leftMinor, 600000);
    expect(board.overspentMinor, 50000);
    expect(board.daysLeft, 16);
    expect(board.safeTodayMinor, 600000 ~/ 16);
    expect(board.status, BudgetStatus.atRisk);
    expect(board.needsAttention.single.budget.id, 'b_dining');
    expect(board.groups.map((g) => g.group), [
      BudgetGroup.essentials,
      BudgetGroup.lifestyle,
    ]);
  });

  test('a category in two budgets counts once in the plan total', () {
    final duplicate = budget(id: 'b_dup', limit: 1000);
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: [dining, groceries, duplicate],
      period: nov,
      now: kNow,
    );
    expect(board.plannedMinor, 1500000);
    expect(board.spentMinor, 850000);
  });

  test('other cadences sit in their own period around the viewed day', () {
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: all,
      period: nov,
      now: kNow,
    );
    final fuel = board.otherCadence.firstWhere((r) => r.budget.id == 'b_fuel');
    expect(fuel.period.start, DateTime(2026, 11, 9));
    expect(fuel.spentMinor, 30000);
    final travel = board.otherCadence.firstWhere(
      (r) => r.budget.id == 'b_travel',
    );
    expect(travel.period.start, DateTime(2026, 1, 1));
  });

  test('a closed period shows its final result', () {
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: all,
      period: nov.previous(),
      now: kNow,
    );
    expect(board.timing, PeriodTiming.past);
    expect(board.spentMinor, 300000);
    expect(board.safeTodayMinor, 0);
    expect(board.closedWithinPlan, isTrue);
    // Weekly budgets are shown for the last week of October.
    final fuel = board.otherCadence.firstWhere((r) => r.budget.id == 'b_fuel');
    expect(fuel.period.start, DateTime(2026, 10, 26));
  });

  test('a week view shows weekly budgets in the plan', () {
    final week = Period.containing(PeriodUnit.week, kNow);
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: all,
      period: week,
      now: kNow,
    );
    expect(board.results.single.budget.id, 'b_fuel');
    expect(board.daysLeft, 1); // Sunday is the last day of a Monday week.
  });

  test('no budgets is an empty board, not an error', () {
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: const [],
      period: nov,
      now: kNow,
    );
    expect(board.isEmpty, isTrue);
    expect(board.plannedMinor, 0);
    expect(board.status, BudgetStatus.onTrack);
  });
}
