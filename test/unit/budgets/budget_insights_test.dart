import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budgets/budget_engine.dart';
import 'package:financeflow/services/budgets/budget_insights.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

/// [count] purchases of 500 in a month.
List<Transaction> month(int m, int count, {String merchant = 'Cafe'}) => [
  for (var i = 0; i < count; i++)
    tx(DateTime(2026, m, 1 + i), 500, merchant: merchant),
];

void main() {
  final nov = Period.containing(PeriodUnit.month, kNow);

  BudgetInsight insight(List<Transaction> txs) => BudgetInsight.compute(
    BudgetEngine(ledger: BudgetLedger.fromTransactions(txs)),
    budget(),
    nov,
    now: kNow,
  );

  test('often over: suggest raising to the usual spend, or skipping a few '
      'purchases', () {
    // Jun–Oct: 7,000, 6,500, 7,500, 5,000, 7,000 against 6,000. May empty.
    final i = insight([
      ...month(6, 14),
      ...month(7, 13),
      ...month(8, 15),
      ...month(9, 10),
      ...month(10, 14),
    ]);
    expect(i.history.length, 5); // May had no data and is left out
    expect(i.exceededCount, 4);
    expect(i.averageOvershootMinor, 100000);
    expect(i.medianSpentMinor, 700000);
    expect(i.withinLimitStreak, 0);
    expect(i.averagePurchaseMinor, 50000);
    expect(i.suggestion?.kind, BudgetSuggestionKind.raise);
    expect(i.suggestion?.newLimitMinor, 700000);
    expect(i.suggestion?.skipPurchases, 2);
  });

  test('always well under: suggest lowering, with headroom', () {
    final i = insight([
      for (final m in [7, 8, 9, 10]) ...month(m, 6), // 3,000 a month
    ]);
    expect(i.withinLimitStreak, 4);
    expect(i.suggestion?.kind, BudgetSuggestionKind.lower);
    expect(i.suggestion?.newLimitMinor, 340000); // 3,300 → 3,400
  });

  test('too little history: no suggestion', () {
    final i = insight([...month(9, 20), ...month(10, 20)]);
    expect(i.history.length, 2);
    expect(i.suggestion, isNull);
  });

  test('mixed results: no suggestion', () {
    final i = insight([
      ...month(7, 14),
      ...month(8, 10),
      ...month(9, 10),
      ...month(10, 10),
    ]);
    expect(i.suggestion, isNull);
  });

  test('top merchants for the viewed period, largest first', () {
    final i = insight([
      tx(DateTime(2026, 11, 2), 300, merchant: 'Swiggy'),
      tx(DateTime(2026, 11, 3), 400, merchant: 'Swiggy'),
      tx(DateTime(2026, 11, 4), 500, merchant: 'Zomato'),
      tx(DateTime(2026, 11, 5), 50, merchant: ' '),
    ]);
    expect(i.topMerchants.map((m) => m.name), ['Swiggy', 'Zomato', 'Other']);
    expect(i.topMerchants.first.amountMinor, 70000);
    expect(i.topMerchants.first.count, 2);
  });
}
