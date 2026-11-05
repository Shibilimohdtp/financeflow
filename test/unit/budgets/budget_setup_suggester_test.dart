import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:financeflow/services/budgets/budget_setup_suggester.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

void main() {
  BudgetSetupSuggestion suggest(
    List<Transaction> txs, {
    Set<String> eligible = const {'cat_dining', 'cat_groceries', 'cat_custom'},
  }) => BudgetSetupSuggester.suggest(
    ledger: BudgetLedger.fromTransactions(txs),
    eligibleCategoryIds: eligible,
    now: kNow,
  );

  test('median of the last three full months, rounded up', () {
    final s = suggest([
      tx(DateTime(2026, 8, 5), 6000),
      tx(DateTime(2026, 9, 5), 6400),
      tx(DateTime(2026, 10, 5), 7000),
      tx(DateTime(2026, 11, 5), 90000), // this month is not used
      tx(DateTime(2026, 7, 5), 90000), // nor older months
    ]);
    final dining = s.budgets.single;
    expect(dining.categoryId, 'cat_dining');
    expect(dining.medianMinor, 640000);
    expect(dining.suggestedMinor, 650000);
    expect(dining.group, BudgetGroup.lifestyle);
    expect(s.monthsWithData, 3);
  });

  test('one-month blips and ineligible categories are left out', () {
    final s = suggest([
      for (final m in [8, 9, 10]) tx(DateTime(2026, m, 5), 1000),
      tx(DateTime(2026, 10, 6), 5000, category: 'cat_groceries'),
      for (final m in [8, 9, 10])
        tx(DateTime(2026, m, 7), 800, category: 'cat_archived'),
    ]);
    expect(s.budgets.map((b) => b.categoryId), ['cat_dining']);
  });

  test('a newer user with one month of data still gets suggestions', () {
    final s = suggest([
      tx(DateTime(2026, 10, 5), 1200),
      tx(DateTime(2026, 10, 6), 3000, category: 'cat_groceries'),
      tx(DateTime(2026, 10, 7), 300, category: 'cat_custom'),
    ]);
    expect(s.monthsWithData, 1);
    expect(s.budgets.map((b) => b.categoryId), [
      'cat_groceries',
      'cat_dining',
      'cat_custom',
    ]);
    expect(s.budgets.first.suggestedMinor, 300000);
    expect(s.budgets.last.group, BudgetGroup.other);
  });

  test('income estimate is the median earned income, not transfers', () {
    final s = suggest([
      tx(DateTime(2026, 8, 1), 80000, type: TransactionType.income),
      tx(DateTime(2026, 9, 1), 85000, type: TransactionType.income),
      tx(DateTime(2026, 10, 1), 90000, type: TransactionType.income),
      tx(DateTime(2026, 10, 2), 50000, type: TransactionType.transfer),
    ]);
    expect(s.estimatedMonthlyIncomeMinor, 8500000);
  });

  test('no history: nothing to suggest', () {
    final s = suggest(const []);
    expect(s.budgets, isEmpty);
    expect(s.estimatedMonthlyIncomeMinor, isNull);
    expect(s.monthsWithData, 0);
  });

  test('the 50/30/20 guide counts bills as needs', () {
    const split = PlanSplit(
      incomeMinor: 10000000,
      essentialsMinor: 3000000,
      lifestyleMinor: 2000000,
      otherMinor: 500000,
      billsMinor: 1500000,
      savingsMinor: 2000000,
    );
    expect(split.needsShare, 0.45);
    expect(split.wantsShare, 0.25);
    expect(split.savingsShare, 0.2);
    expect(split.unplannedMinor, 1000000);
  });
}
