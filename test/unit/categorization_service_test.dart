import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/services/categorization_service.dart';

void main() {
  group('CategorizationService Tests', () {
    setUp(() {
      CategorizationService.clearUserOverrides();
    });

    test('Suggests Dining for food delivery and restaurant merchants', () {
      final s1 = CategorizationService.suggestCategory('SWIGGY');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_dining'));
      expect(s1.categoryName, equals('Dining'));
      expect(s1.confidence, greaterThanOrEqualTo(0.9));
      expect(s1.reason.toLowerCase(), contains('swiggy'));

      final s2 = CategorizationService.suggestCategory('Zomato Online');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_dining'));

      final s3 = CategorizationService.suggestCategory('STARBUCKS COFFEE');
      expect(s3, isNotNull);
      expect(s3!.categoryId, equals('cat_dining'));
    });

    test('Suggests Groceries for quick-commerce and supermarket merchants', () {
      final s1 = CategorizationService.suggestCategory('Instamart order');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_groceries'));

      final s2 = CategorizationService.suggestCategory('Blinkit Commerce');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_groceries'));

      final s3 = CategorizationService.suggestCategory('Zepto');
      expect(s3, isNotNull);
      expect(s3!.categoryId, equals('cat_groceries'));
    });

    test('Suggests Transport for ride hailing and travel merchants', () {
      final s1 = CategorizationService.suggestCategory('Uber India Systems');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_transport'));

      final s2 = CategorizationService.suggestCategory('Ola Cabs');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_transport'));

      final s3 = CategorizationService.suggestCategory('Rapido Auto');
      expect(s3, isNotNull);
      expect(s3!.categoryId, equals('cat_transport'));
    });

    test('Suggests Subscriptions for digital streaming and SaaS tools', () {
      final s1 = CategorizationService.suggestCategory('Netflix India');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_subscriptions'));

      final s2 = CategorizationService.suggestCategory('Spotify AB');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_subscriptions'));

      final s3 = CategorizationService.suggestCategory('ChatGPT subscription');
      expect(s3, isNotNull);
      expect(s3!.categoryId, equals('cat_subscriptions'));
    });

    test('Suggests Fuel for petrol pumps and petroleum merchants', () {
      final s1 = CategorizationService.suggestCategory('HPCL Petrol Pump');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_fuel'));

      final s2 = CategorizationService.suggestCategory('Indian Oil Corp');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_fuel'));
    });

    test('Handles case-insensitivity, whitespace, and punctuation', () {
      final s = CategorizationService.suggestCategory(
        '   *** blinkit_groceries ***   ',
      );
      expect(s, isNotNull);
      expect(s!.categoryId, equals('cat_groceries'));
    });

    test(
      'Manual user override takes precedence over default rules with 1.0 confidence',
      () {
        // Default rule for Amazon suggests Shopping
        final defaultS = CategorizationService.suggestCategory('Amazon Pay');
        expect(defaultS!.categoryId, equals('cat_shopping'));

        // User manually records that Amazon Pay is Bills
        CategorizationService.recordUserChoice(
          rawMerchant: 'Amazon Pay',
          categoryId: 'cat_bills',
          categoryName: 'Bills',
          categoryIcon: 'receipt',
          categoryColor: 'damson',
        );

        final overrideS = CategorizationService.suggestCategory('Amazon Pay');
        expect(overrideS, isNotNull);
        expect(overrideS!.categoryId, equals('cat_bills'));
        expect(overrideS.confidence, equals(1.0));
        expect(overrideS.isUserOverride, isTrue);
        expect(overrideS.reason, contains('Based on your previous choice'));
      },
    );

    test('Suggests Transaction for peer-to-peer, transfers, and advances', () {
      final s1 = CategorizationService.suggestCategory('P2P UPI Transfer');
      expect(s1, isNotNull);
      expect(s1!.categoryId, equals('cat_transaction'));
      expect(s1.categoryName, equals('Transaction'));

      final s2 = CategorizationService.suggestCategory('Friend advance');
      expect(s2, isNotNull);
      expect(s2!.categoryId, equals('cat_transaction'));
    });

    test('Returns null for unknown merchants with zero match', () {
      final s = CategorizationService.suggestCategory('XYZ98765RANDOM');
      expect(s, isNull);
    });
  });
}
