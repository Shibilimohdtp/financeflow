import '../../core/period/period.dart';

export '../../core/period/period_format.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../services/budgets/budget_ledger.dart';
import '../../services/ledger_totals.dart';

/// How a transaction is shown and filtered in the list. Derived from
/// [Transaction.effectivePurpose] so it always agrees with the totals:
/// everything in [spending] counts as spending, everything in [income] as
/// income, and the other kinds count as neither.
enum TransactionKind {
  spending('Spending'),
  income('Income'),
  transfer('Transfers'),
  other('Lending & other');

  final String label;
  const TransactionKind(this.label);

  static TransactionKind of(Transaction tx) => switch (tx.effectivePurpose) {
    TransactionPurpose.expense ||
    TransactionPurpose.legacyCash ||
    TransactionPurpose.subscriptionPayment ||
    TransactionPurpose.loanRepayment => spending,
    TransactionPurpose.income => income,
    TransactionPurpose.internalTransfer => transfer,
    _ => other,
  };
}

enum TransactionSort {
  newest('Newest first'),
  oldest('Oldest first'),
  amountHigh('Largest first'),
  amountLow('Smallest first');

  final String label;
  const TransactionSort(this.label);

  bool get isByDate => this == newest || this == oldest;
}

/// Limits the list to exactly what one or more budgets count: transactions
/// in [categoryIds] whose budget amount is above zero
/// ([BudgetLedger.countedMinor]). Bill and EMI payments linked to a tracked
/// subscription or loan, transfers, lending and income are left out, so the
/// list's "Spent" equals the budget figure it was opened from, to the cent.
class BudgetScope {
  final Set<String> categoryIds;

  /// Shown on the filter chip, e.g. "Dining budget" or "November plan".
  final String label;

  const BudgetScope({required this.categoryIds, required this.label});

  bool matches(Transaction tx) =>
      categoryIds.contains(tx.categoryId) && BudgetLedger.countedMinor(tx) > 0;

  @override
  bool operator ==(Object other) =>
      other is BudgetScope &&
      other.label == label &&
      other.categoryIds.length == categoryIds.length &&
      other.categoryIds.containsAll(categoryIds);

  @override
  int get hashCode => Object.hash(label, Object.hashAllUnordered(categoryIds));
}

/// Everything that decides which transactions the list shows. A null
/// [period] means all time.
class TransactionQuery {
  final Period? period;
  final Set<TransactionKind> kinds;
  final String? accountId;
  final String? categoryId;
  final String? tag;
  final String? paymentMethod;
  final double? minAmount;
  final double? maxAmount;
  final String search;
  final TransactionSort sort;

  /// Opened from a budget figure: only what those budgets count.
  final BudgetScope? budgetScope;

  const TransactionQuery({
    this.period,
    this.kinds = const {},
    this.accountId,
    this.categoryId,
    this.tag,
    this.paymentMethod,
    this.minAmount,
    this.maxAmount,
    this.search = '',
    this.sort = TransactionSort.newest,
    this.budgetScope,
  });

  /// The default view: the current month, newest first.
  factory TransactionQuery.initial({DateTime? now}) => TransactionQuery(
    period: Period.containing(PeriodUnit.month, now ?? DateTime.now()),
  );

  TransactionQuery copyWith({
    Period? period,
    bool allTime = false,
    Set<TransactionKind>? kinds,
    String? accountId,
    bool clearAccount = false,
    String? categoryId,
    bool clearCategory = false,
    String? tag,
    bool clearTag = false,
    String? paymentMethod,
    bool clearPaymentMethod = false,
    double? minAmount,
    double? maxAmount,
    bool clearAmount = false,
    String? search,
    TransactionSort? sort,
    BudgetScope? budgetScope,
    bool clearBudgetScope = false,
  }) {
    return TransactionQuery(
      period: allTime ? null : (period ?? this.period),
      kinds: kinds ?? this.kinds,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      tag: clearTag ? null : (tag ?? this.tag),
      paymentMethod:
          clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      minAmount: clearAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmount ? null : (maxAmount ?? this.maxAmount),
      search: search ?? this.search,
      sort: sort ?? this.sort,
      budgetScope:
          clearBudgetScope ? null : (budgetScope ?? this.budgetScope),
    );
  }

  /// Filters other than the period and search, which have their own controls.
  bool get hasRefinements =>
      kinds.isNotEmpty ||
      accountId != null ||
      categoryId != null ||
      tag != null ||
      paymentMethod != null ||
      minAmount != null ||
      maxAmount != null ||
      budgetScope != null;

