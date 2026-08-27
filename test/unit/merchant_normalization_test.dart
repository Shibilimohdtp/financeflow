import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/services/merchant_normalization_service.dart';

void main() {
  test('Brand substrings inside personal names do not replace the person', () {
    expect(
      MerchantNormalizationService.normalize('NICOLA THOMAS'),
      'Nicola Thomas',
    );
    expect(
      MerchantNormalizationService.normalize('ANITHA\nMENON T'),
      'Anitha Menon T',
    );
  });
  group('MerchantNormalizationService Tests', () {
    test('Normalizes various Amazon aliases to canonical Amazon', () {
      expect(
        MerchantNormalizationService.normalize('AMZN PAY'),
        equals('Amazon'),
      );
      expect(
        MerchantNormalizationService.normalize('AMAZON IN'),
        equals('Amazon'),
      );
      expect(
        MerchantNormalizationService.normalize('AMZN MKT'),
        equals('Amazon'),
      );
      expect(
        MerchantNormalizationService.normalize('amazon pay india'),
        equals('Amazon'),
      );
    });

    test('Normalizes Swiggy and Zomato variants', () {
      expect(
        MerchantNormalizationService.normalize('SWIGGY INSTAMART'),
        equals('Swiggy Instamart'),
      );
      expect(
        MerchantNormalizationService.normalize('SWIGGY DINEIN'),
        equals('Swiggy'),
      );
      expect(
        MerchantNormalizationService.normalize('ZOMATO LTD'),
        equals('Zomato'),
      );
      expect(
        MerchantNormalizationService.normalize('ZOMATO ONLINE'),
        equals('Zomato'),
      );
    });

    test('Normalizes Uber and Ola variants', () {
      expect(
        MerchantNormalizationService.normalize('UBER INDIA SYSTEMS'),
        equals('Uber'),
      );
      expect(
        MerchantNormalizationService.normalize('UBER TRIP'),
        equals('Uber'),
      );
      expect(MerchantNormalizationService.normalize('OLA CABS'), equals('Ola'));
      expect(
        MerchantNormalizationService.normalize('ANI TECHNOLOGIES'),
        equals('Ola'),
      );
    });

    test('Normalizes quick commerce and retail', () {
      expect(
        MerchantNormalizationService.normalize('BLINKIT COMMERCE'),
        equals('Blinkit'),
      );
      expect(
        MerchantNormalizationService.normalize('ZEPTO COMMERCE'),
        equals('Zepto'),
      );
      expect(
        MerchantNormalizationService.normalize('SUPERMARKET GROCERY'),
        equals('BigBasket'),
      );
      expect(
        MerchantNormalizationService.normalize('AVENUE SUPERMARTS'),
        equals('DMart'),
      );
    });

    test('Normalizes telecom and fuel', () {
      expect(
        MerchantNormalizationService.normalize('BHARTI AIRTEL'),
        equals('Airtel'),
      );
      expect(
        MerchantNormalizationService.normalize('RELIANCE JIO'),
        equals('Jio'),
      );
      expect(
        MerchantNormalizationService.normalize('INDIAN OIL CORP'),
        equals('Indian Oil'),
      );
      expect(
        MerchantNormalizationService.normalize('BHARAT PETROLEUM'),
        equals('Bharat Petroleum'),
      );
      expect(
        MerchantNormalizationService.normalize('HPCL'),
        equals('Hindustan Petroleum'),
      );
    });

    test(
      'Generic normalization strips corporate noise and titles correctly',
      () {
        expect(
          MerchantNormalizationService.normalize('ACME FOODS PVT LTD'),
          equals('ACME Foods'),
        );
        expect(
          MerchantNormalizationService.normalize('PACIFIC STORE ONLINE'),
          equals('Pacific'),
        );
      },
    );

    test('Handles empty and whitespace safely', () {
      expect(
        MerchantNormalizationService.normalize(''),
        equals('Unknown Payee'),
      );
      expect(
        MerchantNormalizationService.normalize('   '),
        equals('Unknown Payee'),
      );
    });
  });
}
