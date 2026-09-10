import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 24);

  Transaction tx({
    required String id,
    required double amount,
    required TransactionPurpose purpose,
    String accountId = 'bank',
    String? toAccountId,
    double? principal,
    double? interest,
    double? fee,
  }) => Transaction(
    id: id,
    amount: amount,
    type: switch (purpose) {
      TransactionPurpose.income ||
      TransactionPurpose.borrowing => TransactionType.income,
      TransactionPurpose.internalTransfer => TransactionType.transfer,
      TransactionPurpose.loanRepayment => TransactionType.loanEmi,
      TransactionPurpose.investmentPurchase => TransactionType.investment,
      _ => TransactionType.expense,
    },
    purpose: purpose,
    categoryId: 'cat',
    categoryName: 'Category',
    categoryIcon: 'icon',
    categoryColor: 'color',
    merchant: purpose.displayName,
    date: now,
    accountId: accountId,
    toAccountId: toAccountId,
    principalComponent: principal,
    interestComponent: interest,
    feeComponent: fee,
    createdAt: now,
    updatedAt: now,
  );

  Account account(String id, {double opening = 0}) => Account(
    id: id,
    name: id,
    type: id == 'cash' ? AccountType.cash : AccountType.bank,
    openingBalance: opening,
    currentBalance: opening,
    createdAt: now,
    updatedAt: now,
  );

  test(
    'bank to cash changes endpoints but preserves combined owned balance',
    () {
      final transfer = tx(
        id: 'transfer',
        amount: 5000,
        purpose: TransactionPurpose.internalTransfer,
        toAccountId: 'cash',
      );
      final bank = BalanceCalculator.calculateAccountBalance(
        account: account('bank', opening: 10000),
        allTransactions: [transfer],
      );
      final cash = BalanceCalculator.calculateAccountBalance(
        account: account('cash'),
        allTransactions: [transfer],
      );
      expect(bank, 5000);
      expect(cash, 5000);
      expect(bank + cash, 10000);
      expect(transfer.consumptionExpenseAmount, 0);
    },
  );

  test('cash purchase is expense from Cash Wallet', () {
    final purchase = tx(
      id: 'cash_purchase',
      amount: 1000,
      purpose: TransactionPurpose.expense,
      accountId: 'cash',
    );
    expect(
      BalanceCalculator.calculateAccountBalance(
        account: account('cash', opening: 2500),
        allTransactions: [purchase],
      ),
      1500,
    );
    expect(purchase.consumptionExpenseAmount, 1000);
  });

  test(
    'lending and borrowing move cash without income or expense inflation',
    () {
      final lending = tx(
        id: 'lend',
        amount: 10000,
        purpose: TransactionPurpose.lending,
      );
      final borrowing = tx(
        id: 'borrow',
        amount: 10000,
        purpose: TransactionPurpose.borrowing,
      );
      expect(lending.cashOutflowAmount, 10000);
      expect(lending.consumptionExpenseAmount, 0);
      expect(borrowing.cashInflowAmount, 10000);
      expect(borrowing.earnedIncomeAmount, 0);
    },
  );

  test(
    'whole EMI is cash outflow and full consumption expense while tracking principal and interest breakdown',
    () {
      final emi = tx(
        id: 'emi',
        amount: 8000,
        purpose: TransactionPurpose.loanRepayment,
        principal: 6500,
        interest: 1400,
        fee: 100,
      );
      expect(emi.cashOutflowAmount, 8000);
      expect(emi.consumptionExpenseAmount, 8000);
      expect(emi.principalAmount, 6500);
      expect(emi.interestAmount, 1400);
      expect(emi.feeAmount, 100);
      final flow = BalanceCalculator.calculateMonthlyCashFlow([emi]);
      expect(flow.cashOutflow, 8000);
      expect(flow.totalExpense, 8000);
      expect(flow.debtPrincipalPaid, 6500);
    },
  );

  test('investment principal is not consumption spending', () {
    final investment = tx(
      id: 'investment',
      amount: 20000,
      purpose: TransactionPurpose.investmentPurchase,
      principal: 19950,
      fee: 50,
    );
    expect(investment.cashOutflowAmount, 20000);
    expect(investment.consumptionExpenseAmount, 50);
    final report = AnalyticsCalculator.calculateReport(
      allTransactions: [investment],
      timeRange: AnalyticsTimeRange.month,
      referenceDate: now,
    );
    expect(report.totalExpense, 50);
  });

  test('subscription payment is full consumption expense and cash outflow', () {
    final subPayment = tx(
      id: 'sub_payment',
      amount: 499,
      purpose: TransactionPurpose.subscriptionPayment,
    );
    expect(subPayment.cashOutflowAmount, 499);
    expect(subPayment.consumptionExpenseAmount, 499);
    final flow = BalanceCalculator.calculateMonthlyCashFlow([subPayment]);
    expect(flow.cashOutflow, 499);
    expect(flow.totalExpense, 499);
    final report = AnalyticsCalculator.calculateReport(
      allTransactions: [subPayment],
      timeRange: AnalyticsTimeRange.month,
      referenceDate: now,
    );
    expect(report.totalExpense, 499);
  });
}
