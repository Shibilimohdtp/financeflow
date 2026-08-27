import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/services/notifications/notification_id.dart';

void main() {
  group('NotificationId Generator Tests', () {
    test('generates deterministic IDs for identical keys', () {
      const key = 'budget:b1:approaching:2026-08';
      final id1 = NotificationId.fromKey(key);
      final id2 = NotificationId.fromKey(key);
      expect(id1, equals(id2));
    });

    test('always produces positive 31-bit integers', () {
      final keys = [
        '',
        'needs_review_batch',
        'backup_reminder',
        'subscription:sub_123:renewal:2026-08-30',
        'loan:loan_456:emi:2026-09-05',
        'budget:groceries:exceeded:2026-08',
        'very_long_custom_string_with_symbols_!@#\$%^&*()_+',
      ];

      for (final key in keys) {
        final id = NotificationId.fromKey(key);
        expect(id, isPositive, reason: 'ID for "$key" must be positive');
        expect(id, lessThanOrEqualTo(0x7FFFFFFF), reason: 'ID must fit within 31-bit signed range');
      }
    });

    test('different keys produce different deterministic IDs', () {
      final idBudget1 = NotificationId.forBudgetApproaching('groceries', year: 2026, month: 8);
      final idBudget2 = NotificationId.forBudgetExceeded('groceries', year: 2026, month: 8);
      final idBudget3 = NotificationId.forBudgetApproaching('dining', year: 2026, month: 8);

      expect(idBudget1, isNot(equals(idBudget2)));
      expect(idBudget1, isNot(equals(idBudget3)));
    });

    test('forSubscriptionRenewal produces unique IDs for different dates', () {
      final date1 = DateTime(2026, 8, 25);
      final date2 = DateTime(2026, 9, 25);

      final id1 = NotificationId.forSubscriptionRenewal('netflix', date1);
      final id2 = NotificationId.forSubscriptionRenewal('netflix', date2);
      final id3 = NotificationId.forSubscriptionRenewal('spotify', date1);

      expect(id1, isNot(equals(id2)));
      expect(id1, isNot(equals(id3)));
    });

    test('forLoanEmi produces unique IDs for different loans and due dates', () {
      final date1 = DateTime(2026, 9, 5);
      final date2 = DateTime(2026, 10, 5);

      final id1 = NotificationId.forLoanEmi('loan_hdfc', date1);
      final id2 = NotificationId.forLoanEmi('loan_hdfc', date2);
      final id3 = NotificationId.forLoanEmi('loan_icici', date1);

      expect(id1, isNot(equals(id2)));
      expect(id1, isNot(equals(id3)));
    });

    test('static constants have stable assigned values', () {
      expect(NotificationId.needsReviewBatch, equals(10001));
      expect(NotificationId.backupReminder, equals(10002));
    });
  });
}
