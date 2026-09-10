import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/transaction.dart';
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
    DateTime? date,
    String? notes,
    String? paymentMethod,
    List<String> tags = const [],
  }) => Transaction(
    id: id,
    merchant: merchant,
    amount: amount,
    type: type,
    categoryId: type == TransactionType.income ? 'income' : 'food',
    categoryName: type == TransactionType.income ? 'Salary' : 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    accountId: account.id,
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
      date: now.subtract(const Duration(days: 2)),
    ),
    transaction(
      id: '3',
      merchant: 'Transfer',
      amount: 400,
      type: TransactionType.transfer,
      date: now.subtract(const Duration(days: 10)),
    ),
    transaction(
      id: '4',
      merchant: 'Fund',
      amount: 900,
      type: TransactionType.investment,
      date: now.subtract(const Duration(days: 30)),
    ),
  ];

  test(
    'searches merchant, notes, amount, category, account and payment method',
    () {
      for (final query in [
        'metro',
        'groceries',
        '84.5',
        'food',
        'everyday',
        'upi',
      ]) {
        expect(
          applyTransactionFilter(
            transactions: items,
            filter: TransactionFilterState(searchQuery: query),
            accounts: [account],
          ).map((item) => item.id),
          contains('1'),
        );
      }
      expect(
        applyTransactionFilter(
          transactions: items,
          filter: const TransactionFilterState(searchQuery: 'income'),
          accounts: [account],
        ).single.id,
        '2',
      );
    },
  );

  test('combines filters and applies sorting', () {
    final filtered = applyTransactionFilter(
      transactions: items,
      filter: const TransactionFilterState(
        selectedCategoryId: 'food',
        paymentMethod: 'UPI',
        sort: TransactionSort.amountLow,
      ),
      accounts: [account],
    );
    expect(filtered.map((item) => item.id), ['1']);
  });

  test('summaries exclude transfers and groups dates for scanning', () {
    final summary = calculateTransactionListSummary(items);
    expect(summary.income, 2500);
    expect(summary.expenses, 84.50);
    expect(summary.net, 2415.50);
    expect(
      groupTransactionsForList(items, now: now).map((group) => group.label),
      ['Today', 'This week', 'Earlier this month', 'Older dates'],
    );
  });

  test('default filter is clear and newest first', () {
    const filter = TransactionFilterState();
    expect(filter.hasActiveFilters, isFalse);
    expect(
      applyTransactionFilter(
        transactions: items,
        filter: filter,
        accounts: [account],
      ).first.id,
      '1',
    );
  });

  test(
    'keeps every supported transaction type filterable and accurately totals cash flow',
    () {
      final allTypes = [
        transaction(
          id: 'expense',
          merchant: 'Expense',
          amount: 10,
          type: TransactionType.expense,
        ),
        transaction(
          id: 'income',
          merchant: 'Income',
          amount: 100,
          type: TransactionType.income,
        ),
        transaction(
          id: 'transfer',
          merchant: 'Transfer',
          amount: 20,
          type: TransactionType.transfer,
        ),
        transaction(
          id: 'investment',
          merchant: 'Investment',
          amount: 30,
          type: TransactionType.investment,
        ),
        transaction(
          id: 'emi',
          merchant: 'EMI',
          amount: 40,
          type: TransactionType.loanEmi,
        ),
        transaction(
          id: 'cash',
          merchant: 'Cash',
          amount: 50,
          type: TransactionType.cash,
        ),
      ];
      for (final type in TransactionType.values) {
        expect(
          applyTransactionFilter(
            transactions: allTypes,
            filter: TransactionFilterState(selectedType: type),
            accounts: [account],
          ).single.type,
          type,
        );
      }
      final summary = calculateTransactionListSummary(allTypes);
      expect(summary.income, 100);
      // Consumption includes expense, legacy cash, and loan/EMI repayment (10 + 40 + 50).
      // Investment principal is excluded.
      expect(summary.expenses, 100);
    },
  );

  test('searches payee across casing and extra whitespace variants', () {
    final txs = [
      transaction(
        id: '1',
        merchant: 'Bismi CAFE',
        amount: 50,
        type: TransactionType.expense,
      ),
      transaction(
        id: '2',
        merchant: 'Zomato India',
        amount: 200,
        type: TransactionType.expense,
      ),
    ];

    expect(
      applyTransactionFilter(
        transactions: txs,
        filter: const TransactionFilterState(searchQuery: '  bismi   cafe  '),
        accounts: [account],
      ).single.id,
      '1',
    );

    expect(
      applyTransactionFilter(
        transactions: txs,
        filter: const TransactionFilterState(searchQuery: 'zomato'),
        accounts: [account],
      ).single.id,
      '2',
    );
  });
}
