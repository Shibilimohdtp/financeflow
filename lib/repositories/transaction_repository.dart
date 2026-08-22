import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/transaction_entity.dart';
import '../models/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return IsarTransactionRepository();
});

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Stream<List<Transaction>> watchAllTransactions();
  Future<List<Transaction>> getRecentTransactions({int limit = 5});
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5});
  Future<List<Transaction>> getTransactionsByMonth(DateTime month);
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month);
  Future<List<Transaction>> searchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Stream<List<Transaction>> watchSearchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Transaction?> getTransactionById(String id);
  Future<void> saveTransaction(Transaction transaction);
  Future<void> saveTransactions(List<Transaction> transactions);
  Future<void> deleteTransaction(String id);
  Future<void> deleteTransactions(List<String> ids);
}

class IsarTransactionRepository implements TransactionRepository {
  final Isar isar;

  IsarTransactionRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Transaction _toDomain(TransactionEntity entity) {
    return Transaction(
      id: entity.uuid,
      amount: entity.amount,
      type: TransactionType.fromString(entity.type),
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      merchant: entity.merchant,
      date: entity.date,
      notes: entity.notes,
      source: TransactionSource.fromString(entity.source),
      paymentMethod: entity.paymentMethod,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      tags: List<String>.from(entity.tags),
      isReviewed: entity.isReviewed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      originalMerchant: entity.originalMerchant,
      normalizedMerchant: entity.normalizedMerchant,
      sourceName: entity.sourceName,
      sourceReference: entity.sourceReference,
      sourceMessageId: entity.sourceMessageId,
      fingerprint: entity.fingerprint,
      duplicateGroupId: entity.duplicateGroupId,
      mergedSources: List<String>.from(entity.mergedSources),
      importedAt: entity.importedAt,
      detectedAt: entity.detectedAt,
      reviewStatus: entity.reviewStatus,
      categorizationConfidence: entity.categorizationConfidence,
    );
  }

  TransactionEntity _toEntity(
    Transaction domain, [
    TransactionEntity? existing,
  ]) {
    final entity = existing ?? TransactionEntity();
    entity.uuid = domain.id;
    entity.amount = domain.amount;
    entity.type = domain.type.toDbString();
    entity.categoryId = domain.categoryId;
    entity.categoryName = domain.categoryName;
    entity.categoryIcon = domain.categoryIcon;
    entity.categoryColor = domain.categoryColor;
    entity.merchant = domain.merchant;
    entity.date = domain.date;
    entity.notes = domain.notes;
    entity.source = domain.source.toDbString();
    entity.paymentMethod = domain.paymentMethod;
    entity.accountId = domain.accountId;
    entity.toAccountId = domain.toAccountId;
    entity.tags = domain.tags;
    entity.isReviewed = domain.isReviewed;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    entity.originalMerchant = domain.originalMerchant;
    entity.normalizedMerchant = domain.normalizedMerchant;
    entity.sourceName = domain.sourceName;
    entity.sourceReference = domain.sourceReference;
    entity.sourceMessageId = domain.sourceMessageId;
    entity.fingerprint = domain.fingerprint;
    entity.duplicateGroupId = domain.duplicateGroupId;
    entity.mergedSources = domain.mergedSources;
    entity.importedAt = domain.importedAt;
    entity.detectedAt = domain.detectedAt;
    entity.reviewStatus = domain.reviewStatus;
    entity.categorizationConfidence = domain.categorizationConfidence;
    return entity;
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final entities =
        await isar.transactionEntitys.where().sortByDateDesc().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    return isar.transactionEntitys
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async {
    final entities =
        await isar.transactionEntitys
            .where()
            .sortByDateDesc()
            .limit(limit)
            .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) {
    return isar.transactionEntitys
        .where()
        .sortByDateDesc()
        .limit(limit)
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
      999,
    );

    final entities =
        await isar.transactionEntitys
            .filter()
            .dateBetween(startOfMonth, endOfMonth)
            .sortByDateDesc()
            .findAll();

    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
      999,
    );

    return isar.transactionEntitys
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<Transaction>> searchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var isarQuery = isar.transactionEntitys.filter().uuidIsNotEmpty();

