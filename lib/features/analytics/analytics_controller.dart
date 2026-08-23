import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/analytics_calculator.dart';

final selectedAnalyticsTimeRangeProvider = StateProvider<AnalyticsTimeRange>((
  ref,
) {
  return AnalyticsTimeRange.month;
});

final analyticsCustomDateRangeProvider =
    StateProvider<({DateTime start, DateTime end})?>((ref) {
      return null;
    });

final selectedAnalyticsAccountIdProvider = StateProvider<String?>((ref) => null);

final selectedAnalyticsTypeProvider = StateProvider<TransactionType?>((ref) => null);

final analyticsRawTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAllTransactions();
});

final analyticsReportProvider = Provider<AsyncValue<AnalyticsReport>>((ref) {
  final transactionsAsync = ref.watch(analyticsRawTransactionsProvider);
  final timeRange = ref.watch(selectedAnalyticsTimeRangeProvider);
  final customRange = ref.watch(analyticsCustomDateRangeProvider);
  final accountId = ref.watch(selectedAnalyticsAccountIdProvider);
  final txType = ref.watch(selectedAnalyticsTypeProvider);

  return transactionsAsync.when(
    data: (transactions) {
      var filtered = transactions;
      if (accountId != null && accountId.isNotEmpty) {
        filtered = filtered.where((t) => t.accountId == accountId || t.toAccountId == accountId).toList();
      }
      if (txType != null) {
        filtered = filtered.where((t) => t.type == txType).toList();
      }

      final report = AnalyticsCalculator.calculateReport(
        allTransactions: filtered,
        timeRange: timeRange,
        customStartDate: customRange?.start,
        customEndDate: customRange?.end,
      );
      return AsyncValue.data(report);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

