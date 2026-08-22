import 'dart:math';
import '../models/goal_contribution.dart';
import '../models/savings_goal.dart';

/// Pure domain service for calculating savings goal progress, periodic suggestions, and forecasts
class SavingsGoalCalculator {
  SavingsGoalCalculator._();

  /// Calculate summary metrics for a savings goal given its contributions
  static SavingsGoalSummary calculateSummary(
    SavingsGoal goal,
    List<GoalContribution> contributions, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();

    // Sum contributions
    double currentAmount = 0.0;
    for (final c in contributions) {
      currentAmount += c.amount;
    }

    final remainingAmount = max(0.0, goal.targetAmount - currentAmount);
    final isTargetReached = currentAmount >= goal.targetAmount;
    final progressPercentage =
        goal.targetAmount > 0
            ? (currentAmount / goal.targetAmount).clamp(0.0, 1.0)
            : (isTargetReached ? 1.0 : 0.0);

    // Calculate time left
    final daysRemaining =
        goal.targetDate.isAfter(ref)
            ? goal.targetDate.difference(ref).inDays
            : 0;

    final double suggestedMonthly;
    final double suggestedWeekly;

    if (daysRemaining > 0 && remainingAmount > 0) {
      final monthsRemaining = max(1.0, daysRemaining / 30.4375);
      final weeksRemaining = max(1.0, daysRemaining / 7.0);
      suggestedMonthly = remainingAmount / monthsRemaining;
      suggestedWeekly = remainingAmount / weeksRemaining;
    } else if (remainingAmount > 0) {
      // Overdue goal with remaining balance
      suggestedMonthly = remainingAmount;
      suggestedWeekly = remainingAmount;
    } else {
      suggestedMonthly = 0.0;
      suggestedWeekly = 0.0;
    }

    // Completion forecast based on contribution history pace
    DateTime? estimatedCompletion;
    if (isTargetReached) {
      estimatedCompletion = ref;
    } else if (contributions.length >= 2 && remainingAmount > 0) {
      // Sort contributions chronologically
      final sorted = List<GoalContribution>.from(contributions)
        ..sort((a, b) => a.date.compareTo(b.date));

      final firstDate = sorted.first.date;
      final lastDate = sorted.last.date;
      final spanDays = max(1, lastDate.difference(firstDate).inDays);

      // Exclude first contribution amount if it acts like a lump-sum initial deposit,
      // or compute total progress over spanDays
      final progressInSpan = currentAmount;
      final dailyContributionRate = progressInSpan / max(spanDays, 7);

      if (dailyContributionRate > 0) {
        final daysNeeded = (remainingAmount / dailyContributionRate).ceil();
        if (daysNeeded <= 3650) {
          // Max forecast limit 10 years
          estimatedCompletion = ref.add(Duration(days: daysNeeded));
        }
      }
    }

    return SavingsGoalSummary(
      goal: goal,
      currentAmount: currentAmount,
      remainingAmount: remainingAmount,
      progressPercentage: progressPercentage,
      suggestedMonthlyContribution: suggestedMonthly,
      suggestedWeeklyContribution: suggestedWeekly,
      estimatedCompletionDate: estimatedCompletion,
      contributionCount: contributions.length,
      isTargetReached: isTargetReached,
    );
  }

  /// Calculates total target and total saved across all active goals
  static ({
    double totalTarget,
    double totalSaved,
    double totalRemaining,
    int completedCount,
    int totalGoals,
  })
  calculateOverallSummary(
    List<SavingsGoal> goals,
    Map<String, List<GoalContribution>> contributionsByGoal, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    double totalTarget = 0.0;
    double totalSaved = 0.0;
    int completedCount = 0;

    for (final goal in goals) {
      totalTarget += goal.targetAmount;
      final contribs = contributionsByGoal[goal.id] ?? const [];
      final summary = calculateSummary(goal, contribs, referenceDate: ref);
      totalSaved += summary.currentAmount;
      if (summary.isTargetReached || goal.isCompleted) {
        completedCount++;
      }
    }

    final totalRemaining = max(0.0, totalTarget - totalSaved);

    return (
      totalTarget: totalTarget,
      totalSaved: totalSaved,
      totalRemaining: totalRemaining,
      completedCount: completedCount,
      totalGoals: goals.length,
    );
  }
}
