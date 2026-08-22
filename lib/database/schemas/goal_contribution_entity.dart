import 'package:isar/isar.dart';

part 'goal_contribution_entity.g.dart';

@collection
class GoalContributionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String goalId;

  late double amount;

  @Index()
  late DateTime date;

  String? accountId;

  String? notes;

  late DateTime createdAt;
}
