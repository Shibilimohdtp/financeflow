import 'package:isar/isar.dart';

part 'app_settings_entity.g.dart';

@collection
class AppSettingsEntity {
  Id id = 1; // Singleton record

  bool hasCompletedOnboarding = false;

  String themeMode = 'system'; // system, daylight, deep_water

  bool isBiometricEnabled = false;

  bool isPinEnabled = false;

  bool isPrivacyBlurEnabled = false;

  bool isScreenshotProtectionEnabled = false;

  String currencyCode = 'INR';

  bool isDenseMode = false;

  bool isNotificationDetectionEnabled = false;

  bool isSmsDetectionEnabled = false;

  List<String> selectedNotificationPackages = [];

  List<String> selectedSmsSenders = [];

  DateTime? lastIngestionScan;

  // Phase 4 Settings
  bool isGeminiEnabled = false;
  bool geminiConsentGranted = false;
  DateTime? geminiConsentDate;

  bool isAlertsEnabled = true;
  bool isBudgetAlertsEnabled = true;
  bool isSubscriptionAlertsEnabled = true;
  bool isLoanAlertsEnabled = true;
  bool isNeedsReviewAlertsEnabled = true;
  bool isBackupReminderEnabled = true;
  DateTime? lastBackupDate;
  DateTime? lastAlertScan;

  int autoLockTimeoutMinutes = 0; // 0 = disabled / immediate

  late DateTime createdAt;

  late DateTime updatedAt;
}
