import 'dart:convert';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/backup_payload.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupService Encryption & Decryption Tests', () {
    final now = DateTime(2026, 8, 15);

    test('PBKDF2 key derivation derives deterministic 32-byte keys', () {
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final key1 = BackupService.deriveKey(
        'secretPassphrase123',
        salt,
        iterations: 100,
      );
      final key2 = BackupService.deriveKey(
        'secretPassphrase123',
        salt,
        iterations: 100,
      );
      final keyDifferent = BackupService.deriveKey(
        'otherPassphrase',
        salt,
        iterations: 100,
      );

      expect(key1.length, equals(32));
      expect(key1, equals(key2));
      expect(key1, isNot(equals(keyDifferent)));
    });

    test(
      'Full serialization -> mock envelope -> decryption cycle recovers dataset accurately',
      () {
        final accounts = [
          Account(
            id: 'acc_1',
            name: 'HDFC Savings',
            type: AccountType.bank,
            openingBalance: 10000.0,
            currentBalance: 15000.0,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final transactions = [
          Transaction(
            id: 'tx_1',
            amount: 500.0,
            type: TransactionType.expense,
            purpose: TransactionPurpose.lending,
            direction: AccountMovementDirection.outflow,
            externalCounterpartyName: 'Asha',
            linkedMoneyRecordId: 'debt_1',
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Swiggy',
            date: now,
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final payload = BackupDataPayload(
          metadata: BackupMetadata(
            createdAt: now,
            transactionCount: transactions.length,
            accountCount: accounts.length,
            budgetCount: 0,
            goalCount: 0,
            subscriptionCount: 0,
            loanCount: 0,
            investmentCount: 0,
          ),
          accounts: accounts,
          transactions: transactions,
        );

        final rawJson = jsonEncode(payload.toJson());
        final recovered = BackupDataPayload.fromJson(
          jsonDecode(rawJson) as Map<String, dynamic>,
        );

        expect(recovered.accounts.length, equals(1));
        expect(recovered.accounts.first.name, equals('HDFC Savings'));
        expect(recovered.transactions.length, equals(1));
        expect(recovered.transactions.first.merchant, equals('Swiggy'));
        expect(recovered.transactions.first.amount, equals(500.0));
        expect(
          recovered.transactions.first.purpose,
          TransactionPurpose.lending,
        );
        expect(recovered.transactions.first.externalCounterpartyName, 'Asha');
        expect(recovered.transactions.first.linkedMoneyRecordId, 'debt_1');
      },
    );

    test('older backup transactions derive semantics without new fields', () {
      final old = <String, dynamic>{
        'metadata': {
          'version': 1,
          'createdAt': now.toIso8601String(),
          'transactionCount': 1,
          'accountCount': 0,
          'budgetCount': 0,
          'goalCount': 0,
          'subscriptionCount': 0,
          'loanCount': 0,
          'investmentCount': 0,
        },
        'transactions': [
          {
            'id': 'legacy_cash',
            'amount': 100,
            'type': 'cash',
            'categoryId': 'legacy',
            'categoryName': 'Cash',
            'categoryIcon': 'cash',
            'categoryColor': 'slate',
            'merchant': 'Legacy cash',
            'date': now.toIso8601String(),
            'accountId': 'cash',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          },
        ],
      };
      final restored = BackupDataPayload.fromJson(old).transactions.single;
      expect(restored.purpose, isNull);
      expect(restored.effectivePurpose, TransactionPurpose.legacyCash);
    });
  });
}
