import '../../models/account.dart';
import '../../models/transaction.dart';
import 'transactions_controller.dart';

extension TransactionSortLabel on TransactionSort {
  String get label => switch (this) {
    TransactionSort.newest => 'Newest first',
    TransactionSort.oldest => 'Oldest first',
    TransactionSort.amountHigh => 'Amount: high to low',
    TransactionSort.amountLow => 'Amount: low to high',
  };
}

class TransactionListSummary {
  const TransactionListSummary({required this.income, required this.expenses});

  final double income;
  final double expenses;
  double get net => income - expenses;
}

class TransactionDateGroup {
  const TransactionDateGroup({
    required this.label,
    required this.transactions,
    required this.net,
    required this.showDateInRows,
  });

  final String label;
  final List<Transaction> transactions;
  final double net;
  final bool showDateInRows;
}

List<Transaction> applyTransactionFilter({
  required Iterable<Transaction> transactions,
  required TransactionFilterState filter,
  required Iterable<Account> accounts,
}) {
  final accountNames = {
    for (final account in accounts) account.id: account.name,
  };
  final query = filter.searchQuery.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final results =
      transactions.where((transaction) {
        if (filter.selectedType != null &&
            transaction.type != filter.selectedType) {
          return false;
        }
        if (filter.selectedCategoryId != null &&
            transaction.categoryId != filter.selectedCategoryId) {
          return false;
        }
        if (filter.selectedAccountId != null &&
            transaction.accountId != filter.selectedAccountId &&
            transaction.toAccountId != filter.selectedAccountId) {
          return false;
        }
        if (filter.paymentMethod != null &&
            transaction.paymentMethod?.toLowerCase() !=
                filter.paymentMethod!.toLowerCase()) {
          return false;
        }
        if (filter.tag != null &&
            !transaction.tags.any(
              (tag) => tag.toLowerCase() == filter.tag!.toLowerCase(),
            )) {
          return false;
        }
        if (filter.startDate != null &&
            transaction.date.isBefore(_startOfDay(filter.startDate!))) {
          return false;
        }
        if (filter.endDate != null &&
            transaction.date.isAfter(_endOfDay(filter.endDate!))) {
          return false;
        }
        if (query.isEmpty) return true;

        final searchable =
            <String>[
              transaction.merchant,
              transaction.normalizedMerchant ?? '',
              transaction.notes ?? '',
              transaction.amount.toString(),
              transaction.categoryName,
              transaction.paymentMethod ?? '',
              transaction.type.displayName,
              accountNames[transaction.accountId] ?? transaction.accountId,
              accountNames[transaction.toAccountId] ??
                  transaction.toAccountId ??
                  '',
              ...transaction.tags,
            ].join(' ').toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        return searchable.contains(query);
      }).toList();

  results.sort(
    (a, b) => switch (filter.sort) {
      TransactionSort.newest => b.date.compareTo(a.date),
      TransactionSort.oldest => a.date.compareTo(b.date),
      TransactionSort.amountHigh => b.amount.compareTo(a.amount),
      TransactionSort.amountLow => a.amount.compareTo(b.amount),
    },
  );
  return results;
}

TransactionListSummary calculateTransactionListSummary(
  Iterable<Transaction> transactions,
) {
  var income = 0.0;
  var expenses = 0.0;
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else if (transaction.type != TransactionType.transfer) {
      expenses += transaction.amount;
    }
  }
  return TransactionListSummary(income: income, expenses: expenses);
}

List<TransactionDateGroup> groupTransactionsForList(
  List<Transaction> transactions, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final today = _startOfDay(reference);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final startOfMonth = DateTime(today.year, today.month);
  final groups = <String, List<Transaction>>{};

  for (final transaction in transactions) {
    final day = _startOfDay(transaction.date);
    final label =
        day == today
            ? 'Today'
            : day == today.subtract(const Duration(days: 1))
            ? 'Yesterday'
            : !day.isBefore(startOfWeek)
            ? 'This week'
            : !day.isBefore(startOfMonth)
            ? 'Earlier this month'
            : 'Older dates';
    groups.putIfAbsent(label, () => []).add(transaction);
  }

  return groups.entries.map((entry) {
    final summary = calculateTransactionListSummary(entry.value);
    return TransactionDateGroup(
      label: entry.key,
      transactions: entry.value,
      net: summary.net,
      showDateInRows: entry.key != 'Today' && entry.key != 'Yesterday',
    );
  }).toList();
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
