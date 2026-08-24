import 'package:isar/isar.dart';

part 'investment_entity.g.dart';

@collection
class InvestmentEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String name;

  @Index()
  late String assetType; // stocks, mutual_funds, fixed_deposits, recurring_deposits, ppf, nps, gold, crypto, real_estate, other

  String? accountId;

  double quantityOrUnits = 1.0;

  late double purchasePrice;

  @Index()
  late DateTime purchaseDate;

  late double currentValue; // User-entered value

  late double investedAmount;

  double? realizedProfitLoss;

  double unrealizedProfitLoss = 0.0;

  DateTime? lastValuationDate;

  String? notes;

  @Index()
  bool isArchived = false;

  late DateTime createdAt;

  late DateTime updatedAt;

  double? ledgerBaselineInvestedAmount;

  double? ledgerBaselineCurrentValue;

  double? ledgerBaselineRealizedProfitLoss;
}
