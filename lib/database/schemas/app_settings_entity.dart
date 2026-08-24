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
  DateTime? lastSuccessfulSmsEvent;
  DateTime? lastSuccessfulNotificationEvent;
  DateTime? lastGmailScan;
  int ingestionParsedCount = 0;
  int ingestionRejectedCount = 0;
  int ingestionDuplicateCount = 0;
  String? ingestionLastError;

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

  /// Insight IDs explicitly dismissed by the user. Kept in app settings so
  /// generated insights stay dismissed after a process/device restart.
  List<String> dismissedInsightIds = [];

  late DateTime createdAt;

  late DateTime updatedAt;
}
