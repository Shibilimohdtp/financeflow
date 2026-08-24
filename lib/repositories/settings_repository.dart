import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/isar_service.dart';
import '../database/schemas/app_settings_entity.dart';
import '../models/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return IsarSettingsRepository();
});

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Stream<AppSettings> watchSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<void> setOnboardingCompleted(bool completed);
  Future<void> setThemePreference(AppThemePreference preference);
  Future<void> setBiometricEnabled(bool enabled);
  Future<void> setPinEnabled(bool enabled);
  Future<void> setPrivacyBlurEnabled(bool enabled);
  Future<void> setDenseMode(bool enabled);
}

class IsarSettingsRepository implements SettingsRepository {
  final Isar isar;

  IsarSettingsRepository({Isar? isarInstance})
    : isar = isarInstance ?? IsarService.instance.isar;

  AppSettings _toDomain(AppSettingsEntity entity) {
    return AppSettings(
      hasCompletedOnboarding: entity.hasCompletedOnboarding,
      themePreference: AppThemePreference.fromString(entity.themeMode),
      isBiometricEnabled: entity.isBiometricEnabled,
      isPinEnabled: entity.isPinEnabled,
      isPrivacyBlurEnabled: entity.isPrivacyBlurEnabled,
      isScreenshotProtectionEnabled: entity.isScreenshotProtectionEnabled,
      currencyCode: entity.currencyCode,
      isDenseMode: entity.isDenseMode,
      isNotificationDetectionEnabled: entity.isNotificationDetectionEnabled,
      isSmsDetectionEnabled: entity.isSmsDetectionEnabled,
      selectedNotificationPackages:
          entity.selectedNotificationPackages.isNotEmpty
              ? List<String>.from(entity.selectedNotificationPackages)
              : const [
                'com.google.android.apps.nbu.paisa.user',
                'com.phonepe.app',
                'net.one97.paytm',
                'in.org.npci.upiapp',
                'com.dreamplug.androidapp',
              ],
      selectedSmsSenders:
          entity.selectedSmsSenders.isNotEmpty
              ? List<String>.from(entity.selectedSmsSenders)
              : const [
                'HDFCBK',
                'ICICIB',
                'SBIN',
                'AXISBK',
                'FEDBNK',
                'CANBNK',
                'UNIONB',
              ],
      lastIngestionScan: entity.lastIngestionScan,
      lastSuccessfulSmsEvent: entity.lastSuccessfulSmsEvent,
      lastSuccessfulNotificationEvent: entity.lastSuccessfulNotificationEvent,
      lastGmailScan: entity.lastGmailScan,
      ingestionParsedCount: entity.ingestionParsedCount,
      ingestionRejectedCount: entity.ingestionRejectedCount,
      ingestionDuplicateCount: entity.ingestionDuplicateCount,
      ingestionLastError: entity.ingestionLastError,
      isGeminiEnabled: entity.isGeminiEnabled,
      geminiConsentGranted: entity.geminiConsentGranted,
      geminiConsentDate: entity.geminiConsentDate,
      isAlertsEnabled: entity.isAlertsEnabled,
      isBudgetAlertsEnabled: entity.isBudgetAlertsEnabled,
      isSubscriptionAlertsEnabled: entity.isSubscriptionAlertsEnabled,
      isLoanAlertsEnabled: entity.isLoanAlertsEnabled,
      isNeedsReviewAlertsEnabled: entity.isNeedsReviewAlertsEnabled,
      isBackupReminderEnabled: entity.isBackupReminderEnabled,
      lastBackupDate: entity.lastBackupDate,
      lastAlertScan: entity.lastAlertScan,
      autoLockTimeoutMinutes: entity.autoLockTimeoutMinutes,
      dismissedInsightIds: List<String>.from(entity.dismissedInsightIds),
    );
  }

