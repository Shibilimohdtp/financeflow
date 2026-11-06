import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/savings_goals/savings_goals_controller.dart';
import 'package:financeflow/features/savings_goals/savings_goals_screen.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('SavingsGoalsScreen renders goals and targets', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 8, 15);

    final testGoal = SavingsGoal(
      id: 'g1',
      name: 'MacBook Pro',
      targetAmount: 120000.0,
      targetDate: DateTime(2027, 2, 1),
      createdAt: now,
      updatedAt: now,
    );

    final testSummary = SavingsGoalSummary(
      goal: testGoal,
      currentAmount: 60000.0,
      remainingAmount: 60000.0,
      progressPercentage: 0.5,
      suggestedMonthlyContribution: 10000.0,
      suggestedWeeklyContribution: 2500.0,
      contributionCount: 2,
      isTargetReached: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savingsGoalSummariesProvider.overrideWithValue(
            AsyncValue.data([testSummary]),
          ),
          overallSavingsGoalSummaryProvider.overrideWithValue(
            const AsyncValue.data((
              totalTarget: 120000.0,
              totalSaved: 60000.0,
              totalRemaining: 60000.0,
              completedCount: 0,
              totalGoals: 1,
            )),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const SavingsGoalsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Savings Goals'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);
    // ₹60,000 appears in both the Tide summary hero and the active goal card
    expect(find.text('₹60,000'), findsNWidgets(2));
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Add Goal'), findsOneWidget);
  });
}
