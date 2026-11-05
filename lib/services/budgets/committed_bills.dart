import 'dart:math' as math;

import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/loan.dart';
import '../../models/subscription.dart';
import 'budget_ledger.dart';

enum BillKind { subscription, loan }

/// One expected bill or EMI due inside a period.
class BillOccurrence {
  final String sourceId;
  final BillKind kind;
  final String name;
  final DateTime dueDate;
  final int amountMinor;
  final bool isPaid;

  const BillOccurrence({
    required this.sourceId,
    required this.kind,
    required this.name,
    required this.dueDate,
    required this.amountMinor,
    required this.isPaid,
  });
}

/// The "Bills & EMIs" line: money already spoken for by tracked
/// subscriptions and loans in a period.
///
/// Payments are matched only through the typed `linkedSubscriptionId` /
/// `linkedLoanId` links. A due date before the subscription's or loan's next
/// due date is treated as settled, because those dates only move forward
/// once a payment is recorded or skipped.
class CommittedBills {
  final Period period;
  final List<BillOccurrence> occurrences;

  /// What linked bill payments actually cost in the period.
  final int paidMinor;

  const CommittedBills({
    required this.period,
    required this.occurrences,
    required this.paidMinor,
  });

  static CommittedBills none(Period period) =>
      CommittedBills(period: period, occurrences: const [], paidMinor: 0);

  List<BillOccurrence> get unpaid =>
      occurrences.where((o) => !o.isPaid).toList();

  int get dueMinor => unpaid.fold(0, (sum, o) => sum + o.amountMinor);

  factory CommittedBills.forPeriod({
    required Period period,
    required BudgetLedger ledger,
    Iterable<Subscription> subscriptions = const [],
    Iterable<Loan> loans = const [],
  }) {
    final occurrences = <BillOccurrence>[];
    var paid = 0;

    for (final sub in subscriptions) {
      if (sub.status != SubscriptionStatus.active) continue;
      final payments = ledger.subscriptionPayments(sub.id, period);
      paid += payments.fold<int>(0, (s, p) => s + p.amountMinor);
      final dates = _dueDates(
        anchor: sub.nextRenewalDate,
        months: switch (sub.billingFrequency) {
          SubscriptionFrequency.monthly => 1,
          SubscriptionFrequency.quarterly => 3,
          SubscriptionFrequency.yearly => 12,
          _ => 0,
        },
        weekly: sub.billingFrequency == SubscriptionFrequency.weekly,
        period: period,
        notBefore: sub.createdAt,
      );
      occurrences.addAll(
        _settle(
          dates,
          next: sub.nextRenewalDate,
          paymentCount: payments.length,
          build:
              (date, isPaid) => BillOccurrence(
                sourceId: sub.id,
                kind: BillKind.subscription,
                name: sub.merchant,
                dueDate: date,
                amountMinor: MoneyMath.toMinor(sub.amount),
                isPaid: isPaid,
              ),
        ),
      );
    }

    for (final loan in loans) {
      if (loan.status != LoanStatus.active) continue;
      final payments = ledger.loanPayments(loan.id, period);
      paid += payments.fold<int>(0, (s, p) => s + p.amountMinor);
      final dates = _dueDates(
        anchor: loan.nextDueDate,
        months: 1,
        weekly: false,
        period: period,
        notBefore: loan.startDate,
        notAfter: loan.expectedEndDate,
      );
      occurrences.addAll(
        _settle(
          dates,
          next: loan.nextDueDate,
          paymentCount: payments.length,
          build:
              (date, isPaid) => BillOccurrence(
                sourceId: loan.id,
                kind: BillKind.loan,
                name: loan.name,
                dueDate: date,
                amountMinor: MoneyMath.toMinor(loan.emiAmount),
                isPaid: isPaid,
              ),
        ),
      );
    }

    occurrences.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return CommittedBills(
      period: period,
      occurrences: occurrences,
      paidMinor: paid,
    );
  }

  /// Due dates before [next] are settled. Payments recorded in the period
  /// beyond those settle the earliest remaining dates.
  static List<BillOccurrence> _settle(
    List<DateTime> dates, {
    required DateTime next,
    required int paymentCount,
    required BillOccurrence Function(DateTime date, bool isPaid) build,
  }) {
    final nextDay = DateTime(next.year, next.month, next.day);
    final settled = dates.where((d) => d.isBefore(nextDay)).length;
    var extraPaid = math.max(0, paymentCount - settled);
    return [
      for (final d in dates)
        if (d.isBefore(nextDay)) build(d, true) else build(d, extraPaid-- > 0),
    ];
  }

  /// Every due date of a schedule anchored on [anchor] inside [period].
  /// Month steps keep the anchor's day, clamped to short months (31 Jan →
  /// 28/29 Feb → 31 Mar). [months] 0 and not weekly means a single date.
  static List<DateTime> _dueDates({
    required DateTime anchor,
    required int months,
    required bool weekly,
    required Period period,
    DateTime? notBefore,
    DateTime? notAfter,
  }) {
    final a = DateTime(anchor.year, anchor.month, anchor.day);
    DateTime at(int step) {
      if (weekly) return DateTime(a.year, a.month, a.day + 7 * step);
      final first = DateTime(a.year, a.month + months * step);
      final lastDay = DateTime(first.year, first.month + 1, 0).day;
      return DateTime(first.year, first.month, math.min(a.day, lastDay));
    }

    final lower =
        notBefore == null
            ? null
            : DateTime(notBefore.year, notBefore.month, notBefore.day);
    final upper =
        notAfter == null
            ? null
            : DateTime(notAfter.year, notAfter.month, notAfter.day);
    bool allowed(DateTime d) =>
        period.contains(d) &&
        (lower == null || !d.isBefore(lower)) &&
        (upper == null || !d.isAfter(upper));

    if (months == 0 && !weekly) return allowed(a) ? [a] : const [];

    final dates = <DateTime>[];
    // Step back to before the period, then forward through it.
    var step = 0;
    while (!at(step).isBefore(period.start)) {
      step--;
    }
    for (var d = at(step); d.isBefore(period.endExclusive); d = at(++step)) {
      if (allowed(d)) dates.add(d);
    }
    return dates;
  }
}
