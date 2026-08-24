import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';
import 'merchant_normalization_service.dart';

class RecurringSubscriptionSuggestion {
  final String id;
  final String merchant;
  final String normalizedMerchant;
  final double suggestedAmount;
  final SubscriptionFrequency suggestedFrequency;
  final DateTime lastPaymentDate;
  final DateTime nextRenewalDate;
  final List<Transaction> matchingTransactions;
  final String? accountId;
  final String category;

  const RecurringSubscriptionSuggestion({
    required this.id,
    required this.merchant,
    required this.normalizedMerchant,
    required this.suggestedAmount,
    required this.suggestedFrequency,
    required this.lastPaymentDate,
    required this.nextRenewalDate,
    required this.matchingTransactions,
    this.accountId,
    this.category = 'Subscriptions',
  });
}

class SubscriptionService {
  SubscriptionService._();

  static const _uuid = Uuid();

  /// Calculate total monthly commitment across active subscriptions
  static double calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold<double>(0.0, (sum, s) => sum + s.monthlyEquivalentAmount);
  }

  /// Calculate total yearly commitment across active subscriptions
  static double calculateYearlyTotal(List<Subscription> subscriptions) {
    return subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold<double>(0.0, (sum, s) => sum + s.yearlyEquivalentAmount);
  }

  /// Compute next renewal date from last date & frequency
  static DateTime computeNextRenewalDate(
    DateTime fromDate,
    SubscriptionFrequency frequency,
  ) {
    switch (frequency) {
      case SubscriptionFrequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case SubscriptionFrequency.monthly:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case SubscriptionFrequency.quarterly:
        return DateTime(fromDate.year, fromDate.month + 3, fromDate.day);
      case SubscriptionFrequency.yearly:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
      case SubscriptionFrequency.custom:
        return fromDate.add(const Duration(days: 30));
    }
  }

  /// Scan transaction history to suggest recurring subscriptions on-device
  static List<RecurringSubscriptionSuggestion> detectRecurringSuggestions({
    required List<Transaction> transactions,
    required List<Subscription> existingSubscriptions,
  }) {
    final existingNormalizedMerchants =
        existingSubscriptions
            .map((s) => s.normalizedMerchant.toLowerCase())
            .toSet();

    // Group expense transactions by normalized merchant
    final Map<String, List<Transaction>> byMerchant = {};
    for (final tx in transactions) {
      if (tx.consumptionExpenseAmount <= 0) continue;
      final normalized =
          MerchantNormalizationService.normalize(tx.merchant).toLowerCase();
      if (normalized.isEmpty) continue;
      if (existingNormalizedMerchants.contains(normalized)) continue;

      byMerchant.putIfAbsent(normalized, () => []).add(tx);
    }

    final List<RecurringSubscriptionSuggestion> suggestions = [];

    for (final entry in byMerchant.entries) {
      final txList = entry.value;
      if (txList.length < 2) continue;

      // Sort by date ascending
      txList.sort((a, b) => a.date.compareTo(b.date));

      // Calculate intervals between consecutive transactions
      final List<int> intervals = [];
      for (int i = 0; i < txList.length - 1; i++) {
        final diffDays =
            txList[i + 1].date.difference(txList[i].date).inDays.abs();
        intervals.add(diffDays);
      }

      if (intervals.isEmpty) continue;
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

      // Detect frequency
      SubscriptionFrequency? detectedFreq;
      if (avgInterval >= 5 && avgInterval <= 10) {
        detectedFreq = SubscriptionFrequency.weekly;
      } else if (avgInterval >= 25 && avgInterval <= 35) {
        detectedFreq = SubscriptionFrequency.monthly;
      } else if (avgInterval >= 80 && avgInterval <= 100) {
        detectedFreq = SubscriptionFrequency.quarterly;
      } else if (avgInterval >= 340 && avgInterval <= 380) {
        detectedFreq = SubscriptionFrequency.yearly;
      }

      if (detectedFreq != null) {
        final lastTx = txList.last;
        final avgAmount =
            txList.fold<double>(0.0, (s, t) => s + t.amount) / txList.length;
        final nextRenewal = computeNextRenewalDate(lastTx.date, detectedFreq);

        suggestions.add(
          RecurringSubscriptionSuggestion(
            id: 'sug_${_uuid.v4()}',
            merchant: lastTx.merchant,
            normalizedMerchant: entry.key,
            suggestedAmount: double.parse(avgAmount.toStringAsFixed(2)),
            suggestedFrequency: detectedFreq,
            lastPaymentDate: lastTx.date,
            nextRenewalDate: nextRenewal,
            matchingTransactions: txList,
            accountId: lastTx.accountId,
            category:
                lastTx.categoryName.isNotEmpty
                    ? lastTx.categoryName
                    : 'Subscriptions',
          ),
        );
      }
    }

    return suggestions;
  }
}
