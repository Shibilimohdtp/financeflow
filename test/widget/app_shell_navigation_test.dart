import 'package:financeflow/app/router.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/analytics/analytics_controller.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/alert_repository.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<dynamic> createOverrides() {
    return [
      settingsStreamProvider.overrideWith(
        (ref) => Stream.value(const AppSettings()),
      ),
      monthlyCashFlowProvider.overrideWithValue(
        const AsyncValue.data(
          MonthlyCashFlow(totalIncome: 0, totalExpense: 0, netSavings: 0),
        ),
      ),
      accountsWithBalancesProvider.overrideWithValue(const AsyncValue.data([])),
      totalNetWorthProvider.overrideWithValue(const AsyncValue.data(0.0)),
      recentTransactionsProvider.overrideWith((ref) => Stream.value([])),
      filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
      allTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      categoriesStreamProvider.overrideWith((ref) => Stream.value([])),
      rawAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
      pendingTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      pendingReviewCountProvider.overrideWithValue(0),
      unreadAlertsCountProvider.overrideWithValue(0),
      budgetSummariesProvider.overrideWithValue(const AsyncValue.data([])),
      overallBudgetSummaryProvider.overrideWithValue(
        const AsyncValue.data((
          totalBudgeted: 0.0,
          totalSpent: 0.0,
          totalRemaining: 0.0,
          overBudgetCount: 0,
        )),
      ),
      analyticsReportProvider.overrideWithValue(
        AsyncValue.data(
          AnalyticsReport(
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 31),
            timeRange: AnalyticsTimeRange.month,
            totalIncome: 0.0,
            totalExpense: 0.0,
            netSavings: 0.0,
            savingsRate: 0.0,
            transactionCount: 0,
            averageTransactionAmount: 0.0,
            highestTransactionAmount: 0.0,
            categoryBreakdown: const [],
            topMerchants: const [],
            timeSeries: const [],
            dayOfWeekBreakdown: const [],
          ),
        ),
      ),
    ];
  }

  testWidgets(
    'Pressing system back button from any of the 4 non-home screens returns to Home (index 0), and exits from Home',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late StateController<int> navIndexController;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [...createOverrides()],
          child: Consumer(
            builder: (context, ref, _) {
              navIndexController = ref.watch(currentNavIndexProvider.notifier);
              return MaterialApp(
                theme: StillwaterTheme.daylight,
                home: const AppShell(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially on Home (index 0)
      expect(navIndexController.state, 0);

      // 1. Navigate to Money (index 1)
      await tester.tap(find.text('Money'));
      await tester.pumpAndSettle();
      expect(navIndexController.state, 1);

      // Press Android system back button -> returns true (handled) and switches to Home (index 0)
      final handledMoney = await tester.binding.handlePopRoute();
      expect(handledMoney, isTrue);
      await tester.pumpAndSettle();
      expect(navIndexController.state, 0);

      // 2. Navigate to Plan (index 2)
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();
      expect(navIndexController.state, 2);

      // Press Android system back button -> returns true (handled) and switches to Home (index 0)
      final handledPlan = await tester.binding.handlePopRoute();
      expect(handledPlan, isTrue);
      await tester.pumpAndSettle();
      expect(navIndexController.state, 0);

      // 3. Navigate to Insights (index 3)
      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();
      expect(navIndexController.state, 3);

      // Press Android system back button -> returns true (handled) and switches to Home (index 0)
      final handledInsights = await tester.binding.handlePopRoute();
      expect(handledInsights, isTrue);
      await tester.pumpAndSettle();
      expect(navIndexController.state, 0);

      // 4. Navigate to More (index 4)
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(navIndexController.state, 4);

      // Press Android system back button -> returns true (handled) and switches to Home (index 0)
      final handledMore = await tester.binding.handlePopRoute();
      expect(handledMore, isTrue);
      await tester.pumpAndSettle();
      expect(navIndexController.state, 0);

      // 5. When on Home (index 0), system back button allows pop / exit
      final handledHome = await tester.binding.handlePopRoute();
      // Since AppShell is the root route and canPop is true on index 0, handlePopRoute returns false (passed up to OS to exit)
      expect(handledHome, isFalse);
    },
  );
}
