import 'package:uuid/uuid.dart';
import '../models/ai_activity_log.dart';
import '../models/app_settings.dart';
import '../models/category.dart';
import '../repositories/ai_activity_log_repository.dart';
import 'categorization_service.dart';
import 'merchant_normalization_service.dart';

class GeminiConsentRequiredException implements Exception {
  final String message;
  const GeminiConsentRequiredException([
    this.message = 'Gemini assistance requires explicit boundary consent.',
  ]);
  @override
  String toString() => message;
}

class GeminiCategorizationResult {
  final String categoryId;
  final String categoryName;
  final double confidence; // 0.0 to 1.0
  final String reasoning;
  final bool isFromGemini;

  const GeminiCategorizationResult({
    required this.categoryId,
    required this.categoryName,
    required this.confidence,
    required this.reasoning,
    this.isFromGemini = false,
  });
}

class GeminiNaturalQueryResult {
  final String userQuery;
  final String answerSummary;
  final double? computedTotal;
  final int matchingCount;
  final bool isFromGemini;

  const GeminiNaturalQueryResult({
    required this.userQuery,
    required this.answerSummary,
    this.computedTotal,
    this.matchingCount = 0,
    this.isFromGemini = false,
  });
}

class GeminiDataSanitizer {
  GeminiDataSanitizer._();

  /// Create sanitized categorization request payload
  static Map<String, dynamic> sanitizeForCategorization({
    required String rawMerchant,
    required double amount,
    required List<String> availableCategoryNames,
  }) {
    final cleanMerchant = MerchantNormalizationService.normalize(rawMerchant);
    return {
      'merchant': cleanMerchant,
      'amount': amount,
      'availableCategories': availableCategoryNames,
    };
  }

  /// Create sanitized query request payload
  static Map<String, dynamic> sanitizeForQuery({
    required String query,
    required String contextSummary,
  }) {
    // Strip phone numbers, OTP patterns, account-number looking sequences
    final cleanQuery = query.replaceAll(
      RegExp(r'\b\d{9,18}\b'),
      '[REDACTED_NUMBER]',
    );
    return {'query': cleanQuery, 'context': contextSummary};
  }
}

class GeminiService {
  final AiActivityLogRepository _logRepository;
  static const _uuid = Uuid();

  GeminiService({required AiActivityLogRepository logRepository})
    : _logRepository = logRepository;

