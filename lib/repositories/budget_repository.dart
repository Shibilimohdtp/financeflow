import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/budget_entity.dart';
import '../models/budget.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return IsarBudgetRepository();
});

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Stream<List<Budget>> watchAllBudgets();
  Future<List<Budget>> getActiveBudgets();
  Stream<List<Budget>> watchActiveBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<void> saveBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<void> archiveBudget(String id, bool isArchived);
}

class IsarBudgetRepository implements BudgetRepository {
  final Isar isar;

  IsarBudgetRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Budget _toDomain(BudgetEntity entity) {
    return Budget(
      id: entity.uuid,
      name: entity.name,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      amountLimit: entity.amountLimit,
      period: BudgetPeriod.fromString(entity.period),
      startDate: entity.startDate,
      endDate: entity.endDate,
      alertThreshold: entity.alertThreshold,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BudgetEntity _toEntity(Budget domain, [BudgetEntity? existing]) {
    final entity = existing ?? BudgetEntity();
    entity.uuid = domain.id;
    entity.name = domain.name;
    entity.categoryId = domain.categoryId;
    entity.categoryName = domain.categoryName;
    entity.categoryIcon = domain.categoryIcon;
    entity.categoryColor = domain.categoryColor;
    entity.amountLimit = domain.amountLimit;
    entity.period = domain.period.toDbString();
    entity.startDate = domain.startDate;
    entity.endDate = domain.endDate;
    entity.alertThreshold = domain.alertThreshold;
    entity.isArchived = domain.isArchived;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    final entities =
        await isar.budgetEntitys.where().sortByCreatedAtDesc().findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Budget>> watchAllBudgets() {
    return isar.budgetEntitys
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    final entities =
        await isar.budgetEntitys
            .filter()
            .isArchivedEqualTo(false)
            .sortByCreatedAtDesc()
            .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Budget>> watchActiveBudgets() {
    return isar.budgetEntitys
        .filter()
        .isArchivedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final entity =
        await isar.budgetEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    budget.validate();
    await isar.writeTxn(() async {
      final existing =
          await isar.budgetEntitys.filter().uuidEqualTo(budget.id).findFirst();
      final entity = _toEntity(budget, existing);
      await isar.budgetEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteBudget(String id) async {
    await isar.writeTxn(() async {
      await isar.budgetEntitys.filter().uuidEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> archiveBudget(String id, bool isArchived) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.budgetEntitys.filter().uuidEqualTo(id).findFirst();
      if (existing != null) {
        existing.isArchived = isArchived;
        existing.updatedAt = DateTime.now();
        await isar.budgetEntitys.put(existing);
      }
    });
  }
}
