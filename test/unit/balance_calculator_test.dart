import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/balance_calculator.dart';

void main() {
  group('BalanceCalculator Tests', () {
    final now = DateTime.now();

    final accountA = Account(
      id: 'acc_a',
      name: 'Bank A',
      type: AccountType.bank,
      openingBalance: 10000.0,
      currentBalance: 10000.0,
      createdAt: now,
      updatedAt: now,
    );

    final accountB = Account(
      id: 'acc_b',
      name: 'Cash Wallet',
      type: AccountType.cash,
      openingBalance: 2000.0,
      currentBalance: 2000.0,
      createdAt: now,
      updatedAt: now,
    );

    test('Calculates account balance with income, expense, and transfers', () {
      final transactions = [
        // Income +5000 to Account A
        Transaction(
          id: 't1',
          amount: 5000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          categoryName: 'Salary',
          categoryIcon: 'account_balance_wallet',
          categoryColor: 'grove',
          merchant: 'Salary',
          date: now,
          accountId: 'acc_a',
          createdAt: now,
          updatedAt: now,
        ),
        // Expense -1500 from Account A
        Transaction(
          id: 't2',
          amount: 1500.0,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Restaurant',
          date: now,
          accountId: 'acc_a',
          createdAt: now,
          updatedAt: now,
        ),
        // Transfer 2000 from Account A to Account B
        Transaction(
          id: 't3',
          amount: 2000.0,
          type: TransactionType.transfer,
          categoryId: 'cat_transfer',
          categoryName: 'Transfer',
          categoryIcon: 'sync',
          categoryColor: 'slate',
          merchant: 'ATM Withdrawal',
          date: now,
          accountId: 'acc_a',
          toAccountId: 'acc_b',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Account A: 10000 + 5000 - 1500 - 2000 = 11500
      final balanceA = BalanceCalculator.calculateAccountBalance(
        account: accountA,
        allTransactions: transactions,
      );
      expect(balanceA, 11500.0);

      // Account B: 2000 + 2000 (transfer received) = 4000
      final balanceB = BalanceCalculator.calculateAccountBalance(
        account: accountB,
        allTransactions: transactions,
      );
      expect(balanceB, 4000.0);
    });

    test('Calculates monthly cash flow totals accurately', () {
      final transactions = [
        Transaction(
          id: 't1',
          amount: 50000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          categoryName: 'Salary',
          categoryIcon: 'wallet',
          categoryColor: 'grove',
          merchant: 'Salary',
          date: now,
          accountId: 'acc_a',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 't2',
          amount: 12000.0,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food',
          categoryIcon: 'food',
          categoryColor: 'clay',
          merchant: 'Food & Groceries',
          date: now,
          accountId: 'acc_a',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 't3',
          amount: 8000.0,
          type: TransactionType.loanEmi,
          categoryId: 'cat_emi',
          categoryName: 'EMI',
          categoryIcon: 'payments',
          categoryColor: 'plum',
          merchant: 'Car EMI',
          date: now,
          accountId: 'acc_a',
          createdAt: now,
          updatedAt: now,
        ),
        // Transfer does not change external income/expense
        Transaction(
          id: 't4',
          amount: 5000.0,
          type: TransactionType.transfer,
          categoryId: 'cat_transfer',
          categoryName: 'Transfer',
          categoryIcon: 'sync',
          categoryColor: 'slate',
          merchant: 'Transfer to Wallet',
          date: now,
          accountId: 'acc_a',
          toAccountId: 'acc_b',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(transactions);

      expect(cashFlow.totalIncome, 50000.0);
      expect(cashFlow.totalExpense, 20000.0); // 12000 + 8000
      expect(cashFlow.netSavings, 30000.0);
      expect(cashFlow.isPositiveSavings, isTrue);
    });

    test('Calculates combined total balance across active accounts', () {
      final accounts = [
        accountA.copyWith(currentBalance: 25000.0),
        accountB.copyWith(currentBalance: 5000.0),
        accountA.copyWith(
          id: 'acc_c',
          currentBalance: 10000.0,
          isArchived: true,
        ), // Archived excluded
      ];

      final total = BalanceCalculator.calculateTotalBalance(accounts);
      expect(total, 30000.0);
    });
  });
}
