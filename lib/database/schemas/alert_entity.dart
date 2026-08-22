import 'package:isar/isar.dart';

part 'alert_entity.g.dart';

@collection
class AlertEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String type; // budget_approaching_limit, budget_exceeded, upcoming_subscription_renewal, upcoming_emi, large_expense, unusual_spending, savings_goal_reminder, income_received, needs_review_count, backup_reminder

  late String title;

  late String message;

  @Index()
  String severity = 'informational'; // informational, attention, urgent

  String?
  relatedEntityType; // budget, subscription, loan, savings_goal, transaction, backup, pending_review

  String? relatedEntityId;

  @Index()
  late DateTime scheduledAt;

  late DateTime createdAt;

  @Index()
  bool isRead = false;

  @Index()
  bool isDismissed = false;

  int? localNotificationId;
}
