/// Database Migration Strategy & Schema Evolution Notes
///
/// Phase 1 Schema (v1.0):
/// - AccountEntity: uuid, name, type, institutionName, maskedIdentifier, openingBalance, currentBalance, isArchived
/// - TransactionEntity: uuid, amount, type, categoryId, categoryName, categoryIcon, categoryColor, merchant, date, notes, source, paymentMethod, accountId, tags, isReviewed
/// - CategoryEntity: uuid, name, iconIdentifier, colorTokenIdentifier, typeCompatibility, isDefault, isArchived, sortOrder
/// - AppSettingsEntity: singleton id=1, hasCompletedOnboarding, themeMode, isBiometricEnabled, isPinEnabled, isPrivacyBlurEnabled, isScreenshotProtectionEnabled
///
/// Future Phase Migration Rules:
/// 1. In Isar, adding new non-indexed fields is backwards-compatible without data loss.
/// 2. New indices or renamed fields should use `@Name` annotations or explicit data transformation functions in this file.
/// 3. Database backups are exported in encrypted format before major schema changes.
class DatabaseMigrations {
  DatabaseMigrations._();

  static const int currentSchemaVersion = 2;

  static Future<void> performMigrationsIfNeeded() async {
    // Migration logic for future versions will be placed here
  }
}
