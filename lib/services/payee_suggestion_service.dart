import '../models/transaction.dart';
import 'merchant_normalization_service.dart';

/// A suggestion for a payee or merchant based on historical context
class PayeeSuggestion {
  final String displayName;
  final String normalizedKey;
  final String? primaryCategoryId;
  final String? primaryCategoryName;
  final bool isCategoryMatch;
  final int totalCount;
  final int categoryCount;
  final DateTime lastUsed;
  final double score;
  final String? reasonLabel;

  const PayeeSuggestion({
    required this.displayName,
    required this.normalizedKey,
    this.primaryCategoryId,
    this.primaryCategoryName,
    this.isCategoryMatch = false,
    required this.totalCount,
    this.categoryCount = 0,
    required this.lastUsed,
    required this.score,
    this.reasonLabel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayeeSuggestion &&
          runtimeType == other.runtimeType &&
          normalizedKey == other.normalizedKey &&
          isCategoryMatch == other.isCategoryMatch;

  @override
  int get hashCode => Object.hash(normalizedKey, isCategoryMatch);
}

/// Internal aggregator helper
class _PayeeAggregate {
  final String normalizedKey;
  final Map<String, int> displayNames = {};
  final Map<String, int> categoryCounts = {};
  final Map<String, String> categoryNames = {};
  final Map<String, DateTime> categoryLastUsed = {};
  int totalCount = 0;
  DateTime lastUsed = DateTime.fromMillisecondsSinceEpoch(0);

  _PayeeAggregate(this.normalizedKey);

  void addTransaction(Transaction tx) {
    totalCount++;
    if (tx.date.isAfter(lastUsed)) {
      lastUsed = tx.date;
    }

    final rawName = tx.merchant.trim().replaceAll(RegExp(r'\s+'), ' ');
    displayNames[rawName] = (displayNames[rawName] ?? 0) + 1;

    if (tx.categoryId.isNotEmpty) {
      categoryCounts[tx.categoryId] =
          (categoryCounts[tx.categoryId] ?? 0) + 1;
      categoryNames[tx.categoryId] = tx.categoryName;
      final prevDate = categoryLastUsed[tx.categoryId];
      if (prevDate == null || tx.date.isAfter(prevDate)) {
        categoryLastUsed[tx.categoryId] = tx.date;
      }
    }
  }

  String get canonicalDisplayName {
    // 1. Find the most frequently recorded raw display name
    String best = '';
    int maxCount = -1;
    for (final entry in displayNames.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        best = entry.key;
      }
    }
    if (best.isEmpty) best = normalizedKey;

    // 2. Check if known canonical dictionary has a match
    final norm = MerchantNormalizationService.normalize(best);
    if (norm != 'Unknown Payee' && norm.toLowerCase() == normalizedKey) {
      return norm;
    }

    // 3. If best is all lowercase, title-case it nicely
    if (best == best.toLowerCase()) {
      return MerchantNormalizationService.normalize(best);
    }

    return best;
  }

  String? get primaryCategoryId {
    if (categoryCounts.isEmpty) return null;
    String? bestCat;
    int maxCount = -1;
    for (final entry in categoryCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestCat = entry.key;
      }
    }
    return bestCat;
  }

  String? get primaryCategoryName {
    final catId = primaryCategoryId;
    return catId != null ? categoryNames[catId] : null;
  }
}

/// Intelligent, local, deterministic Payee/Merchant suggestion engine
class PayeeSuggestionService {
  PayeeSuggestionService._();

