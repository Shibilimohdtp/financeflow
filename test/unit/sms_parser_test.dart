import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parser_registry.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parsers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Structured UPI counterparty evidence', () {
    for (final sample in [
      (
        'P2A',
        '2500.00',
        '412345678901',
        'ANITHA\nMENON T',
        'Anitha Menon T',
      ),
      (
        'P2M',
        '300.00',
        '660563126913',
        'ANITHA\nMENON T',
        'Anitha Menon T',
      ),
      ('P2M', '105.40', '659798667691', 'ZOMATO', 'Zomato'),
    ]) {
      test('Axis ${sample.$1} ${sample.$2} prioritizes path over footer', () {
        final body =
            'INR ${sample.$2} debited\nA/c no. XX5645\n'
            '27-08-26, 15:19:37\nUPI/${sample.$1}/${sample.$3}/${sample.$4}\n'
            'Not you? SMS BLOCKUPI Cust ID to\n919951860002\nAxis Bank';
        final parsed =
            AxisSmsParser().parse(sender: 'AD-AXISBK-S', body: body)!;
        expect(parsed.amount, double.parse(sample.$2));
        expect(parsed.type, TransactionType.expense);
        expect(parsed.rawMerchant, sample.$4.replaceAll('\n', ' '));
        expect(parsed.normalizedMerchant, sample.$5);
        expect(parsed.referenceNumber, sample.$3);
        expect(parsed.date, DateTime(2026, 8, 27, 15, 19, 37));
        expect(parsed.warnings, isEmpty);
        expect(parsed.rawSource, body);
        expect(parsed.toTransaction().merchant, sample.$5);
      });
    }

    for (final footer in [
      'Not you?',
      'Cust ID',
      'Axis Bank',
      'Available balance',
      'Avl Bal',
      'Bal',
      'Ref',
      'UPI Ref',
    ]) {
      test('wrapped lowercase path stops at $footer', () {
        final parsed =
            AxisSmsParser().parse(
              sender: 'AXIS',
              body:
                  'INR 50 debited to Incorrect Name\nupi/p2a/123456789012/Muhammed Ajinas K\nP\n$footer 99999',
            )!;
        expect(parsed.rawMerchant, 'Muhammed Ajinas K P');
      });
    }

    test('optional slash fields never replace the counterparty', () {
      final parsed =
          AxisSmsParser().parse(
            sender: 'AXIS',
            body:
                'INR 50 debited UPI/P2M/123456789012/ZOMATO/okaxis/919951860002',
          )!;
      expect(parsed.normalizedMerchant, 'Zomato');
    });

    for (final invalid in [
      '919951860002',
      '+91 99518 60002',
      '9951860002',
      '5645',
      'XX5645',
      'Card **9876',
      'A/c no. XX5645',
      '412345678901',
      'UTR ABC123456789',
      'ABC123456789',
      '27-08-26',
      '27 Aug 26',
      '15:19:37',
      'Axis Bank',
      'Bank Transaction',
      'Not you? SMS BLOCKUPI Cust ID to 919951860002',
      'Cust ID to 919951860002',
    ]) {
      test('rejects false payee: $invalid', () {
        final parsed =
            AxisSmsParser().parse(
              sender: 'AXIS',
              body: 'INR 50 debited to $invalid',
            )!;
        expect(parsed.rawMerchant, 'Bank Transaction');
        expect(
          parsed.warnings,
          contains('Could not clearly identify payee from SMS'),
        );
      });
    }

    test('legacy ICICI UPI narration and balance-only rejection', () {
      final parser = IciciSmsParser();
      expect(
        parser
            .parse(
              sender: 'ICICI',
              body: 'INR 50 debited. Info: UPI/SWIGGY/423524. Avl Bal INR 500',
            )!
            .normalizedMerchant,
        'Swiggy',
      );
      expect(
        parser.parse(
          sender: 'ICICI',
          body: 'Available balance INR 500 in A/c XX1234',
        ),
        isNull,
      );
    });
    test(
      'generic extraction never resumes after balance or reference footer',
      () {
        for (final footer in ['Available balance', 'Avl Bal', 'UPI Ref']) {
          final parsed =
              AxisSmsParser().parse(
                sender: 'AXIS',
                body: 'INR 50 debited. $footer info: Customer',
              )!;
          expect(parsed.rawMerchant, 'Bank Transaction');
        }
      },
    );
  });

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

    test('Parses current UPI, card, and bank transaction wording', () {
      final samples = <({String sender, String body, String bank})>[
        (
          sender: 'VM-HDFCBK-S',
          body:
              'HDFC Bank: transaction successful. Payment of Rs 1,500 made using card ending 4321 at SWIGGY.',
          bank: 'HDFC Bank',
        ),
        (
          sender: 'AD-ICICIB',
          body:
              'ICICI Bank Card ending 1234 was used for INR 1,250.00 at AMAZON.',
          bank: 'ICICI Bank',
        ),
        (
          sender: 'VK-SBIN',
          body:
              'SBI UPI transfer of Rs.275 completed from account XX4321 to ZOMATO. UTR 99112233.',
          bank: 'State Bank of India',
        ),
        (
          sender: 'VM-KOTAKB',
          body: 'Payment of INR 899 made using card ending 1234 at NETFLIX.',
          bank: 'Bank SMS',
        ),
        (
          sender: 'UPI-ALERT',
          body: 'UPI mandate executed. Amount: 799 from account XX1001.',
          bank: 'Bank SMS',
        ),
      ];

      for (final sample in samples) {
        final parsed = registry.parse(
          sender: sample.sender,
          body: sample.body,
          timestamp: DateTime(2026, 8, 22),
        );
        expect(parsed, isNotNull, reason: sample.sender);
        expect(parsed!.amount, greaterThan(0), reason: sample.sender);
        expect(parsed.type, TransactionType.expense, reason: sample.sender);
        expect(parsed.sourceName, sample.bank, reason: sample.sender);
      }
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

      expect(
        registry.parse(
          sender: 'VM-HDFCBK',
          body: 'Your verification code is 123456. Do not share it.',
          timestamp: now,
        ),
        isNull,
      );
      expect(
        registry.parse(
          sender: 'AD-ICICIB',
          body: 'Limited time offer: get Rs 500 cashback. Apply now.',
          timestamp: now,
        ),
        isNull,
      );
      expect(
        registry.parse(
          sender: 'UNKNOWN',
          body: 'Your parcel will arrive tomorrow.',
          timestamp: now,
        ),
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
