import 'package:uuid/uuid.dart';
import '../transaction.dart';
import '../../services/ingestion/duplicate_matcher.dart';
import '../../services/merchant_normalization_service.dart';

const _unset = Object();

enum DuplicateMatchLevel {
  none,
  possible,
  likely,
  exact;

  String get displayName {
    switch (this) {
      case DuplicateMatchLevel.none:
        return 'New';
      case DuplicateMatchLevel.possible:
        return 'Possible Duplicate';
      case DuplicateMatchLevel.likely:
        return 'Likely Duplicate';
      case DuplicateMatchLevel.exact:
        return 'Exact Duplicate';
    }
  }

  bool get isDuplicate => this != DuplicateMatchLevel.none;
}

enum DuplicateResolution {
  unresolved,
  merge,
  keepBoth,
  ignore,
  exclude;

  String get displayName {
    switch (this) {
      case DuplicateResolution.unresolved:
        return 'Needs Resolution';
      case DuplicateResolution.merge:
        return 'Merge with Existing';
      case DuplicateResolution.keepBoth:
        return 'Keep Both';
      case DuplicateResolution.ignore:
        return 'Ignore / Dismiss';
      case DuplicateResolution.exclude:
        return 'Exclude';
    }
  }
}

enum ReviewStatus {
  pending,
  confirmed,
  merged,
  excluded,
  resolved;

  String get displayName {
    switch (this) {
      case ReviewStatus.pending:
        return 'Needs Review';
      case ReviewStatus.confirmed:
        return 'Confirmed';
      case ReviewStatus.merged:
        return 'Merged';
      case ReviewStatus.excluded:
        return 'Excluded';
      case ReviewStatus.resolved:
        return 'Resolved';
    }
  }
}

class ParsedTransaction {
  final TransactionPurpose? purpose;
  final AccountMovementDirection? direction;
  final String? merchantDisplayName;
  final String? externalCounterpartyName;
  final String? linkedLoanId;
  final String? linkedMoneyRecordId;
  final String? linkedInvestmentId;
  final double? principalComponent;
  final double? interestComponent;
  final double? feeComponent;
  final List<String> tags;
  final String tempId;
  final TransactionSource source;
  final String? sourceName;
  final String? rawSource;
  final String? sourceIdentifier; // Message ID, CSV row number, etc.
  final double amount;
  final TransactionType type;
  final String rawMerchant;
  final String normalizedMerchant;
  final DateTime date;
  final DateTime? time;
  final String? notes;
  final String accountId;
  final String? toAccountId;
  final String? paymentMethod;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double categorizationConfidence;
  final String? categorizationReason;
  final String? referenceNumber;
  final String fingerprint;
  final List<String> warnings;
  final List<String> validationErrors;
  final DuplicateMatchLevel duplicateStatus;
  final String? matchedTransactionId;
  final Transaction? matchedTransaction;
  final List<String> duplicateReasons;
  final double duplicateConfidence;
  final DuplicateResolution duplicateResolution;
  final bool isIncluded;
  final ReviewStatus reviewStatus;
  final DateTime importedAt;
  final DateTime detectedAt;

  ParsedTransaction({
    this.purpose,
    this.direction,
    this.merchantDisplayName,
    this.externalCounterpartyName,
    this.linkedLoanId,
    this.linkedMoneyRecordId,
    this.linkedInvestmentId,
    this.principalComponent,
    this.interestComponent,
    this.feeComponent,
    this.tags = const [],
    String? tempId,
    this.source = TransactionSource.csv,
    this.sourceName,
    this.rawSource,
    this.sourceIdentifier,
    required this.amount,
    required this.type,
    required this.rawMerchant,
    required this.normalizedMerchant,
    required this.date,
    this.time,
    this.notes,
    required this.accountId,
    this.toAccountId,
    this.paymentMethod,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.categorizationConfidence = 0.5,
    this.categorizationReason,
    this.referenceNumber,
    required this.fingerprint,
    this.warnings = const [],
    this.validationErrors = const [],
    this.duplicateStatus = DuplicateMatchLevel.none,
    this.matchedTransactionId,
    this.matchedTransaction,
    this.duplicateReasons = const [],
    this.duplicateConfidence = 0.0,
    this.duplicateResolution = DuplicateResolution.unresolved,
    this.isIncluded = true,
    this.reviewStatus = ReviewStatus.pending,
    DateTime? importedAt,
    DateTime? detectedAt,
  }) : tempId = tempId ?? const Uuid().v4(),
       importedAt = importedAt ?? DateTime.now(),
       detectedAt = detectedAt ?? DateTime.now();

