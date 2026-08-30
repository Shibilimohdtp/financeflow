import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/models/money_advance.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';

void main() {
  group('MoneyAdvance Unit & FIFO Allocation Tests', () {
    final t1 = DateTime(2026, 3, 1, 10, 0);
    final t2 = DateTime(2026, 3, 5, 14, 0);
    final due1 = DateTime(2026, 3, 20);
    final due2 = DateTime(2026, 3, 30);

    test('validates successfully with positive amount', () {
      final advance = MoneyAdvance(
        id: 'adv_1',
        moneyRecordId: 'rec_1',
        amount: 2500.0,
        date: t1,
        dueDate: due1,
        notes: 'Dinner and taxi',
      );

      expect(() => advance.validate(), returnsNormally);
    });

    test('throws ValidationError when advance amount is zero or negative', () {
      final advZero = MoneyAdvance(
        id: 'adv_1',
        moneyRecordId: 'rec_1',
        amount: 0.0,
        date: t1,
        dueDate: due1,
      );
      final advNeg = advZero.copyWith(amount: -50.0);

      expect(() => advZero.validate(), throwsA(isA<ValidationError>()));
      expect(() => advNeg.validate(), throwsA(isA<ValidationError>()));
    });

    test('serializes and deserializes MoneyAdvance to/from JSON correctly', () {
      final original = MoneyAdvance(
        id: 'adv_100',
        moneyRecordId: 'rec_100',
        userId: 'user_1',
        amount: 300.0,
        date: t2,
        dueDate: due2,
        notes: 'Coffee',
        accountId: 'bank_acc',
        transactionId: 'tx_123',
        createdAt: t2,
        updatedAt: t2,
      );

      final json = original.toJson();
      final parsed = MoneyAdvance.fromJson(json);

      expect(parsed.id, original.id);
      expect(parsed.moneyRecordId, original.moneyRecordId);
      expect(parsed.amount, original.amount);
      expect(parsed.date, original.date);
      expect(parsed.dueDate, original.dueDate);
      expect(parsed.notes, original.notes);
      expect(parsed.accountId, original.accountId);
      expect(parsed.transactionId, original.transactionId);
    });

    test(
      'calculates total advanced and remaining amount across multi-advances',
      () {
        final record = MoneyRecord(
          id: 'rec_menon',
          type: MoneyRecordType.lent,
          personName: 'Menon',
          normalizedPersonName: 'menon',
          originalAmount: 2800.0,
          transactionDate: t1,
          dueDate: due1,
          createdAt: t1,
          updatedAt: t2,
        );

        final advances = [
          MoneyAdvance(
            id: 'adv_1',
            moneyRecordId: 'rec_menon',
            amount: 2500.0,
            date: t1,
            dueDate: due1,
          ),
          MoneyAdvance(
            id: 'adv_2',
            moneyRecordId: 'rec_menon',
            amount: 300.0,
            date: t2,
            dueDate: due2,
          ),
        ];

        final repayments = [
          MoneyRepayment(
            id: 'rep_1',
            moneyRecordId: 'rec_menon',
            amount: 1000.0,
            repaymentDate: DateTime(2026, 3, 10),
            createdAt: DateTime(2026, 3, 10),
          ),
        ];

        expect(record.calculateTotalAdvanced(advances), 2800.0);
        expect(record.calculateTotalRepaid(repayments), 1000.0);
        expect(
          record.calculateRemainingAmount(repayments, advances: advances),
          1800.0,
        );
        expect(record.isFullySettled(repayments, advances: advances), false);
      },
    );

    test(
      'FIFO allocation correctly allocates repayments against ordered advances',
      () {
        final record = MoneyRecord(
          id: 'rec_menon',
          type: MoneyRecordType.lent,
          personName: 'Menon',
          normalizedPersonName: 'menon',
          originalAmount: 2800.0,
          transactionDate: t1,
          dueDate: due1,
          createdAt: t1,
          updatedAt: t2,
        );

        final advances = [
          MoneyAdvance(
            id: 'adv_1',
            moneyRecordId: 'rec_menon',
            amount: 2500.0,
            date: t1,
            dueDate: due1,
          ),
          MoneyAdvance(
            id: 'adv_2',
            moneyRecordId: 'rec_menon',
            amount: 300.0,
            date: t2,
            dueDate: due2,
          ),
        ];

        // Repayment of 2600 should completely cover adv_1 (2500) and cover 100 of adv_2 (leaving 200)
        final repayments = [
          MoneyRepayment(
            id: 'rep_1',
            moneyRecordId: 'rec_menon',
            amount: 2600.0,
            repaymentDate: DateTime(2026, 3, 10),
            createdAt: DateTime(2026, 3, 10),
          ),
        ];

        final allocations = record.calculateAllocatedAdvances(
          advances: advances,
          repayments: repayments,
        );

        expect(allocations.length, 2);
        expect(allocations[0].advance.id, 'adv_1');
        expect(allocations[0].allocatedRepaid, 2500.0);
        expect(allocations[0].isFullyPaid, true);
        expect(allocations[0].remainingAmount, 0.0);

        expect(allocations[1].advance.id, 'adv_2');
        expect(allocations[1].allocatedRepaid, 100.0);
        expect(allocations[1].isFullyPaid, false);
        expect(allocations[1].remainingAmount, 200.0);

        // Effective due date should be adv_2's due date since adv_1 is paid
        expect(
          record.calculateEffectiveDueDate(
            advances: advances,
            repayments: repayments,
          ),
          due2,
        );
      },
    );

    test('name normalization produces expected canonical keys', () {
      expect(
        MoneyRecord.normalizePersonName('  Anitha   Menon T.  '),
        'anitha menon t',
      );
      expect(MoneyRecord.normalizePersonName('menon'), 'menon');
      expect(MoneyRecord.normalizePersonName('Dr. John Doe'), 'dr john doe');
    });
  });
}
