import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/money_record_entity.dart';
import '../database/schemas/money_repayment_entity.dart';
import '../models/money_record.dart';
import '../models/money_repayment.dart';

final moneyRecordRepositoryProvider = Provider<MoneyRecordRepository>((ref) {
  return IsarMoneyRecordRepository();
});

abstract class MoneyRecordRepository {
  Future<List<MoneyRecord>> getAllRecords({String userId = 'local_user'});
  Stream<List<MoneyRecord>> watchAllRecords({String userId = 'local_user'});
  Future<MoneyRecord?> getRecordById(String id, {String userId = 'local_user'});
  Future<void> saveRecord(MoneyRecord record);
  Future<void> deleteRecord(String id, {String userId = 'local_user'});

  Future<List<MoneyRepayment>> getAllRepayments({String userId = 'local_user'});
  Future<List<MoneyRepayment>> getRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  });
  Stream<List<MoneyRepayment>> watchRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  });
  Stream<List<MoneyRepayment>> watchAllRepayments({
    String userId = 'local_user',
  });
  Future<void> addRepayment(MoneyRepayment repayment);
  Future<void> deleteRepayment(String id, {String userId = 'local_user'});
}

class IsarMoneyRecordRepository implements MoneyRecordRepository {
  final Isar isar;

  IsarMoneyRecordRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  MoneyRecord _toRecordDomain(MoneyRecordEntity entity) {
    return MoneyRecord(
      id: entity.uuid,
      userId: entity.userId,
      type: MoneyRecordType.fromString(entity.type),
      personName: entity.personName,
      originalAmount: entity.originalAmount,
      transactionDate: entity.transactionDate,
      dueDate: entity.dueDate,
      notes: entity.notes,
      isReminderEnabled: entity.isReminderEnabled,
      reminderDaysBefore: entity.reminderDaysBefore,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      settledAt: entity.settledAt,
      originTransactionId: entity.originTransactionId,
    );
  }

  MoneyRecord recordFromEntity(MoneyRecordEntity entity) =>
      _toRecordDomain(entity);

  MoneyRecordEntity recordEntityFromDomain(
    MoneyRecord domain, [
    MoneyRecordEntity? existing,
  ]) => _toRecordEntity(domain, existing);

  MoneyRecordEntity _toRecordEntity(
    MoneyRecord domain, [
    MoneyRecordEntity? existing,
  ]) {
    final entity = existing ?? MoneyRecordEntity();
    entity.uuid = domain.id;
    entity.userId = domain.userId;
    entity.type = domain.type.toDbString();
    entity.personName = domain.personName;
    entity.originalAmount = domain.originalAmount;
    entity.transactionDate = domain.transactionDate;
    entity.dueDate = domain.dueDate;
    entity.notes = domain.notes;
    entity.isReminderEnabled = domain.isReminderEnabled;
    entity.reminderDaysBefore = domain.reminderDaysBefore;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    entity.settledAt = domain.settledAt;
    entity.status = domain.settledAt != null ? 'settled' : 'active';
    entity.originTransactionId = domain.originTransactionId;
    return entity;
  }

  MoneyRepayment _toRepaymentDomain(MoneyRepaymentEntity entity) {
    return MoneyRepayment(
      id: entity.uuid,
      moneyRecordId: entity.moneyRecordId,
      userId: entity.userId,
      amount: entity.amount,
      repaymentDate: entity.repaymentDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      transactionId: entity.transactionId,
    );
  }

  MoneyRepayment repaymentFromEntity(MoneyRepaymentEntity entity) =>
      _toRepaymentDomain(entity);

  MoneyRepaymentEntity repaymentEntityFromDomain(
    MoneyRepayment domain, [
    MoneyRepaymentEntity? existing,
  ]) => _toRepaymentEntity(domain, existing);