    if (type != null) {
      isarQuery = isarQuery.typeEqualTo(type.toDbString());
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      isarQuery = isarQuery.categoryIdEqualTo(categoryId);
    }

    if (accountId != null && accountId.isNotEmpty) {
      isarQuery = isarQuery.accountIdEqualTo(accountId);
    }

    if (startDate != null && endDate != null) {
      isarQuery = isarQuery.dateBetween(startDate, endDate);
    } else if (startDate != null) {
      isarQuery = isarQuery.dateGreaterThan(startDate, include: true);
    } else if (endDate != null) {
      isarQuery = isarQuery.dateLessThan(endDate, include: true);
    }

    final entities = await isarQuery.sortByDateDesc().findAll();

    var domainList = entities.map(_toDomain).toList();

    // In-memory multi-field search for merchant, notes, categoryName, tags, amount
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      domainList =
          domainList.where((tx) {
            final merchantMatch = tx.merchant.toLowerCase().contains(q);
            final notesMatch = tx.notes?.toLowerCase().contains(q) ?? false;
            final catMatch = tx.categoryName.toLowerCase().contains(q);
            final tagMatch = tx.tags.any((t) => t.toLowerCase().contains(q));
            final amountMatch = tx.amount.toString().contains(q);
            return merchantMatch ||
                notesMatch ||
                catMatch ||
                tagMatch ||
                amountMatch;
          }).toList();
    }

    return domainList;
  }

  @override
  Stream<List<Transaction>> watchSearchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Watch all and apply the exact search/filter on stream changes
    return isar.transactionEntitys
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((entities) {
          var domainList = entities.map(_toDomain).toList();

          if (type != null) {
            domainList = domainList.where((tx) => tx.type == type).toList();
          }
          if (categoryId != null && categoryId.isNotEmpty) {
            domainList =
                domainList.where((tx) => tx.categoryId == categoryId).toList();
          }
          if (accountId != null && accountId.isNotEmpty) {
            domainList =
                domainList
                    .where(
                      (tx) =>
                          tx.accountId == accountId ||
                          tx.toAccountId == accountId,
                    )
                    .toList();
          }
          if (startDate != null) {
            domainList =
                domainList.where((tx) => !tx.date.isBefore(startDate)).toList();
          }
          if (endDate != null) {
            domainList =
                domainList.where((tx) => !tx.date.isAfter(endDate)).toList();
          }
          if (query != null && query.trim().isNotEmpty) {
            final q = query.trim().toLowerCase();
            domainList =
                domainList.where((tx) {
                  final merchantMatch = tx.merchant.toLowerCase().contains(q);
                  final notesMatch =
                      tx.notes?.toLowerCase().contains(q) ?? false;
                  final catMatch = tx.categoryName.toLowerCase().contains(q);
                  final tagMatch = tx.tags.any(
                    (t) => t.toLowerCase().contains(q),
                  );
                  final amountMatch = tx.amount.toString().contains(q);
                  return merchantMatch ||
                      notesMatch ||
                      catMatch ||
                      tagMatch ||
                      amountMatch;
                }).toList();
          }

          return domainList;
        });
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final entity =
        await isar.transactionEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    transaction.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.transactionEntitys
              .filter()
              .uuidEqualTo(transaction.id)
              .findFirst();
      final entity = _toEntity(transaction, existing);
      await isar.transactionEntitys.put(entity);
    });
  }

  @override
  Future<void> saveTransactions(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;
    for (final tx in transactions) {
      tx.validate();
    }
    await isar.writeTxn(() async {
      for (final tx in transactions) {
        final existing =
            await isar.transactionEntitys
                .filter()
                .uuidEqualTo(tx.id)
                .findFirst();
        final entity = _toEntity(tx, existing);
        await isar.transactionEntitys.put(entity);
      }
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await isar.writeTxn(() async {
      await isar.transactionEntitys.filter().uuidEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return;
    await isar.writeTxn(() async {
      for (final id in ids) {
        await isar.transactionEntitys.filter().uuidEqualTo(id).deleteAll();
      }
    });
  }
}
