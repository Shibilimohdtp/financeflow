import 'package:isar/isar.dart';

part 'money_record_entity.g.dart';

@collection
class MoneyRecordEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String type; // lent, borrowed

  @Index()
  late String personName;

  late double originalAmount;

  @Index()
  late DateTime transactionDate;

  @Index()
  late DateTime dueDate;

  String? notes;

  bool isReminderEnabled = true;

  int reminderDaysBefore = 1;

  late DateTime createdAt;

  late DateTime updatedAt;

  @Index()
  DateTime? settledAt;

  @Index()
  String status = 'active';
}
