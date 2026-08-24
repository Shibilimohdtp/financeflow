import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parser_registry.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bank SMS Parsers Tests', () {
    late SmsParserRegistry registry;

    setUp(() {
      registry = SmsParserRegistry();
    });

    test('Parses HDFC Bank debit SMS', () {
      final parser = HdfcSmsParser();
      final now = DateTime.now();

      const body =
          'Sent Rs.430.00 from HDFC Bank A/C **1234 to SWIGGY on 15-AUG-26. Ref 622819283921. Bal Rs.45200.00.';

      final parsed = parser.parse(
        sender: 'VM-HDFCBK',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(430.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Swiggy'));
      expect(parsed.referenceNumber, equals('622819283921'));
      expect(parsed.source, equals(TransactionSource.sms));
      expect(parsed.sourceName, equals('HDFC Bank'));
    });

    test('Parses HDFC Bank credit SMS', () {
      final parser = HdfcSmsParser();
      final now = DateTime.now();

      const body =
          'Rs.75000.00 credited to HDFC Bank A/C **1234 on 01-AUG-26 by ACME CORP. Ref 998877665544. Bal Rs.120200.00.';

      final parsed = parser.parse(
        sender: 'AD-HDFCBK',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(75000.00));
      expect(parsed.type, equals(TransactionType.income));
      expect(parsed.referenceNumber, equals('998877665544'));
    });

    test('Parses ICICI Bank debit SMS', () {
      final parser = IciciSmsParser();
      final now = DateTime.now();

      const body =
          'Dear Customer, Acct XX567 debited with INR 1,299.50 on 12-Aug-26. Info: Amazon Pay. Available Bal INR 34,500.00.';

      final parsed = parser.parse(
        sender: 'VK-ICICIB',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(1299.50));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Amazon'));
      expect(parsed.sourceName, equals('ICICI Bank'));
    });

    test('Parses SBI Bank debit SMS', () {
      final parser = SbiSmsParser();
      final now = DateTime.now();

      const body =
          'Your A/C XXXXX12345 debited by Rs.2,500.00 on 14Aug26 by transfer to RELIANCE RETAIL. Ref No 6123456789.';

      final parsed = parser.parse(
        sender: 'VM-SBIN',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(2500.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Reliance'));
      expect(parsed.referenceNumber, equals('6123456789'));
      expect(parsed.sourceName, equals('State Bank of India'));
    });

    test('Parses Axis Bank debit SMS', () {
      final parser = AxisSmsParser();
      final now = DateTime.now();

      const body =
          'INR 650.00 spent on Axis Bank Card ending 9876 at STARBUCKS on 15-08-2026. Avail Lmt INR 1,45,000.00.';

      final parsed = parser.parse(
        sender: 'VM-AXISBK',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(650.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.normalizedMerchant, equals('Starbucks'));
      expect(parsed.sourceName, equals('Axis Bank'));
    });

    for (final bankCase in const [
      ('FEDBNK', 'Federal Bank', 'Federal Bank'),
      ('CANBNK', 'Canara Bank', 'Canara Bank'),
      ('UNIONB', 'Union Bank', 'Union Bank'),
    ]) {
      test('Parses ${bankCase.$2} debit SMS', () {
        final result = registry.parse(
          sender: bankCase.$1,
          body:
              '${bankCase.$2}: Rs 750.00 debited from A/C **1234 to AMAZON on 22-AUG-26. Ref 778899.',
          timestamp: DateTime(2026, 8, 22),
        );
        expect(result, isNotNull);
        expect(result!.sourceName, bankCase.$3);
        expect(result.amount, 750);
        expect(result.type, TransactionType.expense);
        expect(result.referenceNumber, '778899');
      });
    }

    test('Parses Generic UPI transaction SMS', () {
      final parser = GenericUpiSmsParser();
      final now = DateTime.now();

      const body =
          'Rs.180.00 debited from A/C **7890 on 16-Aug-2026 for UPI txn to chaiwala@okaxis. UPI Ref 321654987012.';

      final parsed = parser.parse(
        sender: 'UPI-TXN',
        body: body,
        timestamp: now,
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(180.00));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.referenceNumber, equals('321654987012'));
    });

    test('Rejects OTP, balance enquiry, and non-financial SMS', () {
      final hdfcParser = HdfcSmsParser();
      final now = DateTime.now();

      const otpSms =
          '123456 is your secret OTP for login to HDFC NetBanking. Do not share with anyone.';
      expect(
        hdfcParser.parse(sender: 'HDFCBK', body: otpSms, timestamp: now),
        isNull,
      );

      const promoSms =
          'Get pre-approved Personal Loan up to Rs. 10 Lakhs with HDFC Bank. Apply now at bit.ly/test';
      expect(
        hdfcParser.parse(sender: 'HDFCBK', body: promoSms, timestamp: now),
        isNull,
      );
    });

    test(
      'Registry resolves appropriate parser from sender code or message body',
      () {
        final now = DateTime.now();

        final result = registry.parse(
          body:
              'Dear Customer, Acct XX567 debited with INR 350.00 on 10-Aug-26. Info: Uber Rides.',
          sender: 'AX-ICICIB',
          timestamp: now,
        );

        expect(result, isNotNull);
        expect(result!.amount, equals(350.00));
        expect(result.normalizedMerchant, equals('Uber'));
        expect(result.sourceName, equals('ICICI Bank'));
      },
    );
  });
}
