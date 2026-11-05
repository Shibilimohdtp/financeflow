import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ledger_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 23, 10);
  final account = Account(
    id: 'account',
    name: 'Everyday account',
    type: AccountType.bank,
    createdAt: now,
    updatedAt: now,
  );
  Transaction transaction({
    required String id,
    required String merchant,
    required double amount,
    required TransactionType type,
    TransactionPurpose? purpose,
    DateTime? date,
    String? notes,
    String? paymentMethod,
    String accountId = 'account',
    String? toAccountId,
    List<String> tags = const [],
  }) => Transaction(
    id: id,
    merchant: merchant,
    amount: amount,
    type: type,
    purpose: purpose,
    categoryId: type == TransactionType.income ? 'income' : 'food',
    categoryName: type == TransactionType.income ? 'Salary' : 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    accountId: accountId,
    toAccountId: toAccountId,
    date: date ?? now,
    notes: notes,
    paymentMethod: paymentMethod,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );

  final items = [
    transaction(
      id: '1',
      merchant: 'Metro Market',
      amount: 84.50,
      type: TransactionType.expense,
      notes: 'weekly groceries',
      paymentMethod: 'UPI',
      tags: ['home'],
    ),
    transaction(
      id: '2',
      merchant: 'Acme',
      amount: 2500,
      type: TransactionType.income,
      date: DateTime(2026, 8, 21, 9),
    ),
    transaction(
      id: '3',
      merchant: 'Savings move',
      amount: 400,
      type: TransactionType.transfer,
      toAccountId: 'savings',
      date: DateTime(2026, 8, 13),
    ),
    transaction(
      id: '4',
      merchant: 'Fund',
      amount: 900,
      type: TransactionType.investment,
      date: DateTime(2026, 7, 24),
    ),
    transaction(
      id: '5',
      merchant: 'Bike EMI',
      amount: 9047.92,
      type: TransactionType.loanEmi,
      date: DateTime(2026, 8, 21, 8),
    ),
  ];

  List<Transaction> run(TransactionQuery query) => applyTransactionQuery(
    transactions: items,
    query: query,
    accounts: [account],
  );

  group('TransactionKind', () {
    test('agrees with what totals count as spending and income', () {
      for (final tx in items) {
        final kind = TransactionKind.of(tx);
        expect(
          kind == TransactionKind.spending,
          tx.consumptionExpenseAmount > 0 &&
              tx.effectivePurpose != TransactionPurpose.investmentPurchase,
          reason: tx.merchant,
        );
        expect(
          kind == TransactionKind.income,
          tx.earnedIncomeAmount > 0,
          reason: tx.merchant,
        );
      }
    });

    test('EMI is spending, transfer is transfer, investing is other', () {
      expect(TransactionKind.of(items[4]), TransactionKind.spending);
      expect(TransactionKind.of(items[2]), TransactionKind.transfer);
      expect(TransactionKind.of(items[3]), TransactionKind.other);
    });
  });

  group('TransactionQuery', () {
    test('defaults to the current month', () {
      final q = TransactionQuery.initial(now: now);
      expect(q.period, Period.containing(PeriodUnit.month, now));
      expect(run(q).map((t) => t.id), ['1', '2', '5', '3']);
    });

    test('all time includes every period', () {
      expect(run(const TransactionQuery()), hasLength(5));
    });

    test('searches merchant, notes, amount, category, account, method', () {
      for (final query in [
        'metro',
        'groceries',
        '84.50',
        'food',
        'everyday',
        'upi',
        'home',
        '  metro   market ',
      ]) {
        expect(
          run(TransactionQuery(search: query)).map((t) => t.id),
          contains('1'),
          reason: query,
        );
      }
      expect(run(const TransactionQuery(search: 'zomato')), isEmpty);
    });

    test('kinds filter is a union of the selected kinds', () {
      final q = TransactionQuery(
        kinds: {TransactionKind.spending, TransactionKind.income},
      );
      expect(run(q).map((t) => t.id).toSet(), {'1', '2', '5'});
    });

    test('account filter matches either side of a transfer', () {
      expect(
        run(const TransactionQuery(accountId: 'savings')).map((t) => t.id),
        ['3'],
      );
    });

    test('amount range is inclusive', () {
      final q = TransactionQuery(minAmount: 400, maxAmount: 2500);
      expect(run(q).map((t) => t.id).toSet(), {'2', '3', '4'});
    });

    test('sorts by amount', () {
      expect(
        run(const TransactionQuery(sort: TransactionSort.amountHigh)).first.id,
        '5',
      );
      expect(
        run(const TransactionQuery(sort: TransactionSort.amountLow)).first.id,
        '1',
      );
    });

    test('cleared() keeps period and sort only', () {
      final period = Period.containing(PeriodUnit.month, now);
      final q =
          TransactionQuery(
            period: period,
            sort: TransactionSort.oldest,
            accountId: 'a',
            kinds: {TransactionKind.income},
            search: 'x',
          ).cleared();
      expect(q.period, period);
      expect(q.sort, TransactionSort.oldest);
      expect(q.hasRefinements, isFalse);
      expect(q.hasSearch, isFalse);
    });

    test('equality ignores kind order', () {
      expect(
        TransactionQuery(
          kinds: {TransactionKind.income, TransactionKind.spending},
        ),
        TransactionQuery(
          kinds: {TransactionKind.spending, TransactionKind.income},
        ),
      );
    });
  });

  group('day groups', () {
    test('one group per calendar day with that day\'s totals', () {
      final sorted = run(TransactionQuery.initial(now: now));
      final groups = groupTransactionsByDay(sorted);
      expect(groups.map((g) => g.day), [
        DateTime(2026, 8, 23),
        DateTime(2026, 8, 21),
        DateTime(2026, 8, 13),
      ]);
      final aug21 = groups[1];
      expect(aug21.totals.income, 2500);
      expect(aug21.totals.spending, closeTo(9047.92, 1e-9));
      // Transfers do not count as spending or income.
      expect(groups[2].totals.spending, 0);
      expect(groups[2].totals.income, 0);
    });

    test('day totals add up to the list total', () {
      final sorted = run(const TransactionQuery());
      final groups = groupTransactionsByDay(sorted);
      final whole = LedgerTotals.of(sorted);
      expect(
        groups.fold<double>(0, (s, g) => s + g.totals.spending),
        closeTo(whole.spending, 1e-9),
      );
      expect(
        groups.fold<double>(0, (s, g) => s + g.totals.income),
        closeTo(whole.income, 1e-9),
      );
    });

    test('labels', () {
      expect(dayLabel(DateTime(2026, 8, 23), now: now), 'Today');
      expect(dayLabel(DateTime(2026, 8, 22), now: now), 'Yesterday');
      expect(dayLabel(DateTime(2026, 8, 3), now: now), 'Mon, 3 Aug');
      expect(dayLabel(DateTime(2025, 8, 4), now: now), 'Mon, 4 Aug 2025');
      expect(
        dayLabel(DateTime(2026, 9, 1), now: DateTime(2026, 9, 1, 0, 5)),
        'Today',
      );
    });
  });

  test('period labels', () {
    expect(periodLabel(null), 'All time');
    expect(
      periodLabel(Period.containing(PeriodUnit.month, now), now: now),
      'August 2026',
    );
    expect(
      periodLabel(Period.containing(PeriodUnit.week, now), now: now),
      'This week',
    );
    expect(periodLabel(Period.containing(PeriodUnit.year, now)), '2026');
  });
}