  bool get isValid =>
      validationErrors.isEmpty && amount > 0 && normalizedMerchant.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isDuplicate => duplicateStatus.isDuplicate;
  bool get needsReview =>
      !isValid ||
      hasWarnings ||
      isDuplicate ||
      categorizationConfidence < 0.7 ||
      reviewStatus == ReviewStatus.pending;

  ParsedTransaction copyWith({
    Object? purpose = _unset,
    Object? direction = _unset,
    Object? merchantDisplayName = _unset,
    Object? externalCounterpartyName = _unset,
    Object? linkedLoanId = _unset,
    Object? linkedMoneyRecordId = _unset,
    Object? linkedInvestmentId = _unset,
    Object? principalComponent = _unset,
    Object? interestComponent = _unset,
    Object? feeComponent = _unset,
    List<String>? tags,
    String? tempId,
    TransactionSource? source,
    String? sourceName,
    String? rawSource,
    String? sourceIdentifier,
    double? amount,
    TransactionType? type,
    String? rawMerchant,
    String? normalizedMerchant,
    DateTime? date,
    DateTime? time,
    Object? notes = _unset,
    String? accountId,
    Object? toAccountId = _unset,
    String? paymentMethod,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? categorizationConfidence,
    String? categorizationReason,
    String? referenceNumber,
    String? fingerprint,
    List<String>? warnings,
    List<String>? validationErrors,
    DuplicateMatchLevel? duplicateStatus,
    Object? matchedTransactionId = _unset,
    Object? matchedTransaction = _unset,
    List<String>? duplicateReasons,
    double? duplicateConfidence,
    DuplicateResolution? duplicateResolution,
    bool? isIncluded,
    ReviewStatus? reviewStatus,
    DateTime? importedAt,
    DateTime? detectedAt,
  }) {
    return ParsedTransaction(
      purpose:
          identical(purpose, _unset)
              ? this.purpose
              : purpose as TransactionPurpose?,
      direction:
          identical(direction, _unset)
              ? this.direction
              : direction as AccountMovementDirection?,
      merchantDisplayName:
          identical(merchantDisplayName, _unset)
              ? this.merchantDisplayName
              : merchantDisplayName as String?,
      externalCounterpartyName:
          identical(externalCounterpartyName, _unset)
              ? this.externalCounterpartyName
              : externalCounterpartyName as String?,
      linkedLoanId:
          identical(linkedLoanId, _unset)
              ? this.linkedLoanId
              : linkedLoanId as String?,
      linkedMoneyRecordId:
          identical(linkedMoneyRecordId, _unset)
              ? this.linkedMoneyRecordId
              : linkedMoneyRecordId as String?,
      linkedInvestmentId:
          identical(linkedInvestmentId, _unset)
              ? this.linkedInvestmentId
              : linkedInvestmentId as String?,
      principalComponent:
          identical(principalComponent, _unset)
              ? this.principalComponent
              : principalComponent as double?,
      interestComponent:
          identical(interestComponent, _unset)
              ? this.interestComponent
              : interestComponent as double?,
      feeComponent:
          identical(feeComponent, _unset)
              ? this.feeComponent
              : feeComponent as double?,
      tags: tags ?? this.tags,
      tempId: tempId ?? this.tempId,
      source: source ?? this.source,
      sourceName: sourceName ?? this.sourceName,
      rawSource: rawSource ?? this.rawSource,
      sourceIdentifier: sourceIdentifier ?? this.sourceIdentifier,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      rawMerchant: rawMerchant ?? this.rawMerchant,
      normalizedMerchant: normalizedMerchant ?? this.normalizedMerchant,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      accountId: accountId ?? this.accountId,
      toAccountId:
          identical(toAccountId, _unset)
              ? this.toAccountId
              : toAccountId as String?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      categorizationConfidence:
          categorizationConfidence ?? this.categorizationConfidence,
      categorizationReason: categorizationReason ?? this.categorizationReason,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      fingerprint: fingerprint ?? this.fingerprint,
      warnings: warnings ?? this.warnings,
      validationErrors: validationErrors ?? this.validationErrors,
      duplicateStatus: duplicateStatus ?? this.duplicateStatus,
      matchedTransactionId:
          identical(matchedTransactionId, _unset)
              ? this.matchedTransactionId
              : matchedTransactionId as String?,
      matchedTransaction:
          identical(matchedTransaction, _unset)
              ? this.matchedTransaction
              : matchedTransaction as Transaction?,
      duplicateReasons: duplicateReasons ?? this.duplicateReasons,
      duplicateConfidence: duplicateConfidence ?? this.duplicateConfidence,
      duplicateResolution: duplicateResolution ?? this.duplicateResolution,
      isIncluded: isIncluded ?? this.isIncluded,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      importedAt: importedAt ?? this.importedAt,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  /// Apply only editable values; source evidence and duplicate resolution stay intact.
  ParsedTransaction withReviewEdit(Transaction edited) {
    edited.validate();
    final normalized = MerchantNormalizationService.normalize(edited.merchant);
    return copyWith(
      amount: edited.amount,
      type: edited.type,
      normalizedMerchant: normalized,
      merchantDisplayName: edited.merchant.trim(),
      date: edited.date,
      time: edited.date,
      notes: edited.notes,
      accountId: edited.accountId,
      toAccountId: edited.toAccountId,
      paymentMethod: edited.paymentMethod,
      categoryId: edited.categoryId,
      categoryName: edited.categoryName,
      categoryIcon: edited.categoryIcon,
      categoryColor: edited.categoryColor,
      purpose: edited.purpose,
      direction: edited.direction,
      externalCounterpartyName: edited.externalCounterpartyName,
      linkedLoanId: edited.linkedLoanId,
      linkedMoneyRecordId: edited.linkedMoneyRecordId,
      linkedInvestmentId: edited.linkedInvestmentId,
      principalComponent: edited.principalComponent,
      interestComponent: edited.interestComponent,
      feeComponent: edited.feeComponent,
      tags: edited.tags,
      categorizationConfidence: 1,
      categorizationReason: 'User reviewed category',
      fingerprint: DuplicateMatcher.generateFingerprint(
        amount: edited.amount,
        date: edited.date,
        normalizedMerchant: normalized,
        type: edited.type,
        referenceNumber: referenceNumber,
        accountId: edited.accountId,
      ),
      warnings:
          warnings
              .where(
                (warning) =>
                    !warning.startsWith('Could not clearly identify payee') ||
                    normalized == 'Bank Transaction',
              )
              .toList(),
      // The shared form validates these editable fields. Retain unrelated
      // import errors and all original source evidence.
      validationErrors:
          validationErrors
              .where(
                (error) =>
                    error != 'Could not extract positive transaction amount' &&
                    !RegExp(
                      r'^Row \d+: (?:Non-positive or unreadable amount|Missing payee or description|Invalid or missing date)',
                    ).hasMatch(error),
              )
              .toList(),
      reviewStatus: ReviewStatus.pending,
    );
  }

  /// Converts the parsed transaction into a fully valid committed Transaction
  Transaction toTransaction({String? targetId}) {
    final now = DateTime.now();
    return Transaction(
      purpose: purpose,
      direction: direction,
      externalCounterpartyName: externalCounterpartyName,
      linkedLoanId: linkedLoanId,
      linkedMoneyRecordId: linkedMoneyRecordId,
      linkedInvestmentId: linkedInvestmentId,
      principalComponent: principalComponent,
      interestComponent: interestComponent,
      feeComponent: feeComponent,
      id: targetId ?? const Uuid().v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      merchant:
          merchantDisplayName ??
          (normalizedMerchant.isNotEmpty ? normalizedMerchant : rawMerchant),
      date: date,
      notes: notes,
      source: source,
      paymentMethod: paymentMethod,
      accountId: accountId,
      toAccountId: toAccountId,
      tags: tags,
      isReviewed: true,
      createdAt: now,
      updatedAt: now,
      originalMerchant: rawMerchant,
      normalizedMerchant: normalizedMerchant,
      sourceName: sourceName,
      sourceReference: referenceNumber,
      sourceMessageId: sourceIdentifier,
      fingerprint: fingerprint,
      duplicateGroupId: matchedTransactionId,
      mergedSources: [
        if (sourceName != null && sourceName!.isNotEmpty)
          '${source.displayName}: $sourceName'
        else
          source.displayName,
      ],
      importedAt: importedAt,
      detectedAt: detectedAt,
      reviewStatus: 'confirmed',
      categorizationConfidence: categorizationConfidence,
    );
  }

  /// Creates a ParsedTransaction from an existing Transaction (for review editing)
  static ParsedTransaction fromTransaction(Transaction tx) {
    return ParsedTransaction(
      purpose: tx.purpose,
      direction: tx.direction,
      merchantDisplayName: tx.merchant,
      externalCounterpartyName: tx.externalCounterpartyName,
      linkedLoanId: tx.linkedLoanId,
      linkedMoneyRecordId: tx.linkedMoneyRecordId,
      linkedInvestmentId: tx.linkedInvestmentId,
      principalComponent: tx.principalComponent,
      interestComponent: tx.interestComponent,
      feeComponent: tx.feeComponent,
      tags: tx.tags,
      tempId: tx.id,
      source: tx.source,
      sourceName: tx.sourceName,
      rawSource: null,
      sourceIdentifier: tx.sourceMessageId,
      amount: tx.amount,
      type: tx.type,
      rawMerchant: tx.originalMerchant ?? tx.merchant,
      normalizedMerchant: tx.normalizedMerchant ?? tx.merchant,
      date: tx.date,
      time: tx.date,
      notes: tx.notes,
      accountId: tx.accountId,
      toAccountId: tx.toAccountId,
      paymentMethod: tx.paymentMethod,
      categoryId: tx.categoryId,
      categoryName: tx.categoryName,
      categoryIcon: tx.categoryIcon,
      categoryColor: tx.categoryColor,
      categorizationConfidence: tx.categorizationConfidence ?? 1.0,
      categorizationReason: 'Saved transaction',
      referenceNumber: tx.sourceReference,
      fingerprint: tx.fingerprint ?? '',
      warnings: const [],
      validationErrors: const [],
      duplicateStatus: DuplicateMatchLevel.none,
      isIncluded: true,
      reviewStatus: ReviewStatus.confirmed,
      importedAt: tx.importedAt ?? tx.createdAt,
      detectedAt: tx.detectedAt ?? tx.createdAt,
    );
  }
}

class ImportReviewSession {
  final String sessionId;
  final String sourceName;
  final TransactionSource source;
  final List<ParsedTransaction> items;
  final DateTime createdAt;

  ImportReviewSession({
    String? sessionId,
    required this.sourceName,
    this.source = TransactionSource.csv,
    required this.items,
    DateTime? createdAt,
  }) : sessionId = sessionId ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  int get totalCount => items.length;
  int get includedCount => items.where((i) => i.isIncluded).length;
  int get validCount => items.where((i) => i.isIncluded && i.isValid).length;
  int get invalidCount => items.where((i) => i.isIncluded && !i.isValid).length;
  int get duplicateCount =>
      items.where((i) => i.isIncluded && i.isDuplicate).length;
  int get newCount =>
      items.where((i) => i.isIncluded && !i.isDuplicate && i.isValid).length;
  int get needsReviewCount =>
      items.where((i) => i.isIncluded && i.needsReview).length;
  int get excludedCount => items.where((i) => !i.isIncluded).length;

  ImportReviewSession copyWith({
    String? sessionId,
    String? sourceName,
    TransactionSource? source,
    List<ParsedTransaction>? items,
    DateTime? createdAt,
  }) {
    return ImportReviewSession(
      sessionId: sessionId ?? this.sessionId,
      sourceName: sourceName ?? this.sourceName,
      source: source ?? this.source,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
