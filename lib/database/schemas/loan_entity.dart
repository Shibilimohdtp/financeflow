import 'package:isar/isar.dart';

part 'loan_entity.g.dart';

@collection
class LoanEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String name;

  @Index()
  late String lender;

  @Index()
  late String loanType; // home_loan, personal_loan, education_loan, vehicle_loan, credit_card_emi, bnpl, other

  String? accountId;

  late double principalAmount;

  late double interestRate; // Annual percentage (e.g. 8.5)

  String interestType = 'reducing_balance'; // reducing_balance, flat_rate

  late int tenureMonths;

  @Index()
  late DateTime startDate;

  late DateTime expectedEndDate;

  late double emiAmount;

  int paymentDay = 5;

  double totalPrincipalPaid = 0.0;

  double totalInterestPaid = 0.0;

  late double outstandingPrincipal;

  @Index()
  late DateTime nextDueDate;

  @Index()
  String status = 'active'; // active, paid_off, paused, archived

  String? notes;

  late DateTime createdAt;

  late DateTime updatedAt;
}
