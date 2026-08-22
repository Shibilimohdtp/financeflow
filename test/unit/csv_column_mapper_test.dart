import 'package:financeflow/services/ingestion/parsers/csv_column_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvColumnMapper Tests', () {
    test('Auto-detects HDFC Bank statement headers', () {
      final headers = [
        'Date',
        'Narration',
        'Chq./Ref.No.',
        'Value Dt',
        'Withdrawal Amt.',
        'Deposit Amt.',
        'Closing Balance',
      ];

      final mapping = CsvColumnMapper.autoDetect(headers);

      expect(mapping.dateIndex, equals(0));
      expect(mapping.merchantIndex, equals(1));
      expect(mapping.referenceIndex, equals(2));
      expect(mapping.debitIndex, equals(4));
      expect(mapping.creditIndex, equals(5));
      expect(mapping.hasSeparateDebitCredit, isTrue);
      expect(mapping.isValid, isTrue);
    });

    test('Auto-detects ICICI Bank statement headers', () {
      final headers = [
        'Tran Date',
        'Transaction Remarks',
        'Cheque No.',
        'Withdrawal Amount (INR )',
        'Deposit Amount (INR )',
        'Balance (INR )',
      ];

      final mapping = CsvColumnMapper.autoDetect(headers);

      expect(mapping.dateIndex, equals(0));
      expect(mapping.merchantIndex, equals(1));
      expect(mapping.debitIndex, equals(3));
      expect(mapping.creditIndex, equals(4));
      expect(mapping.isValid, isTrue);
    });

    test('Auto-detects SBI Bank statement headers', () {
      final headers = [
        'Txn Date',
        'Description',
        'Ref No./Cheque No.',
        'Debit',
        'Credit',
        'Balance',
      ];

      final mapping = CsvColumnMapper.autoDetect(headers);

      expect(mapping.dateIndex, equals(0));
      expect(mapping.merchantIndex, equals(1));
      expect(mapping.referenceIndex, equals(2));
      expect(mapping.debitIndex, equals(3));
      expect(mapping.creditIndex, equals(4));
    });

    test('Auto-detects single Amount + Type column format', () {
      final headers = ['Date', 'Payee', 'Amount', 'Type', 'Category', 'Notes'];

      final mapping = CsvColumnMapper.autoDetect(headers);

      expect(mapping.dateIndex, equals(0));
      expect(mapping.merchantIndex, equals(1));
      expect(mapping.amountIndex, equals(2));
      expect(mapping.typeIndex, equals(3));
      expect(mapping.hasSeparateDebitCredit, isFalse);
      expect(mapping.isValid, isTrue);
    });

    test('Allows custom user overrides to column mapping', () {
      final initialMapping = const CsvColumnMapping();

      final updatedMapping = initialMapping.copyWith(
        dateIndex: 0,
        merchantIndex: 1,
        amountIndex: 2,
        typeIndex: 3,
      );

      expect(updatedMapping.dateIndex, equals(0));
      expect(updatedMapping.merchantIndex, equals(1));
      expect(updatedMapping.amountIndex, equals(2));
      expect(updatedMapping.typeIndex, equals(3));
      expect(updatedMapping.isValid, isTrue);
    });
  });
}
