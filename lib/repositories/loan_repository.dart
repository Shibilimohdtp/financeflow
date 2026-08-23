import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../core/errors/app_error.dart';
import '../database/isar_service.dart';
import '../database/schemas/emi_payment_entity.dart';
import '../database/schemas/loan_entity.dart';
import '../models/loan.dart';
import '../services/loan_calculator.dart';

abstract class LoanRepository {
  Future<List<Loan>> getAllLoans();
  Stream<List<Loan>> watchAllLoans();
  Future<Loan?> getLoanById(String id);
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<void> updateLoanStatus(String id, LoanStatus status);

  // EMI Payment Tracking
  Future<List<EmiPayment>> getPaymentsForLoan(String loanId);
  Stream<List<EmiPayment>> watchPaymentsForLoan(String loanId);
  Future<List<EmiPayment>> getAllPayments();
  Future<void> recordEmiPayment(EmiPayment payment);
  Future<void> recordMultipleEmiPayments(List<EmiPayment> payments);
  Future<void> deleteEmiPayment(String paymentId);
}

class IsarLoanRepository implements LoanRepository {
  final Isar isar;

  IsarLoanRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Loan _toDomain(LoanEntity entity) {
    return Loan(
      id: entity.uuid,
      name: entity.name,
      lender: entity.lender,
      loanType: LoanType.fromString(entity.loanType),
      accountId: entity.accountId,
      principalAmount: entity.principalAmount,
      interestRate: entity.interestRate,
      interestType: InterestType.fromString(entity.interestType),
      tenureMonths: entity.tenureMonths,
      startDate: entity.startDate,
      expectedEndDate: entity.expectedEndDate,
      emiAmount: entity.emiAmount,
      paymentDay: entity.paymentDay,
      totalPrincipalPaid: entity.totalPrincipalPaid,
      totalInterestPaid: entity.totalInterestPaid,
      outstandingPrincipal: entity.outstandingPrincipal,
      nextDueDate: entity.nextDueDate,
      status: LoanStatus.fromString(entity.status),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  LoanEntity _toEntity(Loan domain, [LoanEntity? existing]) {
    final entity = existing ?? LoanEntity();
    entity.uuid = domain.id;
    entity.name = domain.name;
    entity.lender = domain.lender;
    entity.loanType = domain.loanType.toDbString();
    entity.accountId = domain.accountId;
    entity.principalAmount = domain.principalAmount;
    entity.interestRate = domain.interestRate;
    entity.interestType = domain.interestType.toDbString();
    entity.tenureMonths = domain.tenureMonths;
    entity.startDate = domain.startDate;
    entity.expectedEndDate = domain.expectedEndDate;
    entity.emiAmount = domain.emiAmount;
    entity.paymentDay = domain.paymentDay;
    entity.totalPrincipalPaid = domain.totalPrincipalPaid;
    entity.totalInterestPaid = domain.totalInterestPaid;
    entity.outstandingPrincipal = domain.outstandingPrincipal;
    entity.nextDueDate = domain.nextDueDate;
    entity.status = domain.status.toDbString();
    entity.notes = domain.notes;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  EmiPayment _toPaymentDomain(EmiPaymentEntity entity) {
    return EmiPayment(
      id: entity.uuid,
      loanId: entity.loanId,
      installmentNumber: entity.installmentNumber,
      dueDate: entity.dueDate,
      paymentDate: entity.paymentDate,
      principalPaid: entity.principalPaid,
      interestPaid: entity.interestPaid,
      emiAmount: entity.emiAmount,
      accountId: entity.accountId,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  EmiPaymentEntity _toPaymentEntity(
    EmiPayment domain, [
    EmiPaymentEntity? existing,
  ]) {
    final entity = existing ?? EmiPaymentEntity();
    entity.uuid = domain.id;
    entity.loanId = domain.loanId;
    entity.installmentNumber = domain.installmentNumber;
    entity.dueDate = domain.dueDate;
    entity.paymentDate = domain.paymentDate;
    entity.principalPaid = domain.principalPaid;
    entity.interestPaid = domain.interestPaid;
    entity.emiAmount = domain.emiAmount;
    entity.accountId = domain.accountId;
    entity.notes = domain.notes;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  @override
  Future<List<Loan>> getAllLoans() async {
    final entities =
        await isar.loanEntitys.where().sortByNextDueDate().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Loan>> watchAllLoans() {
    return isar.loanEntitys
        .where()
        .sortByNextDueDate()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<Loan?> getLoanById(String id) async {
    final entity = await isar.loanEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.loanEntitys.filter().uuidEqualTo(loan.id).findFirst();
      final entity = _toEntity(loan, existing);
      await isar.loanEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteLoan(String id) async {
    await isar.writeTxn(() async {
      // 1. Delete loan
      await isar.loanEntitys.filter().uuidEqualTo(id).deleteAll();
      // 2. Cascade delete all EMI payments for this loan
      await isar.emiPaymentEntitys.filter().loanIdEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> updateLoanStatus(String id, LoanStatus status) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.loanEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.status = status.toDbString();
        entity.updatedAt = DateTime.now();
        await isar.loanEntitys.put(entity);
      }
    });
  }

  @override
  Future<List<EmiPayment>> getPaymentsForLoan(String loanId) async {
    final entities =
        await isar.emiPaymentEntitys
            .filter()
            .loanIdEqualTo(loanId)
            .sortByInstallmentNumber()
            .findAll();
    return entities.map(_toPaymentDomain).toList();
  }

  @override
  Stream<List<EmiPayment>> watchPaymentsForLoan(String loanId) {
    return isar.emiPaymentEntitys
        .filter()
        .loanIdEqualTo(loanId)
        .sortByInstallmentNumber()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toPaymentDomain).toList());
  }

  @override
  Future<List<EmiPayment>> getAllPayments() async {
    final entities =
        await isar.emiPaymentEntitys.where().sortByPaymentDateDesc().findAll();
    return entities.map(_toPaymentDomain).toList();
  }

  @override
  Future<void> recordEmiPayment(EmiPayment payment) async {
    payment.validate();

    await isar.writeTxn(() async {
      // 1. Duplicate check: verify no payment exists for this loan & installment number
      final duplicate =
          await isar.emiPaymentEntitys
              .filter()
              .loanIdEqualTo(payment.loanId)
              .and()
              .installmentNumberEqualTo(payment.installmentNumber)
              .findFirst();

      if (duplicate != null && duplicate.uuid != payment.id) {
        throw ValidationError(
          message:
              'EMI installment #${payment.installmentNumber} has already been marked as paid.',
          actionableStep: 'Select the next unpaid installment.',
        );
      }

      // 2. Put the payment entity
      final existingPayment =
          await isar.emiPaymentEntitys
              .filter()
              .uuidEqualTo(payment.id)
              .findFirst();
      final paymentEntity = _toPaymentEntity(payment, existingPayment);
      await isar.emiPaymentEntitys.put(paymentEntity);

      // 3. Recalculate loan state
      final loanEntity =
          await isar.loanEntitys
              .filter()
              .uuidEqualTo(payment.loanId)
              .findFirst();
      if (loanEntity != null) {
        final currentLoan = _toDomain(loanEntity);
        final allPaymentsEntities =
            await isar.emiPaymentEntitys
                .filter()
                .loanIdEqualTo(payment.loanId)
                .findAll();
        final allPayments = allPaymentsEntities.map(_toPaymentDomain).toList();

        final updatedLoan = LoanCalculator.recalculateLoanState(
          loan: currentLoan,
          payments: allPayments,
        );

        _toEntity(updatedLoan, loanEntity);
        await isar.loanEntitys.put(loanEntity);
      }
    });
  }

  @override
  Future<void> recordMultipleEmiPayments(List<EmiPayment> payments) async {
    if (payments.isEmpty) return;

    for (final p in payments) {
      p.validate();
    }

    await isar.writeTxn(() async {
      final loanId = payments.first.loanId;

      for (final payment in payments) {
        final duplicate =
            await isar.emiPaymentEntitys
                .filter()
                .loanIdEqualTo(payment.loanId)
                .and()
                .installmentNumberEqualTo(payment.installmentNumber)
                .findFirst();

        if (duplicate == null) {
          final paymentEntity = _toPaymentEntity(payment);
          await isar.emiPaymentEntitys.put(paymentEntity);
        }
      }

      // Recalculate loan state once
      final loanEntity =
          await isar.loanEntitys.filter().uuidEqualTo(loanId).findFirst();
      if (loanEntity != null) {
        final currentLoan = _toDomain(loanEntity);
        final allPaymentsEntities =
            await isar.emiPaymentEntitys
                .filter()
                .loanIdEqualTo(loanId)
                .findAll();
        final allPayments = allPaymentsEntities.map(_toPaymentDomain).toList();

        final updatedLoan = LoanCalculator.recalculateLoanState(
          loan: currentLoan,
          payments: allPayments,
        );

        _toEntity(updatedLoan, loanEntity);
        await isar.loanEntitys.put(loanEntity);
      }
    });
  }

  @override
  Future<void> deleteEmiPayment(String paymentId) async {
    await isar.writeTxn(() async {
      final paymentEntity =
          await isar.emiPaymentEntitys
              .filter()
              .uuidEqualTo(paymentId)
              .findFirst();
      if (paymentEntity == null) return;

      final loanId = paymentEntity.loanId;
      await isar.emiPaymentEntitys.delete(paymentEntity.id);

      // Recalculate loan state
      final loanEntity =
          await isar.loanEntitys.filter().uuidEqualTo(loanId).findFirst();
      if (loanEntity != null) {
        final currentLoan = _toDomain(loanEntity);
        final allPaymentsEntities =
            await isar.emiPaymentEntitys
                .filter()
                .loanIdEqualTo(loanId)
                .findAll();
        final allPayments = allPaymentsEntities.map(_toPaymentDomain).toList();

        final updatedLoan = LoanCalculator.recalculateLoanState(
          loan: currentLoan,
          payments: allPayments,
        );

        _toEntity(updatedLoan, loanEntity);
        await isar.loanEntitys.put(loanEntity);
      }
    });
  }
}

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return IsarLoanRepository();
});

final allLoansStreamProvider = StreamProvider<List<Loan>>((ref) {
  try {
    final repo = ref.watch(loanRepositoryProvider);
    return repo.watchAllLoans();
  } catch (_) {
    return Stream.value(const []);
  }
});
