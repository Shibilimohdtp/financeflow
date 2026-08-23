import 'package:isar/isar.dart';

part 'money_repayment_entity.g.dart';

@collection
class MoneyRepaymentEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moneyRecordId;

  @Index()
  late String userId;

  late double amount;

  @Index()
  late DateTime repaymentDate;

  String? notes;

  late DateTime createdAt;
}
