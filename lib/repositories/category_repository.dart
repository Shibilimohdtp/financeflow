import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/default_categories.dart';
import '../database/isar_service.dart';
import '../database/schemas/category_entity.dart';
import '../models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return IsarCategoryRepository();
});

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories({bool includeArchived = false});
  Stream<List<Category>> watchAllCategories({bool includeArchived = false});
  Future<List<Category>> getCategoriesByType(String type);
  Future<Category?> getCategoryById(String id);
  Future<void> saveCategory(Category category);
  Future<void> archiveCategory(String id, bool isArchived);
  Future<void> ensureDefaultCategoriesSeeded();
}

class IsarCategoryRepository implements CategoryRepository {
  final Isar isar;

  IsarCategoryRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Category _toDomain(CategoryEntity entity) {
    return Category(
      id: entity.uuid,
      name: entity.name,
      iconIdentifier: entity.iconIdentifier,
      colorTokenIdentifier: entity.colorTokenIdentifier,
      typeCompatibility: List<String>.from(entity.typeCompatibility),
      isDefault: entity.isDefault,
      isArchived: entity.isArchived,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryEntity _toEntity(Category domain, [CategoryEntity? existing]) {
    final entity = existing ?? CategoryEntity();
    entity.uuid = domain.id;
    entity.name = domain.name;
    entity.iconIdentifier = domain.iconIdentifier;
    entity.colorTokenIdentifier = domain.colorTokenIdentifier;
    entity.typeCompatibility = domain.typeCompatibility;
    entity.isDefault = domain.isDefault;
    entity.isArchived = domain.isArchived;
    entity.sortOrder = domain.sortOrder;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  @override
  Future<List<Category>> getAllCategories({
    bool includeArchived = false,
  }) async {
    final query =
        includeArchived
            ? isar.categoryEntitys.where().sortBySortOrder()
            : isar.categoryEntitys
                .filter()
                .isArchivedEqualTo(false)
                .sortBySortOrder();

    final entities = await query.findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Category>> watchAllCategories({bool includeArchived = false}) {
    final query =
        includeArchived
            ? isar.categoryEntitys.where().sortBySortOrder()
            : isar.categoryEntitys
                .filter()
                .isArchivedEqualTo(false)
                .sortBySortOrder();

    return query
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<List<Category>> getCategoriesByType(String type) async {
    final entities =
        await isar.categoryEntitys
            .filter()
            .isArchivedEqualTo(false)
            .typeCompatibilityElementEqualTo(type.toLowerCase())
            .sortBySortOrder()
            .findAll();

    return entities.map(_toDomain).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final entity =
        await isar.categoryEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveCategory(Category category) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.categoryEntitys
              .filter()
              .uuidEqualTo(category.id)
              .findFirst();
      final entity = _toEntity(category, existing);
      await isar.categoryEntitys.put(entity);
    });
  }

  @override
  Future<void> archiveCategory(String id, bool isArchived) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.categoryEntitys.filter().uuidEqualTo(id).findFirst();
      if (existing != null) {
        existing.isArchived = isArchived;
        existing.updatedAt = DateTime.now();
        await isar.categoryEntitys.put(existing);
      }
    });
  }

  @override
  Future<void> ensureDefaultCategoriesSeeded() async {
    final count = await isar.categoryEntitys.count();
    if (count == 0) {
      await isar.writeTxn(() async {
        await isar.categoryEntitys.putAll(DefaultCategories.list);
      });
    } else {
      final existingTransaction =
          await isar.categoryEntitys
              .where()
              .uuidEqualTo('cat_transaction')
              .findFirst();
      if (existingTransaction == null) {
        final transactionCat = DefaultCategories.list.firstWhere(
          (c) => c.uuid == 'cat_transaction',
        );
        await isar.writeTxn(() async {
          await isar.categoryEntitys.put(transactionCat);
        });
      }
    }
  }
}
