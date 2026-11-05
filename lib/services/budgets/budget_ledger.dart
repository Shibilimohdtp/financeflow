import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/transaction.dart';

/// One transaction as budgets see it: the amount that counts, in minor units.
class CountedTransaction {
  final String id;
  final DateTime date;
  final int amountMinor;
  final String categoryId;
  final String merchant;

  const CountedTransaction({
    required this.id,
    required this.date,
    required this.amountMinor,
    required this.categoryId,
    required this.merchant,
  });
}

/// A single pass over the ledger, bucketed for budget queries.
///
/// Build it once per data change from a date-bounded read, then answer every
/// budget, history and bill question from it without rescanning. Each bucket
/// is sorted by date so a period lookup is two binary searches.
class BudgetLedger {
  final Map<String, List<CountedTransaction>> _byCategory;
  final Map<String, List<CountedTransaction>> _bySubscription;
  final Map<String, List<CountedTransaction>> _byLoan;
  final List<CountedTransaction> _income;

  BudgetLedger._(
    this._byCategory,
    this._bySubscription,
    this._byLoan,
    this._income,
  );

  static final empty = BudgetLedger._(const {}, const {}, const {}, const []);

  /// A payment for a tracked subscription or loan. It belongs to the
  /// "Bills & EMIs" line, never to a category budget. Identified only by the
  /// typed link, never by merchant or category text.
  static bool isBillPayment(Transaction tx) =>
      (tx.linkedSubscriptionId != null || tx.linkedLoanId != null) &&
      tx.consumptionExpenseAmount > 0;

  /// The amount a category budget counts for [tx], in minor units: its
  /// consumption expense, unless it is a bill payment. Transfers, lending,
  /// income and investment principal are 0 by definition of
  /// [Transaction.consumptionExpenseAmount].
  static int countedMinor(Transaction tx) {
    if (isBillPayment(tx)) return 0;
    final amount = tx.consumptionExpenseAmount;
    return amount > 0 ? MoneyMath.toMinor(amount) : 0;
  }

  factory BudgetLedger.fromTransactions(Iterable<Transaction> transactions) {
    final byCategory = <String, List<CountedTransaction>>{};
    final bySubscription = <String, List<CountedTransaction>>{};
    final byLoan = <String, List<CountedTransaction>>{};
    final income = <CountedTransaction>[];

    for (final tx in transactions) {
      final merchant = tx.normalizedMerchant ?? tx.merchant;
      if (isBillPayment(tx)) {
        final row = CountedTransaction(
          id: tx.id,
          date: tx.date,
          amountMinor: MoneyMath.toMinor(tx.consumptionExpenseAmount),
          categoryId: tx.categoryId,
          merchant: merchant,
        );
        if (tx.linkedSubscriptionId != null) {
          (bySubscription[tx.linkedSubscriptionId!] ??= []).add(row);
        } else {
          (byLoan[tx.linkedLoanId!] ??= []).add(row);
        }
        continue;
      }
      final counted = countedMinor(tx);
      if (counted > 0) {
        (byCategory[tx.categoryId] ??= []).add(
          CountedTransaction(
            id: tx.id,
            date: tx.date,
            amountMinor: counted,
            categoryId: tx.categoryId,
            merchant: merchant,
          ),
        );
      }
      final earned = tx.earnedIncomeAmount;
      if (earned > 0) {
        income.add(
          CountedTransaction(
            id: tx.id,
            date: tx.date,
            amountMinor: MoneyMath.toMinor(earned),
            categoryId: tx.categoryId,
            merchant: merchant,
          ),
        );
      }
    }

    int byDate(CountedTransaction a, CountedTransaction b) {
      final c = a.date.compareTo(b.date);
      return c != 0 ? c : a.id.compareTo(b.id);
    }

    for (final list in byCategory.values) {
      list.sort(byDate);
    }
    for (final list in bySubscription.values) {
      list.sort(byDate);
    }
    for (final list in byLoan.values) {
      list.sort(byDate);
    }
    income.sort(byDate);
    return BudgetLedger._(byCategory, bySubscription, byLoan, income);
  }

  /// Counted transactions in any of [categoryIds] within [period], oldest
  /// first. A category listed twice is still read once, so overlapping
  /// budgets never double-count in a combined total.
  List<CountedTransaction> transactionsIn(
    Iterable<String> categoryIds,
    Period period,
  ) {
    final result = <CountedTransaction>[];
    for (final id in categoryIds.toSet()) {
      result.addAll(_slice(_byCategory[id], period));
    }
    if (categoryIds.toSet().length > 1) {
      result.sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    }
    return result;
  }

  int spentMinor(Iterable<String> categoryIds, Period period) {
    var total = 0;
    for (final id in categoryIds.toSet()) {
      for (final row in _slice(_byCategory[id], period)) {
        total += row.amountMinor;
      }
    }
    return total;
  }

  /// Whether any counted spending exists in [categoryIds] during [period].
  bool hasSpending(Iterable<String> categoryIds, Period period) => categoryIds
      .toSet()
      .any((id) => _slice(_byCategory[id], period).isNotEmpty);

  List<CountedTransaction> subscriptionPayments(String id, Period period) =>
      _slice(_bySubscription[id], period);

  List<CountedTransaction> loanPayments(String id, Period period) =>
      _slice(_byLoan[id], period);

  int incomeMinor(Period period) {
    var total = 0;
    for (final row in _slice(_income, period)) {
      total += row.amountMinor;
    }
    return total;
  }

  /// Category ids that have counted spending at any time in this ledger.
  Iterable<String> get spendingCategoryIds => _byCategory.keys;

  static List<CountedTransaction> _slice(
    List<CountedTransaction>? rows,
    Period period,
  ) {
    if (rows == null || rows.isEmpty) return const [];
    final from = _lowerBound(rows, period.start);
    final to = _lowerBound(rows, period.endExclusive);
    if (from >= to) return const [];
    return rows.sublist(from, to);
  }

  /// First index whose date is not before [instant].
  static int _lowerBound(List<CountedTransaction> rows, DateTime instant) {
    var lo = 0;
    var hi = rows.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (rows[mid].date.isBefore(instant)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }
}
