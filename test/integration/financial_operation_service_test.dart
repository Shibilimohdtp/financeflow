import 'dart:io';
import 'dart:ffi';

import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/database/schemas/account_entity.dart';
import 'package:financeflow/database/schemas/emi_payment_entity.dart';
import 'package:financeflow/database/schemas/loan_entity.dart';
import 'package:financeflow/database/schemas/investment_entity.dart';
import 'package:financeflow/database/schemas/money_advance_entity.dart';
import 'package:financeflow/database/schemas/money_record_entity.dart';
import 'package:financeflow/database/schemas/money_repayment_entity.dart';
import 'package:financeflow/database/schemas/transaction_entity.dart';
import 'package:financeflow/database/schemas/pending_transaction_entity.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parsers.dart';
import 'package:financeflow/services/payee_suggestion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/investment.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/investment_repository.dart';
import 'package:financeflow/repositories/money_record_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/services/financial_operation_service.dart';
import 'package:financeflow/services/loan_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory directory;
  late FinancialOperationService service;
  late IsarAccountRepository accounts;
  late IsarLoanRepository loans;
  late IsarTransactionRepository transactions;
  late IsarInvestmentRepository investments;
  late IsarMoneyRecordRepository debts;
  final now = DateTime(2026, 8, 24);

  setUpAll(() async {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA']!;
      await Isar.initializeIsarCore(
        libraries: {
          Abi.current():
              '$localAppData\\Pub\\Cache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
        },
      );
    } else {
      await Isar.initializeIsarCore(download: true);
    }
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('financeflow_ledger_');
    isar = await Isar.open(
      [
        AccountEntitySchema,
        TransactionEntitySchema,
        PendingTransactionEntitySchema,
        LoanEntitySchema,
        InvestmentEntitySchema,
        EmiPaymentEntitySchema,
        MoneyRecordEntitySchema,
        MoneyAdvanceEntitySchema,
        MoneyRepaymentEntitySchema,
      ],
      directory: directory.path,
      name: 'ledger_test',
      inspector: false,
    );
    service = FinancialOperationService(isarInstance: isar);
    accounts = IsarAccountRepository(isarInstance: isar);
    loans = IsarLoanRepository(isarInstance: isar);
    transactions = IsarTransactionRepository(isarInstance: isar);
    investments = IsarInvestmentRepository(isarInstance: isar);
    debts = IsarMoneyRecordRepository(isarInstance: isar);

    for (final account in [
      Account(
        id: 'bank',
        name: 'Bank',
        type: AccountType.bank,
        openingBalance: 50000,
        currentBalance: 50000,
        createdAt: now,
        updatedAt: now,
      ),
      Account(
        id: 'cash',
        name: 'Cash Wallet',
        type: AccountType.cash,
        openingBalance: 0,
        currentBalance: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ]) {
      await accounts.saveAccount(account);
    }
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  ParsedTransaction pendingSample() =>
      AxisSmsParser().parse(
        sender: 'AD-AXISBK-S',
        defaultAccountId: 'bank',
        body:
            'INR 2500.00 debited\nA/c no. XX5645\n27-08-26, 15:19:37\n'
            'UPI/P2A/412345678901/ANITHA\nMENON T\n'
            'Not you? SMS BLOCKUPI Cust ID to\n919951860002\nAxis Bank',
      )!;

  ProviderContainer reviewContainer(IsarPendingTransactionRepository pending) =>
      ProviderContainer(
        overrides: [
          pendingTransactionRepositoryProvider.overrideWithValue(pending),
          transactionRepositoryProvider.overrideWithValue(transactions),
          financialOperationServiceProvider.overrideWithValue(service),
        ],
      );

  test(
    'Pending edit survives Isar and creates linked debt only on approval',
    () async {
      final pending = IsarPendingTransactionRepository(isarInstance: isar);
      final container = reviewContainer(pending);
      addTearDown(container.dispose);
      final controller = container.read(needsReviewControllerProvider.notifier);
      final original = pendingSample();
      await pending.savePendingTransaction(original);
      final edited = original.withReviewEdit(
        original
            .toTransaction(targetId: original.tempId)
            .copyWith(
              merchant: 'Menon Family',
              purpose: TransactionPurpose.lending,
              externalCounterpartyName: 'Menon',
              linkedMoneyRecordId: 'debt_${original.tempId}',
              notes: 'Family support',
              tags: ['family'],
              paymentMethod: 'UPI',
            ),
      );
      await controller.updateItem(edited);
      final stored = (await pending.getPendingTransactions()).single;
      expect(stored.rawSource, original.rawSource);
      expect(stored.rawMerchant, original.rawMerchant);
      expect(stored.source, original.source);
      expect(stored.sourceName, original.sourceName);
      expect(stored.sourceIdentifier, original.sourceIdentifier);
      expect(stored.referenceNumber, original.referenceNumber);
      expect(stored.importedAt, original.importedAt);
      expect(stored.detectedAt, original.detectedAt);
      expect(stored.purpose, TransactionPurpose.lending);
      expect(stored.externalCounterpartyName, 'Menon');
      expect(stored.tags, ['family']);
      expect(stored.notes, 'Family support');
      expect(await transactions.getAllTransactions(), isEmpty);
      expect(await isar.moneyRecordEntitys.count(), 0);
      await controller.approveItem(stored);
      final saved = (await transactions.getAllTransactions()).single;
      expect(saved.merchant, 'Menon Family');
      expect(saved.normalizedMerchant, 'Menon Family');
      expect(saved.originalMerchant, original.rawMerchant);
      expect(saved.effectivePurpose, TransactionPurpose.lending);
      expect(saved.consumptionExpenseAmount, 0);
      expect(saved.tags, ['family']);
      expect(await isar.moneyRecordEntitys.count(), 1);
      expect(await pending.getPendingTransactions(), isEmpty);
      expect(
        await transactions.searchAndFilterTransactions(query: 'Menon'),
        hasLength(1),
      );
      expect(
        PayeeSuggestionService.getSuggestions(
          transactions: [saved],
          type: saved.type,
          query: 'Menon',
        ).single.displayName,
        'Menon Family',
      );
    },
  );

  test(
    'Pending purpose, links, splits and cleared nullable fields round trip',
    () async {
      final pending = IsarPendingTransactionRepository(isarInstance: isar);
      final original = pendingSample().copyWith(
        purpose: TransactionPurpose.loanRepayment,
        direction: AccountMovementDirection.outflow,
        linkedLoanId: 'loan',
        linkedInvestmentId: 'investment',
        principalComponent: 2000.0,
        interestComponent: 450.0,
        feeComponent: 50.0,
        toAccountId: 'cash',
        notes: 'original note',
      );
      await pending.savePendingTransaction(original);
      final loaded = (await pending.getPendingTransactions()).single;
      final tx = loaded.toTransaction();
      expect(tx.linkedLoanId, 'loan');
      expect(tx.linkedInvestmentId, 'investment');
      expect(tx.principalComponent, 2000);
      expect(tx.interestComponent, 450);
      expect(tx.feeComponent, 50);
      expect(tx.direction, AccountMovementDirection.outflow);
      final reset = loaded.copyWith(
        purpose: TransactionPurpose.expense,
        linkedLoanId: null,
        linkedInvestmentId: null,
        principalComponent: null,
        interestComponent: null,
        feeComponent: null,
        toAccountId: null,
        notes: null,
      );
      await pending.savePendingTransaction(reset);
      final cleared =
          (await pending.getPendingTransactions()).single.toTransaction();
      expect(cleared.linkedLoanId, isNull);
      expect(cleared.linkedInvestmentId, isNull);
      expect(cleared.principalComponent, isNull);
      expect(cleared.toAccountId, isNull);
      expect(cleared.notes, isNull);
    },
  );

  test(
    'Persisted duplicate resolves by ID and keeps manual merchant on merge',
    () async {
      final pending = IsarPendingTransactionRepository(isarInstance: isar);
      final container = reviewContainer(pending);
      addTearDown(container.dispose);
      final original = pendingSample();
      final existing = original.toTransaction(targetId: 'existing');
      await transactions.saveTransaction(existing);
      final edited = original
          .withReviewEdit(existing.copyWith(merchant: 'MENON family'))
          .copyWith(
            duplicateStatus: DuplicateMatchLevel.exact,
            duplicateResolution: DuplicateResolution.merge,
            matchedTransactionId: existing.id,
          );
      await pending.savePendingTransaction(edited);
      final loaded = (await pending.getPendingTransactions()).single;
      expect(loaded.matchedTransaction, isNull);
      await container
          .read(needsReviewControllerProvider.notifier)
          .approveItem(loaded);
      final saved = (await transactions.getAllTransactions()).single;
      expect(saved.id, existing.id);
      expect(saved.merchant, 'MENON family');
      expect(saved.normalizedMerchant, 'Menon Family');
    },
  );

  test(
    'Editing duplicate evidence does not silently replace merge resolution',
    () async {
      final pending = IsarPendingTransactionRepository(isarInstance: isar);
      final container = reviewContainer(pending);
      addTearDown(container.dispose);
      final controller = container.read(needsReviewControllerProvider.notifier);
      final original = pendingSample();
      final existing = original.toTransaction(targetId: 'existing');
      await transactions.saveTransaction(existing);
      final duplicate = original.copyWith(
        duplicateStatus: DuplicateMatchLevel.exact,
        duplicateResolution: DuplicateResolution.merge,
        matchedTransactionId: existing.id,
      );
      await pending.savePendingTransaction(duplicate);
      await controller.updateItem(
        duplicate.withReviewEdit(
          existing.copyWith(amount: 300, merchant: 'Someone else'),
        ),
      );
      final loaded = (await pending.getPendingTransactions()).single;
      expect(loaded.duplicateResolution, DuplicateResolution.merge);
      expect(loaded.matchedTransactionId, existing.id);
      expect(loaded.warnings, contains(contains('duplicate match')));
      await expectLater(controller.approveItem(loaded), throwsStateError);
      expect(await pending.getPendingTransactions(), hasLength(1));
      expect(await transactions.getAllTransactions(), hasLength(1));
    },
  );

  Transaction transaction({
    required String id,
    required double amount,
    required TransactionPurpose purpose,
    String accountId = 'bank',
    String? toAccountId,
    String? counterparty,
    String? loanId,
    String? debtId,
    double? principal,
    double? interest,
    double? fee,
  }) => Transaction(
    id: id,
    amount: amount,
    type: TransactionType.expense,
    purpose: purpose,
    categoryId: 'cat',
    categoryName: 'Category',
    categoryIcon: 'icon',
    categoryColor: 'color',
    merchant: purpose.displayName,
    date: now,
    accountId: accountId,
    toAccountId: toAccountId,
    externalCounterpartyName: counterparty,
    linkedLoanId: loanId,
    linkedMoneyRecordId: debtId,
    principalComponent: principal,
    interestComponent: interest,
    feeComponent: fee,
    createdAt: now,
    updatedAt: now,
  );

  test('internal transfer validates distinct active owned accounts', () async {
    await service.postTransaction(
      transaction(
        id: 'transfer',
        amount: 5000,
        purpose: TransactionPurpose.internalTransfer,
        toAccountId: 'cash',
      ),
    );
    final saved = await transactions.getTransactionById('transfer');
    expect(saved?.type, TransactionType.transfer);
    expect(saved?.toAccountId, 'cash');

    await expectLater(
      service.postTransaction(
        transaction(
          id: 'bad_transfer',
          amount: 1,
          purpose: TransactionPurpose.internalTransfer,
          toAccountId: 'bank',
        ),
      ),
      throwsA(isA<ValidationError>()),
    );

    await accounts.archiveAccount('cash', true);
    await expectLater(
      service.postTransaction(
        transaction(
          id: 'archived_transfer',
          amount: 1,
          purpose: TransactionPurpose.internalTransfer,
          toAccountId: 'cash',
        ),
      ),
      throwsA(isA<ValidationError>()),
    );
  });

  test(
    'tracked EMI is atomic, idempotent, editable, reversible and restorable',
    () async {
      final emi = LoanCalculator.calculateEmi(
        principal: 120000,
        annualRate: 12,
        tenureMonths: 12,
        interestType: InterestType.reducingBalance,
      );
      final loan = Loan(
        id: 'loan',
        name: 'Personal Loan',
        lender: 'Bank Ltd',
        accountId: 'bank',
        principalAmount: 120000,
        interestRate: 12,
        tenureMonths: 12,
        startDate: DateTime(2026, 7, 1),
        expectedEndDate: DateTime(2027, 7, 1),
        emiAmount: emi,
        outstandingPrincipal: 120000,
        nextDueDate: DateTime(2026, 8, 5),
        createdAt: now,
        updatedAt: now,
      );
      await loans.saveLoan(loan);

      final id = await service.postTrackedInstallment(
        loan: loan,
        installmentNumber: 1,
        accountId: 'bank',
        paymentDate: now,
      );
      await service.postTrackedInstallment(
        loan: loan,
        installmentNumber: 1,
        accountId: 'bank',
        paymentDate: now.add(const Duration(days: 1)),
        transactionId: id,
      );

      var payments = await loans.getPaymentsForLoan('loan');
      expect(payments, hasLength(1));
      expect(payments.single.transactionId, id);
      expect(payments.single.paymentDate, now.add(const Duration(days: 1)));
      expect((await transactions.getAllTransactions()), hasLength(1));
      expect(
        (await loans.getLoanById('loan'))!.outstandingPrincipal,
        lessThan(120000),
      );

      final snapshot = await service.deleteTransaction(id);
      expect(await loans.getPaymentsForLoan('loan'), isEmpty);
      expect((await loans.getLoanById('loan'))!.outstandingPrincipal, 120000);
      expect(await transactions.getTransactionById(id), isNull);

      await service.restore(snapshot!);
      payments = await loans.getPaymentsForLoan('loan');
      expect(payments, hasLength(1));
      expect(await transactions.getTransactionById(id), isNotNull);

      await service.postTrackedInstallment(
        loan: loan,
        installmentNumber: 2,
        accountId: 'bank',
        paymentDate: now.add(const Duration(days: 30)),
      );
      payments = await loans.getPaymentsForLoan('loan');
      expect(
        payments.map((payment) => payment.installmentNumber),
        containsAll(<int>[1, 2]),
      );
    },
  );

  test(
    'lending and partial/full repayments stay linked and settle record',
    () async {
      await service.postTransaction(
        transaction(
          id: 'lend',
          amount: 10000,
          purpose: TransactionPurpose.lending,
          counterparty: 'Asha',
          debtId: 'debt',
        ),
      );
      var record = await debts.getRecordById('debt');
      expect(record?.originTransactionId, 'lend');
      expect(record?.type, MoneyRecordType.lent);

      await service.postTransaction(
        transaction(
          id: 'repay_1',
          amount: 4000,
          purpose: TransactionPurpose.personalDebtRepaymentReceived,
          counterparty: 'Asha',
          debtId: 'debt',
        ),
      );
      var repayments = await debts.getRepaymentsForRecord('debt');
      expect(repayments.single.transactionId, 'repay_1');
      expect(record!.calculateRemainingAmount(repayments), 6000);

      await service.postTransaction(
        transaction(
          id: 'repay_2',
          amount: 6000,
          purpose: TransactionPurpose.personalDebtRepaymentReceived,
          counterparty: 'Asha',
          debtId: 'debt',
        ),
      );
      record = await debts.getRecordById('debt');
      expect(record?.settledAt, isNotNull);

      await service.deleteTransaction('repay_2');
      record = await debts.getRecordById('debt');
      repayments = await debts.getRepaymentsForRecord('debt');
      expect(record?.settledAt, isNull);
      expect(record!.calculateRemainingAmount(repayments), 6000);
    },
  );

  test(
    'linked investment purchase updates asset without becoming spending',
    () async {
      await investments.saveInvestment(
        Investment(
          id: 'fund',
          name: 'Index Fund',
          assetType: AssetType.mutualFunds,
          purchasePrice: 0,
          purchaseDate: now,
          currentValue: 0,
          investedAmount: 0,
          unrealizedProfitLoss: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final purchase = transaction(
        id: 'buy',
        amount: 20000,
        purpose: TransactionPurpose.investmentPurchase,
        principal: 19950,
        fee: 50,
      ).copyWith(linkedInvestmentId: 'fund');
      await service.postTransaction(purchase);
      var fund = await investments.getInvestmentById('fund');
      expect(fund?.investedAmount, 19950);
      expect(fund?.currentValue, 19950);
      expect(purchase.consumptionExpenseAmount, 50);

      await service.deleteTransaction('buy');
      fund = await investments.getInvestmentById('fund');
      expect(fund?.investedAmount, 0);
      expect(fund?.currentValue, 0);
    },
  );

  test(
    'Menon lending: ₹2,500 and ₹300 creates 1 active relationship with 2 advances totaling ₹2,800',
    () async {
      // 1. First transaction: ₹2,500 lent to Menon
      await service.postTransaction(
        transaction(
          id: 'tx_menon_1',
          amount: 2500,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );

      var allRecords = await debts.getAllRecords();
      expect(allRecords, hasLength(1));
      var menonRecord = allRecords.single;
      expect(menonRecord.personName, 'Menon');
      expect(menonRecord.normalizedPersonName, 'menon');
      expect(menonRecord.originalAmount, 2500);
      expect(menonRecord.type, MoneyRecordType.lent);

      var menonAdvances = await debts.getAdvancesForRecord(menonRecord.id);
      expect(menonAdvances, hasLength(1));
      expect(menonAdvances.first.amount, 2500);

      // 2. Second transaction: ₹300 lent to Menon
      await service.postTransaction(
        transaction(
          id: 'tx_menon_2',
          amount: 300,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );

      allRecords = await debts.getAllRecords();
      // Should STILL be 1 active record for Menon!
      expect(allRecords, hasLength(1));
      menonRecord = allRecords.single;
      expect(menonRecord.personName, 'Menon');
      expect(menonRecord.originalAmount, 2800);

      // Should have 2 advances
      menonAdvances = await debts.getAdvancesForRecord(menonRecord.id);
      expect(menonAdvances, hasLength(2));
      expect(menonAdvances[0].amount, 2500);
      expect(menonAdvances[1].amount, 300);

      // Both transactions point to the same MoneyRecord
      final tx1 = await transactions.getTransactionById('tx_menon_1');
      final tx2 = await transactions.getTransactionById('tx_menon_2');
      expect(tx1?.linkedMoneyRecordId, menonRecord.id);
      expect(tx2?.linkedMoneyRecordId, menonRecord.id);
    },
  );

  test(
    'FIFO repayment of ₹2,600 on Menon relationship allocates correctly and delete restores balance',
    () async {
      // Setup ₹2,500 + ₹300 lent to Menon
      await service.postTransaction(
        transaction(
          id: 'tx_menon_1',
          amount: 2500,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );
      await service.postTransaction(
        transaction(
          id: 'tx_menon_2',
          amount: 300,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );

      final menonRecord = (await debts.getAllRecords()).single;
      final advances = await debts.getAdvancesForRecord(menonRecord.id);

      // Repay ₹2,600
      await service.postTransaction(
        transaction(
          id: 'tx_repay_menon',
          amount: 2600,
          purpose: TransactionPurpose.personalDebtRepaymentReceived,
          counterparty: 'Menon',
          debtId: menonRecord.id,
        ),
      );

      final repayments = await debts.getRepaymentsForRecord(menonRecord.id);
      expect(repayments, hasLength(1));
      expect(repayments.single.amount, 2600);

      expect(
        menonRecord.calculateRemainingAmount(repayments, advances: advances),
        200,
      );

      final allocations = menonRecord.calculateAllocatedAdvances(
        advances: advances,
        repayments: repayments,
      );
      expect(allocations[0].isFullyPaid, true);
      expect(allocations[0].allocatedRepaid, 2500);
      expect(allocations[1].isFullyPaid, false);
      expect(allocations[1].allocatedRepaid, 100);
      expect(allocations[1].remainingAmount, 200);

      // Delete the second advance of ₹300
      await service.deleteTransaction('tx_menon_2');
      final updatedRecord = (await debts.getAllRecords()).single;
      final remainingAdvances = await debts.getAdvancesForRecord(
        updatedRecord.id,
      );
      expect(remainingAdvances, hasLength(1));
      expect(remainingAdvances.single.amount, 2500);
      expect(updatedRecord.originalAmount, 2500);
    },
  );

  test(
    'Separate obligation flag creates isolated MoneyRecord instead of merging',
    () async {
      // 1. Active Menon lending relationship
      await service.postTransaction(
        transaction(
          id: 'tx_menon_1',
          amount: 2500,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );

      // 2. Add another advance marked explicitly as separate obligation
      final details = MoneyRecord(
        id: 'tx_menon_sep',
        type: MoneyRecordType.lent,
        personName: 'Menon',
        originalAmount: 5000,
        transactionDate: now,
        dueDate: now.add(const Duration(days: 30)),
        isCustomSeparateObligation: true,
        createdAt: now,
        updatedAt: now,
      );
      await service.postTransaction(
        transaction(
          id: 'tx_menon_sep',
          amount: 5000,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
        moneyRecordDetails: details,
      );

      final allRecords = await debts.getAllRecords();
      expect(allRecords, hasLength(2));
      expect(allRecords.any((r) => r.isCustomSeparateObligation), true);
    },
  );

  test(
    'Borrowing from Menon creates distinct borrowed record, keeping lending record isolated',
    () async {
      // Lent ₹2,500 to Menon
      await service.postTransaction(
        transaction(
          id: 'tx_menon_lent',
          amount: 2500,
          purpose: TransactionPurpose.lending,
          counterparty: 'Menon',
        ),
      );

      // Borrowed ₹1,000 from Menon
      await service.postTransaction(
        transaction(
          id: 'tx_menon_borrowed',
          amount: 1000,
          purpose: TransactionPurpose.borrowing,
          counterparty: 'Menon',
        ),
      );

      final allRecords = await debts.getAllRecords();
      expect(allRecords, hasLength(2));
      final lentRec = allRecords.firstWhere(
        (r) => r.type == MoneyRecordType.lent,
      );
      final borrowedRec = allRecords.firstWhere(
        (r) => r.type == MoneyRecordType.borrowed,
      );

      expect(lentRec.originalAmount, 2500);
      expect(borrowedRec.originalAmount, 1000);
    },
  );
}
