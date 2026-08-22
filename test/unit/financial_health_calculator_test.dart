import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/financial_health.dart';
import 'package:financeflow/models/goal_contribution.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/financial_health_calculator.dart';

void main() {
  group('FinancialHealthCalculator Tests', () {
    final now = DateTime(2026, 8, 15);

    test(
      'Returns building history status when there is insufficient transaction and budget data',
      () {
        final report = FinancialHealthCalculator.calculateReport(
          transactions: [],
          activeBudgets: [],
          activeGoals: [],
          contributionsByGoal: {},
          referenceDate: now,
        );

        expect(report.hasOverallSufficientData, isFalse);
        expect(report.grade, equals(HealthScoreGrade.insufficientData));
        expect(report.components.every((c) => !c.hasSufficientData), isTrue);
      },
    );

    test(
      'Calculates strong/excellent score with solid savings rate and on-track budgets',
      () {
        final transactions = [
          Transaction(
            id: 't_inc',
            amount: 100000.0,
            type: TransactionType.income,
            categoryId: 'cat_salary',
            categoryName: 'Salary',
            categoryIcon: 'payments',
            categoryColor: 'grove',
            merchant: 'Employer Payroll',
            date: DateTime(2026, 8, 1),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          Transaction(
            id: 't_exp',
            amount: 40000.0, // 60% savings rate (60k net savings)
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Swiggy',
            date: DateTime(2026, 8, 5),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final budgets = [
          Budget(
            id: 'b1',
            name: 'Food',
            categoryId: 'cat_dining',
            amountLimit: 50000.0, // 40k spent <= 50k limit -> on track
            startDate: DateTime(2026, 8, 1),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final goals = [
          SavingsGoal(
            id: 'g1',
            name: 'Emergency Fund',
            targetAmount: 50000.0,
            targetDate: DateTime(2026, 12, 31),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final contributions = {
          'g1': [
            GoalContribution(
              id: 'c1',
              goalId: 'g1',
              amount: 25000.0, // 50% progress
              date: DateTime(2026, 8, 10),
              createdAt: now,
            ),
          ],
        };

        final report = FinancialHealthCalculator.calculateReport(
          transactions: transactions,
          activeBudgets: budgets,
          activeGoals: goals,
          contributionsByGoal: contributions,
          referenceDate: now,
        );

        expect(report.hasOverallSufficientData, isTrue);
        expect(report.totalScore, greaterThanOrEqualTo(80.0));
        expect(report.grade, equals(HealthScoreGrade.excellent));

        // Check savings rate component
        final srComp = report.components.firstWhere(
          (c) => c.key == 'savings_rate',
        );
        expect(srComp.hasSufficientData, isTrue);
        expect(srComp.score, equals(25.0));

        // Check budget discipline component
        final bdComp = report.components.firstWhere(
          (c) => c.key == 'budget_discipline',
        );
        expect(bdComp.hasSufficientData, isTrue);
        expect(bdComp.score, equals(25.0));
      },
    );

    test(
      'Marks unavailable components as Not enough data without crashing or skewing',
      () {
        final transactions = [
          Transaction(
            id: 't_exp',
            amount: 5000.0,
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Cafe',
            date: DateTime(2026, 8, 5),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        // No budgets, no goals, no income
        final report = FinancialHealthCalculator.calculateReport(
          transactions: transactions,
          activeBudgets: [],
          activeGoals: [],
          contributionsByGoal: {},
          referenceDate: now,
        );

        final bdComp = report.components.firstWhere(
          (c) => c.key == 'budget_discipline',
        );
        expect(bdComp.hasSufficientData, isFalse);
        expect(bdComp.summary, equals('Not enough data'));

        final goalComp = report.components.firstWhere(
          (c) => c.key == 'goal_progress',
        );
        expect(goalComp.hasSufficientData, isFalse);
        expect(goalComp.summary, equals('Not enough data'));
      },
    );
  });
}
