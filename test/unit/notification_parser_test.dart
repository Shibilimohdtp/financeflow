import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/parsers/notification_parser_registry.dart';
import 'package:financeflow/services/ingestion/parsers/notification_parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Parsers Tests', () {
    late NotificationParserRegistry registry;

    setUp(() {
      registry = NotificationParserRegistry();
    });

    test('Parses Google Pay debit notification', () {
      final parser = GooglePayNotificationParser();
      final now = DateTime.now();

      final parsed = parser.parse(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Google Pay',
        text: 'Paid ₹450 to Swiggy',
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(450.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Swiggy'));
      expect(parsed.source, equals(TransactionSource.notification));
      expect(parsed.sourceName, equals('Google Pay'));
    });

    test('Parses Google Pay credit notification', () {
      final parser = GooglePayNotificationParser();
      final now = DateTime.now();

      final parsed = parser.parse(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Google Pay',
        text: 'Rahul sent you ₹1,200',
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(1200.00));
      expect(parsed.type, equals(TransactionType.income));
      expect(parsed.rawMerchant, equals('Rahul'));
    });

    test('Parses PhonePe payment notification', () {
      final parser = PhonePeNotificationParser();
      final now = DateTime.now();

      final parsed = parser.parse(
        packageName: 'com.phonepe.app',
        title: 'PhonePe',
        text: 'Paid ₹230 to Starbucks Coffee successfully.',
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(230.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Starbucks'));
      expect(parsed.sourceName, equals('PhonePe'));
    });

    test('Parses Paytm payment notification', () {
      final parser = PaytmNotificationParser();
      final now = DateTime.now();

      final parsed = parser.parse(
        packageName: 'net.one97.paytm',
        title: 'Paytm',
        text: 'Paid ₹550 at Apollo Pharmacy successfully',
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(550.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Apollo Pharmacy'));
      expect(parsed.sourceName, equals('Paytm'));
    });

    test('Parses CRED credit card payment notification', () {
      final parser = CredNotificationParser();
      final now = DateTime.now();

      final parsed = parser.parse(
        packageName: 'com.dreamplug.androidapp',
        title: 'CRED',
        text: '₹15,400 paid towards HDFC Bank Credit Card',
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(15400.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.sourceName, equals('CRED'));
    });

    test('Rejects non-transactional notifications (marketing, OTP, chat)', () {
      final gpayParser = GooglePayNotificationParser();
      final now = DateTime.now();

      expect(
        gpayParser.parse(
          packageName: 'com.google.android.apps.nbu.paisa.user',
          title: 'Google Pay',
          text: 'Scratch card unlocked! Win up to ₹500',
          timestamp: now,
        ),
        isNull,
      );
      expect(
        gpayParser.parse(
          packageName: 'com.google.android.apps.nbu.paisa.user',
          title: 'Google Pay',
          text: 'Your OTP for login is 123456',
          timestamp: now,
        ),
        isNull,
      );
    });

    test(
      'Registry dispatches to appropriate parser by package name or content',
      () {
        final now = DateTime.now();

        final result = registry.parse(
          packageName: 'com.phonepe.app',
          title: 'Payment Successful',
          text: 'Paid ₹890 to Zomato',
          timestamp: now,
        );

        expect(result, isNotNull);
        expect(result!.amount, equals(890.00));
        expect(result.normalizedMerchant, equals('Zomato'));
        expect(result.sourceName, equals('PhonePe'));
      },
    );
  });
}
