import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/services/notifications/notification_scheduler.dart';

void main() {
  group('NotificationScheduler Tests', () {
    test('calculateSubscriptionReminderDate calculates target date and hour correctly', () {
      final now = DateTime(2026, 8, 20, 10, 0);
      final sub = Subscription(
        id: 'sub_1',
        merchant: 'Netflix',
        normalizedMerchant: 'netflix',
        amount: 649,
        nextRenewalDate: DateTime(2026, 8, 25),
        reminderDaysBefore: 2,
        isReminderEnabled: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final scheduled = NotificationScheduler.calculateSubscriptionReminderDate(
        sub,
        referenceDate: now,
        targetHour: 9,
        targetMinute: 30,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.year, equals(2026));
      expect(scheduled.month, equals(8));
      expect(scheduled.day, equals(23)); // 25 - 2 days
      expect(scheduled.hour, equals(9));
      expect(scheduled.minute, equals(30));
    });

    test('calculateSubscriptionReminderDate returns null if reminder date is in the past', () {
      final now = DateTime(2026, 8, 26, 10, 0);
      final sub = Subscription(
        id: 'sub_past',
        merchant: 'Old Sub',
        normalizedMerchant: 'old sub',
        amount: 199,
        nextRenewalDate: DateTime(2026, 8, 25),
        reminderDaysBefore: 1,
        isReminderEnabled: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final scheduled = NotificationScheduler.calculateSubscriptionReminderDate(
        sub,
        referenceDate: now,
      );

      expect(scheduled, isNull);
    });

    test('calculateSubscriptionReminderDate returns null if reminder is disabled or sub is not active', () {
      final now = DateTime(2026, 8, 20);
      final subDisabled = Subscription(
        id: 'sub_disabled',
        merchant: 'Gym',
        normalizedMerchant: 'gym',
        amount: 2000,
        nextRenewalDate: DateTime(2026, 8, 25),
        reminderDaysBefore: 2,
        isReminderEnabled: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(
        NotificationScheduler.calculateSubscriptionReminderDate(
          subDisabled,
          referenceDate: now,
        ),
        isNull,
      );
    });

    test('calculateLoanEmiReminderDate calculates reminder date correctly', () {
      final now = DateTime(2026, 8, 20, 8, 0);
      final loan = Loan(
        id: 'loan_1',
        name: 'Auto Loan',
        lender: 'HDFC Bank',
        principalAmount: 500000,
        interestRate: 8.5,
        tenureMonths: 36,
        startDate: DateTime(2026, 1, 1),
        expectedEndDate: DateTime(2029, 1, 1),
        emiAmount: 15780,
        outstandingPrincipal: 450000,
        nextDueDate: DateTime(2026, 8, 25),
        status: LoanStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final scheduled = NotificationScheduler.calculateLoanEmiReminderDate(
        loan,
        referenceDate: now,
        reminderDaysBefore: 3,
        targetHour: 9,
      );

      expect(scheduled, isNotNull);
      expect(scheduled!.day, equals(22)); // 25 - 3 days
      expect(scheduled.hour, equals(9));
    });

    test('calculateLoanEmiReminderDate returns null if loan is closed/paid off', () {
      final now = DateTime(2026, 8, 20);
      final loanPaid = Loan(
        id: 'loan_paid',
        name: 'Closed Loan',
        lender: 'Bank',
        principalAmount: 100000,
        interestRate: 10,
        tenureMonths: 12,
        startDate: DateTime(2025, 1, 1),
        expectedEndDate: DateTime(2026, 1, 1),
        emiAmount: 8000,
        outstandingPrincipal: 0,
        nextDueDate: DateTime(2026, 8, 25),
        status: LoanStatus.paidOff,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      expect(
        NotificationScheduler.calculateLoanEmiReminderDate(
          loanPaid,
          referenceDate: now,
        ),
        isNull,
      );
    });
  });
}
