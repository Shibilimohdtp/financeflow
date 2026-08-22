import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/transaction_merge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionMergeService Tests', () {
    final baseDate = DateTime(2026, 8, 15, 10, 0);

    test(
      'Merges SMS and Notification preserving highest precision data & provenance',
      () {
        final existingTx = Transaction(
          id: 'tx_notif_1',
          amount: 550.0,
          type: TransactionType.expense,
          categoryId: 'health_medical',
          categoryName: 'Health & Medical',
          categoryIcon: 'medical_services',
          categoryColor: 'sage',
          merchant: 'Apollo Pharmacy',
          originalMerchant: 'Apollo Pharmacy Bangalore',
          date: baseDate,
          accountId: 'acc_main',
          source: TransactionSource.notification,
          sourceName: 'Paytm',
          mergedSources: ['Notification: Paytm'],
          createdAt: baseDate,
          updatedAt: baseDate,
        );

        final incomingSms = ParsedTransaction(
          tempId: 'temp_sms_1',
          source: TransactionSource.sms,
          sourceName: 'HDFC Bank',
          amount: 550.0,
          type: TransactionType.expense,
          rawMerchant: 'APOLLO PHARMACY',
          normalizedMerchant: 'Apollo Pharmacy',
          date: baseDate.add(const Duration(minutes: 2)),
          referenceNumber: 'HDFC987654321',
          accountId: 'acc_main',
          categoryId: 'health_medical',
          categoryName: 'Health & Medical',
          categoryIcon: 'medical_services',
          categoryColor: 'sage',
          fingerprint: 'fp_1',
        );

        final merged = TransactionMergeService.mergeWithExisting(
          existing: existingTx,
          incoming: incomingSms,
        );

        expect(merged.id, equals(existingTx.id));
        expect(merged.amount, equals(550.0));
        expect(merged.sourceReference, equals('HDFC987654321'));
        expect(merged.categoryName, equals('Health & Medical'));
        expect(merged.mergedSources.length, equals(2));
        expect(merged.mergedSources.contains('Notification: Paytm'), isTrue);
        expect(merged.mergedSources.contains('SMS: HDFC Bank'), isTrue);
        expect(merged.reviewStatus, equals(ReviewStatus.merged.name));

        final summary = TransactionMergeService.formatProvenanceSummary(merged);
        expect(
          summary,
          contains('Merged from Notification: Paytm + SMS: HDFC Bank'),
        );
      },
    );

    test('Merge combines non-duplicate notes and preserves user edits', () {
      final existingTx = Transaction(
        id: 'tx_user_1',
        amount: 250.0,
        type: TransactionType.expense,
        categoryId: 'food_dining',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Chai Point',
        notes: 'Team evening snacks',
        date: baseDate,
        accountId: 'acc_cash',
        source: TransactionSource.manual,
        mergedSources: ['Manual'],
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final incomingCsv = ParsedTransaction(
        tempId: 'temp_csv_1',
        source: TransactionSource.csv,
        sourceName: 'ICICI Statement',
        amount: 250.0,
        type: TransactionType.expense,
        rawMerchant: 'POS CHAI POINT INDIRANAGAR',
        normalizedMerchant: 'Chai Point',
        notes: 'Chq 000123',
        date: baseDate,
        accountId: 'acc_cash',
        categoryId: 'food_dining',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_2',
      );

      final merged = TransactionMergeService.mergeWithExisting(
        existing: existingTx,
        incoming: incomingCsv,
      );

      expect(merged.categoryName, equals('Food & Dining'));
      expect(merged.notes, contains('Team evening snacks'));
      expect(merged.notes, contains('Chq 000123'));
      expect(merged.mergedSources.contains('Manual'), isTrue);
      expect(merged.mergedSources.contains('CSV: ICICI Statement'), isTrue);
    });
  });
}