  MoneyRepaymentEntity _toRepaymentEntity(
    MoneyRepayment domain, [
    MoneyRepaymentEntity? existing,
  ]) {
    final entity = existing ?? MoneyRepaymentEntity();
    entity.uuid = domain.id;
    entity.moneyRecordId = domain.moneyRecordId;
    entity.userId = domain.userId;
    entity.amount = domain.amount;
    entity.repaymentDate = domain.repaymentDate;
    entity.notes = domain.notes;
    entity.createdAt = domain.createdAt;
    entity.transactionId = domain.transactionId;
    return entity;
  }

  @override
  Future<List<MoneyRecord>> getAllRecords({
    String userId = 'local_user',
  }) async {
    final entities =
        await isar.moneyRecordEntitys
            .filter()
            .userIdEqualTo(userId)
            .sortByDueDateDesc()
            .findAll();
    return entities.map(_toRecordDomain).toList();
  }

  @override
  Stream<List<MoneyRecord>> watchAllRecords({String userId = 'local_user'}) {
    return isar.moneyRecordEntitys
        .filter()
        .userIdEqualTo(userId)
        .sortByDueDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toRecordDomain).toList());
  }

  @override
  Future<MoneyRecord?> getRecordById(
    String id, {
    String userId = 'local_user',
  }) async {
    final entity =
        await isar.moneyRecordEntitys
            .filter()
            .uuidEqualTo(id)
            .and()
            .userIdEqualTo(userId)
            .findFirst();
    if (entity == null) return null;
    return _toRecordDomain(entity);
  }

  @override
  Future<void> saveRecord(MoneyRecord record) async {
    record.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.moneyRecordEntitys
              .filter()
              .uuidEqualTo(record.id)
              .and()
              .userIdEqualTo(record.userId)
              .findFirst();
      final entity = _toRecordEntity(record, existing);
      await isar.moneyRecordEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteRecord(String id, {String userId = 'local_user'}) async {
    await isar.writeTxn(() async {
      // 1. Delete associated repayments
      await isar.moneyRepaymentEntitys
          .filter()
          .moneyRecordIdEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();

      // 2. Delete the record itself
      await isar.moneyRecordEntitys
          .filter()
          .uuidEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  @override
  Future<List<MoneyRepayment>> getAllRepayments({
    String userId = 'local_user',
  }) async {
    final entities =
        await isar.moneyRepaymentEntitys
            .filter()
            .userIdEqualTo(userId)
            .sortByRepaymentDateDesc()
            .findAll();
    return entities.map(_toRepaymentDomain).toList();
  }

  @override
  Future<List<MoneyRepayment>> getRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    final entities =
        await isar.moneyRepaymentEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .and()
            .userIdEqualTo(userId)
            .sortByRepaymentDateDesc()
            .findAll();
    return entities.map(_toRepaymentDomain).toList();
  }

  @override
  Stream<List<MoneyRepayment>> watchRepaymentsForRecord(
    String recordId, {
    String userId = 'local_user',
  }) {
    return isar.moneyRepaymentEntitys
        .filter()
        .moneyRecordIdEqualTo(recordId)
        .and()
        .userIdEqualTo(userId)
        .sortByRepaymentDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toRepaymentDomain).toList());
  }

  @override
  Stream<List<MoneyRepayment>> watchAllRepayments({
    String userId = 'local_user',
  }) {
    return isar.moneyRepaymentEntitys
        .filter()
        .userIdEqualTo(userId)
        .sortByRepaymentDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toRepaymentDomain).toList());
  }

  @override
  Future<void> addRepayment(MoneyRepayment repayment) async {
    repayment.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.moneyRepaymentEntitys
              .filter()
              .uuidEqualTo(repayment.id)
              .and()
              .userIdEqualTo(repayment.userId)
              .findFirst();
      final entity = _toRepaymentEntity(repayment, existing);
      await isar.moneyRepaymentEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteRepayment(
    String id, {
    String userId = 'local_user',
  }) async {
    await isar.writeTxn(() async {
      await isar.moneyRepaymentEntitys
          .filter()
          .uuidEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }
}
