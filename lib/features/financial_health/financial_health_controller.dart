import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/financial_health.dart';
import '../../models/goal_contribution.dart';
import '../../repositories/investment_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/financial_health_calculator.dart';
import '../budgets/budgets_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../savings_goals/savings_goals_controller.dart';

final financialHealthReportProvider =
    Provider<AsyncValue<FinancialHealthReport>>((ref) {
      final monthTxAsync = ref.watch(monthTransactionsProvider);
      final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
      final goalsAsync = ref.watch(allSavingsGoalsStreamProvider);
      final contribsAsync = ref.watch(allGoalContributionsStreamProvider);
      final subsAsync = ref.watch(allSubscriptionsStreamProvider);
      final loansAsync = ref.watch(allLoansStreamProvider);
      final invsAsync = ref.watch(allInvestmentsStreamProvider);
      final selectedMonth = ref.watch(selectedDashboardMonthProvider);

      if (monthTxAsync.isLoading ||
          budgetsAsync.isLoading ||
          goalsAsync.isLoading ||
          contribsAsync.isLoading ||
          subsAsync.isLoading ||
          loansAsync.isLoading ||
          invsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final transactions = monthTxAsync.value ?? const [];
      final budgets = budgetsAsync.value ?? const [];
      final goals = goalsAsync.value ?? const [];
      final contributions = contribsAsync.value ?? const [];
      final subscriptions = subsAsync.value ?? const [];
      final loans = loansAsync.value ?? const [];
      final investments = invsAsync.value ?? const [];

      final Map<String, List<GoalContribution>> map = {};
      for (final c in contributions) {
        map.putIfAbsent(c.goalId, () => []).add(c);
      }

      final report = FinancialHealthCalculator.calculateReport(
        transactions: transactions,
        activeBudgets: budgets,
        activeGoals: goals,
        contributionsByGoal: map,
        activeLoans: loans,
        activeSubscriptions: subscriptions,
        activeInvestments: investments,
        referenceDate: selectedMonth,
      );

      return AsyncValue.data(report);
    });
