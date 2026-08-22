import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/budgets/budgets_screen.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('BudgetsScreen renders active budgets and progress', (
    WidgetTester tester,
  ) async {
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
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('₹6,000 left'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Add Budget'), findsOneWidget);
  });
}
