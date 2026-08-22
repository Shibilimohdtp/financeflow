import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/ai_activity_log_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final logRepo = ref.watch(aiActivityLogRepositoryProvider);
  return GeminiService(logRepository: logRepo);
});

class GeminiController extends StateNotifier<AsyncValue<void>> {
  final SettingsRepository _settingsRepo;
  final AiActivityLogRepository _logRepo;
  final GeminiService _geminiService;
  final TransactionRepository _txRepo;

  GeminiController({
    required SettingsRepository settingsRepo,
    required AiActivityLogRepository logRepo,
    required GeminiService geminiService,
    required TransactionRepository txRepo,
  }) : _settingsRepo = settingsRepo,
       _logRepo = logRepo,
       _geminiService = geminiService,
       _txRepo = txRepo,
       super(const AsyncValue.data(null));

  Future<void> grantConsent() async {
    final settings = await _settingsRepo.getSettings();
    await _settingsRepo.updateSettings(
      settings.copyWith(
        isGeminiEnabled: true,
        geminiConsentGranted: true,
        geminiConsentDate: DateTime.now(),
      ),
    );
  }

  Future<void> revokeConsent() async {
    final settings = await _settingsRepo.getSettings();
    await _settingsRepo.updateSettings(
      settings.copyWith(
        isGeminiEnabled: false,
        geminiConsentGranted: false,
        geminiConsentDate: null,
      ),
    );
  }

  Future<void> clearActivityLogs() async {
    await _logRepo.clearLogs();
  }

  Future<GeminiNaturalQueryResult> queryFinance(String query) async {
    final settings = await _settingsRepo.getSettings();
    final allTxs = await _txRepo.getAllTransactions();

    // Local filtering
    final lower = query.toLowerCase();
    final matchingTxs =
        allTxs.where((t) {
          return t.merchant.toLowerCase().contains(lower) ||
              t.categoryName.toLowerCase().contains(lower) ||
              (t.notes?.toLowerCase().contains(lower) ?? false);
        }).toList();

    final total = matchingTxs.fold<double>(0.0, (s, t) => s + t.amount);

    return _geminiService.answerQuery(
      query: query,
      settings: settings,
      calculatedTotal: total,
      matchingCount: matchingTxs.length,
    );
  }
}

final geminiControllerProvider =
    StateNotifierProvider<GeminiController, AsyncValue<void>>((ref) {
      return GeminiController(
        settingsRepo: ref.watch(settingsRepositoryProvider),
        logRepo: ref.watch(aiActivityLogRepositoryProvider),
        geminiService: ref.watch(geminiServiceProvider),
        txRepo: ref.watch(transactionRepositoryProvider),
      );
    });
