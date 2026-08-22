import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/subscription.dart';
import '../../repositories/subscription_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/merchant_normalization_service.dart';
import '../../services/subscription_service.dart';

final subscriptionsSummaryProvider = Provider<
  ({
    double monthlyTotal,
    double yearlyTotal,
    int activeCount,
    List<Subscription> upcomingRenewals,
  })
>((ref) {
  final subscriptions =
      ref.watch(allSubscriptionsStreamProvider).value ?? const [];
  final active =
      subscriptions
          .where((s) => s.status == SubscriptionStatus.active)
          .toList();

  final monthlyTotal = SubscriptionService.calculateMonthlyTotal(active);
  final yearlyTotal = SubscriptionService.calculateYearlyTotal(active);

  final upcoming =
      active.where((s) => s.isDueSoon(daysThreshold: 7)).toList()
        ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));

  return (
    monthlyTotal: monthlyTotal,
    yearlyTotal: yearlyTotal,
    activeCount: active.length,
    upcomingRenewals: upcoming,
  );
});

final recurringSuggestionsProvider =
    FutureProvider<List<RecurringSubscriptionSuggestion>>((ref) async {
      final transactions =
          await ref.watch(transactionRepositoryProvider).getAllTransactions();
      final subscriptions =
          await ref.watch(subscriptionRepositoryProvider).getAllSubscriptions();

      return SubscriptionService.detectRecurringSuggestions(
        transactions: transactions,
        existingSubscriptions: subscriptions,
      );
    });

class SubscriptionsController extends StateNotifier<AsyncValue<void>> {
  final SubscriptionRepository _repository;
  static const _uuid = Uuid();

  SubscriptionsController(this._repository)
    : super(const AsyncValue.data(null));

  Future<void> addSubscription({
    required String merchant,
    required double amount,
    String currency = 'INR',
    SubscriptionFrequency billingFrequency = SubscriptionFrequency.monthly,
    required DateTime nextRenewalDate,
    String? accountId,
    String category = 'Subscriptions',
    String? paymentMethod,
    String? sourceTransactionId,
    int reminderDaysBefore = 1,
    bool isReminderEnabled = true,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final normalized = MerchantNormalizationService.normalize(merchant);
      final sub = Subscription(
        id: 'sub_${_uuid.v4()}',
        merchant: merchant,
        normalizedMerchant: normalized,
        amount: amount,
        currency: currency,
        billingFrequency: billingFrequency,
        nextRenewalDate: nextRenewalDate,
        accountId: accountId,
        category: category,
        paymentMethod: paymentMethod,
        sourceTransactionId: sourceTransactionId,
        status: SubscriptionStatus.active,
        reminderDaysBefore: reminderDaysBefore,
        isReminderEnabled: isReminderEnabled,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.saveSubscription(sub);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    state = const AsyncValue.loading();
    try {
      final updated = subscription.copyWith(
        normalizedMerchant: MerchantNormalizationService.normalize(
          subscription.merchant,
        ),
        updatedAt: DateTime.now(),
      );
      await _repository.saveSubscription(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubscription(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteSubscription(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String id, SubscriptionStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(id, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFromSuggestion(
    RecurringSubscriptionSuggestion suggestion,
  ) async {
    await addSubscription(
      merchant: suggestion.merchant,
      amount: suggestion.suggestedAmount,
      billingFrequency: suggestion.suggestedFrequency,
      nextRenewalDate: suggestion.nextRenewalDate,
      accountId: suggestion.accountId,
      category: suggestion.category,
      sourceTransactionId:
          suggestion.matchingTransactions.isNotEmpty
              ? suggestion.matchingTransactions.last.id
              : null,
    );
  }
}

final subscriptionsControllerProvider =
    StateNotifierProvider<SubscriptionsController, AsyncValue<void>>((ref) {
      final repo = ref.watch(subscriptionRepositoryProvider);
      return SubscriptionsController(repo);
    });
