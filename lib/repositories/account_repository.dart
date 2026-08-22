import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/account_entity.dart';
import '../models/account.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return IsarAccountRepository();
});

final allAccountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAllAccounts();
});

abstract class AccountRepository {
  Future<List<Account>> getAllAccounts({bool includeArchived = false});
  Stream<List<Account>> watchAllAccounts({bool includeArchived = false});
  Future<Account?> getAccountById(String id);
  Future<void> saveAccount(Account account);
  Future<void> archiveAccount(String id, bool isArchived);
  Future<void> deleteAccount(String id);
  Future<void> updateAccountBalance(String id, double newBalance);
}

class IsarAccountRepository implements AccountRepository {
  final Isar isar;

  IsarAccountRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Account _toDomain(AccountEntity entity) {
    return Account(
      id: entity.uuid,
      name: entity.name,
      type: AccountType.fromString(entity.type),
      institutionName: entity.institutionName,
      maskedIdentifier: entity.maskedIdentifier,
      openingBalance: entity.openingBalance,
      currentBalance: entity.currentBalance,
      currency: entity.currency,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AccountEntity _toEntity(Account domain, [AccountEntity? existing]) {
    final entity = existing ?? AccountEntity();
    entity.uuid = domain.id;
    entity.name = domain.name;
    entity.type = domain.type.toDbString();
    entity.institutionName = domain.institutionName;
    entity.maskedIdentifier = domain.maskedIdentifier;
    entity.openingBalance = domain.openingBalance;
    entity.currentBalance = domain.currentBalance;
    entity.currency = domain.currency;
    entity.isArchived = domain.isArchived;
    entity.createdAt = domain.createdAt;
    entity.updatedAt = domain.updatedAt;
    return entity;
  }

  @override
  Future<List<Account>> getAllAccounts({bool includeArchived = false}) async {
    final query =
        includeArchived
            ? isar.accountEntitys.where().sortByCreatedAtDesc()
            : isar.accountEntitys
                .filter()
                .isArchivedEqualTo(false)
                .sortByCreatedAtDesc();

    final entities = await query.findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Account>> watchAllAccounts({bool includeArchived = false}) {
    final query =
        includeArchived
            ? isar.accountEntitys.where().sortByCreatedAtDesc()
            : isar.accountEntitys
                .filter()
                .isArchivedEqualTo(false)
                .sortByCreatedAtDesc();

    return query
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final entity =
        await isar.accountEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveAccount(Account account) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.accountEntitys
              .filter()
              .uuidEqualTo(account.id)
              .findFirst();
      final entity = _toEntity(account, existing);
      await isar.accountEntitys.put(entity);
    });
  }

  @override
  Future<void> archiveAccount(String id, bool isArchived) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.accountEntitys.filter().uuidEqualTo(id).findFirst();
      if (existing != null) {
        existing.isArchived = isArchived;
        existing.updatedAt = DateTime.now();
        await isar.accountEntitys.put(existing);
      }
    });
  }

  @override
  Future<void> deleteAccount(String id) async {
    await isar.writeTxn(() async {
      await isar.accountEntitys.filter().uuidEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> updateAccountBalance(String id, double newBalance) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.accountEntitys.filter().uuidEqualTo(id).findFirst();
      if (existing != null) {
        existing.currentBalance = newBalance;
        existing.updatedAt = DateTime.now();
        await isar.accountEntitys.put(existing);
      }
    });
  }
}
