import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/period/report_period_provider.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/analytics_calculator.dart';

/// Transactions for the shared report period and the one before it (needed
/// for the "vs last period" comparison), read through the date index.
final analyticsRawTransactionsProvider = StreamProvider<List<Transaction>>((
  ref,
) {
  final period = ref.watch(reportPeriodProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactionsBetween(
    period.previous().start,
    period.endExclusive,
  );
});

final analyticsReportProvider = Provider<AsyncValue<AnalyticsReport>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  return ref
      .watch(analyticsRawTransactionsProvider)
      .whenData(
        (transactions) => AnalyticsCalculator.calculateReport(
          allTransactions: transactions,
          timeRange: AnalyticsCalculator.rangeFor(period.unit),
          forPeriod: period,
        ),
      );
});
