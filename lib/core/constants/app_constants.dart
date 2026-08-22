/// Core App Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'FinanceFlow';
  static const String appTagline = 'Private, Local-First Personal Finance';
  static const String appVersion = '1.0.0 (Stillwater)';
  static const String brandSystemName = 'Stillwater';

  // Secure Storage Keys
  static const String keyAppPin = 'ff_secure_app_pin';
  static const String keyBiometricEnabled = 'ff_secure_biometric_enabled';
  static const String keyEncryptionKey = 'ff_secure_isar_encryption_key';

  // Shared Prefs / Isar Settings Keys
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';

  // Seed Data Version
  static const int seedCategoryVersion = 1;
}
