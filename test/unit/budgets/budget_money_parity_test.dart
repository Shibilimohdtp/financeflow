// Single source of truth: a budget figure and the Money list it opens agree
// to the cent. The list is filtered with the same TransactionQuery the Plan
// tab builds (period + BudgetScope), and its "Spent" is LedgerTotals over
// the rows, exactly what the Money tab shows.
import 'package:financeflow/core/money/money_math.dart';
import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budgets/budget_board.dart';
import 'package:financeflow/services/budgets/budget_engine.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:financeflow/services/ledger_totals.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

void main() {
  final month = Period.containing(PeriodUnit.month, kNow);

  // Everything a budget could plausibly confuse, in two budgeted categories.
  final ledger = [
    // Counted: plain expenses with awkward paise.
    tx(DateTime(2026, 11, 2, 9), 1450.37),
    tx(DateTime(2026, 11, 9, 20), 0.01),
    tx(DateTime(2026, 11, 14, 13), 2380.10, category: 'cat_groceries'),
    // Counted: boundaries of the month (first instant and last minute).
    tx(DateTime(2026, 11, 1), 99.99),
    tx(DateTime(2026, 11, 30, 23, 59), 200.50),
    // Counted: future-dated inside the month.
    tx(DateTime(2026, 11, 28), 640),
    // Counted: only the fee of an investment purchase.
    tx(
      DateTime(2026, 11, 5),
      10000,
      category: 'cat_dining',
      type: TransactionType.investment,
      purpose: TransactionPurpose.investmentPurchase,
      fee: 25.75,
    ),
    // Not counted: a linked EMI and a linked subscription in the same
    // category (the Bills & EMIs line, owner decision D1).
    tx(DateTime(2026, 11, 5), 29600, loanId: 'l1'),
    tx(DateTime(2026, 11, 7), 649, subscriptionId: 's1'),
    // Not counted: income, a transfer, another category, outside the month.
    tx(DateTime(2026, 11, 3), 500, type: TransactionType.income),
    tx(DateTime(2026, 11, 3), 900, type: TransactionType.transfer),
    tx(DateTime(2026, 11, 3), 777, category: 'cat_fuel'),
    tx(DateTime(2026, 10, 31, 23, 59), 333),
    tx(DateTime(2026, 12, 1), 444),
  ];

  final engine = BudgetEngine(ledger: BudgetLedger.fromTransactions(ledger));

  int moneySpentMinor(BudgetScope scope) {
    final rows = applyTransactionQuery(
      transactions: ledger,
      query: TransactionQuery(period: month, budgetScope: scope),
    );
    return MoneyMath.toMinor(LedgerTotals.of(rows).spending);
  }

  test('one budget: Money total equals the budget spent to the cent', () {
    final dining = budget();
    final result = engine.evaluate(dining, month, now: kNow);
    final scope = BudgetScope(
      categoryIds: dining.categoryIds.toSet(),
      label: 'Dining budget',
    );
    expect(result.spentMinor, 145037 + 1 + 9999 + 20050 + 64000 + 2575);
    expect(moneySpentMinor(scope), result.spentMinor);
  });

  test('the whole plan: Money total equals the board spent', () {
    final budgets = [
      budget(),
      budget(id: 'b_groceries', categories: const ['cat_groceries']),
      // Two budgets sharing a category: the plan counts it once.
      budget(id: 'b_food', categories: const ['cat_dining']),
    ];
    final board = BudgetBoard.compute(
      engine: engine,
      budgets: budgets,
      period: month,
      now: kNow,
    );
    final scope = BudgetScope(
      categoryIds: {for (final r in board.results) ...r.budget.categoryIds},
      label: 'November plan',
    );
    expect(moneySpentMinor(scope), board.spentMinor);
  });

  test('the scope keeps the rows the budget counts and nothing else', () {
    final rows = applyTransactionQuery(
      transactions: ledger,
      query: TransactionQuery(
        period: month,
        budgetScope: const BudgetScope(
          categoryIds: {'cat_dining'},
          label: 'Dining budget',
        ),
      ),
    );
    final counted = engine.ledger.transactionsIn(['cat_dining'], month);
    expect(rows.map((t) => t.id).toSet(), counted.map((r) => r.id).toSet());
  });

  test('the scope is a refinement with its own chip and clears', () {
    const scope = BudgetScope(categoryIds: {'a', 'b'}, label: 'Plan');
    final q = TransactionQuery(period: month, budgetScope: scope);
    expect(q.hasRefinements, isTrue);
    expect(
      q,
      TransactionQuery(
        period: month,
        budgetScope: const BudgetScope(categoryIds: {'b', 'a'}, label: 'Plan'),
      ),
    );
    expect(q.copyWith(clearBudgetScope: true).budgetScope, isNull);
    expect(q.cleared().budgetScope, isNull);
  });
}
