import 'package:isar/isar.dart';

part 'account_entity.g.dart';

@collection
class AccountEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String name;

  @Index()
  late String type; // bank, cash, credit_card, upi, investment, business

  String? institutionName; // e.g. HDFC, SBI, ICICI

  String? maskedIdentifier; // e.g. ••4321

  double openingBalance = 0.0;

  double currentBalance = 0.0;

  String currency = 'INR';

  @Index()
  bool isArchived = false;

  late DateTime createdAt;

  late DateTime updatedAt;
}
