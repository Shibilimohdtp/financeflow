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
    );
  }
}
