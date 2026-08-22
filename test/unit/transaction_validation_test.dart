import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/models/transaction.dart';

void main() {
  group('Transaction Validation Tests', () {
    final now = DateTime.now();

    test('Valid transaction passes validation', () {
      final tx = Transaction(
        id: 't1',
        amount: 430.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Swiggy',
        date: now,
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(() => tx.validate(), returnsNormally);
    });

    test('Throws ValidationError when amount <= 0', () {
      final tx = Transaction(
        id: 't1',
        amount: 0.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Swiggy',
        date: now,
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(() => tx.validate(), throwsA(isA<ValidationError>()));
    });

    test('Throws ValidationError when merchant is empty', () {
      final tx = Transaction(
        id: 't1',
        amount: 430.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: '   ',
        date: now,
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(() => tx.validate(), throwsA(isA<ValidationError>()));
    });

    test('Throws ValidationError when account is empty', () {
      final tx = Transaction(
        id: 't1',
        amount: 430.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Swiggy',
        date: now,
        accountId: '',
        createdAt: now,
        updatedAt: now,
      );

      expect(() => tx.validate(), throwsA(isA<ValidationError>()));
    });

    test(
      'Throws ValidationError when transfer source and destination are identical',
      () {
        final tx = Transaction(
          id: 't1',
          amount: 1000.0,
          type: TransactionType.transfer,
          categoryId: 'cat_transfer',
          categoryName: 'Transfer',
          categoryIcon: 'sync',
          categoryColor: 'slate',
          merchant: 'Self Transfer',
          date: now,
          accountId: 'acc_1',
          toAccountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        );

        expect(() => tx.validate(), throwsA(isA<ValidationError>()));
      },
    );
  });
}
