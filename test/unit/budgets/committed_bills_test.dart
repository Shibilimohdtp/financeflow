import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budgets/budget_ledger.dart';
import 'package:financeflow/services/budgets/committed_bills.dart';
import 'package:flutter_test/flutter_test.dart';

import 'budget_fixtures.dart';

Subscription sub(
  String id,
  DateTime next, {
  SubscriptionFrequency frequency = SubscriptionFrequency.monthly,
  SubscriptionStatus status = SubscriptionStatus.active,
  double amount = 499,
  DateTime? created,
}) => Subscription(
  id: id,
  merchant: id,
  normalizedMerchant: id,
  amount: amount,
  billingFrequency: frequency,
  nextRenewalDate: next,
  status: status,
  createdAt: created ?? DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

Loan loan(String id, DateTime next, {DateTime? end, LoanStatus? status}) =>
    Loan(
      id: id,
      name: id,
      lender: 'Bank',
      principalAmount: 500000,
      interestRate: 10,
      tenureMonths: 24,
      startDate: DateTime(2025, 1, 5),
      expectedEndDate: end ?? DateTime(2027, 1, 5),
      emiAmount: 15000,
      outstandingPrincipal: 250000,
      nextDueDate: next,
      status: status ?? LoanStatus.active,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

void main() {
  final nov = Period.containing(PeriodUnit.month, kNow);

  CommittedBills bills({
    List<Subscription> subs = const [],
    List<Loan> loans = const [],
    List<Transaction> txs = const [],
    Period? period,
  }) => CommittedBills.forPeriod(
    period: period ?? nov,
    ledger: BudgetLedger.fromTransactions(txs),
    subscriptions: subs,
    loans: loans,
  );

  test('an upcoming renewal is due', () {
    final b = bills(subs: [sub('netflix', DateTime(2026, 11, 20))]);
    expect(b.occurrences.single.dueDate, DateTime(2026, 11, 20));
    expect(b.dueMinor, 49900);
  });

  test('a renewal before the next due date is already settled', () {
    final b = bills(subs: [sub('music', DateTime(2026, 12, 5))]);
    expect(b.occurrences.single.dueDate, DateTime(2026, 11, 5));
    expect(b.occurrences.single.isPaid, isTrue);
    expect(b.dueMinor, 0);
  });

  test('a linked payment settles the bill and is what was paid', () {
    final b = bills(
      subs: [sub('gym', DateTime(2026, 11, 10))],
      txs: [tx(DateTime(2026, 11, 10), 499, subscriptionId: 'gym')],
    );
    expect(b.occurrences.single.isPaid, isTrue);
    expect(b.paidMinor, 49900);
    expect(b.dueMinor, 0);
  });

  test('weekly renewals after the subscription began', () {
    final b = bills(
      subs: [
        sub(
          'paper',
          DateTime(2026, 11, 18),
          frequency: SubscriptionFrequency.weekly,
          amount: 50,
          created: DateTime(2026, 11, 10),
        ),
      ],
    );
    expect(b.occurrences.map((o) => o.dueDate), [
      DateTime(2026, 11, 11),
      DateTime(2026, 11, 18),
      DateTime(2026, 11, 25),
    ]);
    expect(b.dueMinor, 10000);
  });

  test('month-end due dates clamp to short months', () {
    final s = sub('rent', DateTime(2026, 1, 31));
    final feb = Period.containing(PeriodUnit.month, DateTime(2026, 2, 1));
    final mar = Period.containing(PeriodUnit.month, DateTime(2026, 3, 1));
    expect(
      bills(subs: [s], period: feb).occurrences.single.dueDate,
      DateTime(2026, 2, 28),
    );
    expect(
      bills(subs: [s], period: mar).occurrences.single.dueDate,
      DateTime(2026, 3, 31),
    );
  });

  test('quarterly renewals step back from a future anchor', () {
    final sep = Period.containing(PeriodUnit.month, DateTime(2026, 9, 1));
    final b = bills(
      subs: [
        sub(
          'cloud',
          DateTime(2026, 12, 15),
          frequency: SubscriptionFrequency.quarterly,
        ),
      ],
      period: sep,
    );
    expect(b.occurrences.single.dueDate, DateTime(2026, 9, 15));
  });

  test('paused and cancelled subscriptions are not bills', () {
    final b = bills(
      subs: [
        sub('a', DateTime(2026, 11, 20), status: SubscriptionStatus.paused),
        sub('b', DateTime(2026, 11, 20), status: SubscriptionStatus.cancelled),
      ],
    );
    expect(b.occurrences, isEmpty);
  });

  test('EMIs: due, paid through the link, and not after the loan ends', () {
    final txs = [
      tx(
        DateTime(2026, 11, 5),
        15000,
        purpose: TransactionPurpose.loanRepayment,
        loanId: 'car',
      ),
    ];
    final b = bills(
      loans: [
        loan('car', DateTime(2026, 11, 5)),
        loan('home', DateTime(2026, 11, 25)),
        loan('ended', DateTime(2026, 11, 5), end: DateTime(2026, 10, 5)),
        loan('done', DateTime(2026, 11, 5), status: LoanStatus.paidOff),
      ],
      txs: txs,
    );
    expect(b.occurrences.map((o) => o.sourceId), ['car', 'home']);
    expect(b.occurrences.first.isPaid, isTrue);
    expect(b.paidMinor, 1500000);
    expect(b.dueMinor, 1500000);
  });
}
