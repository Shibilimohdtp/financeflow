import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/analytics/analytics_controller.dart';
import 'package:financeflow/features/analytics/analytics_screen.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('AnalyticsScreen renders metrics and charts when data exists', (
    WidgetTester tester,
  ) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsReportProvider.overrideWithValue(
            AsyncValue.data(testReport),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const AnalyticsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Analytics & Trends'), findsOneWidget);
    expect(find.text('Total Inflow'), findsOneWidget);
    expect(find.text('₹75,000'), findsOneWidget);
    expect(find.text('Total Outflow'), findsOneWidget);
    expect(find.text('₹25,000'), findsOneWidget);
    expect(find.text('Net Savings'), findsOneWidget);
    expect(find.text('₹50,000'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Dining'), findsWidgets);
    expect(find.text('Swiggy'), findsOneWidget);
  });
}
