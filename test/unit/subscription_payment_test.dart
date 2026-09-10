import 'package:financeflow/models/backup_payload.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDate = DateTime(2026, 9, 10, 12, 0);

  group('Subscription Payment Model & Semantics', () {
    test('TransactionPurpose.subscriptionPayment enum properties', () {
      const purpose = TransactionPurpose.subscriptionPayment;
      expect(purpose.displayName, 'Subscription payment');
      expect(purpose.name, 'subscriptionPayment');
      expect(
        TransactionPurpose.fromString('subscriptionPayment'),
        TransactionPurpose.subscriptionPayment,
      );
      expect(TransactionPurpose.fromString('unknown_purpose'), isNull);
    });

    test('Transaction with linkedSubscriptionId behaves as linked operation', () {
      final tx = Transaction(
        id: 'tx_sub_1',
        amount: 299.0,
        type: TransactionType.expense,
        purpose: TransactionPurpose.subscriptionPayment,
        categoryId: 'cat_entertainment',
        categoryName: 'Entertainment',
        categoryIcon: 'movie',
        categoryColor: '#FF0000',
        merchant: 'Netflix',
        date: testDate,
        accountId: 'acc_bank_1',
        linkedSubscriptionId: 'sub_netflix_123',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(tx.isLinkedOperation, isTrue);
      expect(tx.linkedSubscriptionId, 'sub_netflix_123');
      expect(tx.consumptionExpenseAmount, 299.0);
      expect(tx.cashOutflowAmount, 299.0);
      expect(tx.earnedIncomeAmount, 0.0);
      expect(tx.cashInflowAmount, 0.0);
    });

    test('Transaction.copyWith handles linkedSubscriptionId properly', () {
      final tx = Transaction(
        id: 'tx_sub_2',
        amount: 199.0,
        type: TransactionType.expense,
        purpose: TransactionPurpose.subscriptionPayment,
        categoryId: 'cat_music',
        categoryName: 'Music',
        categoryIcon: 'music',
        categoryColor: '#00FF00',
        merchant: 'Spotify',
        date: testDate,
        accountId: 'acc_bank_1',
        linkedSubscriptionId: 'sub_spotify_456',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Preserve existing
      final copiedSame = tx.copyWith(amount: 219.0);
      expect(copiedSame.linkedSubscriptionId, 'sub_spotify_456');
      expect(copiedSame.amount, 219.0);

      // Change linked subscription
      final copiedNew = tx.copyWith(linkedSubscriptionId: 'sub_spotify_789');
      expect(copiedNew.linkedSubscriptionId, 'sub_spotify_789');
    });
  });

  group('Backup & Restore serialization for linkedSubscriptionId', () {
    test('Round-trip JSON serialization preserves linkedSubscriptionId', () {
      final originalTx = Transaction(
        id: 'tx_sub_backup_1',
        amount: 499.0,
        type: TransactionType.expense,
        purpose: TransactionPurpose.subscriptionPayment,
        categoryId: 'cat_cloud',
        categoryName: 'Cloud Storage',
        categoryIcon: 'cloud',
        categoryColor: '#0000FF',
        merchant: 'Google One',
        date: testDate,
        accountId: 'acc_bank_1',
        linkedSubscriptionId: 'sub_google_one',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final metadata = BackupMetadata(
        formatVersion: 2,
        appVersion: '1.0.0',
        createdAt: testDate,
        transactionCount: 1,
        accountCount: 0,
        budgetCount: 0,
        goalCount: 0,
        subscriptionCount: 0,
        loanCount: 0,
        investmentCount: 0,
      );

      final payload = BackupDataPayload(
        metadata: metadata,
        transactions: [originalTx],
      );

      final jsonMap = payload.toJson();
      final restoredPayload = BackupDataPayload.fromJson(jsonMap);

      expect(restoredPayload.transactions.length, 1);
      final restoredTx = restoredPayload.transactions.first;
      expect(restoredTx.id, originalTx.id);
      expect(restoredTx.purpose, TransactionPurpose.subscriptionPayment);
      expect(restoredTx.linkedSubscriptionId, 'sub_google_one');
      expect(restoredTx.amount, 499.0);
    });

    test('Old backup JSON without linkedSubscriptionId restores cleanly to null', () {
      final legacyTxJson = {
        'id': 'tx_legacy_1',
        'amount': 150.0,
        'type': 'expense',
        'categoryId': 'cat_groceries',
        'categoryName': 'Groceries',
        'categoryIcon': 'shopping',
        'categoryColor': '#FFCC00',
        'merchant': 'Supermarket',
        'date': testDate.toIso8601String(),
        'source': 'manual',
        'accountId': 'acc_cash_1',
        'purpose': 'expense',
        'isReviewed': true,
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
      };

      final payloadJson = {
        'metadata': {
          'formatVersion': 1,
          'appVersion': '1.0.0',
          'createdAt': testDate.toIso8601String(),
          'transactionCount': 1,
        },
        'transactions': [legacyTxJson],
      };

      final restoredPayload = BackupDataPayload.fromJson(payloadJson);
      expect(restoredPayload.transactions.length, 1);
      final restoredTx = restoredPayload.transactions.first;
      expect(restoredTx.id, 'tx_legacy_1');
      expect(restoredTx.linkedSubscriptionId, isNull);
    });
  });

  group('subscriptionPaymentsTotalProvider', () {
    test('Calculates total, count, and lastPaymentDate from linked transactions', () async {
      final container = ProviderContainer(
        overrides: [
          subscriptionPaymentsStreamProvider('sub_1').overrideWith(
            (ref) => Stream.value([
              Transaction(
                id: 'tx_1',
                amount: 300.0,
                type: TransactionType.expense,
                purpose: TransactionPurpose.subscriptionPayment,
                categoryId: 'cat_1',
                categoryName: 'Cat',
                categoryIcon: 'icon',
                categoryColor: 'color',
                merchant: 'Merchant',
                date: DateTime(2026, 9, 10),
                accountId: 'acc_1',
                linkedSubscriptionId: 'sub_1',
                createdAt: DateTime(2026, 9, 10),
                updatedAt: DateTime(2026, 9, 10),
              ),
              Transaction(
                id: 'tx_2',
                amount: 200.0,
                type: TransactionType.expense,
                purpose: TransactionPurpose.subscriptionPayment,
                categoryId: 'cat_1',
                categoryName: 'Cat',
                categoryIcon: 'icon',
                categoryColor: 'color',
                merchant: 'Merchant',
                date: DateTime(2026, 8, 10),
                accountId: 'acc_1',
                linkedSubscriptionId: 'sub_1',
                createdAt: DateTime(2026, 8, 10),
                updatedAt: DateTime(2026, 8, 10),
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subscriptionPaymentsStreamProvider('sub_1').future);

      final summary = container.read(subscriptionPaymentsTotalProvider('sub_1'));
      expect(summary.totalPaid, 500.0);
      expect(summary.count, 2);
      expect(summary.lastPaymentDate, DateTime(2026, 9, 10));
    });

    test('Returns zeros when subscription has no linked transactions', () async {
      final container = ProviderContainer(
        overrides: [
          subscriptionPaymentsStreamProvider('sub_empty').overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(subscriptionPaymentsStreamProvider('sub_empty').future);

      final summary = container.read(subscriptionPaymentsTotalProvider('sub_empty'));
      expect(summary.totalPaid, 0.0);
      expect(summary.count, 0);
      expect(summary.lastPaymentDate, isNull);
    });
  });
}
