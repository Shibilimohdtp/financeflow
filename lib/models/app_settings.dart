enum AppThemePreference {
  system,
  daylight,
  deepWater;

  String get displayName {
    switch (this) {
      case AppThemePreference.system:
        return 'System Default';
      case AppThemePreference.daylight:
        return 'Daylight (Light)';
      case AppThemePreference.deepWater:
        return 'Deep Water (Dark)';
    }
  }

  static AppThemePreference fromString(String val) {
    switch (val.toLowerCase()) {
      case 'daylight':
      case 'light':
        return AppThemePreference.daylight;
      case 'deep_water':
      case 'deepwater':
      case 'dark':
        return AppThemePreference.deepWater;
      default:
        return AppThemePreference.system;
    }
  }

  String toDbString() {
    switch (this) {
      case AppThemePreference.system:
        return 'system';
      case AppThemePreference.daylight:
        return 'daylight';
      case AppThemePreference.deepWater:
        return 'deep_water';
    }
  }
}

class AppSettings {
  final bool hasCompletedOnboarding;
  final AppThemePreference themePreference;
  final bool isBiometricEnabled;
  final bool isPinEnabled;
  final bool isPrivacyBlurEnabled;
  final bool isScreenshotProtectionEnabled;
  final String currencyCode;
  final bool isDenseMode;

  // Phase 3 Ingestion Settings
  final bool isNotificationDetectionEnabled;
  final bool isSmsDetectionEnabled;
  final List<String> selectedNotificationPackages;
  final List<String> selectedSmsSenders;
  final DateTime? lastIngestionScan;
  final DateTime? lastSuccessfulSmsEvent;
  final DateTime? lastSuccessfulNotificationEvent;
  final DateTime? lastGmailScan;
  final int ingestionParsedCount;
  final int ingestionRejectedCount;
  final int ingestionDuplicateCount;
  final String? ingestionLastError;

  // Phase 4 Settings
  final bool isGeminiEnabled;
  final bool geminiConsentGranted;
  final DateTime? geminiConsentDate;
  final bool isAlertsEnabled;
  final bool isBudgetAlertsEnabled;
  final bool isSubscriptionAlertsEnabled;
  final bool isLoanAlertsEnabled;
  final bool isNeedsReviewAlertsEnabled;
  final bool isBackupReminderEnabled;
  final DateTime? lastBackupDate;
  final DateTime? lastAlertScan;
  final int autoLockTimeoutMinutes;
  final List<String> dismissedInsightIds;

  // Local Push Notification Preferences
  final bool isLocalNotificationsEnabled;
  final bool isNeedsReviewNotificationsEnabled;
  final bool isBudgetNotificationEnabled;
  final bool isSubscriptionNotificationEnabled;
  final bool isLoanNotificationEnabled;
  final bool isBackupNotificationEnabled;
  final bool hideSensitiveNotificationContent;

  const AppSettings({
    this.hasCompletedOnboarding = false,
    this.themePreference = AppThemePreference.system,
    this.isBiometricEnabled = false,
    this.isPinEnabled = false,
    this.isPrivacyBlurEnabled = false,
    this.isScreenshotProtectionEnabled = false,
    this.currencyCode = 'INR',
    this.isDenseMode = false,
    this.isNotificationDetectionEnabled = false,
    this.isSmsDetectionEnabled = false,
    this.selectedNotificationPackages = const [
      'com.google.android.apps.nbu.paisa.user', // Google Pay
      'com.phonepe.app', // PhonePe
      'net.one97.paytm', // Paytm
      'in.org.npci.upiapp', // BHIM
      'com.dreamplug.androidapp', // CRED
    ],
    this.selectedSmsSenders = const [
      'HDFCBK',
      'ICICIB',
      'SBIN',
      'AXISBK',
      'FEDBNK',
      'CANBNK',
      'UNIONB',
    ],
    this.lastIngestionScan,
    this.lastSuccessfulSmsEvent,
    this.lastSuccessfulNotificationEvent,
    this.lastGmailScan,
    this.ingestionParsedCount = 0,
    this.ingestionRejectedCount = 0,
    this.ingestionDuplicateCount = 0,
    this.ingestionLastError,
    this.isGeminiEnabled = false,
    this.geminiConsentGranted = false,
    this.geminiConsentDate,
    this.isAlertsEnabled = true,
    this.isBudgetAlertsEnabled = true,
    this.isSubscriptionAlertsEnabled = true,
    this.isLoanAlertsEnabled = true,
    this.isNeedsReviewAlertsEnabled = true,
    this.isBackupReminderEnabled = true,
    this.lastBackupDate,
    this.lastAlertScan,
    this.autoLockTimeoutMinutes = 0,
    this.dismissedInsightIds = const [],
    this.isLocalNotificationsEnabled = true,
    this.isNeedsReviewNotificationsEnabled = true,
    this.isBudgetNotificationEnabled = true,
    this.isSubscriptionNotificationEnabled = true,
    this.isLoanNotificationEnabled = true,
    this.isBackupNotificationEnabled = true,
    this.hideSensitiveNotificationContent = false,
  });

