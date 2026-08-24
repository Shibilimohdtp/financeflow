import 'package:isar/isar.dart';

part 'emi_payment_entity.g.dart';

@collection
class EmiPaymentEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String loanId;

  @Index()
  late int installmentNumber;

  @Index()
  late DateTime dueDate;

  @Index()
  late DateTime paymentDate;

  late double principalPaid;

  late double interestPaid;

  late double emiAmount;

  String? accountId;

  @Index()
  String? transactionId;

  bool isHistoricalStatusOnly = false;

  String? notes;

  late DateTime createdAt;

  late DateTime updatedAt;
}
