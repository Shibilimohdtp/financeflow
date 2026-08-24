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
        switch (tx.effectiveDirection) {
          case AccountMovementDirection.inflow:
            balance += tx.amount;
          case AccountMovementDirection.outflow:
          case AccountMovementDirection.internal:
            balance -= tx.amount;
        }
      }

      if (tx.effectiveDirection == AccountMovementDirection.internal &&
          tx.toAccountId == account.id) {
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
    double cashInflow = 0.0;
    double cashOutflow = 0.0;
    double debtPrincipalPaid = 0.0;
    double investingCashFlow = 0.0;

    for (final tx in monthTransactions) {
      totalIncome += tx.earnedIncomeAmount;
      totalExpense += tx.consumptionExpenseAmount;
      cashInflow += tx.cashInflowAmount;
      cashOutflow += tx.cashOutflowAmount;
      if (tx.effectivePurpose == TransactionPurpose.loanRepayment ||
          tx.effectivePurpose == TransactionPurpose.personalDebtRepaymentMade) {
        debtPrincipalPaid += tx.principalAmount;
      }
      if (tx.effectivePurpose == TransactionPurpose.investmentPurchase) {
        investingCashFlow -= tx.amount;
      } else if (tx.effectivePurpose ==
          TransactionPurpose.investmentRedemption) {
        investingCashFlow += tx.amount;
      }
    }

    final netSavings = totalIncome - totalExpense;

    return MonthlyCashFlow(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      cashInflow: cashInflow,
      cashOutflow: cashOutflow,
      debtPrincipalPaid: debtPrincipalPaid,
      investingCashFlow: investingCashFlow,
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
  final double cashInflow;
  final double cashOutflow;
  final double debtPrincipalPaid;
  final double investingCashFlow;

  const MonthlyCashFlow({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    this.cashInflow = 0,
    this.cashOutflow = 0,
    this.debtPrincipalPaid = 0,
    this.investingCashFlow = 0,
  });

  bool get isPositiveSavings => netSavings >= 0;
  double get netCashFlow => cashInflow - cashOutflow;
}