  AppSettings copyWith({
    bool? hasCompletedOnboarding,
    AppThemePreference? themePreference,
    bool? isBiometricEnabled,
    bool? isPinEnabled,
    bool? isPrivacyBlurEnabled,
    bool? isScreenshotProtectionEnabled,
    String? currencyCode,
    bool? isDenseMode,
    bool? isNotificationDetectionEnabled,
    bool? isSmsDetectionEnabled,
    List<String>? selectedNotificationPackages,
    List<String>? selectedSmsSenders,
    DateTime? lastIngestionScan,
    DateTime? lastSuccessfulSmsEvent,
    DateTime? lastSuccessfulNotificationEvent,
    DateTime? lastGmailScan,
    int? ingestionParsedCount,
    int? ingestionRejectedCount,
    int? ingestionDuplicateCount,
    String? ingestionLastError,
    bool? isGeminiEnabled,
    bool? geminiConsentGranted,
    DateTime? geminiConsentDate,
    bool? isAlertsEnabled,
    bool? isBudgetAlertsEnabled,
    bool? isSubscriptionAlertsEnabled,
    bool? isLoanAlertsEnabled,
    bool? isNeedsReviewAlertsEnabled,
    bool? isBackupReminderEnabled,
    DateTime? lastBackupDate,
    DateTime? lastAlertScan,
    int? autoLockTimeoutMinutes,
    List<String>? dismissedInsightIds,
    bool? isLocalNotificationsEnabled,
    bool? isNeedsReviewNotificationsEnabled,
    bool? isBudgetNotificationEnabled,
    bool? isSubscriptionNotificationEnabled,
    bool? isLoanNotificationEnabled,
    bool? isBackupNotificationEnabled,
    bool? hideSensitiveNotificationContent,
  }) {
    return AppSettings(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themePreference: themePreference ?? this.themePreference,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isPrivacyBlurEnabled: isPrivacyBlurEnabled ?? this.isPrivacyBlurEnabled,
      isScreenshotProtectionEnabled:
          isScreenshotProtectionEnabled ?? this.isScreenshotProtectionEnabled,
      currencyCode: currencyCode ?? this.currencyCode,
      isDenseMode: isDenseMode ?? this.isDenseMode,
      isNotificationDetectionEnabled:
          isNotificationDetectionEnabled ?? this.isNotificationDetectionEnabled,
      isSmsDetectionEnabled:
          isSmsDetectionEnabled ?? this.isSmsDetectionEnabled,
      selectedNotificationPackages:
          selectedNotificationPackages ?? this.selectedNotificationPackages,
      selectedSmsSenders: selectedSmsSenders ?? this.selectedSmsSenders,
      lastIngestionScan: lastIngestionScan ?? this.lastIngestionScan,
      lastSuccessfulSmsEvent:
          lastSuccessfulSmsEvent ?? this.lastSuccessfulSmsEvent,
      lastSuccessfulNotificationEvent:
          lastSuccessfulNotificationEvent ??
          this.lastSuccessfulNotificationEvent,
      lastGmailScan: lastGmailScan ?? this.lastGmailScan,
      ingestionParsedCount: ingestionParsedCount ?? this.ingestionParsedCount,
      ingestionRejectedCount:
          ingestionRejectedCount ?? this.ingestionRejectedCount,
      ingestionDuplicateCount:
          ingestionDuplicateCount ?? this.ingestionDuplicateCount,
      ingestionLastError: ingestionLastError ?? this.ingestionLastError,
      isGeminiEnabled: isGeminiEnabled ?? this.isGeminiEnabled,
      geminiConsentGranted: geminiConsentGranted ?? this.geminiConsentGranted,
      geminiConsentDate: geminiConsentDate ?? this.geminiConsentDate,
      isAlertsEnabled: isAlertsEnabled ?? this.isAlertsEnabled,
      isBudgetAlertsEnabled:
          isBudgetAlertsEnabled ?? this.isBudgetAlertsEnabled,
      isSubscriptionAlertsEnabled:
          isSubscriptionAlertsEnabled ?? this.isSubscriptionAlertsEnabled,
      isLoanAlertsEnabled: isLoanAlertsEnabled ?? this.isLoanAlertsEnabled,
      isNeedsReviewAlertsEnabled:
          isNeedsReviewAlertsEnabled ?? this.isNeedsReviewAlertsEnabled,
      isBackupReminderEnabled:
          isBackupReminderEnabled ?? this.isBackupReminderEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastAlertScan: lastAlertScan ?? this.lastAlertScan,
      autoLockTimeoutMinutes:
          autoLockTimeoutMinutes ?? this.autoLockTimeoutMinutes,
      dismissedInsightIds: dismissedInsightIds ?? this.dismissedInsightIds,
      isLocalNotificationsEnabled:
          isLocalNotificationsEnabled ?? this.isLocalNotificationsEnabled,
      isNeedsReviewNotificationsEnabled:
          isNeedsReviewNotificationsEnabled ??
          this.isNeedsReviewNotificationsEnabled,
      isBudgetNotificationEnabled:
          isBudgetNotificationEnabled ?? this.isBudgetNotificationEnabled,
      isSubscriptionNotificationEnabled:
          isSubscriptionNotificationEnabled ??
          this.isSubscriptionNotificationEnabled,
      isLoanNotificationEnabled:
          isLoanNotificationEnabled ?? this.isLoanNotificationEnabled,
      isBackupNotificationEnabled:
          isBackupNotificationEnabled ?? this.isBackupNotificationEnabled,
      hideSensitiveNotificationContent:
          hideSensitiveNotificationContent ??
          this.hideSensitiveNotificationContent,
    );
  }
}
