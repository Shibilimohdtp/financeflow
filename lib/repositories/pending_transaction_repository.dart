import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/pending_transaction_entity.dart';
import '../models/ingestion/parsed_transaction.dart';
import '../models/transaction.dart';

abstract class PendingTransactionRepository {
  Future<List<ParsedTransaction>> getPendingTransactions();
  Stream<List<ParsedTransaction>> watchPendingTransactions();
  Future<ParsedTransaction?> getPendingTransactionById(String tempId);
  Future<void> savePendingTransaction(ParsedTransaction item);
  Future<void> savePendingTransactions(List<ParsedTransaction> items);
  Future<void> removePendingTransaction(String tempId);
  Future<void> removePendingTransactions(List<String> tempIds);
  Future<void> clearAllPending();
}

class IsarPendingTransactionRepository implements PendingTransactionRepository {
  final Isar isar;

  IsarPendingTransactionRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  ParsedTransaction _toDomain(PendingTransactionEntity entity) {
    return ParsedTransaction(
      tempId: entity.tempId,
      source: TransactionSource.fromString(entity.source),
      sourceName: entity.sourceName,
      rawSource: entity.rawSource,
      sourceIdentifier: entity.sourceIdentifier,
      amount: entity.amount,
      type: TransactionType.fromString(entity.type),
      rawMerchant: entity.rawMerchant,
      normalizedMerchant: entity.normalizedMerchant,
      date: entity.date,
      time: entity.time,
      notes: entity.notes,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      paymentMethod: entity.paymentMethod,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      categorizationConfidence: entity.categorizationConfidence,
      categorizationReason: entity.categorizationReason,
      referenceNumber: entity.referenceNumber,
      fingerprint: entity.fingerprint,
      warnings: List<String>.from(entity.warnings),
      validationErrors: List<String>.from(entity.validationErrors),
      duplicateStatus: _parseDuplicateStatus(entity.duplicateStatus),
      matchedTransactionId: entity.matchedTransactionId,
      duplicateReasons: List<String>.from(entity.duplicateReasons),
      duplicateConfidence: entity.duplicateConfidence,
      duplicateResolution: _parseDuplicateResolution(
        entity.duplicateResolution,
      ),
      isIncluded: entity.isIncluded,
      reviewStatus: _parseReviewStatus(entity.reviewStatus),
      importedAt: entity.importedAt,
      detectedAt: entity.detectedAt,
    );
  }

  PendingTransactionEntity _toEntity(
    ParsedTransaction domain, [
    PendingTransactionEntity? existing,
  ]) {
    final entity = existing ?? PendingTransactionEntity();
    entity.tempId = domain.tempId;
    entity.source = domain.source.toDbString();
    entity.sourceName = domain.sourceName;
    entity.rawSource = domain.rawSource;
    entity.sourceIdentifier = domain.sourceIdentifier;
    entity.amount = domain.amount;
    entity.type = domain.type.toDbString();
    entity.rawMerchant = domain.rawMerchant;
    entity.normalizedMerchant = domain.normalizedMerchant;
    entity.date = domain.date;
    entity.time = domain.time;
    entity.notes = domain.notes;
    entity.accountId = domain.accountId;
    entity.toAccountId = domain.toAccountId;
    entity.paymentMethod = domain.paymentMethod;
    entity.categoryId = domain.categoryId;
    entity.categoryName = domain.categoryName;
    entity.categoryIcon = domain.categoryIcon;
    entity.categoryColor = domain.categoryColor;
    entity.categorizationConfidence = domain.categorizationConfidence;
    entity.categorizationReason = domain.categorizationReason;
    entity.referenceNumber = domain.referenceNumber;
    entity.fingerprint = domain.fingerprint;
    entity.warnings = domain.warnings;
    entity.validationErrors = domain.validationErrors;
    entity.duplicateStatus = domain.duplicateStatus.name;
    entity.matchedTransactionId = domain.matchedTransactionId;
    entity.duplicateReasons = domain.duplicateReasons;
    entity.duplicateConfidence = domain.duplicateConfidence;
    entity.duplicateResolution = domain.duplicateResolution.name;
    entity.isIncluded = domain.isIncluded;
    entity.reviewStatus = domain.reviewStatus.name;
    entity.importedAt = domain.importedAt;
    entity.detectedAt = domain.detectedAt;
    return entity;
  }

