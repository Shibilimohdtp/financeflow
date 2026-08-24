import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/investment_entity.dart';
import '../models/investment.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> getAllInvestments();
  Stream<List<Investment>> watchAllInvestments();
  Future<Investment?> getInvestmentById(String id);
  Future<void> saveInvestment(Investment investment);
  Future<void> deleteInvestment(String id);
  Future<void> updateValuation(String id, double newCurrentValue);
}

class IsarInvestmentRepository implements InvestmentRepository {
  final Isar isar;

  IsarInvestmentRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  Investment _toDomain(InvestmentEntity entity) {
    return Investment(
      id: entity.uuid,
      name: entity.name,
      assetType: AssetType.fromString(entity.assetType),
      accountId: entity.accountId,
      quantityOrUnits: entity.quantityOrUnits,
      purchasePrice: entity.purchasePrice,
      purchaseDate: entity.purchaseDate,
      currentValue: entity.currentValue,
      investedAmount: entity.investedAmount,
      realizedProfitLoss: entity.realizedProfitLoss,
      unrealizedProfitLoss: entity.unrealizedProfitLoss,
      lastValuationDate: entity.lastValuationDate,
      notes: entity.notes,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      ledgerBaselineInvestedAmount: entity.ledgerBaselineInvestedAmount,
      ledgerBaselineCurrentValue: entity.ledgerBaselineCurrentValue,
      ledgerBaselineRealizedProfitLoss: entity.ledgerBaselineRealizedProfitLoss,
    );
  }

  InvestmentEntity _toEntity(Investment domain) {
    final entity =
        InvestmentEntity()
          ..uuid = domain.id
          ..name = domain.name
          ..assetType = domain.assetType.toDbString()
          ..accountId = domain.accountId
          ..quantityOrUnits = domain.quantityOrUnits
          ..purchasePrice = domain.purchasePrice
          ..purchaseDate = domain.purchaseDate
          ..currentValue = domain.currentValue
          ..investedAmount = domain.investedAmount
          ..realizedProfitLoss = domain.realizedProfitLoss
          ..unrealizedProfitLoss = domain.unrealizedProfitLoss
          ..lastValuationDate = domain.lastValuationDate
          ..notes = domain.notes
          ..isArchived = domain.isArchived
          ..createdAt = domain.createdAt
          ..updatedAt = domain.updatedAt;
    entity.ledgerBaselineInvestedAmount = domain.ledgerBaselineInvestedAmount;
    entity.ledgerBaselineCurrentValue = domain.ledgerBaselineCurrentValue;
    entity.ledgerBaselineRealizedProfitLoss =
        domain.ledgerBaselineRealizedProfitLoss;
    return entity;
  }

  Investment domainFromEntity(InvestmentEntity entity) => _toDomain(entity);

  InvestmentEntity entityFromDomain(
    Investment domain, [
    InvestmentEntity? existing,
  ]) {
    final entity = _toEntity(domain);
    if (existing != null) entity.id = existing.id;
    return entity;
  }

  @override
  Future<List<Investment>> getAllInvestments() async {
    final entities =
        await isar.investmentEntitys
            .where()
            .filter()
            .isArchivedEqualTo(false)
            .sortByPurchaseDateDesc()
            .findAll();
    return entities.map(_toDomain).toList();
  }

  @override
  Stream<List<Investment>> watchAllInvestments() {
    return isar.investmentEntitys
        .where()
        .filter()
        .isArchivedEqualTo(false)
        .sortByPurchaseDateDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map(_toDomain).toList());
  }

  @override
  Future<Investment?> getInvestmentById(String id) async {
    final entity =
        await isar.investmentEntitys.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> saveInvestment(Investment investment) async {
    await isar.writeTxn(() async {
      final existing =
          await isar.investmentEntitys
              .filter()
              .uuidEqualTo(investment.id)
              .findFirst();
      final entity = _toEntity(investment);
      if (existing != null) {
        entity.id = existing.id;
      }
      await isar.investmentEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteInvestment(String id) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.investmentEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        await isar.investmentEntitys.delete(entity.id);
      }
    });
  }

  @override
  Future<void> updateValuation(String id, double newCurrentValue) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.investmentEntitys.filter().uuidEqualTo(id).findFirst();
      if (entity != null) {
        entity.currentValue = newCurrentValue;
        entity.unrealizedProfitLoss = newCurrentValue - entity.investedAmount;
        entity.lastValuationDate = DateTime.now();
        entity.updatedAt = DateTime.now();
        await isar.investmentEntitys.put(entity);
      }
    });
  }
}

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return IsarInvestmentRepository();
});

final allInvestmentsStreamProvider = StreamProvider<List<Investment>>((ref) {
  try {
    final repo = ref.watch(investmentRepositoryProvider);
    return repo.watchAllInvestments();
  } catch (_) {
    return Stream.value(const []);
  }
});
