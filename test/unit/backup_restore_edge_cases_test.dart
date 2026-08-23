import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/backup_payload.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/backup_service.dart';
import '../helpers/fake_repositories.dart';

void main() {
  group('Backup, Encryption and Restore Edge Cases Tests', () {
    late FakeAccountRepository accountRepo;
    late FakeTransactionRepository transactionRepo;
    late FakeCategoryRepository categoryRepo;
    late FakeBudgetRepository budgetRepo;
    late FakeSavingsGoalRepository goalRepo;
    late FakeSubscriptionRepository subRepo;
    late FakeLoanRepository loanRepo;
    late FakeInvestmentRepository investmentRepo;
    late FakeAlertRepository alertRepo;
    late BackupService backupService;

    setUp(() {
      accountRepo = FakeAccountRepository();
      transactionRepo = FakeTransactionRepository();
      categoryRepo = FakeCategoryRepository();
      budgetRepo = FakeBudgetRepository();
      goalRepo = FakeSavingsGoalRepository();
      subRepo = FakeSubscriptionRepository();
      loanRepo = FakeLoanRepository();
      investmentRepo = FakeInvestmentRepository();
      alertRepo = FakeAlertRepository();

      backupService = BackupService(
        accountRepo: accountRepo,
        transactionRepo: transactionRepo,
        categoryRepo: categoryRepo,
        budgetRepo: budgetRepo,
        goalRepo: goalRepo,
        subscriptionRepo: subRepo,
        loanRepo: loanRepo,
        investmentRepo: investmentRepo,
        alertRepo: alertRepo,
      );
    });

    test(
      'Wrong passphrase throws DecryptionException and does not reveal data',
      () async {
        final now = DateTime(2026, 8, 22);
        final acc = Account(
          id: 'acc_1',
          name: 'Main Bank',
          type: AccountType.bank,
          openingBalance: 1000.0,
          currentBalance: 1000.0,
          currency: 'INR',
          createdAt: now,
          updatedAt: now,
        );
        await accountRepo.saveAccount(acc);

        final backupStr = await backupService.createEncryptedBackup(
          passphrase: 'CorrectPassword123!',
        );

        expect(
          () => BackupService.decryptAndPreview(
            backupFileContent: backupStr,
            passphrase: 'WrongPassword456!',
          ),
          throwsA(isA<DecryptionException>()),
        );
      },
    );

    test(
      'Tampered or corrupted ciphertext throws DecryptionException',
      () async {
        final now = DateTime(2026, 8, 22);
        await accountRepo.saveAccount(
          Account(
            id: 'acc_1',
            name: 'Main Bank',
            type: AccountType.bank,
            openingBalance: 1000.0,
            currentBalance: 1000.0,
            currency: 'INR',
            createdAt: now,
            updatedAt: now,
          ),
        );

        final backupStr = await backupService.createEncryptedBackup(
          passphrase: 'Password123!',
        );

        final envelope = jsonDecode(backupStr) as Map<String, dynamic>;
        // Tamper ciphertext
        final rawCipher = base64Decode(envelope['ciphertext'] as String);
        rawCipher[0] ^= 0xFF; // Flip bit
        envelope['ciphertext'] = base64Encode(rawCipher);

        final tamperedBackupStr = jsonEncode(envelope);

        expect(
          () => BackupService.decryptAndPreview(
            backupFileContent: tamperedBackupStr,
            passphrase: 'Password123!',
          ),
          throwsA(isA<DecryptionException>()),
        );
      },
    );

    test(
      'Tampered HMAC authentication tag throws DecryptionException',
      () async {
        final now = DateTime(2026, 8, 22);
        await accountRepo.saveAccount(
          Account(
            id: 'acc_1',
            name: 'Main Bank',
            type: AccountType.bank,
            openingBalance: 1000.0,
            currentBalance: 1000.0,
            currency: 'INR',
            createdAt: now,
            updatedAt: now,
          ),
        );

        final backupStr = await backupService.createEncryptedBackup(
          passphrase: 'Password123!',
        );

        final envelope = jsonDecode(backupStr) as Map<String, dynamic>;
        final rawHmac = base64Decode(envelope['hmac'] as String);
        rawHmac[0] ^= 0xAA;
        envelope['hmac'] = base64Encode(rawHmac);

        final tamperedBackupStr = jsonEncode(envelope);

        expect(
          () => BackupService.decryptAndPreview(
            backupFileContent: tamperedBackupStr,
            passphrase: 'Password123!',
          ),
          throwsA(isA<DecryptionException>()),
        );
      },
    );

    test('Malformed or truncated backup string throws DecryptionException', () {
      expect(
        () => BackupService.decryptAndPreview(
          backupFileContent: '{ "invalid": "json format" }',
          passphrase: 'Password123!',
        ),
        throwsA(isA<DecryptionException>()),
      );

      expect(
        () => BackupService.decryptAndPreview(
          backupFileContent: 'not even json',
          passphrase: 'Password123!',
        ),
        throwsA(isA<DecryptionException>()),
      );
    });

    test(
      'Empty database creates valid authenticated backup and restores safely',
      () async {
        final backupStr = await backupService.createEncryptedBackup(
          passphrase: 'EmptyDbPassword!',
        );

        final preview = BackupService.decryptAndPreview(
          backupFileContent: backupStr,
          passphrase: 'EmptyDbPassword!',
        );

        expect(preview.transactions, isEmpty);
        expect(preview.accounts, isEmpty);

        final result = await backupService.executeRestore(
          payload: preview,
          mode: RestoreMode.replace,
        );

        expect(result.isSuccess, isTrue);
        expect(result.restoredTransactions, 0);
      },
    );

    test(
      'Large dataset encrypts and restores accurately without data loss',
      () async {
        final now = DateTime(2026, 8, 22);

        // Create 100 transactions
        final List<Transaction> txList = [];
        for (int i = 0; i < 100; i++) {
          txList.add(
            Transaction(
              id: 'tx_large_$i',
              amount: 100.0 + (i * 10),
              type:
                  i % 4 == 0 ? TransactionType.income : TransactionType.expense,
              categoryId: 'cat_${i % 5}',
              categoryName: 'Category ${i % 5}',
              categoryIcon: 'shopping_bag',
              categoryColor: 'clay',
              merchant: 'Merchant $i',
              date: now.subtract(Duration(days: i)),
              accountId: 'acc_main',
              isReviewed: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
        await transactionRepo.saveTransactions(txList);

        final backupStr = await backupService.createEncryptedBackup(
          passphrase: 'LargeDatasetKey!',
        );

        final preview = BackupService.decryptAndPreview(
          backupFileContent: backupStr,
          passphrase: 'LargeDatasetKey!',
        );

        expect(preview.transactions.length, 100);

        // Restore into clean repos
        final cleanTxRepo = FakeTransactionRepository();
        final cleanService = BackupService(
          accountRepo: FakeAccountRepository(),
          transactionRepo: cleanTxRepo,
          categoryRepo: FakeCategoryRepository(),
          budgetRepo: FakeBudgetRepository(),
          goalRepo: FakeSavingsGoalRepository(),
          subscriptionRepo: FakeSubscriptionRepository(),
          loanRepo: FakeLoanRepository(),
          investmentRepo: FakeInvestmentRepository(),
          alertRepo: FakeAlertRepository(),
        );

        final restoreResult = await cleanService.executeRestore(
          payload: preview,
          mode: RestoreMode.replace,
        );

        expect(restoreResult.isSuccess, isTrue);
        expect(restoreResult.restoredTransactions, 100);
        expect((await cleanTxRepo.getAllTransactions()).length, 100);
      },
    );
  });
}
