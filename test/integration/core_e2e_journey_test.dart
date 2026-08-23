import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/backup_payload.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/backup_service.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/services/budget_calculator.dart';
import 'package:financeflow/services/export_service.dart';
import '../helpers/fake_repositories.dart';

void main() {
  group('Core End-to-End User Journey Tests (27 Steps)', () {
    late FakeSettingsRepository settingsRepo;
    late FakeAccountRepository accountRepo;
    late FakeTransactionRepository transactionRepo;
    late FakeCategoryRepository categoryRepo;
    late FakeBudgetRepository budgetRepo;
    late FakeSavingsGoalRepository goalRepo;
    late FakeSubscriptionRepository subRepo;
    late FakeLoanRepository loanRepo;
    late FakeInvestmentRepository investmentRepo;
    late FakeAlertRepository alertRepo;
    late BackupService backupService;

    setUp(() {
      settingsRepo = FakeSettingsRepository();
      accountRepo = FakeAccountRepository();
      transactionRepo = FakeTransactionRepository();
      categoryRepo = FakeCategoryRepository();
      budgetRepo = FakeBudgetRepository();
      goalRepo = FakeSavingsGoalRepository();
      subRepo = FakeSubscriptionRepository();
      loanRepo = FakeLoanRepository();
      investmentRepo = FakeInvestmentRepository();
      alertRepo = FakeAlertRepository();

      backupService = BackupService(
        accountRepo: accountRepo,
        transactionRepo: transactionRepo,
        categoryRepo: categoryRepo,
        budgetRepo: budgetRepo,
        goalRepo: goalRepo,
        subscriptionRepo: subRepo,
        loanRepo: loanRepo,
        investmentRepo: investmentRepo,
        alertRepo: alertRepo,
      );
    });

    test(
      'Executes complete 27-step core lifecycle flow deterministically',
      () async {
        // Step 1: Clean app state
        var initialSettings = await settingsRepo.getSettings();
        expect(initialSettings.hasCompletedOnboarding, isFalse);
        expect(await accountRepo.getAllAccounts(), isEmpty);
        expect(await transactionRepo.getAllTransactions(), isEmpty);

        // Step 2 & 3: Launch app and confirm onboarding is pending
        expect(initialSettings.hasCompletedOnboarding, isFalse);

        // Step 4: Complete onboarding
        await settingsRepo.setOnboardingCompleted(true);
        final onboardedSettings = await settingsRepo.getSettings();
        expect(onboardedSettings.hasCompletedOnboarding, isTrue);

        // Step 5: Deny optional permissions (Notification & SMS remain disabled)
        expect(onboardedSettings.isNotificationDetectionEnabled, isFalse);
        expect(onboardedSettings.isSmsDetectionEnabled, isFalse);

        // Step 6: Create bank account
        final now = DateTime(2026, 8, 22, 10, 0);
        final bankAccount = Account(
          id: 'acc_hdfc_bank',
          name: 'HDFC Salary Account',
          type: AccountType.bank,
          institutionName: 'HDFC Bank',
          maskedIdentifier: '••4321',
          openingBalance: 50000.0,
          currentBalance: 50000.0,
          currency: 'INR',
          createdAt: now,
          updatedAt: now,
        );
        await accountRepo.saveAccount(bankAccount);

        // Step 7: Create cash wallet
        final cashAccount = Account(
          id: 'acc_cash_wallet',
          name: 'Cash Wallet',
          type: AccountType.cash,
          institutionName: 'Cash',
          openingBalance: 5000.0,
          currentBalance: 5000.0,
          currency: 'INR',
          createdAt: now,
          updatedAt: now,
        );
        await accountRepo.saveAccount(cashAccount);

        final accounts = await accountRepo.getAllAccounts();
        expect(accounts.length, 2);

        // Step 8: Add an expense (Swiggy ₹450)
        final expenseTx = Transaction(
          id: 'tx_swiggy_1',
          amount: 450.0,
          type: TransactionType.expense,
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Swiggy',
          date: DateTime(2026, 8, 22, 12, 30),
          accountId: bankAccount.id,
          paymentMethod: 'UPI',
          isReviewed: true,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(expenseTx);

        // Step 9: Add income (Salary ₹85,000)
        final incomeTx = Transaction(
          id: 'tx_salary_1',
          amount: 85000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          categoryName: 'Salary',
          categoryIcon: 'payments',
          categoryColor: 'verified',
          merchant: 'Acme Corp',
          date: DateTime(2026, 8, 22, 9, 0),
          accountId: bankAccount.id,
          paymentMethod: 'IMPS / NEFT',
          isReviewed: true,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(incomeTx);

        // Step 10: Add transfer (Bank -> Cash ₹2,000)
        final transferTx = Transaction(
          id: 'tx_transfer_1',
          amount: 2000.0,
          type: TransactionType.transfer,
          categoryId: 'cat_transfer',
          categoryName: 'Transfer',
          categoryIcon: 'sync',
          categoryColor: 'slate',
          merchant: 'ATM Cash Withdrawal',
          date: DateTime(2026, 8, 22, 15, 0),
          accountId: bankAccount.id,
          toAccountId: cashAccount.id,
          paymentMethod: 'ATM Debit Card',
          isReviewed: true,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(transferTx);

        // Step 11: Add investment (Mutual Fund ₹10,000)
        final investmentTx = Transaction(
          id: 'tx_investment_1',
          amount: 10000.0,
          type: TransactionType.investment,
          categoryId: 'cat_investments',
          categoryName: 'Investments',
          categoryIcon: 'trending_up',
          categoryColor: 'sprout',
          merchant: 'Parag Parikh Flexi Cap Fund',
          date: DateTime(2026, 8, 22, 16, 0),
          accountId: bankAccount.id,
          paymentMethod: 'UPI',
          isReviewed: true,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(investmentTx);

        // Step 12: Add loan payment / EMI (Home loan EMI ₹15,000)
        final emiTx = Transaction(
          id: 'tx_loan_emi_1',
          amount: 15000.0,
          type: TransactionType.loanEmi,
          categoryId: 'cat_loans',
          categoryName: 'Loans & EMI',
          categoryIcon: 'account_balance',
          categoryColor: 'sand',
          merchant: 'HDFC Home Loan EMI',
          date: DateTime(2026, 8, 22, 18, 0),
          accountId: bankAccount.id,
          paymentMethod: 'Auto Debit',
          isReviewed: true,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(emiTx);

        expect((await transactionRepo.getAllTransactions()).length, 5);

        // Step 13: Edit transaction (Update Swiggy amount to ₹520)
        final updatedExpense = expenseTx.copyWith(
          amount: 520.0,
          notes: 'Dinner with team',
        );
        await transactionRepo.saveTransaction(updatedExpense);
        final retrievedExpense = await transactionRepo.getTransactionById(
          'tx_swiggy_1',
        );
        expect(retrievedExpense?.amount, 520.0);
        expect(retrievedExpense?.notes, 'Dinner with team');

        // Step 14: Delete a transaction (Create temporary tx and delete it)
        final tempTx = Transaction(
          id: 'tx_temp_delete',
          amount: 100.0,
          type: TransactionType.expense,
          categoryId: 'cat_misc',
          categoryName: 'Miscellaneous',
          categoryIcon: 'category',
          categoryColor: 'slate',
          merchant: 'Test Misc',
          date: now,
          accountId: cashAccount.id,
          createdAt: now,
          updatedAt: now,
        );
        await transactionRepo.saveTransaction(tempTx);
        expect((await transactionRepo.getAllTransactions()).length, 6);
        await transactionRepo.deleteTransaction('tx_temp_delete');
        expect((await transactionRepo.getAllTransactions()).length, 5);

        // Step 15 & 16: Verify data persistence & correctness
        final allTxs = await transactionRepo.getAllTransactions();
        expect(allTxs.any((t) => t.id == 'tx_temp_delete'), isFalse);

        // Step 17: Verify Dashboard totals (Cash Flow calculations)
        final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(allTxs);
        expect(cashFlow.totalIncome, 85000.0);
        // Expenses = 520 (Dining) + 10000 (Investment) + 15000 (EMI) = 25520.0
        expect(cashFlow.totalExpense, 25520.0);
        expect(cashFlow.netSavings, 85000.0 - 25520.0);
        expect(cashFlow.isPositiveSavings, isTrue);

        // Step 18: Verify Budgets update
        final diningBudget = Budget(
          id: 'bdg_dining',
          name: 'Dining Budget',
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          amountLimit: 5000.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime(2026, 8, 1),
          alertThreshold: 0.80,
          createdAt: now,
          updatedAt: now,
        );
        await budgetRepo.saveBudget(diningBudget);

        final budgetSummary = BudgetCalculator.calculateSummary(
          diningBudget,
          allTxs,
          referenceDate: DateTime(2026, 8, 22),
        );
        expect(budgetSummary.amountSpent, 520.0);
        expect(budgetSummary.remainingAmount, 5000.0 - 520.0);
        expect(budgetSummary.isExceeded, isFalse);

        // Step 19: Verify Analytics update
        final report = AnalyticsCalculator.calculateReport(
          allTransactions: allTxs,
          timeRange: AnalyticsTimeRange.month,
          referenceDate: DateTime(2026, 8, 22),
        );
        expect(report.totalIncome, 85000.0);
        expect(report.categoryBreakdown.isNotEmpty, isTrue);
        final diningCatSpend = report.categoryBreakdown.firstWhere(
          (c) => c.categoryId == 'cat_dining',
        );
        expect(diningCatSpend.amount, 520.0);

        // Step 20: Verify Account balances update
        final bankBalance = BalanceCalculator.calculateAccountBalance(
          account: bankAccount,
          allTransactions: allTxs,
        );
        // Opening (50000) + Income (85000) - Expense (520) - Transfer Out (2000) - Investment (10000) - Loan (15000)
        expect(
          bankBalance,
          50000.0 + 85000.0 - 520.0 - 2000.0 - 10000.0 - 15000.0,
        ); // 107480.0

        final cashBalance = BalanceCalculator.calculateAccountBalance(
          account: cashAccount,
          allTransactions: allTxs,
        );
        // Opening (5000) + Transfer In (2000)
        expect(cashBalance, 5000.0 + 2000.0); // 7000.0

        // Step 21 & 22: Search and Filter transactions
        final swiggySearch = await transactionRepo.searchAndFilterTransactions(
          query: 'swiggy',
        );
        expect(swiggySearch.length, 1);
        expect(swiggySearch.first.merchant, 'Swiggy');

        final incomeFilter = await transactionRepo.searchAndFilterTransactions(
          type: TransactionType.income,
        );
        expect(incomeFilter.length, 1);
        expect(incomeFilter.first.merchant, 'Acme Corp');

        final bankAccountFilter = await transactionRepo
            .searchAndFilterTransactions(accountId: bankAccount.id);
        expect(bankAccountFilter.length, 5); // All 5 involve bank account

        // Step 23: Switch Daylight and Deep Water themes
        await settingsRepo.setThemePreference(AppThemePreference.deepWater);
        expect(
          (await settingsRepo.getSettings()).themePreference,
          AppThemePreference.deepWater,
        );
        await settingsRepo.setThemePreference(AppThemePreference.daylight);
        expect(
          (await settingsRepo.getSettings()).themePreference,
          AppThemePreference.daylight,
        );

        // Step 24: Security Lock & Unlock
        await settingsRepo.setPinEnabled(true);
        expect((await settingsRepo.getSettings()).isPinEnabled, isTrue);

        // Step 25: Export Data (CSV, JSON, Excel HTML, Report)
        final csv = ExportService.generateCsv(
          transactions: allTxs,
          accounts: [bankAccount, cashAccount],
        );
        expect(csv.contains('Swiggy'), isTrue);
        expect(csv.contains('Acme Corp'), isTrue);
        expect(csv.startsWith('\uFEFF'), isTrue); // BOM present

        final jsonExport = ExportService.generateJson(
          transactions: allTxs,
          accounts: [bankAccount, cashAccount],
        );
        final decodedJson = jsonDecode(jsonExport);
        expect(decodedJson['transactions'].length, 5);

        final reportText = ExportService.generateReportText(
          transactions: allTxs,
          budgets: [diningBudget],
          accounts: [bankAccount, cashAccount],
        );
        expect(reportText.contains('FINANCEFLOW FINANCIAL REPORT'), isTrue);
        expect(reportText.contains('CASH FLOW SUMMARY'), isTrue);

        // Step 26: Create Encrypted Backup
        const passphrase = 'MySuperSecurePassphrase2026!';
        final encryptedBackup = await backupService.createEncryptedBackup(
          passphrase: passphrase,
        );
        expect(encryptedBackup.isNotEmpty, isTrue);

        final backupEnvelope =
            jsonDecode(encryptedBackup) as Map<String, dynamic>;
        expect(backupEnvelope['formatVersion'], 1);
        expect(backupEnvelope['app'], 'FinanceFlow');
        expect(backupEnvelope['salt'], isNotNull);
        expect(backupEnvelope['iv'], isNotNull);
        expect(backupEnvelope['hmac'], isNotNull);
        expect(backupEnvelope['ciphertext'], isNotNull);

        // Step 27: Restore into clean state
        // Wipe current state
        final freshAccountRepo = FakeAccountRepository();
        final freshTxRepo = FakeTransactionRepository();
        final freshCategoryRepo = FakeCategoryRepository();
        final freshBudgetRepo = FakeBudgetRepository();
        final freshGoalRepo = FakeSavingsGoalRepository();
        final freshSubRepo = FakeSubscriptionRepository();
        final freshLoanRepo = FakeLoanRepository();
        final freshInvRepo = FakeInvestmentRepository();
        final freshAlertRepo = FakeAlertRepository();

        final freshBackupService = BackupService(
          accountRepo: freshAccountRepo,
          transactionRepo: freshTxRepo,
          categoryRepo: freshCategoryRepo,
          budgetRepo: freshBudgetRepo,
          goalRepo: freshGoalRepo,
          subscriptionRepo: freshSubRepo,
          loanRepo: freshLoanRepo,
          investmentRepo: freshInvRepo,
          alertRepo: freshAlertRepo,
        );

        // Preview & Decrypt
        final previewPayload = BackupService.decryptAndPreview(
          backupFileContent: encryptedBackup,
          passphrase: passphrase,
        );
        expect(previewPayload.transactions.length, 5);
        expect(previewPayload.accounts.length, 2);

        // Execute Replace Restore
        final restoreResult = await freshBackupService.executeRestore(
          payload: previewPayload,
          mode: RestoreMode.replace,
        );
        expect(restoreResult.isSuccess, isTrue);
        expect(restoreResult.restoredTransactions, 5);
        expect(restoreResult.restoredAccounts, 2);

        // Confirm restored data is identical
        final restoredTxs = await freshTxRepo.getAllTransactions();
        expect(restoredTxs.length, 5);
        expect(
          restoredTxs.any((t) => t.merchant == 'Swiggy' && t.amount == 520.0),
          isTrue,
        );

        // Test Merge Restore (does not duplicate existing transactions)
        final mergeResult = await freshBackupService.executeRestore(
          payload: previewPayload,
          mode: RestoreMode.merge,
        );
        expect(mergeResult.isSuccess, isTrue);
        expect(
          mergeResult.restoredTransactions,
          0,
        ); // 0 added because all 5 already exist
        expect(mergeResult.skippedDuplicates, 5);
        expect((await freshTxRepo.getAllTransactions()).length, 5);
      },
    );
  });
}