  bool get hasSearch => search.trim().isNotEmpty;

  /// Keeps the period and sort, removes every other filter.
  TransactionQuery cleared() => TransactionQuery(period: period, sort: sort);

  bool matches(Transaction tx, {Map<String, String> accountNames = const {}}) {
    final p = period;
    if (p != null && !p.contains(tx.date)) return false;
    if (kinds.isNotEmpty && !kinds.contains(TransactionKind.of(tx))) {
      return false;
    }
    if (accountId != null &&
        tx.accountId != accountId &&
        tx.toAccountId != accountId) {
      return false;
    }
    if (categoryId != null && tx.categoryId != categoryId) return false;
    if (budgetScope != null && !budgetScope!.matches(tx)) return false;
    if (tag != null &&
        !tx.tags.any((t) => t.toLowerCase() == tag!.toLowerCase())) {
      return false;
    }
    if (paymentMethod != null &&
        tx.paymentMethod?.toLowerCase() != paymentMethod!.toLowerCase()) {
      return false;
    }
    if (minAmount != null && tx.amount < minAmount!) return false;
    if (maxAmount != null && tx.amount > maxAmount!) return false;
    if (!hasSearch) return true;
    return _searchText(tx, accountNames).contains(_normalize(search));
  }

  @override
  bool operator ==(Object other) =>
      other is TransactionQuery &&
      other.period == period &&
      other.kinds.length == kinds.length &&
      other.kinds.containsAll(kinds) &&
      other.accountId == accountId &&
      other.categoryId == categoryId &&
      other.tag == tag &&
      other.paymentMethod == paymentMethod &&
      other.minAmount == minAmount &&
      other.maxAmount == maxAmount &&
      other.search == search &&
      other.sort == sort &&
      other.budgetScope == budgetScope;

  @override
  int get hashCode => Object.hash(
    period,
    Object.hashAllUnordered(kinds),
    accountId,
    categoryId,
    tag,
    paymentMethod,
    minAmount,
    maxAmount,
    search,
    sort,
    budgetScope,
  );
}

String _normalize(String s) =>
    s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _searchText(Transaction tx, Map<String, String> accountNames) {
  final amount = tx.amount;
  final amountText =
      amount == amount.roundToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2);
  return _normalize(
    [
      tx.merchant,
      tx.normalizedMerchant ?? '',
      tx.notes ?? '',
      tx.categoryName,
      tx.paymentMethod ?? '',
      tx.externalCounterpartyName ?? '',
      amountText,
      accountNames[tx.accountId] ?? '',
      accountNames[tx.toAccountId] ?? '',
      ...tx.tags,
    ].join(' '),
  );
}

/// Applies [query] and its sort order.
List<Transaction> applyTransactionQuery({
  required Iterable<Transaction> transactions,
  required TransactionQuery query,
  Iterable<Account> accounts = const [],
}) {
  final names = {for (final a in accounts) a.id: a.name};
  final results =
      transactions
          .where((tx) => query.matches(tx, accountNames: names))
          .toList()
        ..sort(
          (a, b) => switch (query.sort) {
            TransactionSort.newest => b.date.compareTo(a.date),
            TransactionSort.oldest => a.date.compareTo(b.date),
            TransactionSort.amountHigh => b.amount.compareTo(a.amount),
            TransactionSort.amountLow => a.amount.compareTo(b.amount),
          },
        );
  return results;
}

/// One calendar day of the list with that day's totals.
class TransactionDayGroup {
  final DateTime day;
  final List<Transaction> transactions;
  final LedgerTotals totals;

  const TransactionDayGroup({
    required this.day,
    required this.transactions,
    required this.totals,
  });
}

/// Groups an already-sorted list by calendar day, preserving order.
List<TransactionDayGroup> groupTransactionsByDay(List<Transaction> sorted) {
  final groups = <TransactionDayGroup>[];
  DateTime? currentDay;
  var current = <Transaction>[];

  void flush() {
    final day = currentDay;
    if (day == null) return;
    groups.add(
      TransactionDayGroup(
        day: day,
        transactions: current,
        totals: LedgerTotals.of(current),
      ),
    );
  }

  for (final tx in sorted) {
    final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
    if (day != currentDay) {
      flush();
      currentDay = day;
      current = <Transaction>[];
    }
    current.add(tx);
  }
  flush();
  return groups;
}
