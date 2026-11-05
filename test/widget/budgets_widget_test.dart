import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/add_edit_budget_sheet.dart';
import 'package:financeflow/features/budgets/budget_detail_screen.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/budgets/budgets_screen.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  final now = DateTime(2026, 8, 15);

  final testBudget = Budget(
    id: 'b1',
    name: 'Food & Dining',
    categoryId: 'cat_dining',
    categoryName: 'Dining',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    amountLimit: 10000.0,
    startDate: DateTime(2026, 8, 1),
    createdAt: now,
    updatedAt: now,
  );

  final testSummary = BudgetSummary(
    budget: testBudget,
    amountSpent: 4000.0,
    remainingAmount: 6000.0,
    percentageUsed: 0.4,
    amountOverBudget: 0.0,
    daysRemaining: 17,
    totalDaysInPeriod: 31,
    daysElapsed: 15,
    dailyAllowanceRemaining: 352.94,
    projectedPeriodEndSpending: 8266.67,
    isApproachingThreshold: false,
    isExceeded: false,
  );

  final testCategory = Category(
    id: 'cat_dining',
    name: 'Dining',
    iconIdentifier: 'restaurant',
    colorTokenIdentifier: 'clay',
    typeCompatibility: ['expense'],
    createdAt: now,
    updatedAt: now,
  );

  final testTransaction = Transaction(
    id: 'tx1',
    amount: 500.0,
    type: TransactionType.expense,
    categoryId: 'cat_dining',
    categoryName: 'Dining',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    merchant: 'Cafe Delight',
    date: DateTime(2026, 8, 10),
    accountId: 'acc1',
    createdAt: now,
    updatedAt: now,
  );

  testWidgets('BudgetsScreen renders active budgets, overview and progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetSummariesProvider.overrideWithValue(
            AsyncValue.data([testSummary]),
          ),
          overallBudgetSummaryProvider.overrideWithValue(
            const AsyncValue.data((
              totalBudgeted: 10000.0,
              totalSpent: 4000.0,
              totalRemaining: 6000.0,
              overBudgetCount: 0,
            )),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const BudgetsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('TOTAL BUDGET POOL'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('₹6,000 left'), findsOneWidget);
    expect(find.text('40%'), findsWidgets);
    expect(find.text('Add Budget'), findsOneWidget);
  });

  testWidgets('BudgetsScreen renders empty state when no budgets exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetSummariesProvider.overrideWithValue(const AsyncValue.data([])),
          overallBudgetSummaryProvider.overrideWithValue(
            const AsyncValue.data((
              totalBudgeted: 0.0,
              totalSpent: 0.0,
              totalRemaining: 0.0,
              overBudgetCount: 0,
            )),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const BudgetsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No budgets for this month'), findsOneWidget);
    expect(find.text('Create Budget'), findsOneWidget);
  });

  testWidgets('BudgetsScreen renders cleanly in Deep Water dark theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetSummariesProvider.overrideWithValue(
            AsyncValue.data([testSummary]),
          ),
          overallBudgetSummaryProvider.overrideWithValue(
            const AsyncValue.data((
              totalBudgeted: 10000.0,
              totalSpent: 4000.0,
              totalRemaining: 6000.0,
              overBudgetCount: 0,
            )),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.deepWater,
          home: const BudgetsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Budgets'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
  });

  testWidgets(
    'BudgetDetailScreen renders hero metrics, pace and transactions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDashboardMonthProvider.overrideWith(
              (ref) => DateTime(2026, 8, 1),
            ),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: BudgetDetailScreen(budget: testBudget),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Food & Dining'), findsWidgets);
      expect(find.text('DAILY ALLOWANCE'), findsOneWidget);
      expect(find.text('PROJECTED SPEND'), findsOneWidget);
      expect(find.text('Budget Settings'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Cafe Delight'), findsOneWidget);
    },
  );

  testWidgets(
    'AddEditBudgetSheet renders fields, category selection and slider',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const Scaffold(body: AddEditBudgetSheet()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('New Budget Plan'), findsOneWidget);
      expect(find.text('PLANNED SPENDING LIMIT'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Period Cycle'), findsOneWidget);
      expect(find.text('Alert Threshold'), findsOneWidget);
      expect(find.text('Save Budget'), findsOneWidget);
    },
  );
}
