import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../core/errors/app_error.dart';
import 'default_categories.dart';
import 'schemas/account_entity.dart';
import 'schemas/ai_activity_log_entity.dart';
import 'schemas/alert_entity.dart';
import 'schemas/app_settings_entity.dart';
import 'schemas/budget_entity.dart';
import 'schemas/category_entity.dart';
import 'schemas/goal_contribution_entity.dart';
import 'schemas/investment_entity.dart';
import 'schemas/loan_entity.dart';
import 'schemas/emi_payment_entity.dart';
import 'schemas/money_record_entity.dart';
import 'schemas/money_repayment_entity.dart';
import 'schemas/pending_transaction_entity.dart';
import 'schemas/savings_goal_entity.dart';
import 'schemas/subscription_entity.dart';
import 'schemas/transaction_entity.dart';

/// Database Persistence Service managing the local-first Isar database
class IsarService {
  static IsarService? _instance;
  late final Isar isar;

  IsarService._(this.isar);

  static List<CollectionSchema<dynamic>> get _schemas => [
    AccountEntitySchema,
    TransactionEntitySchema,
    PendingTransactionEntitySchema,
    CategoryEntitySchema,
    AppSettingsEntitySchema,
    BudgetEntitySchema,
    SavingsGoalEntitySchema,
    GoalContributionEntitySchema,
    SubscriptionEntitySchema,
    LoanEntitySchema,
    EmiPaymentEntitySchema,
    InvestmentEntitySchema,
    MoneyRecordEntitySchema,
    MoneyRepaymentEntitySchema,
    AlertEntitySchema,
    AiActivityLogEntitySchema,
  ];

  static Future<Isar> _openIsar(String dir) {
    return Isar.open(
      _schemas,
      directory: dir,
      name: 'financeflow_local_db',
      inspector: false,
    );
  }

  static IsarService get instance {
    if (_instance == null) {
      throw const DatabaseError(
        message:
            'Isar database is not initialized. Please call initialize() first.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;

  /// Initialize Isar Database on device storage
  static Future<IsarService> initialize({
    String? directoryPath,
    bool isTest = false,
  }) async {
    if (_instance != null) return _instance!;

    try {
      String dir;
      if (directoryPath != null) {
        dir = directoryPath;
      } else if (isTest) {
        dir = '';
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        dir = appDocDir.path;
      }

      Isar isarInstance;
      try {
        isarInstance = await _openIsar(dir);
      } catch (e) {
        // If an outdated development/corrupted database file throws RangeError or schema mismatch,
        // safely delete the stale .isar file and re-open cleanly.
        debugPrint(
          'Warning: Isar database open failed with ($e). Attempting recovery by recreating local database...',
        );
        if (dir.isNotEmpty) {
          try {
            final isarFile = File('$dir/financeflow_local_db.isar');
            if (await isarFile.exists()) {
              await isarFile.delete();
            }
            final lockFile = File('$dir/financeflow_local_db.isar.lock');
            if (await lockFile.exists()) {
              await lockFile.delete();
            }
          } catch (delError) {
            debugPrint('Failed to delete corrupted isar file: $delError');
          }
        }
        isarInstance = await _openIsar(dir);
      }

      final service = IsarService._(isarInstance);
      await service._seedInitialDataIfNeeded();
      _instance = service;
      return service;
    } catch (e) {
      throw DatabaseError(message: 'Failed to initialize local database: $e');
    }
  }

  /// Ensure default categories and basic settings exist
  Future<void> _seedInitialDataIfNeeded() async {
    await isar.writeTxn(() async {
      // 1. Check Categories
      final categoryCount = await isar.categoryEntitys.count();
      if (categoryCount == 0) {
        final defaults = DefaultCategories.list;
        await isar.categoryEntitys.putAll(defaults);
      }

      // 2. Check App Settings
      final settings = await isar.appSettingsEntitys.get(1);
      if (settings == null) {
        final initialSettings =
            AppSettingsEntity()
              ..id = 1
              ..hasCompletedOnboarding = false
              ..themeMode = 'system'
              ..isBiometricEnabled = false
              ..isPinEnabled = false
              ..isPrivacyBlurEnabled = false
              ..isScreenshotProtectionEnabled = false
              ..currencyCode = 'INR'
              ..isDenseMode = false
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();
        await isar.appSettingsEntitys.put(initialSettings);
      }

      // 3. Create a primary account if none exist
      final accountCount = await isar.accountEntitys.count();
      if (accountCount == 0) {
        final defaultAccount =
            AccountEntity()
              ..uuid = 'acc_primary_cash'
              ..name = 'Cash Wallet'
              ..type = 'cash'
              ..institutionName = 'Cash'
              ..openingBalance = 0.0
              ..currentBalance = 0.0
              ..currency = 'INR'
              ..isArchived = false
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now();
        await isar.accountEntitys.put(defaultAccount);
      }
    });
  }

  /// Wipe all local app data (for privacy reset in Settings)
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.transactionEntitys.clear();
      await isar.pendingTransactionEntitys.clear();
      await isar.accountEntitys.clear();
      await isar.categoryEntitys.clear();
      await isar.appSettingsEntitys.clear();
      await isar.budgetEntitys.clear();
      await isar.savingsGoalEntitys.clear();
      await isar.goalContributionEntitys.clear();
      await isar.subscriptionEntitys.clear();
      await isar.loanEntitys.clear();
      await isar.emiPaymentEntitys.clear();
      await isar.investmentEntitys.clear();
      await isar.moneyRecordEntitys.clear();
      await isar.moneyRepaymentEntitys.clear();
      await isar.alertEntitys.clear();
      await isar.aiActivityLogEntitys.clear();
    });
    // Reseed defaults
    await _seedInitialDataIfNeeded();
  }
}
