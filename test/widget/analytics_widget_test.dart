import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/analytics/analytics_controller.dart';
import 'package:financeflow/features/analytics/analytics_screen.dart';
import 'package:financeflow/core/period/report_period_provider.dart';
import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('AnalyticsScreen renders metrics and charts when data exists', (
    WidgetTester tester,
  ) async {
    final sampleTx = Transaction(
      id: 'tx_dining_1',
      amount: 1500.0,
      type: TransactionType.expense,
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      date: DateTime(2026, 8, 15),
      createdAt: DateTime(2026, 8, 15),
      updatedAt: DateTime(2026, 8, 15),
      accountId: 'acc_hdfc',
      merchant: 'Swiggy',
      source: TransactionSource.manual,
    );

    final testReport = AnalyticsReport(
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
      timeRange: AnalyticsTimeRange.month,
      totalIncome: 75000.0,
      totalExpense: 25000.0,
      netSavings: 50000.0,
      savingsRate: 0.6667,
      transactionCount: 15,
      averageTransactionAmount: 1666.67,
      highestTransactionAmount: 8000.0,
      categoryBreakdown: const [
        CategorySpend(
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          amount: 15000.0,
          percentage: 0.6,
          transactionCount: 10,
        ),
      ],
      categoryTransactions: {
        'cat_dining': [sampleTx],
      },
      accountBreakdown: const [
        AccountSpend(
          accountId: 'acc_hdfc',
          accountName: 'HDFC Salary',
          totalExpense: 15000.0,
          totalIncome: 75000.0,
          transactionCount: 12,
        ),
      ],
      topMerchants: const [
        MerchantSpend(
          normalizedMerchant: 'Swiggy',
          totalAmount: 12000.0,
          transactionCount: 8,
        ),
      ],
      timeSeries: [
        TimeSeriesPoint(
          date: DateTime(2026, 8, 1),
          label: '1',
          expense: 5000.0,
          income: 75000.0,
        ),
      ],
      dayOfWeekBreakdown: const [
        DayOfWeekSpend(
          weekday: 1,
          dayName: 'Mon',
          totalAmount: 5000.0,
          count: 3,
        ),
      ],
    );

    TransactionQuery? opened;
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rawAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
          analyticsReportProvider.overrideWithValue(
            AsyncValue.data(testReport),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return AnalyticsScreen(onShowTransactions: (q) => opened = q);
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Total Inflow'), findsOneWidget);
    expect(find.text('₹75,000'), findsWidgets);
    expect(find.text('Total Outflow'), findsOneWidget);
    expect(find.text('₹25,000'), findsOneWidget);
    expect(find.text('Net Savings'), findsOneWidget);
    expect(find.text('₹50,000'), findsOneWidget);
    expect(find.text('Where your money went'), findsOneWidget);
    expect(find.text('Dining'), findsWidgets);
    expect(find.text('Swiggy'), findsOneWidget);

    // A category opens the transaction list for exactly that category,
    // period and kind, so the number always reconciles with the list.
    final categoryRow = find.byKey(const ValueKey('category-row-cat_dining'));
    await tester.ensureVisible(categoryRow);
    await tester.pumpAndSettle();
    await tester.tap(categoryRow);
    await tester.pumpAndSettle();

    expect(opened?.categoryId, 'cat_dining');
    expect(opened?.kinds, {TransactionKind.spending});
    expect(opened?.period, capturedRef.read(reportPeriodProvider));
  });
}
