import 'package:uuid/uuid.dart';
import '../transaction.dart';

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
    String? notes,
    String? accountId,
    String? toAccountId,
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
    String? matchedTransactionId,
    Transaction? matchedTransaction,
    List<String>? duplicateReasons,
    double? duplicateConfidence,
    DuplicateResolution? duplicateResolution,
    bool? isIncluded,
    ReviewStatus? reviewStatus,
    DateTime? importedAt,
    DateTime? detectedAt,
  }) {
    return ParsedTransaction(
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
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
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
      matchedTransactionId: matchedTransactionId ?? this.matchedTransactionId,
      matchedTransaction: matchedTransaction ?? this.matchedTransaction,
      duplicateReasons: duplicateReasons ?? this.duplicateReasons,
      duplicateConfidence: duplicateConfidence ?? this.duplicateConfidence,
      duplicateResolution: duplicateResolution ?? this.duplicateResolution,
      isIncluded: isIncluded ?? this.isIncluded,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      importedAt: importedAt ?? this.importedAt,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  /// Converts the parsed transaction into a fully valid committed Transaction
  Transaction toTransaction({String? targetId}) {
    final now = DateTime.now();
    return Transaction(
      id: targetId ?? const Uuid().v4(),
      amount: amount,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      merchant:
          normalizedMerchant.isNotEmpty ? normalizedMerchant : rawMerchant,
      date: date,
      notes: notes,
      source: source,
      paymentMethod: paymentMethod,
      accountId: accountId,
      toAccountId: toAccountId,
      tags: const [],
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
