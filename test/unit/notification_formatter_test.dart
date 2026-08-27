import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/services/notifications/notification_formatter.dart';

void main() {
  group('NotificationFormatter Tests', () {
    group('Needs Review formatting', () {
      test('formats singular item with merchant and amount when privacy is off', () {
        final text = NotificationFormatter.formatNeedsReview(
          count: 1,
          singleMerchant: 'Swiggy',
          singleAmount: 450.0,
          hideSensitive: false,
        );
        expect(text.title, equals('Transaction needs review'));
        expect(text.body, contains('Swiggy'));
        expect(text.body, contains('450'));
        expect(text.body, contains('waiting for review'));
      });

      test('formats plural items with count when privacy is off', () {
        final text = NotificationFormatter.formatNeedsReview(
          count: 3,
          singleMerchant: 'Swiggy',
          singleAmount: 450.0,
          hideSensitive: false,
        );
        expect(text.title, equals('Transactions need review'));
        expect(text.body, equals('3 imported transactions are waiting for your review.'));
      });

      test('formats privacy-safe text hiding merchant and amount when privacy is on', () {
        final textSingular = NotificationFormatter.formatNeedsReview(
          count: 1,
          singleMerchant: 'Swiggy',
          singleAmount: 450.0,
          hideSensitive: true,
        );
        expect(textSingular.title, equals('Transaction needs review'));
        expect(textSingular.body, equals('1 imported transaction is waiting for your review.'));
        expect(textSingular.body, isNot(contains('Swiggy')));
        expect(textSingular.body, isNot(contains('450')));

        final textPlural = NotificationFormatter.formatNeedsReview(
          count: 4,
          singleMerchant: 'Swiggy',
          singleAmount: 450.0,
          hideSensitive: true,
        );
        expect(textPlural.title, equals('Transactions need review'));
        expect(textPlural.body, equals('4 imported transactions are waiting for your review.'));
      });
    });

    group('Budget Alerts formatting', () {
      test('formats budget approaching limit detailed vs privacy-safe', () {
        final detailed = NotificationFormatter.formatBudgetApproaching(
          categoryName: 'Dining',
          percentageUsed: 0.85,
          hideSensitive: false,
        );
        expect(detailed.title, equals('Dining budget nearing limit'));
        expect(detailed.body, contains('85%'));

        final safe = NotificationFormatter.formatBudgetApproaching(
          categoryName: 'Dining',
          percentageUsed: 0.85,
          hideSensitive: true,
        );
        expect(safe.title, equals('Budget update'));
        expect(safe.body, equals('A FinanceFlow budget is nearing its limit. Open to view.'));
        expect(safe.body, isNot(contains('Dining')));
      });

      test('formats budget exceeded detailed vs privacy-safe', () {
        final detailed = NotificationFormatter.formatBudgetExceeded(
          categoryName: 'Groceries',
          amountOver: 1200.0,
          hideSensitive: false,
        );
        expect(detailed.title, equals('Groceries budget exceeded'));
        expect(detailed.body, contains('Groceries is'));
        expect(detailed.body, contains('1,200'));

        final safe = NotificationFormatter.formatBudgetExceeded(
          categoryName: 'Groceries',
          amountOver: 1200.0,
          hideSensitive: true,
        );
        expect(safe.title, equals('Budget update'));
        expect(safe.body, equals('A FinanceFlow budget has been exceeded. Open to view.'));
      });
    });

    group('Subscription Renewal formatting', () {
      test('formats upcoming renewal detailed with days and amount', () {
        final detailed = NotificationFormatter.formatSubscriptionRenewal(
          merchant: 'Netflix',
          amount: 649.0,
          daysUntil: 2,
          hideSensitive: false,
        );
        expect(detailed.title, equals('Netflix renewal due'));
        expect(detailed.body, contains('Netflix'));
        expect(detailed.body, contains('649'));
        expect(detailed.body, contains('in 2 days'));
      });

      test('formats today and tomorrow correctly', () {
        final today = NotificationFormatter.formatSubscriptionRenewal(
          merchant: 'Spotify',
          amount: 119.0,
          daysUntil: 0,
          hideSensitive: false,
        );
        expect(today.body, contains('renews today'));

        final tomorrow = NotificationFormatter.formatSubscriptionRenewal(
          merchant: 'Spotify',
          amount: 119.0,
          daysUntil: 1,
          hideSensitive: false,
        );
        expect(tomorrow.body, contains('renews tomorrow'));
      });

      test('formats privacy-safe subscription renewal', () {
        final safe = NotificationFormatter.formatSubscriptionRenewal(
          merchant: 'Netflix',
          amount: 649.0,
          daysUntil: 1,
          hideSensitive: true,
        );
        expect(safe.title, equals('Subscription reminder'));
        expect(safe.body, equals('An upcoming subscription renewal is due tomorrow. Open to view.'));
        expect(safe.body, isNot(contains('Netflix')));
        expect(safe.body, isNot(contains('649')));
      });
    });

    group('Loan EMI formatting', () {
      test('formats loan EMI detailed vs privacy-safe', () {
        final detailed = NotificationFormatter.formatLoanEmi(
          loanName: 'HDFC Home Loan',
          emiAmount: 32500.0,
          daysUntil: 3,
          hideSensitive: false,
        );
        expect(detailed.title, equals('HDFC Home Loan EMI due'));
        expect(detailed.body, contains('32,500'));
        expect(detailed.body, contains('in 3 days'));

        final safe = NotificationFormatter.formatLoanEmi(
          loanName: 'HDFC Home Loan',
          emiAmount: 32500.0,
          daysUntil: 3,
          hideSensitive: true,
        );
        expect(safe.title, equals('Loan EMI reminder'));
        expect(safe.body, equals('An upcoming loan EMI payment is due in 3 days. Open to view.'));
      });
    });

    group('Backup Reminder formatting', () {
      test('formats backup reminder detailed vs privacy-safe', () {
        final detailed = NotificationFormatter.formatBackupReminder(
          daysSinceLastBackup: 35,
          hideSensitive: false,
        );
        expect(detailed.title, equals('Encrypted backup reminder'));
        expect(detailed.body, contains('35 days'));

        final safe = NotificationFormatter.formatBackupReminder(
          daysSinceLastBackup: 35,
          hideSensitive: true,
        );
        expect(safe.title, equals('Backup reminder'));
        expect(safe.body, equals('A local encrypted backup is recommended. Open to view.'));
      });
    });
  });
}
