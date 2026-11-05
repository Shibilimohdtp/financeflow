import 'dart:math';
import '../core/period/period.dart';
import '../models/budget.dart';
import '../models/transaction.dart';

/// Pure domain service for local budget calculations and period boundaries
class BudgetCalculator {
  BudgetCalculator._();

  /// Determine start and end date for a given budget and target reference date
  static ({DateTime start, DateTime end}) getPeriodBounds(
    Budget budget,
    DateTime referenceDate,
  ) {
    switch (budget.period) {
      case BudgetPeriod.weekly:
      case BudgetPeriod.monthly:
      case BudgetPeriod.yearly:
        final period = Period.containing(switch (budget.period) {
          BudgetPeriod.weekly => PeriodUnit.week,
          BudgetPeriod.monthly => PeriodUnit.month,
          _ => PeriodUnit.year,
        }, referenceDate);
        return (start: period.start, end: period.endInclusive);

      case BudgetPeriod.custom:
        final start = budget.startDate;
        final end =
            budget.endDate ??
            DateTime(
              budget.startDate.year + 1,
              budget.startDate.month,
              budget.startDate.day,
            );
        return (start: start, end: end);
    }
  }

  /// Calculate spending for a budget from a list of transactions
  /// Strictly filters for:
  /// 1. Expense type only (Income, transfer, investment excluded)
  /// 2. Matching category ID
  /// 3. Within the period date boundaries
  static double calculateSpending(
    Budget budget,
    List<Transaction> transactions, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final bounds = getPeriodBounds(budget, ref);

    double total = 0.0;
    for (final tx in transactions) {
      if (tx.consumptionExpenseAmount <= 0) continue;
      if (tx.categoryId != budget.categoryId) continue;

      if (!tx.date.isBefore(bounds.start) && !tx.date.isAfter(bounds.end)) {
        total += tx.consumptionExpenseAmount;
      }
    }
    return total;
  }

  /// Calculate full summary metrics for a budget
  static BudgetSummary calculateSummary(
    Budget budget,
    List<Transaction> transactions, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final bounds = getPeriodBounds(budget, ref);
    final amountSpent = calculateSpending(
      budget,
      transactions,
      referenceDate: ref,
    );

    final remainingAmount = max(0.0, budget.amountLimit - amountSpent);
    final percentageUsed =
        budget.amountLimit > 0 ? (amountSpent / budget.amountLimit) : 0.0;
    final amountOverBudget =
        amountSpent > budget.amountLimit
            ? (amountSpent - budget.amountLimit)
            : 0.0;
    final isExceeded = amountSpent > budget.amountLimit;
    final isApproachingThreshold =
        !isExceeded && (percentageUsed >= budget.alertThreshold);

    // Days calculations
    final totalDaysInPeriod = max(
      1,
      bounds.end.difference(bounds.start).inDays + 1,
    );

    // Days elapsed from start of period up to referenceDate (clamped between 1 and totalDays)
    final daysSinceStart =
        ref.isBefore(bounds.start)
            ? 0
            : ref.isAfter(bounds.end)
            ? totalDaysInPeriod
            : max(1, ref.difference(bounds.start).inDays + 1);

    // Days remaining from referenceDate to end of period
    final daysRemaining =
        ref.isAfter(bounds.end)
            ? 0
            : ref.isBefore(bounds.start)
            ? totalDaysInPeriod
            : max(0, bounds.end.difference(ref).inDays + 1);

    // Daily allowance remaining
    final dailyAllowance =
        daysRemaining > 0 ? (remainingAmount / daysRemaining) : 0.0;

    // Projected spend: based on current spending pace per day
    final double projectedSpending;
    if (daysSinceStart > 0 && amountSpent > 0) {
      final dailyPace = amountSpent / daysSinceStart;
      projectedSpending = dailyPace * totalDaysInPeriod;
    } else {
      projectedSpending = amountSpent;
    }

    return BudgetSummary(
      budget: budget,
      amountSpent: amountSpent,
      remainingAmount: remainingAmount,
      percentageUsed: percentageUsed,
      amountOverBudget: amountOverBudget,
      daysRemaining: daysRemaining,
      totalDaysInPeriod: totalDaysInPeriod,
      daysElapsed: daysSinceStart,
      dailyAllowanceRemaining: dailyAllowance,
      projectedPeriodEndSpending: projectedSpending,
      isApproachingThreshold: isApproachingThreshold,
      isExceeded: isExceeded,
    );
  }

  /// Calculates total budgeted vs total spent across all active budgets
  static ({
    double totalBudgeted,
    double totalSpent,
    double totalRemaining,
    int overBudgetCount,
  })
  calculateOverallSummary(
    List<Budget> activeBudgets,
    List<Transaction> transactions, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    double totalBudgeted = 0.0;
    double totalSpent = 0.0;
    int overBudgetCount = 0;

    for (final budget in activeBudgets) {
      if (budget.isArchived) continue;
      final summary = calculateSummary(
        budget,
        transactions,
        referenceDate: ref,
      );
      totalBudgeted += budget.amountLimit;
      totalSpent += summary.amountSpent;
      if (summary.isExceeded) {
        overBudgetCount++;
      }
    }

    final totalRemaining = max(0.0, totalBudgeted - totalSpent);

    return (
      totalBudgeted: totalBudgeted,
      totalSpent: totalSpent,
      totalRemaining: totalRemaining,
      overBudgetCount: overBudgetCount,
    );
  }
}
