import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../core/errors/app_error.dart';
import '../core/money/money_math.dart';
import '../database/isar_service.dart';
import '../database/schemas/emi_payment_entity.dart';
import '../database/schemas/account_entity.dart';
import '../database/schemas/loan_entity.dart';
import '../database/schemas/investment_entity.dart';
import '../database/schemas/money_record_entity.dart';
import '../database/schemas/money_repayment_entity.dart';
import '../database/schemas/transaction_entity.dart';
import '../models/loan.dart';
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
    this.moneyRepayments = const [],
  });

  final Transaction transaction;
  final List<EmiPayment> emiPayments;
  final MoneyRecord? moneyRecord;
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
    transaction.validate();
    _validateComponents(transaction);

    await isar.writeTxn(() async {
      await _validateAccounts(transaction);
      final existing =
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(transaction.id)
              .findFirst();

      final affectedLoans = <String>{};
      final affectedInvestments = <String>{};
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
        affectedLoans.addAll(
          await _reverseLinks(
            existing.uuid,
            preserveOriginRecordId:
                preservesOrigin ? transaction.linkedMoneyRecordId : null,
          ),
        );
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
          await _postMoneyRecord(transaction, details: moneyRecordDetails);
        case TransactionPurpose.personalDebtRepaymentMade:
        case TransactionPurpose.personalDebtRepaymentReceived:
          await _postMoneyRepayment(transaction);
        default:
          break;
      }

      for (final loanId in affectedLoans) {
        await _recalculateLoan(loanId);
      }
      for (final investmentId in affectedInvestments) {
        await _recalculateInvestment(investmentId);
      }
    });
  }

  /// Posts an installment from the Loans feature. A stable transaction id makes
  /// this safe to retry after a double tap or interrupted UI transition.
  Future<String> postTrackedInstallment({
    required Loan loan,
    required int installmentNumber,
    required String accountId,
    DateTime? paymentDate,
    String? transactionId,
  }) async {
    final split = LoanCalculator.calculateInstallmentSplit(
      loan: loan,
      installmentNumber: installmentNumber,
    );
    final id = transactionId ?? 'loan_${loan.id}_$installmentNumber';
    final now = DateTime.now();
    await postTransaction(
      Transaction(
        id: id,
        amount: MoneyMath.round(split.emi),
        type: TransactionType.loanEmi,
        purpose: TransactionPurpose.loanRepayment,
        direction: AccountMovementDirection.outflow,
        categoryId: 'cat_loan_emi',
        categoryName: 'Loan / EMI',
        categoryIcon: 'receipt_long',
        categoryColor: 'debt',
        merchant: loan.name,
        externalCounterpartyName: loan.lender,
        date: paymentDate ?? now,
        source: TransactionSource.manual,
        paymentMethod: 'Auto Debit',
        accountId: accountId,
        linkedLoanId: loan.id,
        principalComponent: MoneyMath.round(split.principal),
        interestComponent: MoneyMath.round(split.interest),
        feeComponent: MoneyMath.round(
          split.emi - split.principal - split.interest,
        ).clamp(0, double.infinity),
        tags: const ['linked-loan-payment'],
        isReviewed: true,
        createdAt: now,
        updatedAt: now,
      ),
      preferredInstallmentNumber: installmentNumber,
    );
    return id;
  }

  Future<FinancialOperationSnapshot?> deleteTransaction(String id) async {
    FinancialOperationSnapshot? snapshot;
    await isar.writeTxn(() async {
      final entity =
          await isar.transactionEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity == null) return;

      final paymentEntities =
          await isar.emiPaymentEntitys
              .filter()
              .transactionIdEqualTo(id)
              .findAll();
      final repaymentEntities =
          await isar.moneyRepaymentEntitys
              .filter()
              .transactionIdEqualTo(id)
              .findAll();
      final recordEntity =
          await isar.moneyRecordEntitys
              .filter()
              .originTransactionIdEqualTo(id)
              .findFirst();
      final recordRepayments =
          recordEntity == null
              ? <MoneyRepaymentEntity>[]
              : await isar.moneyRepaymentEntitys
                  .filter()
                  .moneyRecordIdEqualTo(recordEntity.uuid)
                  .findAll();

      snapshot = FinancialOperationSnapshot(
        transaction: _transactions.domainFromEntity(entity),
        emiPayments: paymentEntities.map(_loans.paymentFromEntity).toList(),
        moneyRecord:
            recordEntity == null ? null : _money.recordFromEntity(recordEntity),
        moneyRepayments:
            <MoneyRepayment>[
                  ...repaymentEntities.map(_money.repaymentFromEntity),
                  ...recordRepayments.map(_money.repaymentFromEntity),
                ]
                .fold(<String, MoneyRepayment>{}, (map, item) {
                  map[item.id] = item;
                  return map;
                })
                .values
                .toList(),
      );

      final affectedLoans = await _reverseLinks(id);
      final affectedInvestmentId = entity.linkedInvestmentId;
      await isar.transactionEntitys.delete(entity.id);
      for (final loanId in affectedLoans) {
        await _recalculateLoan(loanId);
      }
      if (affectedInvestmentId != null) {
        await _recalculateInvestment(affectedInvestmentId);
      }
    });
    return snapshot;
  }

  Future<void> restore(FinancialOperationSnapshot snapshot) async {
    await isar.writeTxn(() async {
      await _validateAccounts(snapshot.transaction);
      final existing =
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(snapshot.transaction.id)
              .findFirst();
      await isar.transactionEntitys.put(
        _transactions.entityFromDomain(snapshot.transaction, existing),
      );
      if (snapshot.moneyRecord != null) {
        final old =
            await isar.moneyRecordEntitys
                .filter()
                .uuidEqualTo(snapshot.moneyRecord!.id)
                .findFirst();
        await isar.moneyRecordEntitys.put(
          _money.recordEntityFromDomain(snapshot.moneyRecord!, old),
        );
      }
      for (final repayment in snapshot.moneyRepayments) {
        final old =
            await isar.moneyRepaymentEntitys
                .filter()
                .uuidEqualTo(repayment.id)
                .findFirst();
        await isar.moneyRepaymentEntitys.put(
          _money.repaymentEntityFromDomain(repayment, old),
        );
      }
      final affectedLoans = <String>{};
      for (final payment in snapshot.emiPayments) {
        final old =
            await isar.emiPaymentEntitys
                .filter()
                .uuidEqualTo(payment.id)
                .findFirst();
        await isar.emiPaymentEntitys.put(
          _loans.paymentEntityFromDomain(payment, old),
        );
        affectedLoans.add(payment.loanId);
      }
      for (final loanId in affectedLoans) {
        await _recalculateLoan(loanId);
      }
    });
  }

  /// Deleting a linked allocation follows the documented owner policy: delete
  /// its ledger transaction and all allocations. Historical status-only rows
  /// have no owner and are deleted directly.
  Future<FinancialOperationSnapshot?> deleteEmiPayment(String paymentId) async {
    final payment =
        await isar.emiPaymentEntitys
            .filter()
            .uuidEqualTo(paymentId)
            .findFirst();
    if (payment == null) return null;
    if (payment.transactionId != null) {
      return deleteTransaction(payment.transactionId!);
    }
    await isar.writeTxn(() async {
      await isar.emiPaymentEntitys.delete(payment.id);
      await _recalculateLoan(payment.loanId);
    });
    return null;
  }

  /// Removes a tracked loan while retaining linked ledger rows as explicitly
  /// unlinked historical payments. No misleading live link is left behind.
  Future<void> deleteLoanKeepingHistory(String loanId) async {
    await isar.writeTxn(() async {
      final payments =
          await isar.emiPaymentEntitys.filter().loanIdEqualTo(loanId).findAll();
      for (final payment in payments) {
        final transactionId = payment.transactionId;
        if (transactionId == null) continue;
        final transaction =
            await isar.transactionEntitys
                .filter()
                .uuidEqualTo(transactionId)
                .findFirst();
        if (transaction != null) {
          transaction.linkedLoanId = null;
          transaction.updatedAt = DateTime.now();
          await isar.transactionEntitys.put(transaction);
        }
      }
      await isar.emiPaymentEntitys.filter().loanIdEqualTo(loanId).deleteAll();
      await isar.loanEntitys.filter().uuidEqualTo(loanId).deleteAll();
    });
  }

  Future<void> deleteInvestmentKeepingHistory(String investmentId) async {
    await isar.writeTxn(() async {
      final entries =
          await isar.transactionEntitys
              .filter()
              .linkedInvestmentIdEqualTo(investmentId)
              .findAll();
      for (final entry in entries) {
        entry.linkedInvestmentId = null;
        entry.updatedAt = DateTime.now();
        await isar.transactionEntitys.put(entry);
      }
      await isar.investmentEntitys
          .filter()
          .uuidEqualTo(investmentId)
          .deleteAll();
    });
  }

  Transaction _normalized(Transaction transaction) {
    final isInternal =
        transaction.effectivePurpose == TransactionPurpose.internalTransfer;
    final keepsCounterparty = <TransactionPurpose>{
      TransactionPurpose.lending,
      TransactionPurpose.borrowing,
      TransactionPurpose.personalDebtRepaymentMade,
      TransactionPurpose.personalDebtRepaymentReceived,
      TransactionPurpose.loanDisbursement,
      TransactionPurpose.loanRepayment,
    }.contains(transaction.effectivePurpose);
    return transaction.copyWith(
      type: _legacyTypeFor(transaction.effectivePurpose),
      direction: transaction.effectiveDirection,
      clearToAccountId: !isInternal,
      externalCounterpartyName:
          keepsCounterparty ? transaction.externalCounterpartyName : null,
    );
  }

  TransactionType _legacyTypeFor(
    TransactionPurpose purpose,
  ) => switch (purpose) {
    TransactionPurpose.income ||
    TransactionPurpose.borrowing ||
    TransactionPurpose.loanDisbursement ||
    TransactionPurpose.personalDebtRepaymentReceived => TransactionType.income,
    TransactionPurpose.internalTransfer => TransactionType.transfer,
    TransactionPurpose.investmentPurchase ||
    TransactionPurpose.investmentRedemption => TransactionType.investment,
    TransactionPurpose.loanRepayment => TransactionType.loanEmi,
    TransactionPurpose.legacyCash => TransactionType.cash,
    _ => TransactionType.expense,
  };

  void _validateComponents(Transaction transaction) {
    if (transaction.effectivePurpose == TransactionPurpose.loanRepayment &&
        transaction.linkedLoanId != null) {
      final total =
          transaction.principalAmount +
          transaction.interestAmount +
          transaction.feeAmount;
      if (!MoneyMath.close(total, transaction.amount)) {
        throw const ValidationError(
          message:
              'Principal, interest and fees must equal the payment amount.',
          actionableStep: 'Correct the payment split or record it as unlinked.',
        );
      }
    }
    if (transaction.linkedInvestmentId != null &&
        transaction.effectivePurpose == TransactionPurpose.investmentPurchase) {
      if (!MoneyMath.close(
        transaction.principalAmount + transaction.feeAmount,
        transaction.amount,
      )) {
        throw const ValidationError(
          message: 'Investment asset value and fees must equal the cash paid.',
        );
      }
    }
    if (transaction.linkedInvestmentId != null &&
        transaction.effectivePurpose ==
            TransactionPurpose.investmentRedemption) {
      if (!MoneyMath.close(
        transaction.principalAmount +
            transaction.interestAmount -
            transaction.feeAmount,
        transaction.amount,
      )) {
        throw const ValidationError(
          message:
              'Cost basis plus realized gain, less fees, must equal redemption proceeds.',
        );
      }
    }
  }

  Future<void> _validateAccounts(Transaction transaction) async {
    final source =
        await isar.accountEntitys
            .filter()
            .uuidEqualTo(transaction.accountId)
            .findFirst();
    if (source == null || source.isArchived) {
      throw const ValidationError(
        message: 'The selected account is missing or archived.',
        actionableStep: 'Choose an active account you own.',
      );
    }
    if (transaction.effectiveDirection == AccountMovementDirection.internal) {
      final destinationId = transaction.toAccountId;
      if (destinationId == null || destinationId == transaction.accountId) {
        throw const ValidationError(
          message: 'Transfer accounts must be distinct owned accounts.',
        );
      }
      final destination =
          await isar.accountEntitys
              .filter()
              .uuidEqualTo(destinationId)
              .findFirst();
      if (destination == null || destination.isArchived) {
        throw const ValidationError(
          message: 'The destination account is missing or archived.',
          actionableStep: 'Choose an active destination account you own.',
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
        message: 'The selected tracked loan was not found.',
      );
    }
    final loan = _loans.domainFromEntity(loanEntity);
    if (loan.status != LoanStatus.active) {
      throw const ValidationError(
        message: 'Only an active loan can receive a payment.',
      );
    }
    final existing =
        await isar.emiPaymentEntitys.filter().loanIdEqualTo(loanId).findAll();
    final payments = existing.map(_loans.paymentFromEntity).toList();
    final unpaid =
        LoanCalculator.generateSchedule(
          loan,
          payments: payments,
        ).where((item) => !item.isPaid).toList();
    if (unpaid.isEmpty) {
      throw const ValidationError(
        message: 'This loan has no unpaid installments.',
      );
    }
    final installment =
        preferredInstallmentNumber == null
            ? unpaid.first
            : unpaid
                .where((item) => item.monthNumber == preferredInstallmentNumber)
                .firstOrNull;
    if (installment == null) {
      throw ValidationError(
        message:
            'Installment #$preferredInstallmentNumber is already paid or unavailable.',
      );
    }
    if (!MoneyMath.close(transaction.amount, installment.emiAmount)) {
      throw ValidationError(
        message:
            'This amount does not match installment #${installment.monthNumber}.',
        actionableStep:
            'Use the expected EMI amount or save this as an unlinked loan payment.',
      );
    }
    final now = DateTime.now();
    final payment = EmiPayment(
      id: 'emi_${transaction.id}_${installment.monthNumber}',
      loanId: loanId,
      installmentNumber: installment.monthNumber,
      dueDate: installment.dueDate,
      paymentDate: transaction.date,
      principalPaid: transaction.principalAmount,
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

  Future<void> _postMoneyRecord(
    Transaction transaction, {
    MoneyRecord? details,
  }) async {
    final recordId = transaction.linkedMoneyRecordId;
    final person = transaction.externalCounterpartyName?.trim();
    if (recordId == null || person == null || person.isEmpty) {
      throw const ValidationError(
        message: 'A linked debt record and counterparty are required.',
      );
    }
    final existing =
        await isar.moneyRecordEntitys
            .filter()
            .uuidEqualTo(recordId)
            .findFirst();
    final now = DateTime.now();
    final record = MoneyRecord(
      id: recordId,
      type:
          transaction.effectivePurpose == TransactionPurpose.lending
              ? MoneyRecordType.lent
              : MoneyRecordType.borrowed,
      personName: person,
      originalAmount: transaction.amount,
      transactionDate: transaction.date,
      dueDate:
          details?.dueDate ??
          existing?.dueDate ??
          transaction.date.add(const Duration(days: 30)),
      notes: details?.notes ?? transaction.notes,
      isReminderEnabled: details?.isReminderEnabled ?? true,
      reminderDaysBefore: details?.reminderDaysBefore ?? 1,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      originTransactionId: transaction.id,
    );
    record.validate();
    final repayments =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final totalRepaid = repayments.fold<double>(
      0,
      (sum, repayment) => sum + repayment.amount,
    );
    if (record.originalAmount + MoneyMath.tolerance < totalRepaid) {
      throw ValidationError(
        message:
            'The original amount cannot be less than repayments already recorded.',
        actionableStep:
            'Use at least ${MoneyMath.round(totalRepaid).toStringAsFixed(2)}.',
      );
    }
    await isar.moneyRecordEntitys.put(
      _money.recordEntityFromDomain(record, existing),
    );
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
    final old =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final remaining = record.calculateRemainingAmount(
      old.map(_money.repaymentFromEntity).toList(),
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
    final all = [...old.map(_money.repaymentFromEntity), repayment];
    final settled = record.calculateRemainingAmount(all) <= MoneyMath.tolerance;
    await isar.moneyRecordEntitys.put(
      _money.recordEntityFromDomain(
        record.copyWith(
          settledAt: settled ? DateTime.now() : null,
          clearSettledAt: !settled,
          updatedAt: DateTime.now(),
        ),
        recordEntity,
      ),
    );
  }

  Future<Set<String>> _reverseLinks(
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

    final origin =
        await isar.moneyRecordEntitys
            .filter()
            .originTransactionIdEqualTo(transactionId)
            .findFirst();
    if (origin != null && origin.uuid != preserveOriginRecordId) {
      final linkedRepayments =
          await isar.moneyRepaymentEntitys
              .filter()
              .moneyRecordIdEqualTo(origin.uuid)
              .findAll();
      for (final repayment in linkedRepayments) {
        if (repayment.transactionId != null) {
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(repayment.transactionId!)
              .deleteAll();
        }
      }
      await isar.moneyRepaymentEntitys
          .filter()
          .moneyRecordIdEqualTo(origin.uuid)
          .deleteAll();
      await isar.moneyRecordEntitys.delete(origin.id);
    }

    for (final recordId in affectedRecords) {
      await _recalculateMoneyRecord(recordId);
    }
    return affectedLoans;
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
    final repayments =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .findAll();
    final settled =
        record.calculateRemainingAmount(
          repayments.map(_money.repaymentFromEntity).toList(),
        ) <=
        MoneyMath.tolerance;
    await isar.moneyRecordEntitys.put(
      _money.recordEntityFromDomain(
        record.copyWith(
          settledAt: settled ? record.settledAt ?? DateTime.now() : null,
          clearSettledAt: !settled,
          updatedAt: DateTime.now(),
        ),
        entity,
      ),
    );
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
