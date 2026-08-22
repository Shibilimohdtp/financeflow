import 'package:isar/isar.dart';

part 'budget_entity.g.dart';

@collection
class BudgetEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;

  @Index()
  late String categoryId;

  String? categoryName;

  String? categoryIcon;

  String? categoryColor;

  late double amountLimit;

  @Index()
  late String period; // weekly, monthly, yearly, custom

  @Index()
  late DateTime startDate;

  DateTime? endDate;

  late double alertThreshold; // 0.0 to 1.0 (e.g. 0.8 = 80%)

  @Index()
  late bool isArchived;

  late DateTime createdAt;

  late DateTime updatedAt;
}
