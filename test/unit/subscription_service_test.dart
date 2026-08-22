import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/subscription_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionService Tests', () {
    final now = DateTime(2026, 8, 15);

    test(
      'calculateMonthlyTotal normalizes weekly, monthly, quarterly, and yearly frequencies',
      () {
        final subs = [
          Subscription(
            id: 's1',
            merchant: 'Netflix',
            normalizedMerchant: 'netflix',
            amount: 649.0,
            billingFrequency: SubscriptionFrequency.monthly,
            nextRenewalDate: DateTime(2026, 9, 1),
            createdAt: now,
            updatedAt: now,
          ),
          Subscription(
            id: 's2',
            merchant: 'Amazon Prime',
            normalizedMerchant: 'amazon prime',
            amount: 1499.0,
            billingFrequency: SubscriptionFrequency.yearly,
            nextRenewalDate: DateTime(2027, 8, 1),
            createdAt: now,
            updatedAt: now,
          ),
          Subscription(
            id: 's3',
            merchant: 'Gym',
            normalizedMerchant: 'gym',
            amount: 3000.0,
            billingFrequency: SubscriptionFrequency.quarterly,
            nextRenewalDate: DateTime(2026, 11, 1),
            createdAt: now,
            updatedAt: now,
          ),
          Subscription(
            id: 's4',
            merchant: 'Milk Delivery',
            normalizedMerchant: 'milk delivery',
            amount: 250.0,
            billingFrequency: SubscriptionFrequency.weekly,
            nextRenewalDate: DateTime(2026, 8, 22),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final totalMonthly = SubscriptionService.calculateMonthlyTotal(subs);
        expect(
          totalMonthly,
          closeTo(
            649.0 + (1499.0 / 12.0) + 1000.0 + (250.0 * 52.0 / 12.0),
            1.0,
          ),
        );

        final totalYearly = SubscriptionService.calculateYearlyTotal(subs);
        expect(totalYearly, closeTo(totalMonthly * 12.0, 5.0));
      },
    );

    test(
      'computeNextRenewalDate computes next date accurately based on frequency',
      () {
        final fromDate = DateTime(2026, 1, 15);

        final nextMonthly = SubscriptionService.computeNextRenewalDate(
          fromDate,
          SubscriptionFrequency.monthly,
        );
        expect(nextMonthly.year, equals(2026));
        expect(nextMonthly.month, equals(2));
        expect(nextMonthly.day, equals(15));

        final nextQuarterly = SubscriptionService.computeNextRenewalDate(
          fromDate,
          SubscriptionFrequency.quarterly,
        );
        expect(nextQuarterly.month, equals(4));
        expect(nextQuarterly.day, equals(15));

        final nextYearly = SubscriptionService.computeNextRenewalDate(
          fromDate,
          SubscriptionFrequency.yearly,
        );
        expect(nextYearly.year, equals(2027));
        expect(nextYearly.month, equals(1));
        expect(nextYearly.day, equals(15));

        final nextWeekly = SubscriptionService.computeNextRenewalDate(
          fromDate,
          SubscriptionFrequency.weekly,
        );
        expect(nextWeekly.day, equals(22));
      },
    );

    test(
      'detectRecurringSuggestions discovers recurring merchant patterns from transaction history',
      () {
        final txs = [
          Transaction(
            id: 't1',
            amount: 199.0,
            type: TransactionType.expense,
            categoryId: 'cat_entertainment',
            categoryName: 'Entertainment',
            categoryIcon: 'movie',
            categoryColor: 'marigold',
            merchant: 'Spotify India',
            date: DateTime(2026, 6, 10),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          Transaction(
            id: 't2',
            amount: 199.0,
            type: TransactionType.expense,
            categoryId: 'cat_entertainment',
            categoryName: 'Entertainment',
            categoryIcon: 'movie',
            categoryColor: 'marigold',
            merchant: 'Spotify India',
            date: DateTime(2026, 7, 10),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          Transaction(
            id: 't3',
            amount: 199.0,
            type: TransactionType.expense,
            categoryId: 'cat_entertainment',
            categoryName: 'Entertainment',
            categoryIcon: 'movie',
            categoryColor: 'marigold',
            merchant: 'Spotify India',
            date: DateTime(2026, 8, 10),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final suggestions = SubscriptionService.detectRecurringSuggestions(
          transactions: txs,
          existingSubscriptions: [],
        );

        expect(suggestions, isNotEmpty);
        final spotify = suggestions.firstWhere(
          (s) => s.merchant.contains('Spotify'),
        );
        expect(spotify.suggestedAmount, equals(199.0));
        expect(
          spotify.suggestedFrequency,
          equals(SubscriptionFrequency.monthly),
        );
        expect(spotify.matchingTransactions.length, equals(3));
      },
    );
  });
}
