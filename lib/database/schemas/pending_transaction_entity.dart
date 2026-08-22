import 'package:isar/isar.dart';

part 'pending_transaction_entity.g.dart';

@collection
class PendingTransactionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String tempId;

  @Index()
  late String source; // csv, notification, sms, email, manual, other

  String? sourceName;
  String? rawSource;
  String? sourceIdentifier;

  late double amount;

  @Index()
  late String type; // expense, income, transfer, investment, loan_emi, cash

  late String rawMerchant;

  @Index(type: IndexType.value, caseSensitive: false)
  late String normalizedMerchant;

  @Index()
  late DateTime date;

  DateTime? time;
  String? notes;

  @Index()
  late String accountId;

  String? toAccountId;
  String? paymentMethod;

  @Index()
  late String categoryId;

  late String categoryName;
  late String categoryIcon;
  late String categoryColor;

  double categorizationConfidence = 0.5;
  String? categorizationReason;

  @Index()
  String? referenceNumber;

  @Index()
  late String fingerprint;

  List<String> warnings = [];
  List<String> validationErrors = [];

  @Index()
  late String duplicateStatus; // none, possible, likely, exact

  String? matchedTransactionId;
  List<String> duplicateReasons = [];
  double duplicateConfidence = 0.0;
  String duplicateResolution =
      'unresolved'; // unresolved, merge, keepBoth, ignore, exclude

  bool isIncluded = true;

  @Index()
  String reviewStatus = 'pending'; // pending, confirmed, merged, excluded, resolved

  @Index()
  late DateTime importedAt;

  @Index()
  late DateTime detectedAt;
}
