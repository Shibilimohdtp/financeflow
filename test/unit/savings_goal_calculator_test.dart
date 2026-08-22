import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/goal_contribution.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/services/savings_goal_calculator.dart';

void main() {
  group('SavingsGoalCalculator Tests', () {
    final now = DateTime(2026, 8, 1);
    final targetDate = DateTime(2027, 2, 1); // 6 months (approx 184 days)

    final laptopGoal = SavingsGoal(
      id: 'g_laptop',
      name: 'MacBook Pro',
      targetAmount: 120000.0,
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
    );

    test(
      'Calculates current amount, remaining, and progress percentage correctly',
      () {
        final contributions = [
          GoalContribution(
            id: 'c1',
            goalId: 'g_laptop',
            amount: 30000.0,
            date: DateTime(2026, 8, 5),
            createdAt: now,
          ),
          GoalContribution(
            id: 'c2',
            goalId: 'g_laptop',
            amount: 30000.0,
            date: DateTime(2026, 8, 15),
            createdAt: now,
          ),
        ];

        final summary = SavingsGoalCalculator.calculateSummary(
          laptopGoal,
          contributions,
          referenceDate: now,
        );
        expect(summary.currentAmount, equals(60000.0));
        expect(summary.remainingAmount, equals(60000.0));
        expect(summary.progressPercentage, equals(0.5)); // 50%
        expect(summary.isTargetReached, isFalse);
        expect(summary.contributionCount, equals(2));
        // Suggested monthly: 60,000 / ~6 months = ~10,000
        expect(summary.suggestedMonthlyContribution, closeTo(10000.0, 500.0));
      },
    );

    test(
      'Forecast returns null when there is insufficient contribution history (< 2 contributions)',
      () {
        final singleContrib = [
          GoalContribution(
            id: 'c1',
            goalId: 'g_laptop',
            amount: 20000.0,
            date: DateTime(2026, 8, 5),
            createdAt: now,
          ),
        ];

        final summary = SavingsGoalCalculator.calculateSummary(
          laptopGoal,
          singleContrib,
          referenceDate: now,
        );
        expect(summary.estimatedCompletionDate, isNull);
      },
    );

    test(
      'Forecast returns estimated completion date when multiple contributions exist',
      () {
        final multipleContribs = [
          GoalContribution(
            id: 'c1',
            goalId: 'g_laptop',
            amount: 20000.0,
            date: DateTime(2026, 6, 1),
            createdAt: now,
          ),
          GoalContribution(
            id: 'c2',
            goalId: 'g_laptop',
            amount: 20000.0,
            date: DateTime(2026, 7, 1),
            createdAt: now,
          ),
          GoalContribution(
            id: 'c3',
            goalId: 'g_laptop',
            amount: 20000.0,
            date: DateTime(2026, 8, 1),
            createdAt: now,
          ),
        ];

        final summary = SavingsGoalCalculator.calculateSummary(
          laptopGoal,
          multipleContribs,
          referenceDate: now,
        );
        expect(summary.currentAmount, equals(60000.0));
        expect(summary.estimatedCompletionDate, isNotNull);
        expect(summary.estimatedCompletionDate!.isAfter(now), isTrue);
      },
    );

    test(
      'Marks target reached and caps progress at 100% when goal is fully funded',
      () {
        final fullContribs = [
          GoalContribution(
            id: 'c1',
            goalId: 'g_laptop',
            amount: 150000.0, // > 120,000
            date: DateTime(2026, 8, 10),
            createdAt: now,
          ),
        ];

        final summary = SavingsGoalCalculator.calculateSummary(
          laptopGoal,
          fullContribs,
          referenceDate: now,
        );
        expect(summary.isTargetReached, isTrue);
        expect(summary.remainingAmount, equals(0.0));
        expect(summary.progressPercentage, equals(1.0));
        expect(summary.suggestedMonthlyContribution, equals(0.0));
      },
    );
  });
}