  /// Normalize a raw payee input to a canonical matching key
  static String normalizeKey(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Clean display name helper
  static String cleanDisplayName(String raw) {
    final trimmed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return 'Unknown Payee';
    return MerchantNormalizationService.normalize(trimmed);
  }

  /// Calculates a recency score from 0.0 to 100.0 based on days elapsed
  static double calculateRecencyScore(DateTime date, DateTime now) {
    final diffDays = now.difference(date).inDays;
    if (diffDays <= 0) return 100.0;
    if (diffDays <= 1) return 90.0;
    if (diffDays <= 7) return 70.0;
    if (diffDays <= 14) return 55.0;
    if (diffDays <= 30) return 40.0;
    if (diffDays <= 90) return 25.0;
    return 10.0;
  }

  /// Generate intelligent, context-aware suggestions
  ///
  /// Ranking considerations:
  /// 1. Query match (exact, prefix, word boundary, substring)
  /// 2. Category match (prioritize payees used with [categoryId])
  /// 3. Transaction type match (prioritize payees matching [type])
  /// 4. Usage frequency (both category-specific and overall)
  /// 5. Recency of last use
  /// 6. Deterministic tie-breaking
  static List<PayeeSuggestion> getSuggestions({
    required Iterable<Transaction> transactions,
    required TransactionType type,
    String? categoryId,
    String? query,
    int limit = 6,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final cleanQuery = query?.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ?? '';

    // 1. Group and aggregate transactions for the matching type
    final typeTransactions = transactions.where((tx) => tx.type == type && tx.merchant.trim().isNotEmpty);

    final aggregates = <String, _PayeeAggregate>{};
    for (final tx in typeTransactions) {
      final key = normalizeKey(tx.merchant);
      if (key.isEmpty) continue;
      aggregates.putIfAbsent(key, () => _PayeeAggregate(key)).addTransaction(tx);
    }

    if (aggregates.isEmpty) {
      return const [];
    }

    final hasCategory = categoryId != null && categoryId.trim().isNotEmpty;
    final cleanCategoryId = categoryId?.trim();

    final scoredList = <PayeeSuggestion>[];

    for (final agg in aggregates.values) {
      final canonicalName = agg.canonicalDisplayName;
      final normKey = agg.normalizedKey;
      final normNameLower = canonicalName.toLowerCase();

      // Query filtering & scoring
      double queryScore = 0.0;
      if (cleanQuery.isNotEmpty) {
        final queryMatchesKey = normKey.contains(cleanQuery);
        final queryMatchesName = normNameLower.contains(cleanQuery);

        if (!queryMatchesKey && !queryMatchesName) {
          // No match with typed text -> skip
          continue;
        }

        if (normKey == cleanQuery || normNameLower == cleanQuery) {
          queryScore = 2000.0;
        } else if (normKey.startsWith(cleanQuery) || normNameLower.startsWith(cleanQuery)) {
          queryScore = 1000.0;
        } else {
          // Check if any word starts with query
          final words = normKey.split(' ');
          final wordStartsWith = words.any((w) => w.startsWith(cleanQuery));
          if (wordStartsWith) {
            queryScore = 800.0;
          } else {
            queryScore = 400.0;
          }
        }
      }

      // Category matching & scoring
      final isCatMatch = hasCategory && (agg.categoryCounts[cleanCategoryId] ?? 0) > 0;
      final catCount = isCatMatch ? agg.categoryCounts[cleanCategoryId]! : 0;
      final catLastUsed = isCatMatch
          ? agg.categoryLastUsed[cleanCategoryId] ?? agg.lastUsed
          : agg.lastUsed;

      double categoryScore = 0.0;
      String? reasonLabel;

      if (isCatMatch) {
        // Base category boost + frequency within category + recency within category
        final catRecency = calculateRecencyScore(catLastUsed, referenceDate);
        categoryScore = 500.0 + (catCount * 50.0).clamp(0.0, 300.0) + catRecency;
        final catName = agg.categoryNames[cleanCategoryId];
        reasonLabel = catName != null ? 'Used with $catName' : 'Used with this category';
      } else if (hasCategory) {
        reasonLabel = 'Recent';
      } else {
        reasonLabel = agg.totalCount > 1 ? 'Frequently used' : 'Recent';
      }

      // General frequency & recency
      final generalFreqScore = (agg.totalCount * 15.0).clamp(0.0, 200.0);
      final generalRecencyScore = calculateRecencyScore(agg.lastUsed, referenceDate);

      final totalScore = queryScore + categoryScore + generalFreqScore + generalRecencyScore;

      scoredList.add(
        PayeeSuggestion(
          displayName: canonicalName,
          normalizedKey: normKey,
          primaryCategoryId: agg.primaryCategoryId,
          primaryCategoryName: agg.primaryCategoryName,
          isCategoryMatch: isCatMatch,
          totalCount: agg.totalCount,
          categoryCount: catCount,
          lastUsed: agg.lastUsed,
          score: totalScore,
          reasonLabel: reasonLabel,
        ),
      );
    }

    // 2. Deterministic sort:
    // - If category selected and no query: category matches naturally score much higher due to +500 boost.
    // - Highest score first.
    // - Then most recently used.
    // - Then higher frequency.
    // - Then alphabetical by display name.
    scoredList.sort((a, b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;

      final recencyCmp = b.lastUsed.compareTo(a.lastUsed);
      if (recencyCmp != 0) return recencyCmp;

      final freqCmp = b.totalCount.compareTo(a.totalCount);
      if (freqCmp != 0) return freqCmp;

      return a.displayName.compareTo(b.displayName);
    });

    return scoredList.take(limit).toList();
  }
}
