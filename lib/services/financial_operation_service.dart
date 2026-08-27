import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../core/errors/app_error.dart';
import '../core/money/money_math.dart';
import '../database/isar_service.dart';
import '../database/schemas/emi_payment_entity.dart';
import '../database/schemas/account_entity.dart';
import '../database/schemas/loan_entity.dart';
import '../database/schemas/investment_entity.dart';
import '../database/schemas/money_advance_entity.dart';
import '../database/schemas/money_record_entity.dart';
import '../database/schemas/money_repayment_entity.dart';
import '../database/schemas/transaction_entity.dart';
import '../models/loan.dart';
import '../models/money_advance.dart';
import '../models/money_record.dart';
import '../models/money_repayment.dart';
import '../models/transaction.dart';
import '../repositories/loan_repository.dart';
import '../repositories/money_record_repository.dart';
import '../repositories/transaction_repository.dart';
import 'loan_calculator.dart';

final financialOperationServiceProvider = Provider<FinancialOperationService>(
  (ref) => FinancialOperationService(),
);

/// Complete data needed to restore a linked deletion as one operation.
class FinancialOperationSnapshot {
  const FinancialOperationSnapshot({
    required this.transaction,
    this.emiPayments = const [],
    this.moneyRecord,
    this.moneyAdvances = const [],
    this.moneyRepayments = const [],
  });

  final Transaction transaction;
  final List<EmiPayment> emiPayments;
  final MoneyRecord? moneyRecord;
  final List<MoneyAdvance> moneyAdvances;
  final List<MoneyRepayment> moneyRepayments;
}

