// Screenshot capture of Home inside the app shell (DS-B4), not part of the
// test suite. Uses only APIs that exist before and after DS-B4 (AppShell,
// providers), so compare.py can capture both commits.
//
//   flutter test tool/screenshots/home_screenshots_test.dart --update-goldens
import 'package:financeflow/app/router.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/analytics/analytics_controller.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/alert_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

const _size = Size(390, 1640);

void main() {
  setUpAll(loadAppFonts);

  final now = DateTime(2026, 11, 5, 19);
  Account account(String id, String name, AccountType type, double balance) =>
      Account(
        id: id,
        name: name,
        type: type,
        openingBalance: balance,
        currentBalance: balance,
        createdAt: now,
        updatedAt: now,
      );
  final accounts = [
    account('a1', 'Salary account', AccountType.bank, 124500),
    account('a2', 'Cash wallet', AccountType.cash, 6200),
    account('a3', 'Credit card', AccountType.creditCard, -18450),
  ];
  Transaction tx(
    String id,
    String merchant,
    double amount,
    TransactionType type,
    String category,
  ) => Transaction(
    id: id,
    amount: amount,
    type: type,
    categoryId: category,
    categoryName: category,
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    merchant: merchant,
    date: now,
    accountId: 'a1',
    createdAt: now,
    updatedAt: now,
  );
  final loan = Loan(
    id: 'l1',
    name: 'Home loan',
    lender: 'Bank',
    loanType: LoanType.homeLoan,
    principalAmount: 2400000,
    interestRate: 8.4,
    tenureMonths: 240,
    startDate: DateTime(2024, 4, 6),
    expectedEndDate: DateTime(2044, 4, 6),
    emiAmount: 18450,
    paymentDay: 6,
    totalPrincipalPaid: 612000,
    outstandingPrincipal: 1788000,
    nextDueDate: now.add(const Duration(days: 12)),
    createdAt: now,
    updatedAt: now,
  );

  final overrides = [
    settingsStreamProvider.overrideWith(
      (ref) => Stream.value(const AppSettings()),
    ),
    monthlyCashFlowProvider.overrideWithValue(
      const AsyncValue.data(
        MonthlyCashFlow(
          totalIncome: 82000,
          totalExpense: 48210,
          netSavings: 33790,
        ),
      ),
    ),
    accountsWithBalancesProvider.overrideWithValue(AsyncValue.data(accounts)),
    totalNetWorthProvider.overrideWithValue(const AsyncValue.data(112250.0)),
    recentTransactionsProvider.overrideWith(
      (ref) => Stream.value([
        tx('t1', 'Weekly market', 2340, TransactionType.expense, 'Groceries'),
        tx('t2', 'Salary', 82000, TransactionType.income, 'Income'),
        tx('t3', 'Corner café', 454, TransactionType.expense, 'Eating out'),
      ]),
    ),
    filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
    allTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
    categoriesStreamProvider.overrideWith((ref) => Stream.value([])),
    rawAccountsStreamProvider.overrideWith((ref) => Stream.value(accounts)),
    pendingTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
    pendingReviewCountProvider.overrideWithValue(4),
    unreadAlertsCountProvider.overrideWithValue(1),
    allLoansStreamProvider.overrideWith((ref) => Stream.value([loan])),
    allSubscriptionsStreamProvider.overrideWith((ref) => Stream.value([])),
    activeAlertsStreamProvider.overrideWith((ref) => Stream.value([])),
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
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 11, 30),
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

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('home, $mode', (tester) async {
      tester.view.physicalSize = _size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [...overrides],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/home_$mode.png'),
      );
    });
  }
}
