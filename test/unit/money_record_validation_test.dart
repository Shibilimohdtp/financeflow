import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';

void main() {
  group('MoneyRecord & MoneyRepayment Validation Tests', () {
    final validDate = DateTime(2026, 3, 1);
    final validDueDate = DateTime(2026, 3, 15);

    test('validates successfully with correct data', () {
      final record = MoneyRecord(
        id: 'rec_1',
        type: MoneyRecordType.lent,
        personName: 'Ahmed',
        originalAmount: 5000.0,
        transactionDate: validDate,
        dueDate: validDueDate,
        createdAt: validDate,
        updatedAt: validDate,
      );

      expect(() => record.validate(), returnsNormally);
    });

    test('throws ValidationError when person name is empty or whitespace', () {
      final record = MoneyRecord(
        id: 'rec_1',
        type: MoneyRecordType.lent,
        personName: '   ',
        originalAmount: 5000.0,
        transactionDate: validDate,
        dueDate: validDueDate,
        createdAt: validDate,
        updatedAt: validDate,
      );

      expect(() => record.validate(), throwsA(isA<ValidationError>()));
    });

    test('throws ValidationError when amount is zero or negative', () {
      final recordZero = MoneyRecord(
        id: 'rec_1',
        type: MoneyRecordType.lent,
        personName: 'Ahmed',
        originalAmount: 0.0,
        transactionDate: validDate,
        dueDate: validDueDate,
        createdAt: validDate,
        updatedAt: validDate,
      );

      final recordNegative = recordZero.copyWith(originalAmount: -100.0);

      expect(() => recordZero.validate(), throwsA(isA<ValidationError>()));
      expect(() => recordNegative.validate(), throwsA(isA<ValidationError>()));
    });

    test('throws ValidationError when due date is before transaction date', () {
      final record = MoneyRecord(
        id: 'rec_1',
        type: MoneyRecordType.lent,
        personName: 'Ahmed',
        originalAmount: 5000.0,
        transactionDate: DateTime(2026, 3, 15),
        dueDate: DateTime(2026, 3, 1), // Before transaction date
        createdAt: validDate,
        updatedAt: validDate,
      );

      expect(() => record.validate(), throwsA(isA<ValidationError>()));
    });

    test('validates repayment correctly', () {
      final validRepayment = MoneyRepayment(
        id: 'rep_1',
        moneyRecordId: 'rec_1',
        amount: 2000.0,
        repaymentDate: validDate,
        createdAt: validDate,
      );

      expect(() => validRepayment.validate(remainingBalance: 5000.0), returnsNormally);

      final zeroRepayment = validRepayment.copyWith(amount: 0.0);
      expect(
        () => zeroRepayment.validate(remainingBalance: 5000.0),
        throwsA(isA<ValidationError>()),
      );

      final excessRepayment = validRepayment.copyWith(amount: 6000.0);
      expect(
        () => excessRepayment.validate(remainingBalance: 5000.0),
        throwsA(isA<ValidationError>()),
      );
    });

    test('serializes and deserializes MoneyRecord to/from JSON correctly', () {
      final original = MoneyRecord(
        id: 'rec_json_1',
        userId: 'user_123',
        type: MoneyRecordType.borrowed,
        personName: 'Uncle Bob',
        originalAmount: 15000.50,
        transactionDate: DateTime(2026, 1, 10, 14, 30),
        dueDate: DateTime(2026, 4, 10, 14, 30),
        notes: 'House maintenance assistance',
        isReminderEnabled: true,
        reminderDaysBefore: 3,
        createdAt: DateTime(2026, 1, 10, 14, 30),
        updatedAt: DateTime(2026, 1, 10, 14, 30),
      );

      final json = original.toJson();
      final deserialized = MoneyRecord.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.userId, original.userId);
      expect(deserialized.type, original.type);
      expect(deserialized.personName, original.personName);
      expect(deserialized.originalAmount, original.originalAmount);
      expect(deserialized.notes, original.notes);
      expect(deserialized.reminderDaysBefore, 3);
    });

    test('serializes and deserializes MoneyRepayment to/from JSON correctly', () {
      final original = MoneyRepayment(
        id: 'rep_json_1',
        moneyRecordId: 'rec_json_1',
        userId: 'user_123',
        amount: 4500.75,
        repaymentDate: DateTime(2026, 2, 1, 10, 0),
        notes: 'UPI part payment',
        createdAt: DateTime(2026, 2, 1, 10, 0),
      );

      final json = original.toJson();
      final deserialized = MoneyRepayment.fromJson(json);

      expect(deserialized.id, original.id);
      expect(deserialized.moneyRecordId, original.moneyRecordId);
      expect(deserialized.amount, original.amount);
      expect(deserialized.notes, original.notes);
    });
  });
}