/// Atomic application boundary for ledger entries and the domain allocations
/// they own. Widgets/controllers must not independently save the two sides.
class FinancialOperationService {
  FinancialOperationService({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar,
      _transactions = IsarTransactionRepository(isarInstance: isarInstance),
      _loans = IsarLoanRepository(isarInstance: isarInstance),
      _money = IsarMoneyRecordRepository(isarInstance: isarInstance);

  final Isar isar;
  final IsarTransactionRepository _transactions;
  final IsarLoanRepository _loans;
  final IsarMoneyRecordRepository _money;

  Future<void> postTransaction(
    Transaction proposed, {
    MoneyRecord? moneyRecordDetails,
    int? preferredInstallmentNumber,
  }) async {
    final transaction = _normalized(proposed);
    validateDraft(transaction);

    await isar.writeTxn(() async {
      await _validateAccounts(transaction);
      final existing =
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(transaction.id)
              .findFirst();

      final affectedLoans = <String>{};
      final affectedInvestments = <String>{};
      final affectedRecords = <String>{};
      if (existing != null) {
        final existingDomain = _transactions.domainFromEntity(existing);
        if (existingDomain.linkedInvestmentId != null) {
          affectedInvestments.add(existingDomain.linkedInvestmentId!);
        }
        final preservesOrigin =
            existingDomain.linkedMoneyRecordId != null &&
            existingDomain.linkedMoneyRecordId ==
                transaction.linkedMoneyRecordId &&
            <TransactionPurpose>{
              TransactionPurpose.lending,
              TransactionPurpose.borrowing,
            }.contains(transaction.effectivePurpose);
        final reversed = await _reverseLinks(
          existing.uuid,
          preserveOriginRecordId:
              preservesOrigin ? transaction.linkedMoneyRecordId : null,
        );
        affectedLoans.addAll(reversed.affectedLoans);
        affectedRecords.addAll(reversed.affectedRecords);
      }

      await isar.transactionEntitys.put(
        _transactions.entityFromDomain(transaction, existing),
      );
      if (transaction.linkedInvestmentId != null) {
        final investment =
            await isar.investmentEntitys
                .filter()
                .uuidEqualTo(transaction.linkedInvestmentId!)
                .findFirst();
        if (investment == null || investment.isArchived) {
          throw const ValidationError(
            message: 'The selected investment is missing or archived.',
          );
        }
        affectedInvestments.add(transaction.linkedInvestmentId!);
      }

      switch (transaction.effectivePurpose) {
        case TransactionPurpose.loanRepayment:
          if (transaction.linkedLoanId != null) {
            affectedLoans.add(
              await _postLoanPayment(
                transaction,
                preferredInstallmentNumber: preferredInstallmentNumber,
              ),
            );
          }
        case TransactionPurpose.lending:
        case TransactionPurpose.borrowing:
          final recordId = await _postMoneyRecord(
            transaction,
            details: moneyRecordDetails,
          );
          affectedRecords.add(recordId);
          if (transaction.linkedMoneyRecordId != recordId) {
            final txWithLink = transaction.copyWith(
              linkedMoneyRecordId: recordId,
            );
            await isar.transactionEntitys.put(
              _transactions.entityFromDomain(txWithLink, existing),
            );
          }
        case TransactionPurpose.personalDebtRepaymentMade:
        case TransactionPurpose.personalDebtRepaymentReceived:
          await _postMoneyRepayment(transaction);
          if (transaction.linkedMoneyRecordId != null) {
            affectedRecords.add(transaction.linkedMoneyRecordId!);
          }
        default:
          break;
      }

      for (final loanId in affectedLoans) {
        await _recalculateLoan(loanId);
      }
      for (final investmentId in affectedInvestments) {
        await _recalculateInvestment(investmentId);
      }
      for (final recordId in affectedRecords) {
        await _recalculateMoneyRecord(recordId);
      }
    });
  }

  Future<FinancialOperationSnapshot?> deleteTransaction(
    String transactionId,
  ) async {
    return isar.writeTxn(() async {
      final existing =
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(transactionId)
              .findFirst();
      if (existing == null) return null;

      final domain = _transactions.domainFromEntity(existing);
      final emiPayments =
          (await isar.emiPaymentEntitys
                  .filter()
                  .transactionIdEqualTo(transactionId)
                  .findAll())
              .map(_loans.paymentFromEntity)
              .toList();
      final repayments =
          (await isar.moneyRepaymentEntitys
                  .filter()
                  .transactionIdEqualTo(transactionId)
                  .findAll())
              .map(_money.repaymentFromEntity)
              .toList();
      final advances =
          (await isar.moneyAdvanceEntitys
                  .filter()
                  .transactionIdEqualTo(transactionId)
                  .findAll())
              .map(_money.advanceFromEntity)
              .toList();
      final originRecord =
          await isar.moneyRecordEntitys
              .filter()
              .originTransactionIdEqualTo(transactionId)
              .findFirst();

      final reversed = await _reverseLinks(transactionId);
      await isar.transactionEntitys.delete(existing.id);

      for (final loanId in reversed.affectedLoans) {
        await _recalculateLoan(loanId);
      }
      if (domain.linkedInvestmentId != null) {
        await _recalculateInvestment(domain.linkedInvestmentId!);
      }
      for (final recordId in reversed.affectedRecords) {
        await _recalculateMoneyRecord(recordId);
      }

      return FinancialOperationSnapshot(
        transaction: domain,
        emiPayments: emiPayments,
        moneyRecord:
            originRecord != null ? _money.recordFromEntity(originRecord) : null,
        moneyAdvances: advances,
        moneyRepayments: repayments,
      );
    });
  }

  Future<void> restore(FinancialOperationSnapshot snapshot) async {
    await isar.writeTxn(() async {
      await isar.transactionEntitys.put(
        _transactions.entityFromDomain(snapshot.transaction),
      );
      for (final p in snapshot.emiPayments) {
        await isar.emiPaymentEntitys.put(_loans.paymentEntityFromDomain(p));
      }
      if (snapshot.moneyRecord != null) {
        await isar.moneyRecordEntitys.put(
          _money.recordEntityFromDomain(snapshot.moneyRecord!),
        );
      }
      for (final a in snapshot.moneyAdvances) {
        await isar.moneyAdvanceEntitys.put(_money.advanceEntityFromDomain(a));
      }
      for (final r in snapshot.moneyRepayments) {
        await isar.moneyRepaymentEntitys.put(
          _money.repaymentEntityFromDomain(r),
        );
      }

      if (snapshot.transaction.linkedLoanId != null) {
        await _recalculateLoan(snapshot.transaction.linkedLoanId!);
      }
      if (snapshot.transaction.linkedInvestmentId != null) {
        await _recalculateInvestment(snapshot.transaction.linkedInvestmentId!);
      }
      if (snapshot.transaction.linkedMoneyRecordId != null) {
        await _recalculateMoneyRecord(
          snapshot.transaction.linkedMoneyRecordId!,
        );
      }
      if (snapshot.moneyRecord != null) {
        await _recalculateMoneyRecord(snapshot.moneyRecord!.id);
      }
    });
  }

  Future<String> postTrackedInstallment({
    required Loan loan,
    required int installmentNumber,
    required String accountId,
    required DateTime paymentDate,
    String? transactionId,
  }) async {
    final payments = await _loans.getPaymentsForLoan(loan.id);
    final split = LoanCalculator.calculateInstallmentSplit(
      loan: loan,
      installmentNumber: installmentNumber,
    );

    final existingForNumber =
        payments
            .where((p) => p.installmentNumber == installmentNumber)
            .firstOrNull;
    final txId = transactionId ?? existingForNumber?.transactionId ?? 'tx_${DateTime.now().microsecondsSinceEpoch}';

    final transaction = Transaction(
      id: txId,
      amount: split.emi,
      type: TransactionType.expense,
      purpose: TransactionPurpose.loanRepayment,
      categoryId: 'cat_loan_repayment',
      categoryName: 'Loan Repayment',
      categoryIcon: 'account_balance',
      categoryColor: 'loan',
      merchant: loan.lender,
      date: paymentDate,
      accountId: accountId,
      linkedLoanId: loan.id,
      principalComponent: split.principal,
      interestComponent: split.interest,
      feeComponent: 0,
      notes: 'EMI installment #$installmentNumber for ${loan.name}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await postTransaction(
      transaction,
      preferredInstallmentNumber: installmentNumber,
    );
    return txId;
  }

  Future<void> deleteLoanKeepingHistory(String loanId) async {
    await isar.writeTxn(() async {
      await isar.loanEntitys.filter().uuidEqualTo(loanId).deleteAll();
      await isar.emiPaymentEntitys.filter().loanIdEqualTo(loanId).deleteAll();
    });
  }

  Future<void> deleteInvestmentKeepingHistory(String investmentId) async {
    await isar.writeTxn(() async {
      await isar.investmentEntitys.filter().uuidEqualTo(investmentId).deleteAll();
    });
  }

  Future<void> deleteEmiPayment(String paymentId) async {
    await isar.writeTxn(() async {
      final payment =
          await isar.emiPaymentEntitys.filter().uuidEqualTo(paymentId).findFirst();
      if (payment != null) {
        if (payment.transactionId != null) {
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(payment.transactionId!)
              .deleteAll();
        }
        await isar.emiPaymentEntitys.delete(payment.id);
        await _recalculateLoan(payment.loanId);
      }
    });
  }

  void validateDraft(Transaction tx) {
    tx.validate();
    final purpose = tx.effectivePurpose;

    if (purpose == TransactionPurpose.internalTransfer) {
      if (tx.toAccountId == null || tx.toAccountId!.isEmpty) {
        throw const ValidationError(
          message: 'Choose a destination account for internal transfers.',
          actionableStep: 'Select a different owned account in Transfer To.',
        );
      }
      if (tx.toAccountId == tx.accountId) {
        throw const ValidationError(
          message: 'Destination account must be different from source account.',
          actionableStep: 'Choose two distinct accounts.',
        );
      }
    }

    if (purpose == TransactionPurpose.loanRepayment) {
      if (tx.linkedLoanId == null || tx.linkedLoanId!.isEmpty) {
        throw const ValidationError(
          message: 'Select a loan for this repayment.',
          actionableStep: 'Choose a loan from your active liabilities.',
        );
      }
    }

    if (purpose == TransactionPurpose.investmentPurchase ||
        purpose == TransactionPurpose.investmentRedemption) {
      if (tx.linkedInvestmentId == null || tx.linkedInvestmentId!.isEmpty) {
        throw const ValidationError(
          message: 'Select an investment portfolio or holding.',
          actionableStep: 'Link the transaction to an investment asset.',
        );
      }
    }

    if (purpose == TransactionPurpose.personalDebtRepaymentMade ||
        purpose == TransactionPurpose.personalDebtRepaymentReceived) {
      if (tx.linkedMoneyRecordId == null || tx.linkedMoneyRecordId!.isEmpty) {
        throw const ValidationError(
          message: 'Select the personal debt record being settled.',
          actionableStep: 'Choose an active lent or borrowed record.',
        );
      }
    }
  }

  Transaction _normalized(Transaction proposed) {
    var tx = proposed;
    switch (tx.effectivePurpose) {
      case TransactionPurpose.internalTransfer:
        tx = tx.copyWith(
          type: TransactionType.transfer,
          linkedLoanId: null,
          linkedInvestmentId: null,
          linkedMoneyRecordId: null,
          principalComponent: null,
          interestComponent: null,
          feeComponent: null,
        );
      case TransactionPurpose.loanDisbursement:
        tx = tx.copyWith(
          type: TransactionType.income,
          toAccountId: null,
          linkedInvestmentId: null,
          linkedMoneyRecordId: null,
        );
      case TransactionPurpose.loanRepayment:
        tx = tx.copyWith(
          type: TransactionType.expense,
          toAccountId: null,
          linkedInvestmentId: null,
          linkedMoneyRecordId: null,
        );
      case TransactionPurpose.investmentPurchase:
        tx = tx.copyWith(
          type: TransactionType.expense,
          toAccountId: null,
          linkedLoanId: null,
          linkedMoneyRecordId: null,
        );
      case TransactionPurpose.investmentRedemption:
        tx = tx.copyWith(
          type: TransactionType.income,
          toAccountId: null,
          linkedLoanId: null,
          linkedMoneyRecordId: null,
        );
      case TransactionPurpose.lending:
        tx = tx.copyWith(
          type: TransactionType.expense,
          toAccountId: null,
          linkedLoanId: null,
          linkedInvestmentId: null,
        );
      case TransactionPurpose.borrowing:
        tx = tx.copyWith(
          type: TransactionType.income,
          toAccountId: null,
          linkedLoanId: null,
          linkedInvestmentId: null,
        );
      case TransactionPurpose.personalDebtRepaymentReceived:
        tx = tx.copyWith(
          type: TransactionType.income,
          toAccountId: null,
          linkedLoanId: null,
          linkedInvestmentId: null,
        );
      case TransactionPurpose.personalDebtRepaymentMade:
        tx = tx.copyWith(
          type: TransactionType.expense,
          toAccountId: null,
          linkedLoanId: null,
          linkedInvestmentId: null,
        );
      case TransactionPurpose.expense:
      case TransactionPurpose.income:
      case TransactionPurpose.accountAdjustment:
      case TransactionPurpose.legacyCash:
        tx = tx.copyWith(
          toAccountId: null,
          linkedLoanId: null,
          linkedInvestmentId: null,
          linkedMoneyRecordId: null,
          principalComponent: null,
          interestComponent: null,
          feeComponent: null,
        );
    }
    return tx;
  }

  Future<void> _validateAccounts(Transaction tx) async {
    final from =
        await isar.accountEntitys.filter().uuidEqualTo(tx.accountId).findFirst();
    if (from == null || from.isArchived) {
      throw ValidationError(
        message: 'Source account is missing or archived.',
        actionableStep: 'Select an active account for payment.',
      );
    }
    if (tx.effectivePurpose == TransactionPurpose.internalTransfer) {
      final to =
          await isar.accountEntitys
              .filter()
              .uuidEqualTo(tx.toAccountId!)
              .findFirst();
      if (to == null || to.isArchived) {
        throw ValidationError(
          message: 'Destination account is missing or archived.',
          actionableStep: 'Select an active destination account.',
        );
      }
    }
  }

  Future<String> _postLoanPayment(
    Transaction transaction, {
    int? preferredInstallmentNumber,
  }) async {
    final loanId = transaction.linkedLoanId!;
    final loanEntity =
        await isar.loanEntitys.filter().uuidEqualTo(loanId).findFirst();
    if (loanEntity == null) {
      throw const ValidationError(
        message: 'The linked loan could not be found.',
      );
    }
    final loan = _loans.domainFromEntity(loanEntity);
    final payments = (await isar.emiPaymentEntitys
            .filter()
            .loanIdEqualTo(loanId)
            .findAll())
        .map(_loans.paymentFromEntity)
        .toList();

    final nextNumber =
        preferredInstallmentNumber ??
        payments
            .where((p) => p.transactionId == transaction.id)
            .firstOrNull
            ?.installmentNumber ??
        (payments.isEmpty
            ? 1
            : (payments.map((p) => p.installmentNumber).reduce((a, b) => a > b ? a : b) + 1));

    final split = LoanCalculator.calculateInstallmentSplit(
      loan: loan,
      installmentNumber: nextNumber,
    );

    final paymentExisting =
        await isar.emiPaymentEntitys
            .filter()
            .loanIdEqualTo(loanId)
            .and()
            .transactionIdEqualTo(transaction.id)
            .findFirst();

    final now = DateTime.now();
    final payment = EmiPayment(
      id: paymentExisting?.uuid ?? 'emi_${transaction.id}',
      loanId: loanId,
      installmentNumber: nextNumber,
      paymentDate: transaction.date,
      dueDate: split.dueDate,
      principalPaid: transaction.principalComponent ?? split.principal,
      interestPaid: transaction.interestAmount,
      emiAmount: transaction.amount,
      accountId: transaction.accountId,
      transactionId: transaction.id,
      notes: transaction.notes,
      createdAt: now,
      updatedAt: now,
    );
    await isar.emiPaymentEntitys.put(_loans.paymentEntityFromDomain(payment));
    return loanId;
  }

  Future<String> _postMoneyRecord(
    Transaction transaction, {
    MoneyRecord? details,
  }) async {
    final person =
        transaction.externalCounterpartyName?.trim() ??
        details?.personName.trim() ??
        transaction.merchant.trim();
    if (person.isEmpty) {
      throw const ValidationError(
        message: 'A counterparty person name is required for lending/borrowing.',
      );
    }

    final type =
        transaction.effectivePurpose == TransactionPurpose.lending
            ? MoneyRecordType.lent
            : MoneyRecordType.borrowed;
    final normalized = MoneyRecord.normalizePersonName(person);
    final now = DateTime.now();

    // 1. Resolve or locate target MoneyRecord relationship
    MoneyRecordEntity? recordEntity;

    if (transaction.linkedMoneyRecordId != null &&
        transaction.linkedMoneyRecordId!.isNotEmpty) {
      recordEntity =
          await isar.moneyRecordEntitys
              .filter()
              .uuidEqualTo(transaction.linkedMoneyRecordId!)
              .findFirst();
    }

    if (recordEntity == null) {
      if (details?.isCustomSeparateObligation == true) {
        // Explicit separate debt requested
        final newRecordId =
            transaction.linkedMoneyRecordId ?? 'debt_${transaction.id}';
        final newRecord = MoneyRecord(
          id: newRecordId,
          type: type,
          personName: person,
          normalizedPersonName: normalized,
          originalAmount: transaction.amount,
          transactionDate: transaction.date,
          dueDate:
              details?.dueDate ??
              transaction.date.add(const Duration(days: 30)),
          notes: details?.notes ?? transaction.notes,
          isReminderEnabled: details?.isReminderEnabled ?? true,
          reminderDaysBefore: details?.reminderDaysBefore ?? 1,
          createdAt: now,
          updatedAt: now,
          isCustomSeparateObligation: true,
          originTransactionId: transaction.id,
        );
        recordEntity = _money.recordEntityFromDomain(newRecord);
        await isar.moneyRecordEntitys.put(recordEntity);
      } else {
        // Group by active normalized counterparty + direction
        recordEntity =
            await isar.moneyRecordEntitys
                .filter()
                .typeEqualTo(type.toDbString())
                .and()
                .settledAtIsNull()
                .and()
                .isCustomSeparateObligationEqualTo(false)
                .and()
                .group(
                  (q) => q
                      .normalizedPersonNameEqualTo(normalized)
                      .or()
                      .personNameEqualTo(person, caseSensitive: false),
                )
                .findFirst();

        if (recordEntity == null) {
          // No matching active relationship; create a new one
          final newRecordId =
              transaction.linkedMoneyRecordId ?? 'debt_${transaction.id}';
          final newRecord = MoneyRecord(
            id: newRecordId,
            type: type,
            personName: person,
            normalizedPersonName: normalized,
            originalAmount: transaction.amount,
            transactionDate: transaction.date,
            dueDate:
              details?.dueDate ??
              transaction.date.add(const Duration(days: 30)),
            notes: details?.notes ?? transaction.notes,
            isReminderEnabled: details?.isReminderEnabled ?? true,
            reminderDaysBefore: details?.reminderDaysBefore ?? 1,
            createdAt: now,
            updatedAt: now,
            originTransactionId: transaction.id,
          );
          recordEntity = _money.recordEntityFromDomain(newRecord);
          await isar.moneyRecordEntitys.put(recordEntity);
        }
      }
    }

    final targetRecordId = recordEntity.uuid;

    // 2. Create or update MoneyAdvanceEntity for this transaction
    final advanceId = 'adv_${transaction.id}';
    final existingAdvance =
        await isar.moneyAdvanceEntitys
            .filter()
            .uuidEqualTo(advanceId)
            .or()
            .transactionIdEqualTo(transaction.id)
            .findFirst();

    final advance = MoneyAdvance(
      id: existingAdvance?.uuid ?? advanceId,
      moneyRecordId: targetRecordId,
      userId: recordEntity.userId,
      amount: transaction.amount,
      date: transaction.date,
      dueDate:
          details?.dueDate ??
          existingAdvance?.dueDate ??
          recordEntity.dueDate,
      notes: details?.notes ?? transaction.notes,
      accountId: transaction.accountId,
      transactionId: transaction.id,
      createdAt: existingAdvance?.createdAt ?? now,
      updatedAt: now,
    );
    advance.validate();
    await isar.moneyAdvanceEntitys.put(
      _money.advanceEntityFromDomain(advance, existingAdvance),
    );

    // 3. Recalculate relationship amounts, due date, and status
    await _recalculateMoneyRecord(targetRecordId);
    return targetRecordId;
  }

  Future<void> _postMoneyRepayment(Transaction transaction) async {
    final recordId = transaction.linkedMoneyRecordId;
    if (recordId == null) {
      throw const ValidationError(
        message: 'Select the debt record being repaid.',
      );
    }
    final recordEntity =
        await isar.moneyRecordEntitys
            .filter()
            .uuidEqualTo(recordId)
            .findFirst();
    if (recordEntity == null) {
      throw const ValidationError(
        message: 'The linked debt record was not found.',
      );
    }
    final record = _money.recordFromEntity(recordEntity);
    final receiving =
        transaction.effectivePurpose ==
        TransactionPurpose.personalDebtRepaymentReceived;
    if (receiving != (record.type == MoneyRecordType.lent)) {
      throw const ValidationError(
        message: 'Repayment direction does not match the debt record.',
      );
    }
    final oldRepayments =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final advances =
        await isar.moneyAdvanceEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final remaining = record.calculateRemainingAmount(
      oldRepayments.map(_money.repaymentFromEntity).toList(),
      advances: advances.map(_money.advanceFromEntity).toList(),
    );
    final repayment = MoneyRepayment(
      id: 'rep_${transaction.id}',
      moneyRecordId: recordId,
      amount: transaction.amount,
      repaymentDate: transaction.date,
      notes: transaction.notes,
      createdAt: DateTime.now(),
      transactionId: transaction.id,
    );
    repayment.validate(remainingBalance: remaining);
    await isar.moneyRepaymentEntitys.put(
      _money.repaymentEntityFromDomain(repayment),
    );
    await _recalculateMoneyRecord(recordId);
  }

  Future<_ReverseResult> _reverseLinks(
    String transactionId, {
    String? preserveOriginRecordId,
  }) async {
    final payments =
        await isar.emiPaymentEntitys
            .filter()
            .transactionIdEqualTo(transactionId)
            .findAll();
    final affectedLoans = payments.map((p) => p.loanId).toSet();
    await isar.emiPaymentEntitys
        .filter()
        .transactionIdEqualTo(transactionId)
        .deleteAll();

    final repayments =
        await isar.moneyRepaymentEntitys
            .filter()
            .transactionIdEqualTo(transactionId)
            .findAll();
    final affectedRecords = repayments.map((p) => p.moneyRecordId).toSet();
    await isar.moneyRepaymentEntitys
        .filter()
        .transactionIdEqualTo(transactionId)
        .deleteAll();

    final advances =
        await isar.moneyAdvanceEntitys
            .filter()
            .transactionIdEqualTo(transactionId)
            .findAll();
    affectedRecords.addAll(advances.map((a) => a.moneyRecordId));
    await isar.moneyAdvanceEntitys
        .filter()
        .transactionIdEqualTo(transactionId)
        .deleteAll();

    final origin =
        await isar.moneyRecordEntitys
            .filter()
            .originTransactionIdEqualTo(transactionId)
            .findFirst();
    if (origin != null && origin.uuid != preserveOriginRecordId) {
      final remainingAdvances =
          await isar.moneyAdvanceEntitys
              .filter()
              .moneyRecordIdEqualTo(origin.uuid)
              .count();
      final remainingRepayments =
          await isar.moneyRepaymentEntitys
              .filter()
              .moneyRecordIdEqualTo(origin.uuid)
              .count();

      if (remainingAdvances == 0 && remainingRepayments == 0) {
        affectedRecords.remove(origin.uuid);
        await isar.moneyRecordEntitys.delete(origin.id);
      } else {
        affectedRecords.add(origin.uuid);
      }
    }

    return _ReverseResult(
      affectedLoans: affectedLoans,
      affectedRecords: affectedRecords,
    );
  }

  Future<void> _recalculateLoan(String loanId) async {
    final entity =
        await isar.loanEntitys.filter().uuidEqualTo(loanId).findFirst();
    if (entity == null) return;
    final payments =
        await isar.emiPaymentEntitys.filter().loanIdEqualTo(loanId).findAll();
    final updated = LoanCalculator.recalculateLoanState(
      loan: _loans.domainFromEntity(entity),
      payments: payments.map(_loans.paymentFromEntity).toList(),
    );
    await isar.loanEntitys.put(_loans.entityFromDomain(updated, entity));
  }

  Future<void> _recalculateMoneyRecord(String recordId) async {
    final entity =
        await isar.moneyRecordEntitys
            .filter()
            .uuidEqualTo(recordId)
            .findFirst();
    if (entity == null) return;
    final record = _money.recordFromEntity(entity);
    final advances =
        await isar.moneyAdvanceEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final repayments =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();

    final domainAdvances = advances.map(_money.advanceFromEntity).toList();
    final domainRepayments =
        repayments.map(_money.repaymentFromEntity).toList();

    final totalAdvanced = record.calculateTotalAdvanced(domainAdvances);
    final remaining = record.calculateRemainingAmount(
      domainRepayments,
      advances: domainAdvances,
    );
    final settled = remaining <= MoneyMath.tolerance;
    final effectiveDue = record.calculateEffectiveDueDate(
      advances: domainAdvances,
      repayments: domainRepayments,
    );

    entity.originalAmount = totalAdvanced;
    entity.dueDate = effectiveDue;
    entity.settledAt = settled ? (entity.settledAt ?? DateTime.now()) : null;
    entity.status = settled ? 'settled' : 'active';
    entity.updatedAt = DateTime.now();
    await isar.moneyRecordEntitys.put(entity);
  }

  Future<void> _recalculateInvestment(String investmentId) async {
    final entity =
        await isar.investmentEntitys
            .filter()
            .uuidEqualTo(investmentId)
            .findFirst();
    if (entity == null) return;
    entity.ledgerBaselineInvestedAmount ??= entity.investedAmount;
    entity.ledgerBaselineCurrentValue ??= entity.currentValue;
    entity.ledgerBaselineRealizedProfitLoss ??= entity.realizedProfitLoss ?? 0;
    final entries =
        await isar.transactionEntitys
            .filter()
            .linkedInvestmentIdEqualTo(investmentId)
            .findAll();
    var invested = entity.ledgerBaselineInvestedAmount!;
    var current = entity.ledgerBaselineCurrentValue!;
    var realized = entity.ledgerBaselineRealizedProfitLoss!;
    for (final entry in entries.map(_transactions.domainFromEntity)) {
      final principal =
          entry.principalComponent ??
          (entry.amount - entry.feeAmount).clamp(0, double.infinity);
      if (entry.effectivePurpose == TransactionPurpose.investmentPurchase) {
        invested += principal;
        current += principal;
      } else if (entry.effectivePurpose ==
          TransactionPurpose.investmentRedemption) {
        invested = (invested - principal).clamp(0, double.infinity);
        current = (current - principal).clamp(0, double.infinity);
        realized += entry.interestAmount - entry.feeAmount;
      }
    }
    entity.investedAmount = MoneyMath.round(invested);
    entity.currentValue = MoneyMath.round(current);
    entity.realizedProfitLoss = MoneyMath.round(realized);
    entity.unrealizedProfitLoss = MoneyMath.round(current - invested);
    entity.updatedAt = DateTime.now();
    await isar.investmentEntitys.put(entity);
  }
}

class _ReverseResult {
  final Set<String> affectedLoans;
  final Set<String> affectedRecords;

  const _ReverseResult({
    required this.affectedLoans,
    required this.affectedRecords,
  });
}
