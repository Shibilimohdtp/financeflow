// Screenshot capture of the Insights tab (DS-B8b).
//
//   flutter test tool/screenshots/insights_screenshots_test.dart --update-goldens
import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/core/period/report_period_provider.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/analytics/analytics_controller.dart';
import 'package:financeflow/features/analytics/analytics_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

const _size = Size(390, 2100);

void main() {
  setUpAll(loadAppFonts);

  final sampleDate = DateTime(2026, 11, 15);
  final start = DateTime(2026, 11, 1);
  final end = DateTime(2026, 11, 30);

  final tx1 = Transaction(
    id: 'tx_1',
    amount: 14500.0,
    type: TransactionType.expense,
    categoryId: 'dining',
    categoryName: 'Dining & Drinks',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    date: sampleDate,
    createdAt: sampleDate,
    updatedAt: sampleDate,
    accountId: 'acc_1',
    merchant: 'Swiggy',
    source: TransactionSource.manual,
  );

  final report = AnalyticsReport(
    startDate: start,
    endDate: end,
    timeRange: AnalyticsTimeRange.month,
    totalIncome: 125000.0,
    totalExpense: 68450.0,
    netSavings: 56550.0,
    savingsRate: 0.4524,
    transactionCount: 42,
    averageTransactionAmount: 1630.0,
    highestTransactionAmount: 14500.0,
    categoryBreakdown: const [
      CategorySpend(
        categoryId: 'dining',
        categoryName: 'Dining & Drinks',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        amount: 24200.0,
        percentage: 0.354,
        transactionCount: 18,
      ),
      CategorySpend(
        categoryId: 'groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColor: 'moss',
        amount: 18400.0,
        percentage: 0.269,
        transactionCount: 12,
      ),
      CategorySpend(
        categoryId: 'bills',
        categoryName: 'Utilities & Bills',
        categoryIcon: 'bolt',
        categoryColor: 'tide',
        amount: 12600.0,
        percentage: 0.184,
        transactionCount: 4,
      ),
      CategorySpend(
        categoryId: 'transit',
        categoryName: 'Transit',
        categoryIcon: 'directions_car',
        categoryColor: 'dusk',
        amount: 7800.0,
        percentage: 0.114,
        transactionCount: 5,
      ),
      CategorySpend(
        categoryId: 'subs',
        categoryName: 'Subscriptions',
        categoryIcon: 'subscriptions',
        categoryColor: 'rose',
        amount: 5450.0,
        percentage: 0.079,
        transactionCount: 3,
      ),
    ],
    categoryTransactions: {
      'dining': [tx1],
    },
    accountBreakdown: const [
      AccountSpend(
        accountId: 'acc_1',
        accountName: 'HDFC Salary Account',
        totalExpense: 52000.0,
        totalIncome: 125000.0,
        transactionCount: 34,
      ),
      AccountSpend(
        accountId: 'acc_2',
        accountName: 'ICICI Credit Card',
        totalExpense: 16450.0,
        totalIncome: 0.0,
        transactionCount: 8,
      ),
    ],
    topMerchants: const [
      MerchantSpend(
        normalizedMerchant: 'Swiggy',
        totalAmount: 14200.0,
        transactionCount: 12,
      ),
      MerchantSpend(
        normalizedMerchant: 'Nature Basket',
        totalAmount: 9800.0,
        transactionCount: 4,
      ),
      MerchantSpend(
        normalizedMerchant: 'Zepto',
        totalAmount: 8600.0,
        transactionCount: 8,
      ),
      MerchantSpend(
        normalizedMerchant: 'Bescom',
        totalAmount: 6200.0,
        transactionCount: 1,
      ),
    ],
    timeSeries: [
      TimeSeriesPoint(
        date: DateTime(2026, 11, 1),
        label: '1–7 Nov',
        expense: 14200.0,
        income: 125000.0,
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 11, 8),
        label: '8–14 Nov',
        expense: 19800.0,
        income: 0.0,
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 11, 15),
        label: '15–21 Nov',
        expense: 18450.0,
        income: 0.0,
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 11, 22),
        label: '22–28 Nov',
        expense: 16000.0,
        income: 0.0,
      ),
    ],
    dayOfWeekBreakdown: const [
      DayOfWeekSpend(weekday: 1, dayName: 'Mon', totalAmount: 8200.0, count: 6),
      DayOfWeekSpend(weekday: 2, dayName: 'Tue', totalAmount: 6400.0, count: 5),
      DayOfWeekSpend(
        weekday: 3,
        dayName: 'Wed',
        totalAmount: 11200.0,
        count: 8,
      ),
      DayOfWeekSpend(weekday: 4, dayName: 'Thu', totalAmount: 7100.0, count: 4),
      DayOfWeekSpend(
        weekday: 5,
        dayName: 'Fri',
        totalAmount: 14800.0,
        count: 9,
      ),
      DayOfWeekSpend(
        weekday: 6,
        dayName: 'Sat',
        totalAmount: 12450.0,
        count: 7,
      ),
      DayOfWeekSpend(weekday: 7, dayName: 'Sun', totalAmount: 8300.0, count: 3),
    ],
  );

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('insights, $mode', (tester) async {
      tester.view.physicalSize = _size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportPeriodProvider.overrideWith(
              (ref) =>
                  Period.containing(PeriodUnit.month, DateTime(2026, 11, 15)),
            ),
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([
                Account(
                  id: 'acc_1',
                  name: 'HDFC Salary Account',
                  type: AccountType.bank,
                  createdAt: sampleDate,
                  updatedAt: sampleDate,
                ),
              ]),
            ),
            analyticsReportProvider.overrideWithValue(AsyncValue.data(report)),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const AnalyticsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/insights_$mode.png'),
      );
    });
  }
}
