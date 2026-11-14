import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:financeflow/features/savings_goals/add_edit_savings_goal_sheet.dart';
import 'package:financeflow/features/savings_goals/add_goal_contribution_sheet.dart';
import 'package:financeflow/features/savings_goals/savings_goal_detail_screen.dart';
import 'package:financeflow/features/savings_goals/savings_goals_controller.dart';
import 'package:financeflow/models/goal_contribution.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/savings_goal_repository.dart'
    show SavingsGoalRepository;
import 'package:financeflow/theme/stillwater_theme.dart';

class _FakeSavingsGoalRepo implements SavingsGoalRepository {
  final List<SavingsGoal> goals = [];
  final List<GoalContribution> contributions = [];

  @override
  Future<void> addContribution(GoalContribution contribution) async {
    contributions.add(contribution);
  }

  @override
  Future<void> deleteContribution(String id) async {
    contributions.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async {
    return goals.where((g) => g.id == id).firstOrNull;
  }

  @override
  Future<void> saveGoal(SavingsGoal goal) async {
    goals.removeWhere((g) => g.id == goal.id);
    goals.add(goal);
  }

  @override
  Stream<List<GoalContribution>> watchAllContributions() {
    return Stream.value(contributions);
  }

  @override
  Stream<List<SavingsGoal>> watchAllGoals() {
    return Stream.value(goals);
  }

  @override
  Stream<List<GoalContribution>> watchContributionsForGoal(String goalId) {
    return Stream.value(
      contributions.where((c) => c.goalId == goalId).toList(),
    );
  }

  @override
  Future<List<SavingsGoal>> getAllGoals() async => goals;

  @override
  Future<List<GoalContribution>> getAllContributions() async => contributions;

  @override
  Future<List<GoalContribution>> getContributionsForGoal(String goalId) async {
    return contributions.where((c) => c.goalId == goalId).toList();
  }
}

void main() {
  group('Savings Goals Interactions & Sheets', () {
    testWidgets(
      'AddEditSavingsGoalSheet: selecting template prefills form and consequence',
      (tester) async {
        final repo = _FakeSavingsGoalRepo();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              savingsGoalRepositoryProvider.overrideWithValue(repo),
              allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              theme: StillwaterTheme.daylight,
              home: const Scaffold(body: AddEditSavingsGoalSheet()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('New savings goal'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
        expect(find.text('Emergency Fund'), findsOneWidget);
        expect(find.text('Trip / Vacation'), findsOneWidget);

        // Tap Emergency Fund template
        await tester.tap(find.text('Emergency Fund'));
        await tester.pumpAndSettle();

        // Name and amount should be prefilled
        expect(find.text('Emergency Fund'), findsWidgets);
        // The amount field groups digits; the preview shows the same.
        expect(find.text('1,00,000'), findsOneWidget);
        expect(find.textContaining('gets you there by'), findsOneWidget);
      },
    );

    testWidgets(
      'AddGoalContributionSheet: quick chips update deposit amount and projection',
      (tester) async {
        final repo = _FakeSavingsGoalRepo();
        final testGoal = SavingsGoal(
          id: 'g1',
          name: 'Japan Trip',
          targetAmount: 50000.0,
          targetDate: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              savingsGoalRepositoryProvider.overrideWithValue(repo),
              allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
              goalContributionsForGoalProvider(
                'g1',
              ).overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              theme: StillwaterTheme.daylight,
              home: Scaffold(body: AddGoalContributionSheet(goal: testGoal)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Add money'), findsWidgets);
        expect(find.text('+ ₹5,000'), findsOneWidget);

        // Tap +₹5,000 chip
        await tester.tap(find.text('+ ₹5,000'));
        await tester.pumpAndSettle();

        expect(find.text('5,000'), findsOneWidget);
        expect(
          find.textContaining('Reaches 10% of the target'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'SavingsGoalDetailScreen: renders hero, history, and shows delete dialog',
      (tester) async {
        final repo = _FakeSavingsGoalRepo();
        final now = DateTime.now();
        final testGoal = SavingsGoal(
          id: 'g2',
          name: 'Vehicle Downpayment',
          targetAmount: 200000.0,
          targetDate: now.add(const Duration(days: 180)),
          createdAt: now,
          updatedAt: now,
        );
        final testContribution = GoalContribution(
          id: 'c1',
          goalId: 'g2',
          amount: 25000.0,
          date: now.subtract(const Duration(days: 5)),
          createdAt: now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              savingsGoalRepositoryProvider.overrideWithValue(repo),
              allSavingsGoalsStreamProvider.overrideWith(
                (ref) => Stream.value([testGoal]),
              ),
              goalContributionsForGoalProvider(
                'g2',
              ).overrideWith((ref) => Stream.value([testContribution])),
              allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
            ],
            child: MaterialApp(
              theme: StillwaterTheme.deepWater,
              home: SavingsGoalDetailScreen(goal: testGoal),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Vehicle Downpayment'), findsWidgets);
        expect(find.text('Saved so far'), findsOneWidget);
        expect(find.text('Add Funds to Goal'), findsOneWidget);
        expect(find.text('Contribution history'), findsOneWidget);
        expect(find.text('Direct Deposit'), findsOneWidget);

        // Tap delete goal button
        await tester.scrollUntilVisible(find.text('Delete Savings Goal'), 100);
        await tester.tap(find.text('Delete Savings Goal'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Savings Goal?'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      },
    );
  });
}