  static DuplicateMatchLevel _parseDuplicateStatus(String val) {
    switch (val.toLowerCase()) {
      case 'exact':
        return DuplicateMatchLevel.exact;
      case 'likely':
        return DuplicateMatchLevel.likely;
      case 'possible':
        return DuplicateMatchLevel.possible;
      default:
        return DuplicateMatchLevel.none;
    }
  }

  static DuplicateResolution _parseDuplicateResolution(String val) {
    switch (val.toLowerCase()) {
      case 'merge':
        return DuplicateResolution.merge;
      case 'keepboth':
      case 'keep_both':
        return DuplicateResolution.keepBoth;
      case 'ignore':
        return DuplicateResolution.ignore;
      case 'exclude':
        return DuplicateResolution.exclude;
      default:
        return DuplicateResolution.unresolved;
    }
  }

  static ReviewStatus _parseReviewStatus(String val) {
    switch (val.toLowerCase()) {
      case 'confirmed':
        return ReviewStatus.confirmed;
      case 'merged':
        return ReviewStatus.merged;
      case 'excluded':
        return ReviewStatus.excluded;
      case 'resolved':
        return ReviewStatus.resolved;
      default:
        return ReviewStatus.pending;
    }
  }

  @override
  Future<List<ParsedTransaction>> getPendingTransactions() async {
    final entities =
        await isar.pendingTransactionEntitys.where().sortByDateDesc().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<ParsedTransaction>> watchPendingTransactions() {
    return isar.pendingTransactionEntitys
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<ParsedTransaction?> getPendingTransactionById(String tempId) async {
    final entity =
        await isar.pendingTransactionEntitys
            .filter()
            .tempIdEqualTo(tempId)
            .findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> savePendingTransaction(ParsedTransaction item) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.pendingTransactionEntitys
              .filter()
              .tempIdEqualTo(item.tempId)
              .findFirst();
      final entity = _toEntity(item, existing);
      await isar.pendingTransactionEntitys.put(entity);
    });
  }

  @override
  Future<void> savePendingTransactions(List<ParsedTransaction> items) async {
    if (items.isEmpty) return;
    await isar.writeTxn(() async {
      for (final item in items) {
        final existing =
            await isar.pendingTransactionEntitys
                .filter()
                .tempIdEqualTo(item.tempId)
                .findFirst();
        final entity = _toEntity(item, existing);
        await isar.pendingTransactionEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> removePendingTransaction(String tempId) async {
    await isar.writeTxn(() async {
      await isar.pendingTransactionEntitys
          .filter()
          .tempIdEqualTo(tempId)
          .deleteAll();
    });
  }

  @override
  Future<void> removePendingTransactions(List<String> tempIds) async {
    if (tempIds.isEmpty) return;
    await isar.writeTxn(() async {
      for (final id in tempIds) {
        await isar.pendingTransactionEntitys
            .filter()
            .tempIdEqualTo(id)
            .deleteAll();
      }
    });
  }

  @override
  Future<void> clearAllPending() async {
    await isar.writeTxn(() async {
      await isar.pendingTransactionEntitys.clear();
    });
  }
}

final pendingTransactionRepositoryProvider =
    Provider<PendingTransactionRepository>((ref) {
      return IsarPendingTransactionRepository();
    });

final pendingTransactionsStreamProvider =
    StreamProvider<List<ParsedTransaction>>((ref) {
      try {
        final repo = ref.watch(pendingTransactionRepositoryProvider);
        return repo.watchPendingTransactions();
      } catch (_) {
        return Stream.value(const <ParsedTransaction>[]);
      }
    });
