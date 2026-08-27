import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/backup_payload.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/money_record_repository.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../repositories/savings_goal_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    accountRepo: ref.watch(accountRepositoryProvider),
    transactionRepo: ref.watch(transactionRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
    budgetRepo: ref.watch(budgetRepositoryProvider),
    goalRepo: ref.watch(savingsGoalRepositoryProvider),
    subscriptionRepo: ref.watch(subscriptionRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    investmentRepo: ref.watch(investmentRepositoryProvider),
    alertRepo: ref.watch(alertRepositoryProvider),
    moneyRecordRepo: ref.watch(moneyRecordRepositoryProvider),
    pendingTxRepo: ref.watch(pendingTransactionRepositoryProvider),
    settingsRepo: ref.watch(settingsRepositoryProvider),
  );
});

class BackupController extends StateNotifier<AsyncValue<String?>> {
  final BackupService _service;
  final SettingsRepository _settingsRepo;

  BackupController(this._service, this._settingsRepo)
    : super(const AsyncValue.data(null));

  Future<String> createBackup({required String passphrase}) async {
    state = const AsyncValue.loading();
    try {
      final encryptedContent = await _service.createEncryptedBackup(
        passphrase: passphrase,
      );

      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${backupDir.path}/financeflow_backup_$timestamp.ffbackup';
      final file = File(filePath);
      await file.writeAsString(encryptedContent);

      // Update last backup date in settings
      final currentSettings = await _settingsRepo.getSettings();
      await _settingsRepo.updateSettings(
        currentSettings.copyWith(lastBackupDate: DateTime.now()),
      );

      state = AsyncValue.data(filePath);
      return filePath;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  BackupDataPayload decryptAndPreview({
    required String fileContent,
    required String passphrase,
  }) {
    return BackupService.decryptAndPreview(
      backupFileContent: fileContent,
      passphrase: passphrase,
    );
  }

  Future<RestoreResult> executeRestore({
    required BackupDataPayload payload,
    required RestoreMode mode,
  }) async {
    return _service.executeRestore(payload: payload, mode: mode);
  }
}

final backupControllerProvider =
    StateNotifierProvider<BackupController, AsyncValue<String?>>((ref) {
      final service = ref.watch(backupServiceProvider);
      final settingsRepo = ref.watch(settingsRepositoryProvider);
      return BackupController(service, settingsRepo);
    });
