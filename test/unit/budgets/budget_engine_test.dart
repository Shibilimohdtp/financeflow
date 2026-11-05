import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budgets/budget_engine.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

BudgetEngine engineFor(
  List<Transaction> txs, {
  List<BudgetAdjustment> adjustments = const [],
  int weekStart = DateTime.monday,
}) => BudgetEngine(
  ledger: BudgetLedger.fromTransactions(txs),
  adjustments: adjustments,
  weekStart: weekStart,
);

final nov = Period.containing(PeriodUnit.month, kNow);

void main() {
  group('What counts', () {
    test('only consumption spending in the budget categories', () {
      final engine = engineFor([
        tx(DateTime(2026, 11, 2), 100),
        tx(DateTime(2026, 11, 3), 40, category: 'cat_groceries'),
        tx(DateTime(2026, 11, 4), 500, type: TransactionType.transfer),
        tx(DateTime(2026, 11, 5), 900, type: TransactionType.income),
        tx(DateTime(2026, 11, 6), 250, purpose: TransactionPurpose.lending),
      ]);
      final r = engine.evaluate(budget(), nov, now: kNow);
      expect(r.spentMinor, 10000);
    });

    test('investment principal never counts, its fee does', () {
      final engine = engineFor([
        tx(
          DateTime(2026, 11, 2),
          10000,
          type: TransactionType.investment,
          fee: 25.5,
        ),
      ]);
      expect(engine.evaluate(budget(), nov, now: kNow).spentMinor, 2550);
    });

    test('payments linked to a tracked subscription or loan are bills, '
        'not category spending', () {
      final engine = engineFor([
        tx(DateTime(2026, 11, 2), 199, subscriptionId: 'sub_1'),
        tx(
          DateTime(2026, 11, 3),
          15000,
          purpose: TransactionPurpose.loanRepayment,
          loanId: 'loan_1',
        ),
        // An unlinked EMI is still ordinary spending in its category.
        tx(DateTime(2026, 11, 4), 300, type: TransactionType.loanEmi),
      ]);
      expect(engine.evaluate(budget(), nov, now: kNow).spentMinor, 30000);
    });

    test('a refund recorded as income does not change budget spending', () {
      final engine = engineFor([
        tx(DateTime(2026, 11, 2), 1000),
        tx(DateTime(2026, 11, 3), 400, type: TransactionType.income),
      ]);
      expect(engine.evaluate(budget(), nov, now: kNow).spentMinor, 100000);
    });

    test('recategorising a transaction moves it between budgets', () {
      final before = engineFor([tx(DateTime(2026, 11, 2), 80, id: 'x')]);
      final after = engineFor([
        tx(DateTime(2026, 11, 2), 80, id: 'x', category: 'cat_groceries'),
      ]);
      final dining = budget();
      final groceries = budget(id: 'g', categories: ['cat_groceries']);
      expect(before.evaluate(dining, nov, now: kNow).spentMinor, 8000);
      expect(after.evaluate(dining, nov, now: kNow).spentMinor, 0);
      expect(after.evaluate(groceries, nov, now: kNow).spentMinor, 8000);
    });

    test('a budget over a deleted or archived category reads as zero', () {
      final engine = engineFor([tx(DateTime(2026, 11, 2), 80)]);
      final orphan = budget(categories: ['cat_deleted']);
      final r = engine.evaluate(orphan, nov, now: kNow);
      expect(r.spentMinor, 0);
      expect(r.status, BudgetStatus.onTrack);
    });

    test('multi-category budgets add their categories once', () {
      final engine = engineFor([
        tx(DateTime(2026, 11, 2), 100),
        tx(DateTime(2026, 11, 3), 50, category: 'cat_groceries'),
      ]);
      final food = budget(
        categories: ['cat_dining', 'cat_groceries', 'cat_dining'],
      );
      expect(engine.evaluate(food, nov, now: kNow).spentMinor, 15000);
    });

    test('future-dated transactions in the period count as spent', () {
      final engine = engineFor([tx(DateTime(2026, 11, 28), 100)]);
      expect(engine.evaluate(budget(), nov, now: kNow).spentMinor, 10000);
    });
  });

  group('Periods', () {
    test('month boundaries are half-open local days', () {
      final engine = engineFor([
        tx(DateTime(2026, 10, 31, 23, 59, 59), 1),
        tx(DateTime(2026, 11, 1), 2),
        tx(DateTime(2026, 11, 30, 23, 59, 59), 4),
        tx(DateTime(2026, 12, 1), 8),
      ]);
      expect(engine.evaluate(budget(), nov, now: kNow).spentMinor, 600);
    });

    test('leap-year February has 29 days and includes the 29th', () {
      final engine = engineFor([tx(DateTime(2028, 2, 29, 20), 10)]);
      final r = engine.evaluateAt(budget(), DateTime(2028, 2, 10), now: kNow);
      expect(r.totalDays, 29);
      expect(r.spentMinor, 1000);
    });

    test('weekly budgets follow the week-start preference', () {
      final weekly = budget(period: BudgetPeriod.weekly);
      final wed = DateTime(2026, 11, 11);
      final monday = engineFor(const []).periodFor(weekly, wed);
      expect(monday.start, DateTime(2026, 11, 9));
      expect(monday.endExclusive, DateTime(2026, 11, 16));

      final sunday = engineFor(
        const [],
        weekStart: DateTime.sunday,
      ).periodFor(weekly, wed);
      expect(sunday.start, DateTime(2026, 11, 8));
      expect(sunday.endExclusive, DateTime(2026, 11, 15));
    });

    test('custom ranges include the whole first and last day', () {
      final custom = budget(
        period: BudgetPeriod.custom,
        start: DateTime(2026, 11, 3, 15, 30), // time of day is ignored
        end: DateTime(2026, 11, 10),
      );
      final engine = engineFor([
        tx(DateTime(2026, 11, 2, 23, 59), 1),
        tx(DateTime(2026, 11, 3, 8), 2),
        tx(DateTime(2026, 11, 10, 22), 4),
        tx(DateTime(2026, 11, 11), 8),
      ]);
      final r = engine.evaluateAt(custom, kNow, now: kNow);
      expect(r.period.start, DateTime(2026, 11, 3));
      expect(r.period.endExclusive, DateTime(2026, 11, 11));
      expect(r.totalDays, 8);
      expect(r.spentMinor, 600);
      expect(r.timing, PeriodTiming.past);
    });

    test('an old custom budget without an end date runs for one year', () {
      final custom = budget(
        period: BudgetPeriod.custom,
        start: DateTime(2026, 3, 15),
      );
      final p = engineFor(const []).periodFor(custom, kNow);
      expect(p.start, DateTime(2026, 3, 15));
      expect(p.endExclusive, DateTime(2027, 3, 15));
    });

    test('day counts are calendar days across DST changes', () {
      // 29 March 2026 is the EU spring-forward day; 25 October the
      // fall-back day. Whatever the device time zone, days stay whole.
      final engine = engineFor(const []);
      final march = engine.evaluateAt(
        budget(),
        DateTime(2026, 3, 29, 12),
        now: DateTime(2026, 3, 29, 12),
      );
      expect(march.totalDays, 31);
      expect(march.elapsedDays, 29);
      expect(march.daysLeft, 3);

      final october = engine.evaluateAt(
        budget(),
        DateTime(2026, 10, 26, 1),
        now: DateTime(2026, 10, 26, 1),
      );
      expect(october.elapsedDays, 26);
      expect(october.daysLeft, 6);
    });

    test('past, current and future periods', () {
      final engine = engineFor([tx(DateTime(2026, 10, 3), 100)]);
      final past = engine.evaluate(budget(), nov.previous(), now: kNow);
      expect(past.timing, PeriodTiming.past);
      expect(past.daysLeft, 0);
      expect(past.dailyAllowanceMinor, 0);
      expect(past.forecastMinor, past.spentMinor);

      final current = engine.evaluate(budget(), nov, now: kNow);
      expect(current.timing, PeriodTiming.current);
      expect(current.elapsedDays, 15);
      expect(current.daysLeft, 16);

      final future = engine.evaluate(budget(), nov.next(), now: kNow);
      expect(future.timing, PeriodTiming.future);
      expect(future.elapsedDays, 0);
      expect(future.daysLeft, 31);
    });

    test('a budget created mid-period is not pro-rated', () {
      final late = budget(start: DateTime(2026, 11, 12));
      final engine = engineFor([tx(DateTime(2026, 11, 5), 100)]);
      final r = engine.evaluate(late, nov, now: kNow);
      expect(r.startedMidPeriod, isTrue);
      expect(r.limitMinor, 600000);
      expect(r.spentMinor, 10000);
    });
  });

  group('Status, pace and allowance', () {
    test('zero spending', () {
      final r = engineFor(const []).evaluate(budget(), nov, now: kNow);
      expect(r.status, BudgetStatus.onTrack);
      expect(r.fractionUsed, 0);
      expect(r.expectedByTodayMinor, 300000);
      expect(r.dailyAllowanceMinor, 600000 ~/ 16);
      expect(r.isAheadOfPace, isFalse);
    });

    test('overspending', () {
      final engine = engineFor([tx(DateTime(2026, 11, 3), 6500)]);
      final r = engine.evaluate(budget(), nov, now: kNow);
      expect(r.status, BudgetStatus.over);
      expect(r.overMinor, 50000);
      expect(r.leftMinor, 0);
      expect(r.dailyAllowanceMinor, 0);
      expect(r.runOutDate, isNull);
    });

    test('at risk once past the alert threshold and heading over', () {
      final engine = engineFor([
        for (var d = 1; d <= 5; d++) tx(DateTime(2026, 11, d), 1000),
      ]);
      final r = engine.evaluate(budget(), nov, now: kNow);
      expect(r.spentMinor, 500000);
      expect(r.isAheadOfPace, isTrue);
      expect(r.status, BudgetStatus.atRisk);
    });

    test('forecast and run-out day with no history', () {
      final engine = engineFor([
        for (var d = 1; d <= 4; d++) tx(DateTime(2026, 11, d * 3), 1000),
      ]);
      final r = engine.evaluate(budget(), nov, now: kNow);
      // Pace so far 400,000 / 15 days; plan pace 600,000 / 30; half-way
      // through, each counts half: ≈ 23,333 per day for 15 more days.
      expect(r.forecastMinor, closeTo(750000, 1));
      expect(r.status, BudgetStatus.atRisk);
      expect(r.runOutDate, DateTime(2026, 11, 24));
    });

    test('a few early purchases do not project a runaway month', () {
      final txs = [
        for (final m in [8, 9, 10])
          for (final d in [5, 15, 25]) tx(DateTime(2026, m, d), 1500),
        tx(DateTime(2026, 11, 1), 800),
      ];
      final now = DateTime(2026, 11, 2, 10);
      final r = engineFor(txs).evaluate(budget(), nov, now: now);
      // The naive pace (800 / 2 days × 30) would project 12,000 against 6,000.
      expect(r.forecastMinor, lessThan(600000));
      expect(r.forecastMinor, greaterThan(r.spentMinor));
      expect(r.status, BudgetStatus.onTrack);
    });

    test('rent paid on the 1st is a one-off, not a pace', () {
      final housing = budget(categories: ['cat_rent'], limit: 30000);
      final engine = engineFor([
        tx(DateTime(2026, 11, 1), 25000, category: 'cat_rent'),
      ]);
      final r = engine.evaluate(housing, nov, now: DateTime(2026, 11, 2, 9));
      expect(r.forecastMinor, lessThan(3000000));
      expect(r.status, BudgetStatus.onTrack);
    });
  });

  group('Adjustments and rollover', () {
    test('a this-period-only change applies to that period alone', () {
      final engine = engineFor(
        const [],
        adjustments: [
          BudgetAdjustment(
            id: 'a1',
            budgetId: 'b_dining',
            periodStart: DateTime(2026, 11, 1),
            deltaMinor: 100000,
            createdAt: kNow,
          ),
        ],
      );
      expect(engine.evaluate(budget(), nov, now: kNow).limitMinor, 700000);
      expect(
        engine.evaluate(budget(), nov.previous(), now: kNow).limitMinor,
        600000,
      );
    });

    final history = [
      tx(DateTime(2026, 9, 10), 5000), // 1,000 under
      tx(DateTime(2026, 10, 10), 7500), // over the plain limit
    ];

    test('off: every period starts from the plan', () {
      final r = engineFor(history).evaluate(budget(), nov, now: kNow);
      expect(r.carryInMinor, 0);
      expect(r.limitMinor, 600000);
    });

    test('unspent: leftovers carry, overspending does not', () {
      final b = budget(
        rollover: RolloverMode.unspent,
        rolloverSince: DateTime(2026, 9, 1),
      );
      // Sep: 6,000 − 5,000 = +1,000 → Oct limit 7,000, spent 7,500 → 0.
      final r = engineFor(history).evaluate(b, nov, now: kNow);
      expect(r.carryInMinor, 0);

      final oct = engineFor(history).evaluate(b, nov.previous(), now: kNow);
      expect(oct.carryInMinor, 100000);
      expect(oct.limitMinor, 700000);
    });

    test('both: overspending reduces the next period', () {
      final b = budget(
        rollover: RolloverMode.both,
        rolloverSince: DateTime(2026, 9, 1),
      );
      // Sep +1,000 → Oct limit 7,000, spent 7,500 → −500 into Nov.
      final r = engineFor(history).evaluate(b, nov, now: kNow);
      expect(r.carryInMinor, -50000);
      expect(r.limitMinor, 550000);
    });

    test('turning rollover on never adds money to earlier periods', () {
      final b = budget(
        rollover: RolloverMode.both,
        rolloverSince: DateTime(2026, 11, 20),
      );
      expect(engineFor(history).evaluate(b, nov, now: kNow).carryInMinor, 0);
    });

    test('the chain starts no earlier than the budget itself', () {
      final b = budget(
        start: DateTime(2026, 10, 5),
        rollover: RolloverMode.both,
        rolloverSince: DateTime(2026, 1, 1),
      );
      // Only October is replayed: 6,000 − 7,500 = −1,500.
      expect(
        engineFor(history).evaluate(b, nov, now: kNow).carryInMinor,
        -150000,
      );
    });

    test('the chain is capped at twelve periods', () {
      final b = budget(
        start: DateTime(2020, 1, 1),
        rollover: RolloverMode.unspent,
        rolloverSince: DateTime(2020, 1, 1),
      );
      final r = engineFor(const []).evaluate(b, nov, now: kNow);
      expect(r.carryInMinor, BudgetEngine.maxRolloverPeriods * 600000);
    });

    test('a carried overspend never makes the limit negative', () {
      final b = budget(
        rollover: RolloverMode.both,
        rolloverSince: DateTime(2026, 10, 1),
      );
      final engine = engineFor([
        tx(DateTime(2026, 10, 10), 20000),
        tx(DateTime(2026, 11, 2), 10),
      ]);
      final r = engine.evaluate(b, nov, now: kNow);
      expect(r.carryInMinor, -1400000);
      expect(r.limitMinor, 0);
      expect(r.status, BudgetStatus.over);
    });
  });

  test('urgency order: over, at risk, on track', () {
    final engine = engineFor([
      tx(DateTime(2026, 11, 2), 7000, category: 'a'),
      tx(DateTime(2026, 11, 2), 9000, category: 'b'),
      for (var d = 1; d <= 5; d++)
        tx(DateTime(2026, 11, d), 1000, category: 'c'),
      tx(DateTime(2026, 11, 2), 100, category: 'd'),
    ]);
    final results = [
      for (final c in ['d', 'c', 'a', 'b'])
        engine.evaluate(budget(id: c, categories: [c]), nov, now: kNow),
    ]..sort(BudgetEngine.compareUrgency);
    expect(results.map((r) => r.budget.id), ['b', 'a', 'c', 'd']);
  });
}