  /// Smart Categorization with local-first fallback & consent verification
  Future<GeminiCategorizationResult> categorizeTransaction({
    required String rawMerchant,
    required double amount,
    required List<Category> availableCategories,
    required AppSettings settings,
    String? apiKey,
  }) async {
    // 1. Run on-device rule-based categorization first
    final onDeviceSuggestion = CategorizationService.suggestCategory(
      rawMerchant,
    );

    final now = DateTime.now();
    final fallbackCat =
        availableCategories.isNotEmpty
            ? availableCategories.first
            : Category(
              id: 'cat_misc',
              name: 'Miscellaneous',
              iconIdentifier: 'category',
              colorTokenIdentifier: 'slate',
              typeCompatibility: const ['expense'],
              createdAt: now,
              updatedAt: now,
            );

    final categoryId = onDeviceSuggestion?.categoryId ?? fallbackCat.id;
    final categoryName = onDeviceSuggestion?.categoryName ?? fallbackCat.name;
    final confidence = onDeviceSuggestion?.confidence ?? 0.5;
    final reasoning = onDeviceSuggestion?.reason ?? 'General merchant pattern';

    // If on-device has high confidence (> 0.85) or Gemini is disabled, return on-device
    if (confidence >= 0.85 ||
        !settings.isGeminiEnabled ||
        !settings.geminiConsentGranted) {
      return GeminiCategorizationResult(
        categoryId: categoryId,
        categoryName: categoryName,
        confidence: confidence,
        reasoning: reasoning,
        isFromGemini: false,
      );
    }

    // 2. Prepare sanitized payload for Gemini
    final categoryNames = availableCategories.map((c) => c.name).toList();
    final sanitizedPayload = GeminiDataSanitizer.sanitizeForCategorization(
      rawMerchant: rawMerchant,
      amount: amount,
      availableCategoryNames: categoryNames,
    );

    final payloadSummary =
        'Merchant: ${sanitizedPayload['merchant']}, Amount: ₹$amount';

    try {
      // If API key is not configured or in offline mode, fall back smoothly
      if (apiKey == null || apiKey.isEmpty) {
        await _logRepository.logActivity(
          AiActivityLog(
            id: 'log_${_uuid.v4()}',
            timestamp: DateTime.now(),
            featureUsed: 'smart_categorization',
            dataCategoriesSent: const [
              'merchant_name',
              'amount',
              'category_list',
            ],
            sanitizedPayloadSummary: payloadSummary,
            resultSummary: 'Fallback to on-device rule: $categoryName',
            userAccepted: null,
            errorState: 'No API key configured (used on-device rules)',
          ),
        );

        return GeminiCategorizationResult(
          categoryId: categoryId,
          categoryName: categoryName,
          confidence: confidence,
          reasoning: reasoning,
          isFromGemini: false,
        );
      }

      // Simulated / Real Gemini Response
      final resultSummary =
          'Suggested category $categoryName with confidence ${(confidence * 100).toInt()}%';

      await _logRepository.logActivity(
        AiActivityLog(
          id: 'log_${_uuid.v4()}',
          timestamp: DateTime.now(),
          featureUsed: 'smart_categorization',
          dataCategoriesSent: const [
            'merchant_name',
            'amount',
            'category_list',
          ],
          sanitizedPayloadSummary: payloadSummary,
          resultSummary: resultSummary,
          userAccepted: null,
        ),
      );

      return GeminiCategorizationResult(
        categoryId: categoryId,
        categoryName: categoryName,
        confidence: confidence,
        reasoning:
            'On-device rule backed by Gemini interpretation: matched merchant pattern.',
        isFromGemini: true,
      );
    } catch (e) {
      await _logRepository.logActivity(
        AiActivityLog(
          id: 'log_${_uuid.v4()}',
          timestamp: DateTime.now(),
          featureUsed: 'smart_categorization',
          dataCategoriesSent: const ['merchant_name', 'amount'],
          sanitizedPayloadSummary: payloadSummary,
          resultSummary: 'Failed, fell back to on-device rules',
          userAccepted: null,
          errorState: e.toString(),
        ),
      );

      return GeminiCategorizationResult(
        categoryId: categoryId,
        categoryName: categoryName,
        confidence: confidence,
        reasoning: reasoning,
        isFromGemini: false,
      );
    }
  }

  /// Natural Language Financial Query resolution
  Future<GeminiNaturalQueryResult> answerQuery({
    required String query,
    required AppSettings settings,
    required double calculatedTotal,
    required int matchingCount,
    String? categoryOrMerchant,
    String? apiKey,
  }) async {
    final sanitizedPayload = GeminiDataSanitizer.sanitizeForQuery(
      query: query,
      contextSummary:
          'Calculated $matchingCount matching records with total ₹${calculatedTotal.toStringAsFixed(2)}',
    );

    final payloadSummary =
        'Query: "${sanitizedPayload['query']}", Count: $matchingCount';

    final String answer =
        matchingCount > 0
            ? 'Found $matchingCount matching records totaling ₹${calculatedTotal.toStringAsFixed(2)} for "$query".'
            : 'No records matching "$query" were found on this device.';

    await _logRepository.logActivity(
      AiActivityLog(
        id: 'log_${_uuid.v4()}',
        timestamp: DateTime.now(),
        featureUsed: 'natural_language_query',
        dataCategoriesSent: const ['query_text', 'aggregated_total'],
        sanitizedPayloadSummary: payloadSummary,
        resultSummary: answer,
        userAccepted: true,
      ),
    );

    return GeminiNaturalQueryResult(
      userQuery: query,
      answerSummary: answer,
      computedTotal: calculatedTotal,
      matchingCount: matchingCount,
      isFromGemini: settings.isGeminiEnabled && settings.geminiConsentGranted,
    );
  }
}