  @override
  Future<AppSettings> getSettings() async {
    final entity = await isar.appSettingsEntitys.get(1);
    if (entity != null) {
      return _toDomain(entity);
    }
    return const AppSettings();
  }

  @override
  Stream<AppSettings> watchSettings() {
    return isar.appSettingsEntitys.watchObject(1, fireImmediately: true).map((
      entity,
    ) {
      if (entity != null) {
        return _toDomain(entity);
      }
      return const AppSettings();
    });
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await isar.writeTxn(() async {
      final entity =
          await isar.appSettingsEntitys.get(1) ?? AppSettingsEntity()
            ..id = 1
            ..createdAt = DateTime.now();

      entity.hasCompletedOnboarding = settings.hasCompletedOnboarding;
      entity.themeMode = settings.themePreference.toDbString();
      entity.isBiometricEnabled = settings.isBiometricEnabled;
      entity.isPinEnabled = settings.isPinEnabled;
      entity.isPrivacyBlurEnabled = settings.isPrivacyBlurEnabled;
      entity.isScreenshotProtectionEnabled =
          settings.isScreenshotProtectionEnabled;
      entity.currencyCode = settings.currencyCode;
      entity.isDenseMode = settings.isDenseMode;
      entity.isNotificationDetectionEnabled =
          settings.isNotificationDetectionEnabled;
      entity.isSmsDetectionEnabled = settings.isSmsDetectionEnabled;
      entity.selectedNotificationPackages =
          settings.selectedNotificationPackages;
      entity.selectedSmsSenders = settings.selectedSmsSenders;
      entity.lastIngestionScan = settings.lastIngestionScan;
      entity.lastSuccessfulSmsEvent = settings.lastSuccessfulSmsEvent;
      entity.lastSuccessfulNotificationEvent =
          settings.lastSuccessfulNotificationEvent;
      entity.lastGmailScan = settings.lastGmailScan;
      entity.ingestionParsedCount = settings.ingestionParsedCount;
      entity.ingestionRejectedCount = settings.ingestionRejectedCount;
      entity.ingestionDuplicateCount = settings.ingestionDuplicateCount;
      entity.ingestionLastError = settings.ingestionLastError;

      // Phase 4
      entity.isGeminiEnabled = settings.isGeminiEnabled;
      entity.geminiConsentGranted = settings.geminiConsentGranted;
      entity.geminiConsentDate = settings.geminiConsentDate;
      entity.isAlertsEnabled = settings.isAlertsEnabled;
      entity.isBudgetAlertsEnabled = settings.isBudgetAlertsEnabled;
      entity.isSubscriptionAlertsEnabled = settings.isSubscriptionAlertsEnabled;
      entity.isLoanAlertsEnabled = settings.isLoanAlertsEnabled;
      entity.isNeedsReviewAlertsEnabled = settings.isNeedsReviewAlertsEnabled;
      entity.isBackupReminderEnabled = settings.isBackupReminderEnabled;
      entity.lastBackupDate = settings.lastBackupDate;
      entity.lastAlertScan = settings.lastAlertScan;
      entity.autoLockTimeoutMinutes = settings.autoLockTimeoutMinutes;
      entity.dismissedInsightIds = List<String>.from(
        settings.dismissedInsightIds,
      );

      entity.updatedAt = DateTime.now();

      await isar.appSettingsEntitys.put(entity);
    });
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(hasCompletedOnboarding: completed));
  }

  @override
  Future<void> setThemePreference(AppThemePreference preference) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(themePreference: preference));
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(isBiometricEnabled: enabled));
  }

  @override
  Future<void> setPinEnabled(bool enabled) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(isPinEnabled: enabled));
  }

  @override
  Future<void> setPrivacyBlurEnabled(bool enabled) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(isPrivacyBlurEnabled: enabled));
  }

  @override
  Future<void> setDenseMode(bool enabled) async {
    final current = await getSettings();
    await updateSettings(current.copyWith(isDenseMode: enabled));
  }
}
