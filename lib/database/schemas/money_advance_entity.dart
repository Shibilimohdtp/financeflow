import 'package:isar/isar.dart';

part 'money_advance_entity.g.dart';

@collection
class MoneyAdvanceEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moneyRecordId;

  @Index()
  late String userId;

  late double amount;

  @Index()
  late DateTime date;

  @Index()
  late DateTime dueDate;

  String? notes;

  String? accountId;

  @Index()
  String? transactionId;

  late DateTime createdAt;

  late DateTime updatedAt;
}
