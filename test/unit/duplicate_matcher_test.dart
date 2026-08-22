import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/duplicate_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DuplicateMatcher Tests', () {
    final now = DateTime(2026, 8, 15, 14, 30);

    final existingT1 = Transaction(
      id: 'tx_existing_1',
      amount: 450.0,
      type: TransactionType.expense,
      categoryId: 'food_dining',
      categoryName: 'Food & Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      merchant: 'Swiggy',
      originalMerchant: 'SWIGGY BANGALORE',
      sourceReference: 'UTR123456789012',
      date: now,
      accountId: 'acc_hdfc',
      source: TransactionSource.sms,
      sourceName: 'HDFC Bank',
      createdAt: now,
      updatedAt: now,
    );

    final existingT2 = Transaction(
      id: 'tx_existing_2',
      amount: 1299.50,
      type: TransactionType.expense,
      categoryId: 'shopping',
      categoryName: 'Shopping',
      categoryIcon: 'shopping_bag',
      categoryColor: 'marigold',
      merchant: 'Amazon',
      originalMerchant: 'AMAZON PAY INDIA',
      date: now,
      accountId: 'acc_hdfc',
      source: TransactionSource.manual,
      createdAt: now,
      updatedAt: now,
    );

    test('Exact match by reference number / UTR', () {
      final incoming = ParsedTransaction(
        tempId: 'temp_1',
        source: TransactionSource.notification,
        sourceName: 'Google Pay',
        amount: 450.0,
        type: TransactionType.expense,
        rawMerchant: 'Swiggy Order',
        normalizedMerchant: 'Swiggy',
        date: now.add(const Duration(minutes: 5)),
        referenceNumber: 'UTR123456789012',
        accountId: 'acc_hdfc',
        categoryId: 'food_dining',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_1',
      );

      final match = DuplicateMatcher.findDuplicate(
        incoming: incoming,
        existingTransactions: [existingT1, existingT2],
      );

      expect(match.level, equals(DuplicateMatchLevel.exact));
      expect(match.confidence, equals(1.0));
      expect(match.matchedTransaction?.id, equals(existingT1.id));
      expect(match.reasons.any((r) => r.contains('reference')), isTrue);
    });

    test(
      'Exact match by same calendar day, exact amount, and canonical merchant',
      () {
        final incoming = ParsedTransaction(
          tempId: 'temp_2',
          source: TransactionSource.csv,
          amount: 1299.50,
          type: TransactionType.expense,
          rawMerchant: 'Amazon Retail',
          normalizedMerchant: 'Amazon',
          date: now,
          accountId: 'acc_hdfc',
          categoryId: 'shopping',
          categoryName: 'Shopping',
          categoryIcon: 'shopping_bag',
          categoryColor: 'marigold',
          fingerprint: 'fp_2',
        );

        final match = DuplicateMatcher.findDuplicate(
          incoming: incoming,
          existingTransactions: [existingT1, existingT2],
        );

        expect(match.level, equals(DuplicateMatchLevel.exact));
        expect(match.confidence, greaterThanOrEqualTo(0.95));
        expect(match.matchedTransaction?.id, equals(existingT2.id));
      },
    );

    test(
      'Likely match when amount matches, date is within 24h, and fuzzy merchant match is high',
      () {
        final incoming = ParsedTransaction(
          tempId: 'temp_3',
          source: TransactionSource.notification,
          amount: 450.0,
          type: TransactionType.expense,
          rawMerchant: 'Swiggy Delivery App',
          normalizedMerchant: 'Swiggy',
          date: now.add(const Duration(hours: 18)),
          accountId: 'acc_hdfc',
          categoryId: 'food_dining',
          categoryName: 'Food & Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          fingerprint: 'fp_3',
        );

        final match = DuplicateMatcher.findDuplicate(
          incoming: incoming,
          existingTransactions: [existingT1],
        );

        expect(match.level, equals(DuplicateMatchLevel.likely));
        expect(match.confidence, greaterThanOrEqualTo(0.85));
        expect(match.matchedTransaction?.id, equals(existingT1.id));
      },
    );

    test(
      'Possible match when amount matches on same day but merchant description is different',
      () {
        final incoming = ParsedTransaction(
          tempId: 'temp_4',
          source: TransactionSource.csv,
          amount: 450.0,
          type: TransactionType.expense,
          rawMerchant: 'POS TXN STORE X',
          normalizedMerchant: 'Store X',
          date: now,
          accountId: 'acc_hdfc',
          categoryId: 'other',
          categoryName: 'Other',
          categoryIcon: 'help_outline',
          categoryColor: 'sand',
          fingerprint: 'fp_4',
        );

        final match = DuplicateMatcher.findDuplicate(
          incoming: incoming,
          existingTransactions: [existingT1],
        );

        expect(match.level, equals(DuplicateMatchLevel.possible));
        expect(match.confidence, lessThan(0.85));
      },
    );

    test('Not a duplicate when amount differs or direction is opposite', () {
      final incomingDiffAmount = ParsedTransaction(
        tempId: 'temp_5',
        source: TransactionSource.sms,
        amount: 451.0,
        type: TransactionType.expense,
        rawMerchant: 'Swiggy',
        normalizedMerchant: 'Swiggy',
        date: now,
        accountId: 'acc_hdfc',
        categoryId: 'food_dining',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_5',
      );

      final incomingDiffType = ParsedTransaction(
        tempId: 'temp_6',
        source: TransactionSource.sms,
        amount: 450.0,
        type: TransactionType.income,
        rawMerchant: 'Swiggy',
        normalizedMerchant: 'Swiggy',
        date: now,
        accountId: 'acc_hdfc',
        categoryId: 'food_dining',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_6',
      );

      final match1 = DuplicateMatcher.findDuplicate(
        incoming: incomingDiffAmount,
        existingTransactions: [existingT1],
      );
      final match2 = DuplicateMatcher.findDuplicate(
        incoming: incomingDiffType,
        existingTransactions: [existingT1],
      );

      expect(match1.level, equals(DuplicateMatchLevel.none));
      expect(match2.level, equals(DuplicateMatchLevel.none));
    });
  });
}
