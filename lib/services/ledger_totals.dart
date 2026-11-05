import '../models/transaction.dart';

/// Income and spending totals, using the single definition of each that
/// lives on [Transaction] (`earnedIncomeAmount`, `consumptionExpenseAmount`).
/// Transfers, lending and other non-reportable movements contribute zero.
class LedgerTotals {
  final double income;
  final double spending;

  /// Transactions that contributed income or spending.
  final int count;

  const LedgerTotals({
    required this.income,
    required this.spending,
    required this.count,
  });

  static const zero = LedgerTotals(income: 0, spending: 0, count: 0);

  factory LedgerTotals.of(Iterable<Transaction> transactions) {
    var income = 0.0;
    var spending = 0.0;
    var count = 0;
    for (final tx in transactions) {
      final inc = tx.earnedIncomeAmount;
      final exp = tx.consumptionExpenseAmount;
      if (inc == 0 && exp == 0) continue;
      income += inc;
      spending += exp;
      count++;
    }
    return LedgerTotals(income: income, spending: spending, count: count);
  }

  double get net => income - spending;

  /// Percentage change from [previous] to [current], or null when there is no
  /// meaningful base (nothing in the previous window).
  static double? percentChange(double current, double previous) {
    if (previous <= 0) return null;
    return (current - previous) / previous * 100;
  }
}
