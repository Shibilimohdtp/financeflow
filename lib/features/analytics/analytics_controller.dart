import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics_calculator.dart';
import '../transactions/transactions_controller.dart';

final selectedAnalyticsTimeRangeProvider = StateProvider<AnalyticsTimeRange>((
  ref,
) {
  return AnalyticsTimeRange.month;
});

final analyticsCustomDateRangeProvider =
    StateProvider<({DateTime start, DateTime end})?>((ref) {
      return null;
    });

final analyticsReportProvider = Provider<AsyncValue<AnalyticsReport>>((ref) {
  final transactionsAsync = ref.watch(filteredTransactionsProvider);
  final timeRange = ref.watch(selectedAnalyticsTimeRangeProvider);
  final customRange = ref.watch(analyticsCustomDateRangeProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: transactions,
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
