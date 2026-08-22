import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/ingestion/parsers/csv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvParser Tests', () {
    test('Parses standard CSV with withdrawal and deposit columns', () {
      const csv =
          '''Date,Narration,Chq/Ref No,Withdrawal Amt.,Deposit Amt.,Closing Balance
01/08/2026,UPI-SWIGGY-123456@icici-PAYMENT,987654321012,450.00,,52300.50
02/08/2026,SALARY CREDIT - ACME CORP,,0.00,75000.00,127300.50
''';

      final result = CsvParser.parse(csv, sourceFileName: 'hdfc_statement.csv');

      expect(result.parsedTransactions.length, equals(2));

      final tx1 = result.parsedTransactions[0];
      expect(tx1.date.year, equals(2026));
      expect(tx1.date.month, equals(8));
      expect(tx1.date.day, equals(1));
      expect(tx1.amount, equals(450.00));
      expect(tx1.type, equals(TransactionType.expense));
      expect(tx1.normalizedMerchant, equals('Swiggy'));
      expect(tx1.referenceNumber, equals('987654321012'));
      expect(tx1.source, equals(TransactionSource.csv));

      final tx2 = result.parsedTransactions[1];
      expect(tx2.date.day, equals(2));
      expect(tx2.amount, equals(75000.00));
      expect(tx2.type, equals(TransactionType.income));
    });

    test('Parses CSV with quoted commas in narration correctly', () {
      const csv = '''"Date","Particulars","Ref No","Debit","Credit"
"15/08/2026","AMAZON PAY INDIA, BANGALORE, IN","REF998877",1299.50,
"16/08/2026","REFUND FROM FLIPKART, BANGALORE","REF112233",,500.00
''';

      final result = CsvParser.parse(csv);

      expect(result.parsedTransactions.length, equals(2));
      expect(
        result.parsedTransactions[0].rawMerchant,
        equals('AMAZON PAY INDIA, BANGALORE, IN'),
      );
      expect(result.parsedTransactions[0].amount, equals(1299.50));
      expect(
        result.parsedTransactions[0].type,
        equals(TransactionType.expense),
      );
      expect(result.parsedTransactions[0].normalizedMerchant, equals('Amazon'));

      expect(
        result.parsedTransactions[1].rawMerchant,
        equals('REFUND FROM FLIPKART, BANGALORE'),
      );
      expect(result.parsedTransactions[1].amount, equals(500.00));
      expect(result.parsedTransactions[1].type, equals(TransactionType.income));
      expect(
        result.parsedTransactions[1].normalizedMerchant,
        equals('Flipkart'),
      );
    });

    test(
      'Parses various Indian date formats (dd/MM/yyyy, dd-MMM-yyyy, ISO)',
      () {
        const csv = '''Date,Description,Amount,Type
12-Aug-2026,Uber Ride,320.00,DR
2026-08-14,Zomato Order,450.00,DEBIT
15/08/2026,Starbucks,650.00,DR
''';

        final result = CsvParser.parse(csv);

        expect(result.parsedTransactions.length, equals(3));
        expect(
          result.parsedTransactions[0].date,
          equals(DateTime(2026, 8, 12)),
        );
        expect(
          result.parsedTransactions[1].date,
          equals(DateTime(2026, 8, 14)),
        );
        expect(
          result.parsedTransactions[2].date,
          equals(DateTime(2026, 8, 15)),
        );
      },
    );

    test(
      'Parses Indian currency symbols, comma grouping, and negative parentheses',
      () {
        const csv = '''Date,Particulars,Amount
01/08/2026,Purchase at Reliance Fresh,"₹ 1,50,000.50"
02/08/2026,Monthly Rent,"(₹ 25,000.00)"
03/08/2026,Cashback,Rs. 500
''';

        final result = CsvParser.parse(csv);

        expect(result.parsedTransactions.length, equals(3));
        expect(result.parsedTransactions[0].amount, equals(150000.50));
        expect(
          result.parsedTransactions[0].type,
          equals(TransactionType.expense),
        );

        expect(result.parsedTransactions[1].amount, equals(25000.00));
        expect(
          result.parsedTransactions[1].type,
          equals(TransactionType.expense),
        );

        expect(result.parsedTransactions[2].amount, equals(500.00));
        expect(
          result.parsedTransactions[2].type,
          equals(TransactionType.expense),
        );
      },
    );

    test('Handles blank rows, UTF-8 BOM, and trailing newlines gracefully', () {
      const csv =
          '\uFEFFDate,Narration,Debit,Credit\n\n01/08/2026,Netflix,649.00,\n\n\n';

      final result = CsvParser.parse(csv);

      expect(result.parsedTransactions.length, equals(1));
      expect(result.parsedTransactions[0].amount, equals(649.00));
      expect(
        result.parsedTransactions[0].normalizedMerchant,
        equals('Netflix'),
      );
    });

    test(
      'Identifies malformed rows with validation errors without crashing',
      () {
        const csv = '''Date,Narration,Amount
INVALID_DATE,Valid Narration,500.00
01/08/2026,,500.00
02/08/2026,Valid Payee,INVALID_AMOUNT
''';

        final result = CsvParser.parse(csv);

        expect(result.parsedTransactions.length, equals(3));
        expect(result.parsedTransactions[0].validationErrors, isNotEmpty);
        expect(result.parsedTransactions[1].validationErrors, isNotEmpty);
        expect(result.parsedTransactions[2].validationErrors, isNotEmpty);
      },
    );
  });
}
