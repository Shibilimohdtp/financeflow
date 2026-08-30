import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/money_advance_entity.dart';
import '../database/schemas/money_record_entity.dart';
import '../database/schemas/money_repayment_entity.dart';
import '../models/money_advance.dart';
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

  Future<List<MoneyAdvance>> getAllAdvances({String userId = 'local_user'});
  Future<List<MoneyAdvance>> getAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  });
  Stream<List<MoneyAdvance>> watchAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  });
  Stream<List<MoneyAdvance>> watchAllAdvances({String userId = 'local_user'});
  Future<void> saveAdvance(MoneyAdvance advance);
  Future<void> saveAdvances(List<MoneyAdvance> advances);
  Future<void> deleteAdvance(String id, {String userId = 'local_user'});
  Future<void> deleteAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  });

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

  /// Run safe local migration to synthesize advances and consolidate duplicate active records
  Future<void> migrateAdvancesAndConsolidateDuplicates({
    String userId = 'local_user',
  });
}

class IsarMoneyRecordRepository implements MoneyRecordRepository {
  final Isar isar;
  bool _migrationDone = false;

  IsarMoneyRecordRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  MoneyRecord _toRecordDomain(MoneyRecordEntity entity) {
    return MoneyRecord(
      id: entity.uuid,
      userId: entity.userId,
      type: MoneyRecordType.fromString(entity.type),
      personName: entity.personName,
      normalizedPersonName: entity.normalizedPersonName,
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
      isCustomSeparateObligation: entity.isCustomSeparateObligation,
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
    entity.normalizedPersonName = domain.normalizedPersonName;
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
    entity.isCustomSeparateObligation = domain.isCustomSeparateObligation;
    return entity;
  }

  MoneyAdvance _toAdvanceDomain(MoneyAdvanceEntity entity) {
    return MoneyAdvance(
      id: entity.uuid,
      moneyRecordId: entity.moneyRecordId,
      userId: entity.userId,
      amount: entity.amount,
      date: entity.date,
      dueDate: entity.dueDate,
      notes: entity.notes,
      accountId: entity.accountId,
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  MoneyAdvance advanceFromEntity(MoneyAdvanceEntity entity) =>
      _toAdvanceDomain(entity);

  MoneyAdvanceEntity advanceEntityFromDomain(
    MoneyAdvance domain, [
    MoneyAdvanceEntity? existing,
  ]) => _toAdvanceEntity(domain, existing);

  MoneyAdvanceEntity _toAdvanceEntity(
    MoneyAdvance domain, [
    MoneyAdvanceEntity? existing,
  ]) {
    final entity = existing ?? MoneyAdvanceEntity();
    entity.uuid = domain.id;
    entity.moneyRecordId = domain.moneyRecordId;
    entity.userId = domain.userId;
    entity.amount = domain.amount;
    entity.date = domain.date;
    entity.dueDate = domain.dueDate;
    entity.notes = domain.notes;
    entity.accountId = domain.accountId;
    entity.transactionId = domain.transactionId;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
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

  Future<void> _ensureMigrated(String userId) async {
    if (_migrationDone) return;
    _migrationDone = true;
    await migrateAdvancesAndConsolidateDuplicates(userId: userId);
  }

  @override
  Future<void> migrateAdvancesAndConsolidateDuplicates({
    String userId = 'local_user',
  }) async {
    await isar.writeTxn(() async {
      // 1. Ensure every MoneyRecordEntity has at least one MoneyAdvanceEntity
      final allRecords =
          await isar.moneyRecordEntitys
              .filter()
              .userIdEqualTo(userId)
              .findAll();

      for (final record in allRecords) {
        if (record.normalizedPersonName == null ||
            record.normalizedPersonName!.isEmpty) {
          record.normalizedPersonName = MoneyRecord.normalizePersonName(
            record.personName,
          );
          await isar.moneyRecordEntitys.put(record);
        }

        final existingAdvances =
            await isar.moneyAdvanceEntitys
                .filter()
                .moneyRecordIdEqualTo(record.uuid)
                .findAll();

        if (existingAdvances.isEmpty) {
          final advanceId =
              record.originTransactionId != null
                  ? 'adv_${record.originTransactionId}'
                  : 'adv_${record.uuid}';
          final advanceEntity =
              MoneyAdvanceEntity()
                ..uuid = advanceId
                ..moneyRecordId = record.uuid
                ..userId = record.userId
                ..amount = record.originalAmount
                ..date = record.transactionDate
                ..dueDate = record.dueDate
                ..notes = record.notes
                ..transactionId = record.originTransactionId
                ..createdAt = record.createdAt
                ..updatedAt = record.updatedAt;
          await isar.moneyAdvanceEntitys.put(advanceEntity);
        }
      }

      // 2. Consolidate duplicate active records with the same normalized counterparty and direction
      final activeRecords =
          await isar.moneyRecordEntitys
              .filter()
              .userIdEqualTo(userId)
              .and()
              .settledAtIsNull()
              .and()
              .isCustomSeparateObligationEqualTo(false)
              .findAll();

      final grouped = <String, List<MoneyRecordEntity>>{};
      for (final rec in activeRecords) {
        final key =
            '${rec.type}_${rec.normalizedPersonName ?? MoneyRecord.normalizePersonName(rec.personName)}';
        grouped.putIfAbsent(key, () => []).add(rec);
      }

      for (final entry in grouped.entries) {
        final duplicates = entry.value;
        if (duplicates.length <= 1) continue;

        // Earliest record becomes the primary relationship
        duplicates.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final primary = duplicates.first;
        final secondaries = duplicates.sublist(1);

        for (final sec in secondaries) {
          // Move advances from secondary to primary
          final advances =
              await isar.moneyAdvanceEntitys
                  .filter()
                  .moneyRecordIdEqualTo(sec.uuid)
                  .findAll();
          for (final adv in advances) {
            adv.moneyRecordId = primary.uuid;
            adv.updatedAt = DateTime.now();
            await isar.moneyAdvanceEntitys.put(adv);
          }

          // Move repayments from secondary to primary
          final repayments =
              await isar.moneyRepaymentEntitys
                  .filter()
                  .moneyRecordIdEqualTo(sec.uuid)
                  .findAll();
          for (final rep in repayments) {
            rep.moneyRecordId = primary.uuid;
            await isar.moneyRepaymentEntitys.put(rep);
          }

          // Delete secondary record
          await isar.moneyRecordEntitys.delete(sec.id);
        }

        // Recalculate primary record's total advanced amount and dates
        final allPrimaryAdvances =
            await isar.moneyAdvanceEntitys
                .filter()
                .moneyRecordIdEqualTo(primary.uuid)
                .findAll();
        final totalAdv = allPrimaryAdvances.fold<double>(
          0.0,
          (sum, a) => sum + a.amount,
        );
        primary.originalAmount = totalAdv;
        primary.updatedAt = DateTime.now();
        await isar.moneyRecordEntitys.put(primary);
      }
    });
  }

  @override
  Future<List<MoneyRecord>> getAllRecords({
    String userId = 'local_user',
  }) async {
    await _ensureMigrated(userId);
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
      // 1. Delete associated advances
      await isar.moneyAdvanceEntitys
          .filter()
          .moneyRecordIdEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();

      // 2. Delete associated repayments
      await isar.moneyRepaymentEntitys
          .filter()
          .moneyRecordIdEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();

      // 3. Delete the record itself
      await isar.moneyRecordEntitys
          .filter()
          .uuidEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  // --- Advance methods ---

  @override
  Future<List<MoneyAdvance>> getAllAdvances({
    String userId = 'local_user',
  }) async {
    final entities =
        await isar.moneyAdvanceEntitys
            .filter()
            .userIdEqualTo(userId)
            .sortByDateDesc()
            .findAll();
    return entities.map(_toAdvanceDomain).toList();
  }

  @override
  Future<List<MoneyAdvance>> getAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    final entities =
        await isar.moneyAdvanceEntitys
            .filter()
            .moneyRecordIdEqualTo(recordId)
            .and()
            .userIdEqualTo(userId)
            .sortByDate()
            .findAll();
    return entities.map(_toAdvanceDomain).toList();
  }

  @override
  Stream<List<MoneyAdvance>> watchAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) {
    return isar.moneyAdvanceEntitys
        .filter()
        .moneyRecordIdEqualTo(recordId)
        .and()
        .userIdEqualTo(userId)
        .sortByDate()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toAdvanceDomain).toList());
  }

  @override
  Stream<List<MoneyAdvance>> watchAllAdvances({String userId = 'local_user'}) {
    return isar.moneyAdvanceEntitys
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toAdvanceDomain).toList());
  }

  @override
  Future<void> saveAdvance(MoneyAdvance advance) async {
    advance.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.moneyAdvanceEntitys
              .filter()
              .uuidEqualTo(advance.id)
              .and()
              .userIdEqualTo(advance.userId)
              .findFirst();
      final entity = _toAdvanceEntity(advance, existing);
      await isar.moneyAdvanceEntitys.put(entity);
    });
  }

  @override
  Future<void> saveAdvances(List<MoneyAdvance> advances) async {
    if (advances.isEmpty) return;
    for (final a in advances) {
      a.validate();
    }
    await isar.writeTxn(() async {
      for (final a in advances) {
        final existing =
            await isar.moneyAdvanceEntitys
                .filter()
                .uuidEqualTo(a.id)
                .and()
                .userIdEqualTo(a.userId)
                .findFirst();
        final entity = _toAdvanceEntity(a, existing);
        await isar.moneyAdvanceEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> deleteAdvance(String id, {String userId = 'local_user'}) async {
    await isar.writeTxn(() async {
      await isar.moneyAdvanceEntitys
          .filter()
          .uuidEqualTo(id)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  @override
  Future<void> deleteAdvancesForRecord(
    String recordId, {
    String userId = 'local_user',
  }) async {
    await isar.writeTxn(() async {
      await isar.moneyAdvanceEntitys
          .filter()
          .moneyRecordIdEqualTo(recordId)
          .and()
          .userIdEqualTo(userId)
          .deleteAll();
    });
  }

  // --- Repayment methods ---

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
