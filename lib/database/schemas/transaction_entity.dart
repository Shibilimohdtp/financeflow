import 'package:isar/isar.dart';

part 'transaction_entity.g.dart';

@collection
class TransactionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late double amount;

  @Index()
  late String type; // expense, income, transfer, investment, loan_emi, cash

  @Index()
  late String categoryId;

  late String categoryName;

  late String categoryIcon;

  late String categoryColor;

  @Index(type: IndexType.value, caseSensitive: false)
  late String merchant;

  @Index()
  late DateTime date;

  String? notes;

  @Index()
  late String source; // manual, notification, sms, email, csv, other

  String? paymentMethod; // UPI, Card, Cash, NetBanking, etc.

  @Index()
  late String accountId;

  String? toAccountId; // For transfer transactions

  @Index()
  String? purpose;

  @Index()
  String? direction;

  @Index(type: IndexType.value, caseSensitive: false)
  String? externalCounterpartyName;

  @Index()
  String? linkedLoanId;

  @Index()
  String? linkedMoneyRecordId;

  @Index()
  String? linkedInvestmentId;

  @Index()
  String? linkedSubscriptionId;

  double? principalComponent;

  double? interestComponent;

  double? feeComponent;

  List<String> tags = [];

  bool isReviewed = true;

  late DateTime createdAt;

  late DateTime updatedAt;

  // Phase 3 Ingestion & Provenance Fields
  String? originalMerchant;

  @Index(type: IndexType.value, caseSensitive: false)
  String? normalizedMerchant;

  String? sourceName;

  @Index()
  String? sourceReference;

  String? sourceMessageId;

  @Index()
  String? fingerprint;

  String? duplicateGroupId;

  List<String> mergedSources = [];

  @Index()
  DateTime? importedAt;

  @Index()
  DateTime? detectedAt;

  @Index()
  String reviewStatus = 'confirmed'; // confirmed, needs_review, merged, excluded

  double? categorizationConfidence;
}
