import 'dart:convert';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/backup_payload.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/services/budget_calculator.dart';
import 'package:financeflow/services/loan_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 10, 10, 0);

  Account createAccount({
    String id = 'acc_bank',
    double openingBalance = 100000.0,
  }) =>
      Account(
        id: id,
        name: 'HDFC Salary Account',
        type: AccountType.bank,
        openingBalance: openingBalance,
        currentBalance: openingBalance,
        createdAt: now,
        updatedAt: now,
      );

  Loan createLoan({
    String id = 'loan_auto',
    double principal = 500000.0,
    double rate = 9.0,
    int tenureMonths = 36,
    double emi = 15899.86,
  }) =>
      Loan(
        id: id,
        name: 'Auto Loan',
        lender: 'HDFC Bank',
        loanType: LoanType.vehicleLoan,
        principalAmount: principal,
        interestRate: rate,
        interestType: InterestType.reducingBalance,
        tenureMonths: tenureMonths,
        startDate: DateTime(2026, 8, 1),
        expectedEndDate: DateTime(2029, 8, 1),
        emiAmount: emi,
        paymentDay: 5,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: principal,
        nextDueDate: DateTime(2026, 9, 5),
        status: LoanStatus.active,
        createdAt: now,
        updatedAt: now,
      );

  Transaction createRepaymentTx({
    String id = 'tx_repayment_1',
    double amount = 15899.86,
    double? principal = 12149.86,
    double? interest = 3750.0,
    double? fee = 0.0,
    String? linkedLoanId = 'loan_auto',
    String accountId = 'acc_bank',
    String categoryId = 'cat_loans',
    DateTime? date,
  }) =>
      Transaction(
        id: id,
        amount: amount,
        type: TransactionType.loanEmi,
        purpose: TransactionPurpose.loanRepayment,
        categoryId: categoryId,
        categoryName: 'Loans & EMI',
        categoryIcon: 'account_balance',
        categoryColor: 'sand',
        merchant: 'HDFC Auto Loan',
        date: date ?? now,
        accountId: accountId,
        linkedLoanId: linkedLoanId,
        principalComponent: principal,
        interestComponent: interest,
        feeComponent: fee,
        createdAt: now,
        updatedAt: now,
      );

  group('Loan and EMI Repayment Accounting Specification (18 Points)', () {
    // 1. Full repayment amount counted as expense
    test('1. Full repayment amount is counted toward consumptionExpenseAmount', () {
      final tx = createRepaymentTx(
        amount: 8000.0,
        principal: 6500.0,
        interest: 1500.0,
      );
      expect(tx.consumptionExpenseAmount, 8000.0);
      expect(tx.principalAmount, 6500.0);
      expect(tx.interestAmount, 1500.0);
      expect(tx.feeAmount, 0.0);
    });

    // 2. Principal-only repayment
    test('2. Principal-only repayment is fully counted as expense and tracks principal', () {
      final tx = createRepaymentTx(
        amount: 5000.0,
        principal: 5000.0,
        interest: 0.0,
      );
      expect(tx.consumptionExpenseAmount, 5000.0);
      expect(tx.principalAmount, 5000.0);
      expect(tx.interestAmount, 0.0);
    });

    // 3. Interest-only repayment
    test('3. Interest-only repayment is fully counted as expense with 0 principal', () {
      final tx = createRepaymentTx(
        amount: 3000.0,
        principal: 0.0,
        interest: 3000.0,
      );
      expect(tx.consumptionExpenseAmount, 3000.0);
      expect(tx.principalAmount, 0.0);
      expect(tx.interestAmount, 3000.0);
    });

    // 4. Principal + interest + fee
    test('4. Repayment with principal, interest, and fee has amount as full expense', () {
      final tx = createRepaymentTx(
        amount: 8100.0,
        principal: 6500.0,
        interest: 1500.0,
        fee: 100.0,
      );
      expect(tx.consumptionExpenseAmount, 8100.0);
      expect(tx.principalAmount, 6500.0);
      expect(tx.interestAmount, 1500.0);
      expect(tx.feeAmount, 100.0);
    });

    // 5. Account balance decreases by full amount
    test('5. Paying account balance decreases by full repayment amount', () {
      final acc = createAccount(openingBalance: 50000.0);
      final tx = createRepaymentTx(
        amount: 15000.0,
        principal: 12000.0,
        interest: 3000.0,
        accountId: acc.id,
      );
      final balance = BalanceCalculator.calculateAccountBalance(
        account: acc,
        allTransactions: [tx],
      );
      expect(balance, 35000.0);
    });

    // 6. Outstanding principal decreases by principal only
    test('6. Outstanding principal decreases strictly by the principal component', () {
      final loan = createLoan(principal: 500000.0);
      final payment = EmiPayment(
        id: 'emi_1',
        loanId: loan.id,
        installmentNumber: 1,
        dueDate: DateTime(2026, 9, 5),
        paymentDate: now,
        principalPaid: 12000.0,
        interestPaid: 3500.0,
        emiAmount: 15500.0,
        createdAt: now,
        updatedAt: now,
      );

      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: [payment],
        asOfDate: now,
      );

      expect(updated.totalPrincipalPaid, 12000.0);
      expect(updated.totalInterestPaid, 3500.0);
      expect(updated.outstandingPrincipal, 500000.0 - 12000.0); // 488000.0
    });

    // 7. Interest does not reduce principal
    test('7. Interest component does not reduce outstanding principal', () {
      final loan = createLoan(principal: 100000.0);
      // Two payments: same principal, different interest
      final p1 = EmiPayment(
        id: 'emi_1',
        loanId: loan.id,
        installmentNumber: 1,
        dueDate: DateTime(2026, 9, 5),
        paymentDate: now,
        principalPaid: 5000.0,
        interestPaid: 2000.0,
        emiAmount: 7000.0,
        createdAt: now,
        updatedAt: now,
      );
      final p2 = EmiPayment(
        id: 'emi_2',
        loanId: loan.id,
        installmentNumber: 2,
        dueDate: DateTime(2026, 10, 5),
        paymentDate: now,
        principalPaid: 5000.0,
        interestPaid: 500.0, // Lower interest
        emiAmount: 5500.0,
        createdAt: now,
        updatedAt: now,
      );

      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: [p1, p2],
        asOfDate: now,
      );

      expect(updated.totalPrincipalPaid, 10000.0);
      expect(updated.totalInterestPaid, 2500.0);
      expect(updated.outstandingPrincipal, 90000.0);
    });

    // 8. Dashboard expense and net totals
    test('8. Dashboard monthly cash flow reflects full repayment amount in expenses and net savings', () {
      final incomeTx = Transaction(
        id: 'tx_income',
        amount: 80000.0,
        type: TransactionType.income,
        purpose: TransactionPurpose.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'work',
        categoryColor: 'emerald',
        merchant: 'Employer Inc',
        date: now,
        accountId: 'acc_bank',
        createdAt: now,
        updatedAt: now,
      );
      final emiTx = createRepaymentTx(
        amount: 20000.0,
        principal: 16000.0,
        interest: 4000.0,
      );
      final generalExpense = Transaction(
        id: 'tx_groceries',
        amount: 10000.0,
        type: TransactionType.expense,
        purpose: TransactionPurpose.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColor: 'clay',
        merchant: 'Supermarket',
        date: now,
        accountId: 'acc_bank',
        createdAt: now,
        updatedAt: now,
      );

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow([
        incomeTx,
        emiTx,
        generalExpense,
      ]);

      expect(cashFlow.totalIncome, 80000.0);
      expect(cashFlow.totalExpense, 30000.0); // 10000 + 20000 (full EMI)
      expect(cashFlow.netSavings, 50000.0); // 80000 - 30000
      expect(cashFlow.debtPrincipalPaid, 16000.0);
      expect(cashFlow.cashOutflow, 30000.0);
    });

    // 9. Budget and category totals
    test('9. BudgetCalculator accumulates full repayment amount against budget limit', () {
      final loanBudget = Budget(
        id: 'b_loans',
        name: 'Loan Repayments Budget',
        categoryId: 'cat_loans',
        categoryName: 'Loans & EMI',
        categoryIcon: 'account_balance',
        categoryColor: 'sand',
        amountLimit: 25000.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2026, 9, 1),
        alertThreshold: 0.80,
        createdAt: now,
        updatedAt: now,
      );

      final emiTx = createRepaymentTx(
        amount: 22000.0,
        principal: 18000.0,
        interest: 4000.0,
        categoryId: 'cat_loans',
        date: now,
      );

      final summary = BudgetCalculator.calculateSummary(
        loanBudget,
        [emiTx],
        referenceDate: now,
      );

      expect(summary.amountSpent, 22000.0);
      expect(summary.remainingAmount, 3000.0);
      expect(summary.isExceeded, isFalse);
      expect(summary.isApproachingThreshold, isTrue); // 22000 / 25000 = 88% >= 80%
    });

    // 10. Loan detail totals and EMI schedule
    test('10. Loan amortization schedule displays accurate installment status and closing balance', () {
      final loan = createLoan(principal: 100000.0, rate: 12.0, tenureMonths: 6, emi: 17254.84);
      final schedule = LoanCalculator.generateSchedule(loan);
      expect(schedule.length, 6);
      expect(schedule.first.monthNumber, 1);
      expect(schedule.first.openingBalance, 100000.0);
      expect(schedule.first.emiAmount, 17254.84);
      expect(schedule.last.closingBalance, 0.0);
    });

    // 11. Editing a repayment updates cash flow consistently
    test('11. Modifying repayment amount updates consumptionExpenseAmount and net savings', () {
      final originalTx = createRepaymentTx(
        amount: 15000.0,
        principal: 12000.0,
        interest: 3000.0,
      );
      final editedTx = originalTx.copyWith(
        amount: 18000.0,
        principalComponent: 15000.0,
        interestComponent: 3000.0,
      );

      final originalFlow = BalanceCalculator.calculateMonthlyCashFlow([originalTx]);
      final editedFlow = BalanceCalculator.calculateMonthlyCashFlow([editedTx]);

      expect(originalFlow.totalExpense, 15000.0);
      expect(editedFlow.totalExpense, 18000.0);
      expect(editedFlow.debtPrincipalPaid, 15000.0);
    });

    // 12. Deleting a repayment reverses cash flow and account balance
    test('12. Deleting a repayment completely removes expense and restores balance', () {
      final acc = createAccount(openingBalance: 50000.0);
      final tx = createRepaymentTx(amount: 15000.0, accountId: acc.id);

      final withTxBalance = BalanceCalculator.calculateAccountBalance(
        account: acc,
        allTransactions: [tx],
      );
      final afterDeleteBalance = BalanceCalculator.calculateAccountBalance(
        account: acc,
        allTransactions: [],
      );

      expect(withTxBalance, 35000.0);
      expect(afterDeleteBalance, 50000.0);

      final flowWithTx = BalanceCalculator.calculateMonthlyCashFlow([tx]);
      final flowAfterDelete = BalanceCalculator.calculateMonthlyCashFlow([]);

      expect(flowWithTx.totalExpense, 15000.0);
      expect(flowAfterDelete.totalExpense, 0.0);
    });

    // 13. Early settlement and partial payment
    test('13. Early settlement drops loan principal to zero while full payment is recorded as expense', () {
      final loan = createLoan(principal: 50000.0);
      final settlementPayment = EmiPayment(
        id: 'emi_settle',
        loanId: loan.id,
        installmentNumber: 1,
        dueDate: DateTime(2026, 9, 5),
        paymentDate: now,
        principalPaid: 50000.0,
        interestPaid: 500.0,
        emiAmount: 50500.0,
        createdAt: now,
        updatedAt: now,
      );

      final settlementTx = createRepaymentTx(
        amount: 50500.0,
        principal: 50000.0,
        interest: 500.0,
      );

      final updatedLoan = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: [settlementPayment],
        asOfDate: now,
      );

      expect(settlementTx.consumptionExpenseAmount, 50500.0);
      expect(updatedLoan.outstandingPrincipal, 0.0);
      expect(updatedLoan.status, LoanStatus.paidOff);
    });

    // 14. Importing/linking a repayment
    test('14. Unlinked imported EMI has full expense before and after split linking', () {
      // Unlinked imported transaction
      final unlinked = Transaction(
        id: 'tx_imported_emi',
        amount: 12500.0,
        type: TransactionType.loanEmi,
        purpose: TransactionPurpose.loanRepayment,
        categoryId: 'cat_loans',
        categoryName: 'Loans & EMI',
        categoryIcon: 'account_balance',
        categoryColor: 'sand',
        merchant: 'HDFC Loan Auto Debit',
        date: now,
        accountId: 'acc_bank',
        createdAt: now,
        updatedAt: now,
      );

      expect(unlinked.consumptionExpenseAmount, 12500.0);

      // Now user links it to loan with explicit split
      final linked = unlinked.copyWith(
        linkedLoanId: 'loan_auto',
        principalComponent: 9800.0,
        interestComponent: 2700.0,
      );

      expect(linked.consumptionExpenseAmount, 12500.0);
      expect(linked.principalAmount, 9800.0);
      expect(linked.interestAmount, 2700.0);
    });

    // 15. Backup, export, and import round trip
    test('15. Backup serialization preserves all repayment components and restores identical values', () {
      final originalTx = createRepaymentTx(
        amount: 15899.86,
        principal: 12149.86,
        interest: 3750.0,
        fee: 0.0,
      );

      final payload = BackupDataPayload(
        metadata: BackupMetadata(
          createdAt: now,
          transactionCount: 1,
          accountCount: 0,
          budgetCount: 0,
          goalCount: 0,
          subscriptionCount: 0,
          loanCount: 0,
          investmentCount: 0,
        ),
        transactions: [originalTx],
      );
      final jsonStr = json.encode(payload.toJson());
      final restoredPayload = BackupDataPayload.fromJson(
        json.decode(jsonStr) as Map<String, dynamic>,
      );
      final restoredTx = restoredPayload.transactions.single;

      expect(restoredTx.id, originalTx.id);
      expect(restoredTx.amount, 15899.86);
      expect(restoredTx.consumptionExpenseAmount, 15899.86);
      expect(restoredTx.principalComponent, 12149.86);
      expect(restoredTx.interestComponent, 3750.0);
      expect(restoredTx.purpose, TransactionPurpose.loanRepayment);
      expect(restoredTx.type, TransactionType.loanEmi);
      expect(restoredTx.linkedLoanId, 'loan_auto');
    });

    // 16. Existing historical transactions with missing breakdown
    test('16. Historical transactions with null components safely evaluate full amount as expense', () {
      final legacyTx = Transaction(
        id: 'tx_legacy',
        amount: 14500.0,
        type: TransactionType.loanEmi,
        purpose: TransactionPurpose.loanRepayment,
        categoryId: 'cat_loans',
        categoryName: 'Loans & EMI',
        categoryIcon: 'account_balance',
        categoryColor: 'sand',
        merchant: 'Old Bank EMI',
        date: DateTime(2025, 1, 1),
        accountId: 'acc_bank',
        principalComponent: null,
        interestComponent: null,
        feeComponent: null,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      expect(legacyTx.consumptionExpenseAmount, 14500.0);
      expect(legacyTx.principalAmount, 0.0);
      expect(legacyTx.interestAmount, 0.0);
      expect(legacyTx.feeAmount, 0.0);
    });

    // 17. Non-loan transactions remaining unchanged
    test('17. Non-loan transactions (income, transfer, investment, subscription) retain existing behavior', () {
      final income = Transaction(
        id: 'tx_inc',
        amount: 50000.0,
        type: TransactionType.income,
        purpose: TransactionPurpose.income,
        categoryId: 'cat_income',
        categoryName: 'Salary',
        categoryIcon: 'work',
        categoryColor: 'emerald',
        merchant: 'Employer',
        date: now,
        accountId: 'acc_bank',
        createdAt: now,
        updatedAt: now,
      );
      final transfer = Transaction(
        id: 'tx_trans',
        amount: 10000.0,
        type: TransactionType.transfer,
        purpose: TransactionPurpose.internalTransfer,
        categoryId: 'cat_transfer',
        categoryName: 'Transfer',
        categoryIcon: 'sync',
        categoryColor: 'slate',
        merchant: 'Internal Transfer',
        date: now,
        accountId: 'acc_bank',
        toAccountId: 'acc_cash',
        createdAt: now,
        updatedAt: now,
      );
      final investment = Transaction(
        id: 'tx_inv',
        amount: 25000.0,
        type: TransactionType.investment,
        purpose: TransactionPurpose.investmentPurchase,
        categoryId: 'cat_invest',
        categoryName: 'Investments',
        categoryIcon: 'trending_up',
        categoryColor: 'ocean',
        merchant: 'Mutual Fund',
        date: now,
        accountId: 'acc_bank',
        feeComponent: 50.0,
        createdAt: now,
        updatedAt: now,
      );
      final subscription = Transaction(
        id: 'tx_sub',
        amount: 499.0,
        type: TransactionType.expense,
        purpose: TransactionPurpose.subscriptionPayment,
        categoryId: 'cat_sub',
        categoryName: 'Subscriptions',
        categoryIcon: 'subscriptions',
        categoryColor: 'purple',
        merchant: 'Streaming Service',
        date: now,
        accountId: 'acc_bank',
        createdAt: now,
        updatedAt: now,
      );

      expect(income.earnedIncomeAmount, 50000.0);
      expect(income.consumptionExpenseAmount, 0.0);

      expect(transfer.consumptionExpenseAmount, 0.0);
      expect(transfer.earnedIncomeAmount, 0.0);

      expect(investment.consumptionExpenseAmount, 50.0); // Only fee is expense
      expect(investment.cashOutflowAmount, 25000.0);

      expect(subscription.consumptionExpenseAmount, 499.0);
      expect(subscription.cashOutflowAmount, 499.0);
    });

    // 18. No duplicate expense or balance impact
    test('18. AnalyticsCalculator and BalanceCalculator count repayment exactly once in category and overall totals', () {
      final emiTx = createRepaymentTx(
        amount: 15000.0,
        principal: 11000.0,
        interest: 4000.0,
        categoryId: 'cat_loans',
        date: now,
      );

      final report = AnalyticsCalculator.calculateReport(
        allTransactions: [emiTx],
        timeRange: AnalyticsTimeRange.month,
        referenceDate: now,
      );

      expect(report.totalExpense, 15000.0);
      expect(report.categoryBreakdown.length, 1);
      expect(report.categoryBreakdown.first.categoryId, 'cat_loans');
      expect(report.categoryBreakdown.first.amount, 15000.0);

      final cashFlow = BalanceCalculator.calculateMonthlyCashFlow([emiTx]);
      expect(cashFlow.totalExpense, 15000.0);
      expect(cashFlow.cashOutflow, 15000.0);
    });
  });
}
