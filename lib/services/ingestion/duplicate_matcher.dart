import '../merchant_normalization_service.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../core/formatting/currency_formatter.dart';

class DuplicateMatchResult {
  final DuplicateMatchLevel level;
  final double confidence; // 0.0 to 1.0
  final Transaction? matchedTransaction;
  final List<String> reasons;
  final DuplicateResolution recommendedAction;

  const DuplicateMatchResult({
    required this.level,
    required this.confidence,
    this.matchedTransaction,
    this.reasons = const [],
    this.recommendedAction = DuplicateResolution.unresolved,
  });

  static const none = DuplicateMatchResult(
    level: DuplicateMatchLevel.none,
    confidence: 0.0,
    matchedTransaction: null,
    reasons: [],
    recommendedAction: DuplicateResolution.unresolved,
  );
}

class DuplicateMatcher {
  DuplicateMatcher._();

  /// Stable deterministic fingerprint generator
  static String generateFingerprint({
    required double amount,
    required DateTime date,
    required String normalizedMerchant,
    required TransactionType type,
    String? referenceNumber,
    String? accountId,
  }) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final amtKey = amount.toStringAsFixed(2);
    final merchKey = normalizedMerchant.toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final refKey =
        referenceNumber != null && referenceNumber.trim().isNotEmpty
            ? referenceNumber.trim().toLowerCase()
            : 'noref';
    return '$dateKey|$amtKey|$merchKey|${type.toDbString()}|$refKey';
  }

  /// Match an incoming parsed transaction against a candidate pool of existing transactions
  static DuplicateMatchResult findDuplicate({
    required ParsedTransaction incoming,
    required List<Transaction> existingTransactions,
  }) {
    if (existingTransactions.isEmpty) {
      return DuplicateMatchResult.none;
    }

    DuplicateMatchResult bestMatch = DuplicateMatchResult.none;

    for (final existing in existingTransactions) {
      final match = evaluateMatch(incoming: incoming, existing: existing);
      if (match.confidence > bestMatch.confidence) {
        bestMatch = match;
        // If exact duplicate found, we can early exit
        if (bestMatch.level == DuplicateMatchLevel.exact) {
          break;
        }
      }
    }

    return bestMatch;
  }

  /// Evaluate duplicate match probability between an incoming item and an existing transaction
  static DuplicateMatchResult evaluateMatch({
    required ParsedTransaction incoming,
    required Transaction existing,
  }) {
    // Rule 1: Direction must match (expense vs income)
    if (incoming.type != existing.type) {
      return DuplicateMatchResult.none;
    }

    // Rule 2: Amount comparison (must match within one minor unit)
    final amtDiff = (incoming.amount - existing.amount).abs();
    if (amtDiff > 0.01) {
      return DuplicateMatchResult.none;
    }

    final reasons = <String>[];
    double confidence = 0.0;

    // Date difference
    final incomingDate = incoming.date;
    final existingDate = existing.date;
    final dateDiffDays =
        (incomingDate.difference(existingDate).inHours / 24.0).abs();
    final isSameCalendarDay =
        incomingDate.year == existingDate.year &&
        incomingDate.month == existingDate.month &&
        incomingDate.day == existingDate.day;

    // Reference number match
    final incRef = incoming.referenceNumber?.trim().toLowerCase();
    final exRef = existing.sourceReference?.trim().toLowerCase();
    final hasMatchingRef =
        incRef != null &&
        incRef.isNotEmpty &&
        exRef != null &&
        exRef.isNotEmpty &&
        incRef == exRef;

    // 1. Exact Reference Match
    if (hasMatchingRef) {
      reasons.add('Identical transaction reference number: $incRef');
      reasons.add(
        'Exact amount match (${CurrencyFormatter.formatAmount(incoming.amount)})',
      );
      return DuplicateMatchResult(
        level: DuplicateMatchLevel.exact,
        confidence: 1.0,
        matchedTransaction: existing,
        reasons: reasons,
        recommendedAction: DuplicateResolution.merge,
      );
    }

    // Merchant similarity evaluation
    final normIncMerch = incoming.normalizedMerchant.toLowerCase().trim();
    final normExMerch =
        (existing.normalizedMerchant ??
                MerchantNormalizationService.normalize(existing.merchant))
            .toLowerCase()
            .trim();
    final isExactMerchant = normIncMerch == normExMerch;
    final isSimilarMerchant =
        isExactMerchant ||
        normIncMerch.contains(normExMerch) ||
        normExMerch.contains(normIncMerch) ||
        _calculateMerchantSimilarity(normIncMerch, normExMerch) > 0.7;

    // 2. Exact Duplicate: Same calendar day + exact amount + identical normalized merchant
    if (isSameCalendarDay && isExactMerchant) {
      reasons.add(
        'Exact amount match (${CurrencyFormatter.formatAmount(incoming.amount)})',
      );
      reasons.add(
        'Same date (${incomingDate.day}/${incomingDate.month}/${incomingDate.year})',
      );
      reasons.add('Identical payee ("${incoming.normalizedMerchant}")');
      return DuplicateMatchResult(
        level: DuplicateMatchLevel.exact,
        confidence: 0.98,
        matchedTransaction: existing,
        reasons: reasons,
        recommendedAction: DuplicateResolution.merge,
      );
    }

    // 3. Likely Duplicate: Within 24 hours + exact amount + similar/canonical merchant
    if (dateDiffDays <= 1.0 && isSimilarMerchant) {
      confidence = 0.90;
      reasons.add(
        'Exact amount match (${CurrencyFormatter.formatAmount(incoming.amount)})',
      );
      reasons.add('Occurred within 24 hours');
      reasons.add(
        'Matching merchant alias ("${incoming.normalizedMerchant}" vs "${existing.merchant}")',
      );
      return DuplicateMatchResult(
        level: DuplicateMatchLevel.likely,
        confidence: confidence,
        matchedTransaction: existing,
        reasons: reasons,
        recommendedAction: DuplicateResolution.merge,
      );
    }

    // 4. Possible Duplicate:
    // - Same calendar day with distinct source (e.g. Notification vs SMS with slight wording differences)
    // - Or within 48 hours with similar merchant
    if (isSameCalendarDay) {
      confidence = 0.75;
      reasons.add(
        'Same date and exact amount match (${CurrencyFormatter.formatAmount(incoming.amount)})',
      );
      reasons.add(
        'Different merchant descriptions ("${incoming.rawMerchant}" vs "${existing.merchant}")',
      );
      return DuplicateMatchResult(
        level: DuplicateMatchLevel.possible,
        confidence: confidence,
        matchedTransaction: existing,
        reasons: reasons,
        recommendedAction: DuplicateResolution.keepBoth,
      );
    } else if (dateDiffDays <= 2.0 && isSimilarMerchant) {
      confidence = 0.65;
      reasons.add(
        'Exact amount match (${CurrencyFormatter.formatAmount(incoming.amount)})',
      );
      reasons.add('Occurred within 48 hours');
      reasons.add('Similar merchant name');
      return DuplicateMatchResult(
        level: DuplicateMatchLevel.possible,
        confidence: confidence,
        matchedTransaction: existing,
        reasons: reasons,
        recommendedAction: DuplicateResolution.keepBoth,
      );
    }

    return DuplicateMatchResult.none;
  }

  /// Simple character & token overlap similarity score (0.0 to 1.0)
  static double _calculateMerchantSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;

    final tokens1 = s1.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();
    final tokens2 = s2.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toSet();

    if (tokens1.isEmpty || tokens2.isEmpty) return 0.0;

    final intersection = tokens1.intersection(tokens2);
    final union = tokens1.union(tokens2);

    return intersection.length / union.length;
  }
}
