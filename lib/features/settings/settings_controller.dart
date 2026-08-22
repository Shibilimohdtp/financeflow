import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/isar_service.dart';
import '../../models/app_settings.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/security_service.dart';
import '../../services/seed_data_service.dart';

export '../../repositories/account_repository.dart'
    show accountRepositoryProvider, allAccountsStreamProvider;
export '../../repositories/category_repository.dart'
    show categoryRepositoryProvider;
export '../../repositories/settings_repository.dart'
    show settingsRepositoryProvider, settingsStreamProvider;
export '../../repositories/transaction_repository.dart'
    show transactionRepositoryProvider;

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final seedDataServiceProvider = Provider<SeedDataService>((ref) {
  return SeedDataService(
    accountRepo: ref.watch(accountRepositoryProvider),
    transactionRepo: ref.watch(transactionRepositoryProvider),
    subscriptionRepo: ref.watch(subscriptionRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    investmentRepo: ref.watch(investmentRepositoryProvider),
  );
});

// Settings Controller
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>((ref) {
      return SettingsController(ref);
    });

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;

  SettingsController(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final settings =
          await _ref.read(settingsRepositoryProvider).getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setThemePreference(preference);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setOnboardingCompleted(completed);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setBiometricEnabled(enabled);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> setPinEnabled(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setPinEnabled(enabled);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> setPrivacyBlurEnabled(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setPrivacyBlurEnabled(enabled);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> setDenseMode(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setDenseMode(enabled);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> updateSettings(AppSettings settings) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.updateSettings(settings);
    state = AsyncValue.data(await repo.getSettings());
  }

  Future<void> seedDemoData() async {
    final seedService = _ref.read(seedDataServiceProvider);
    await seedService.seedDemoData();
  }

  Future<void> resetAllData() async {
    await IsarService.instance.clearAllData();
    final securityService = _ref.read(securityServiceProvider);
    await securityService.removePin();
    await _init();
  }
}
