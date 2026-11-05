import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/core/formatting/app_currency.dart';
import 'package:financeflow/core/formatting/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Formats standard numbers with Indian digit grouping', () {
      expect(CurrencyFormatter.format(1234), '₹1,234');
      expect(CurrencyFormatter.format(123456), '₹1,23,456');
      expect(CurrencyFormatter.format(1234567), '₹12,34,567');
      expect(CurrencyFormatter.format(12345678), '₹1,23,45,678');
      expect(CurrencyFormatter.format(0), '₹0');
    });

    test('Formats decimal paise only when fraction exists', () {
      expect(CurrencyFormatter.format(1234.50), '₹1,234.50');
      expect(CurrencyFormatter.format(123456.75), '₹1,23,456.75');
      expect(CurrencyFormatter.format(500.00), '₹500');
    });

    test('Formats income with + sign and expense with − sign', () {
      expect(
        CurrencyFormatter.format(25000, showSign: true, isIncome: true),
        '+ ₹25,000',
      );
      expect(
        CurrencyFormatter.format(430, showSign: true, isExpense: true),
        '− ₹430',
      );
    });

    test('Formats compact values for chart axes', () {
      expect(CurrencyFormatter.formatCompact(500), '₹500');
      expect(CurrencyFormatter.formatCompact(1200), '₹1.2k');
      expect(CurrencyFormatter.formatCompact(150000), '₹1.5L');
      expect(CurrencyFormatter.formatCompact(25000000), '₹2.5Cr');
    });

    test('Parses formatted Indian rupee strings to double', () {
      expect(CurrencyFormatter.parse('₹1,23,456'), 123456.0);
      expect(CurrencyFormatter.parse('₹1,23,456.75'), 123456.75);
      expect(CurrencyFormatter.parse(' 500 '), 500.0);
      expect(CurrencyFormatter.parse('invalid'), isNull);
      expect(CurrencyFormatter.parse(''), isNull);
    });
  });

  group('Display currency', () {
    tearDown(() => CurrencyFormatter.current = AppCurrency.inr);

    test('defaults to INR', () {
      expect(CurrencyFormatter.current, AppCurrency.inr);
      expect(CurrencyFormatter.currencySymbol, '₹');
    });

    test('USD, EUR and GBP use thousands grouping and their symbols', () {
      CurrencyFormatter.current = AppCurrency.usd;
      expect(CurrencyFormatter.format(1234567), r'$1,234,567');
      expect(CurrencyFormatter.format(1234.5), r'$1,234.50');
      expect(CurrencyFormatter.format(-430), r'− $430');

      CurrencyFormatter.current = AppCurrency.eur;
      expect(CurrencyFormatter.format(123456), '€123,456');

      CurrencyFormatter.current = AppCurrency.gbp;
      expect(CurrencyFormatter.format(99.99), '£99.99');
    });

    test('compact amounts use k/M/B outside INR and k/L/Cr for INR', () {
      expect(CurrencyFormatter.formatCompact(150000), '₹1.5L');
      CurrencyFormatter.current = AppCurrency.usd;
      expect(CurrencyFormatter.formatCompact(150000), r'$150k');
      expect(CurrencyFormatter.formatCompact(2500000), r'$2.5M');
      expect(CurrencyFormatter.formatCompact(3000000000), r'$3B');
    });

    test('parse accepts any supported symbol', () {
      expect(CurrencyFormatter.parse(r'$1,234.50'), 1234.5);
      expect(CurrencyFormatter.parse('€ 99'), 99);
      expect(CurrencyFormatter.parse('£1,000'), 1000);
      expect(CurrencyFormatter.parse('₹1,23,456'), 123456);
    });

    test('unknown codes fall back to INR', () {
      expect(AppCurrency.fromCode('JPY'), AppCurrency.inr);
      expect(AppCurrency.fromCode(null), AppCurrency.inr);
      expect(AppCurrency.fromCode('GBP'), AppCurrency.gbp);
    });
  });
}
