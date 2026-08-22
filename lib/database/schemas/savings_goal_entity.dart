import 'package:isar/isar.dart';

part 'savings_goal_entity.g.dart';

@collection
class SavingsGoalEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;

  late double targetAmount;

  @Index()
  late DateTime targetDate;

  String? linkedAccountId;

  String? notes;

  @Index()
  late bool isCompleted;

  late DateTime createdAt;

  late DateTime updatedAt;
}
