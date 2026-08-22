import 'package:financeflow/models/ai_activity_log.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/repositories/ai_activity_log_repository.dart';
import 'package:financeflow/services/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAiActivityLogRepository implements AiActivityLogRepository {
  final List<AiActivityLog> logs = [];

  @override
  Future<List<AiActivityLog>> getAllLogs() async => logs;

  @override
  Stream<List<AiActivityLog>> watchAllLogs() => Stream.value(logs);

  @override
  Future<void> logActivity(AiActivityLog log) async => logs.add(log);

  @override
  Future<void> clearLogs() async => logs.clear();

  @override
  Future<void> updateAccepted(String id, bool accepted) async {}
}

void main() {
  group('GeminiDataSanitizer & GeminiService Tests', () {
    final now = DateTime(2026, 8, 15);

    test(
      'GeminiDataSanitizer strips account numbers, phone numbers, and PII',
      () {
        final sanitized = GeminiDataSanitizer.sanitizeForCategorization(
          rawMerchant: 'Swiggy UPI ref 9876543210 from A/c XX4321',
          amount: 450.0,
          availableCategoryNames: ['Dining', 'Groceries', 'Transport'],
        );

        final merchantStr = sanitized['merchant'] as String;
        expect(merchantStr, isNot(contains('9876543210')));
        expect(merchantStr, isNot(contains('4321')));
        expect(merchantStr, contains('Swiggy'));
      },
    );

    test(
      'categorizeTransaction falls back to on-device rules when Gemini is disabled',
      () async {
        final logRepo = FakeAiActivityLogRepository();
        final geminiService = GeminiService(logRepository: logRepo);

        final categories = [
          Category(
            id: 'cat_dining',
            name: 'Dining',
            iconIdentifier: 'restaurant',
            colorTokenIdentifier: 'clay',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        const settings = AppSettings(
          isGeminiEnabled: false,
          geminiConsentGranted: false,
        );

        final result = await geminiService.categorizeTransaction(
          rawMerchant: 'Zomato Order',
          amount: 350.0,
          availableCategories: categories,
          settings: settings,
        );

        expect(result.isFromGemini, isFalse);
        expect(result.categoryName, equals('Dining'));
        expect(
          logRepo.logs,
          isEmpty,
        ); // Zero external calls logged when disabled
      },
    );
  });
}
