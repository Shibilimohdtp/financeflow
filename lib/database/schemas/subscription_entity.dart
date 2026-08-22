import 'package:isar/isar.dart';

part 'subscription_entity.g.dart';

@collection
class SubscriptionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String merchant;

  @Index()
  late String normalizedMerchant;

  late double amount;

  String currency = 'INR';

  late String billingFrequency; // weekly, monthly, quarterly, yearly, custom

  @Index()
  late DateTime nextRenewalDate;

  DateTime? lastPaymentDate;

  String? accountId;

  String category = 'Subscriptions';

  String? paymentMethod;

  String? sourceTransactionId;

  @Index()
  String status = 'active'; // active, paused, cancelled, needs_review

  int reminderDaysBefore = 1;

  bool isReminderEnabled = true;

  String? notes;

  late DateTime createdAt;

  late DateTime updatedAt;
}
