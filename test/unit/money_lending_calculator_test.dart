import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/services/money_lending_calculator.dart';

void main() {
  group('MoneyLendingCalculator Tests', () {
    final now = DateTime(2026, 3, 15, 10, 0);

    final record1Lent = MoneyRecord(
      id: 'rec_1',
      type: MoneyRecordType.lent,
      personName: 'Ahmed',
      originalAmount: 10000.0,
      transactionDate: DateTime(2026, 2, 1),
      dueDate: DateTime(2026, 3, 1), // Overdue as of 15 Mar
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

    final record2Lent = MoneyRecord(
      id: 'rec_2',
      type: MoneyRecordType.lent,
      personName: 'Sarah',
      originalAmount: 5000.0,
      transactionDate: DateTime(2026, 3, 1),
      dueDate: DateTime(2026, 3, 20), // Due soon (within 7 days of 15 Mar)
      createdAt: DateTime(2026, 3, 1),
      updatedAt: DateTime(2026, 3, 1),
    );

    final record3Borrowed = MoneyRecord(
      id: 'rec_3',
      type: MoneyRecordType.borrowed,
      personName: 'Uncle John',
      originalAmount: 8000.0,
      transactionDate: DateTime(2026, 3, 10),
      dueDate: DateTime(2026, 4, 15), // Active, not due soon
      createdAt: DateTime(2026, 3, 10),
      updatedAt: DateTime(2026, 3, 10),
    );

    final record4Settled = MoneyRecord(
      id: 'rec_4',
      type: MoneyRecordType.lent,
      personName: 'Priya',
      originalAmount: 2000.0,
      transactionDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 2, 1),
      settledAt: DateTime(2026, 2, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

    final repayments = [
      MoneyRepayment(
        id: 'rep_1',
        moneyRecordId: 'rec_1',
        amount: 3000.0,
        repaymentDate: DateTime(2026, 2, 15),
        createdAt: DateTime(2026, 2, 15),
      ),
      MoneyRepayment(
        id: 'rep_2',
        moneyRecordId: 'rec_4',
        amount: 2000.0,
        repaymentDate: DateTime(2026, 2, 1),
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    test('calculates remaining amount correctly', () {
      expect(record1Lent.calculateRemainingAmount(repayments), 7000.0);
      expect(record2Lent.calculateRemainingAmount(repayments), 5000.0);
      expect(record3Borrowed.calculateRemainingAmount(repayments), 8000.0);
      expect(record4Settled.calculateRemainingAmount(repayments), 0.0);
    });

    test('calculates total repaid correctly', () {
      expect(record1Lent.calculateTotalRepaid(repayments), 3000.0);
      expect(record2Lent.calculateTotalRepaid(repayments), 0.0);
      expect(record4Settled.calculateTotalRepaid(repayments), 2000.0);
    });

    test('detects overdue and due soon statuses correctly', () {
      expect(
        record1Lent.isOverdue(asOfDate: now, repayments: repayments),
        true,
      );
      expect(
        record2Lent.isOverdue(asOfDate: now, repayments: repayments),
        false,
      );
      expect(
        record2Lent.isDueSoon(
          asOfDate: now,
          thresholdDays: 7,
          repayments: repayments,
        ),
        true,
      );
      expect(
        record3Borrowed.isDueSoon(
          asOfDate: now,
          thresholdDays: 7,
          repayments: repayments,
        ),
        false,
      );
      expect(
        record4Settled.isOverdue(asOfDate: now, repayments: repayments),
        false,
      );
    });

    test('calculates status enum correctly', () {
      expect(
        record1Lent.calculateStatus(repayments, asOfDate: now),
        MoneyRecordStatus.overdue,
      );
      expect(
        record2Lent.calculateStatus(repayments, asOfDate: now),
        MoneyRecordStatus.dueSoon,
      );
      expect(
        record3Borrowed.calculateStatus(repayments, asOfDate: now),
        MoneyRecordStatus.active,
      );
      expect(
        record4Settled.calculateStatus(repayments, asOfDate: now),
        MoneyRecordStatus.settled,
      );
    });

    test('calculates summary metrics accurately', () {
      final summary = MoneyLendingCalculator.calculateSummary(
        [record1Lent, record2Lent, record3Borrowed, record4Settled],
        repayments,
        asOfDate: now,
      );

      expect(summary.totalLent, 17000.0); // 10000 + 5000 + 2000
      expect(summary.totalBorrowed, 8000.0);
      expect(summary.totalOwedToMe, 12000.0); // 7000 (rec1) + 5000 (rec2)
      expect(summary.totalIOwe, 8000.0);
      expect(summary.overdueOwedToMe, 7000.0);
      expect(summary.overdueIOwe, 0.0);
      expect(summary.dueSoonOwedToMe, 5000.0);
      expect(summary.dueSoonIOwe, 0.0);
      expect(summary.activeLentCount, 2);
      expect(summary.activeBorrowedCount, 1);
      expect(summary.unsettledCount, 3);
      expect(summary.settledCount, 1);
      expect(summary.overdueCount, 1);
      expect(summary.dueSoonCount, 1);
    });

    test(
      'sorts records with overdue first, then nearest due date, settled last',
      () {
        final records = [
          record4Settled,
          record3Borrowed,
          record2Lent,
          record1Lent,
        ];
        final sorted = MoneyLendingCalculator.sortRecords(
          records,
          repayments,
          asOfDate: now,
        );

        expect(sorted[0].id, 'rec_1'); // Overdue
        expect(sorted[1].id, 'rec_2'); // Due 20 Mar
        expect(sorted[2].id, 'rec_3'); // Due 15 Apr
        expect(sorted[3].id, 'rec_4'); // Settled
      },
    );

    test('filters records by tab filters', () {
      final all = [record1Lent, record2Lent, record3Borrowed, record4Settled];

      final owedToMe = MoneyLendingCalculator.filterRecords(
        all,
        repayments,
        MoneyRecordFilter.owedToMe,
        asOfDate: now,
      );
      expect(owedToMe.length, 3);

      final iOwe = MoneyLendingCalculator.filterRecords(
        all,
        repayments,
        MoneyRecordFilter.iOwe,
        asOfDate: now,
      );
      expect(iOwe.length, 1);
      expect(iOwe.first.id, 'rec_3');

      final overdue = MoneyLendingCalculator.filterRecords(
        all,
        repayments,
        MoneyRecordFilter.overdue,
        asOfDate: now,
      );
      expect(overdue.length, 1);
      expect(overdue.first.id, 'rec_1');

      final dueSoon = MoneyLendingCalculator.filterRecords(
        all,
        repayments,
        MoneyRecordFilter.dueSoon,
        asOfDate: now,
      );
      expect(dueSoon.length, 1);
      expect(dueSoon.first.id, 'rec_2');

      final settled = MoneyLendingCalculator.filterRecords(
        all,
        repayments,
        MoneyRecordFilter.settled,
        asOfDate: now,
      );
      expect(settled.length, 1);
      expect(settled.first.id, 'rec_4');
    });
  });
}
