import '../models/account.dart';
import '../models/transaction.dart';

/// Calculation Strategy for Account Balances and Cash Flow
///
/// Balance Formula:
/// Account Balance = Opening Balance
///                 + SUM(Income transactions where accountId == account.id)
///                 - SUM(Expense / Loan / Investment transactions where accountId == account.id)
///                 + SUM(Transfer transactions where toAccountId == account.id)
///                 - SUM(Transfer transactions where accountId == account.id)
class BalanceCalculator {
  BalanceCalculator._();

  /// Calculate the current balance of a specific account given its transactions
  static double calculateAccountBalance({
    required Account account,
    required List<Transaction> allTransactions,
  }) {
    double balance = account.openingBalance;

    for (final tx in allTransactions) {
      if (tx.accountId == account.id) {
        switch (tx.type) {
          case TransactionType.income:
            balance += tx.amount;
            break;
          case TransactionType.expense:
          case TransactionType.investment:
          case TransactionType.loanEmi:
          case TransactionType.cash:
            balance -= tx.amount;
            break;
          case TransactionType.transfer:
            balance -= tx.amount;
            break;
        }
      }

      // Handle transfers received into this account
      if (tx.type == TransactionType.transfer && tx.toAccountId == account.id) {
        balance += tx.amount;
      }
    }

    return balance;
  }

  /// Calculate monthly cash flow summary: Income, Expense, Net Savings
  static MonthlyCashFlow calculateMonthlyCashFlow(
    List<Transaction> monthTransactions,
  ) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in monthTransactions) {
      switch (tx.type) {
        case TransactionType.income:
          totalIncome += tx.amount;
          break;
        case TransactionType.expense:
        case TransactionType.loanEmi:
        case TransactionType.investment:
        case TransactionType.cash:
          totalExpense += tx.amount;
          break;
        case TransactionType.transfer:
          // Transfers between personal accounts do not count toward external income or expenses
          break;
      }
    }

    final netSavings = totalIncome - totalExpense;

    return MonthlyCashFlow(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
    );
  }

  /// Calculate total net worth / combined balance across all active accounts
  static double calculateTotalBalance(List<Account> accounts) {
    return accounts
        .where((acc) => !acc.isArchived)
        .fold(0.0, (sum, acc) => sum + acc.currentBalance);
  }
}

class MonthlyCashFlow {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;

  const MonthlyCashFlow({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
  });

  bool get isPositiveSavings => netSavings >= 0;
}
