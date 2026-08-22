import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/loan_entity.dart';
import '../models/loan.dart';

abstract class LoanRepository {
  Future<List<Loan>> getAllLoans();
  Stream<List<Loan>> watchAllLoans();
  Future<Loan?> getLoanById(String id);
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<void> updateLoanStatus(String id, LoanStatus status);
  Future<void> recordEmiPayment({
    required String loanId,
    required double principalPaid,
    required double interestPaid,
    required DateTime nextDueDate,
  });
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

  LoanEntity _toEntity(Loan domain) {
    return LoanEntity()
      ..uuid = domain.id
      ..name = domain.name
      ..lender = domain.lender
      ..loanType = domain.loanType.toDbString()
      ..accountId = domain.accountId
      ..principalAmount = domain.principalAmount
      ..interestRate = domain.interestRate
      ..interestType = domain.interestType.toDbString()
      ..tenureMonths = domain.tenureMonths
      ..startDate = domain.startDate
      ..expectedEndDate = domain.expectedEndDate
      ..emiAmount = domain.emiAmount
      ..paymentDay = domain.paymentDay
      ..totalPrincipalPaid = domain.totalPrincipalPaid
      ..totalInterestPaid = domain.totalInterestPaid
      ..outstandingPrincipal = domain.outstandingPrincipal
      ..nextDueDate = domain.nextDueDate
      ..status = domain.status.toDbString()
      ..notes = domain.notes
      ..createdAt = domain.createdAt
      ..updatedAt = domain.updatedAt;
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
      final entity = _toEntity(loan);
      if (existing != null) {
        entity.id = existing.id;
      }
      await isar.loanEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteLoan(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.loanEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        await isar.loanEntitys.delete(entity.id);
      }
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
  Future<void> recordEmiPayment({
    required String loanId,
    required double principalPaid,
    required double interestPaid,
    required DateTime nextDueDate,
  }) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.loanEntitys.filter().uuidEqualTo(loanId).findFirst();
      if (entity != null) {
        entity.totalPrincipalPaid += principalPaid;
        entity.totalInterestPaid += interestPaid;
        entity.outstandingPrincipal = (entity.outstandingPrincipal -
                principalPaid)
            .clamp(0.0, double.infinity);
        entity.nextDueDate = nextDueDate;
        if (entity.outstandingPrincipal <= 0) {
          entity.status = LoanStatus.paidOff.toDbString();
        }
        entity.updatedAt = DateTime.now();
        await isar.loanEntitys.put(entity);
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
