import '../core/formatting/currency_formatter.dart';
import '../models/budget.dart';
import '../models/insight.dart';
import '../models/savings_goal.dart';
import '../models/goal_contribution.dart';
import '../models/transaction.dart';
import 'balance_calculator.dart';
import 'budget_calculator.dart';

/// Pure domain service generating factual, non-judgmental offline insights from on-device data
class InsightEngine {
  InsightEngine._();

  static List<Insight> generateInsights({
    required List<Transaction> currentMonthTransactions,
    required List<Transaction> previousMonthTransactions,
    required List<Budget> activeBudgets,
    required List<SavingsGoal> activeGoals,
    required Map<String, List<GoalContribution>> contributionsByGoal,
    Set<String> dismissedInsightIds = const {},
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final List<Insight> insights = [];

    // Filter current month expenses and income
    final currentExpenses =
        currentMonthTransactions
            .where((t) => t.consumptionExpenseAmount > 0)
            .toList();
    final previousExpenses =
        previousMonthTransactions
            .where((t) => t.consumptionExpenseAmount > 0)
            .toList();

    final currentCashFlow = BalanceCalculator.calculateMonthlyCashFlow(
      currentMonthTransactions,
    );

    // 1. Savings Rate Insight
    if (currentCashFlow.totalIncome > 0 && currentCashFlow.netSavings > 0) {
      final rate =
          (currentCashFlow.netSavings / currentCashFlow.totalIncome) * 100;
      final id = 'insight_savings_rate_${ref.year}_${ref.month}';
      if (!dismissedInsightIds.contains(id)) {
        insights.add(
          Insight(
            id: id,
            type: InsightType.savingsRate,
            title: 'Current Savings Rate',
            description:
                'You have saved ${rate.toStringAsFixed(0)}% of your recorded income (${CurrencyFormatter.format(currentCashFlow.netSavings)}) this month.',
            severity:
                rate >= 20 ? InsightSeverity.success : InsightSeverity.info,
            dateRange: 'This month',
            supportingValues: {
              'savingsRate': rate,
              'netSavings': currentCashFlow.netSavings,
              'totalIncome': currentCashFlow.totalIncome,
            },
            createdAt: ref,
          ),
        );
      }
    }

    // 2. Largest Expense Category Insight
    if (currentExpenses.isNotEmpty) {
      final Map<String, ({double amount, String name})> catTotals = {};
      for (final tx in currentExpenses) {
        final current =
            catTotals[tx.categoryId] ?? (amount: 0.0, name: tx.categoryName);
        catTotals[tx.categoryId] = (
          amount: current.amount + tx.consumptionExpenseAmount,
          name: tx.categoryName.isNotEmpty ? tx.categoryName : 'Expenses',
        );
      }

      if (catTotals.isNotEmpty) {
        final topCatEntry = catTotals.entries.reduce(
          (a, b) => a.value.amount > b.value.amount ? a : b,
        );
        final topAmount = topCatEntry.value.amount;
        final topName = topCatEntry.value.name;

        final id =
            'insight_top_category_${ref.year}_${ref.month}_${topCatEntry.key}';
        if (!dismissedInsightIds.contains(id) && topAmount > 0) {
          insights.add(
            Insight(
              id: id,
              type: InsightType.topCategory,
              title: 'Top Spending Category',
              description:
                  'Your largest expense category this month is $topName at ${CurrencyFormatter.format(topAmount)}.',
              severity: InsightSeverity.info,
              dateRange: 'This month',
              supportingValues: {
                'categoryId': topCatEntry.key,
                'categoryName': topName,
                'amount': topAmount,
              },
              createdAt: ref,
            ),
          );
        }
      }
    }

    // 3. Category Period-over-Period Spend Change Insight
    if (currentExpenses.isNotEmpty && previousExpenses.isNotEmpty) {
      final Map<String, double> prevCatMap = {};
      for (final tx in previousExpenses) {
        prevCatMap[tx.categoryId] =
            (prevCatMap[tx.categoryId] ?? 0.0) + tx.consumptionExpenseAmount;
      }

      final Map<String, ({double amount, String name})> currCatMap = {};
      for (final tx in currentExpenses) {
        final curr =
            currCatMap[tx.categoryId] ?? (amount: 0.0, name: tx.categoryName);
        currCatMap[tx.categoryId] = (
          amount: curr.amount + tx.consumptionExpenseAmount,
          name: tx.categoryName,
        );
      }

      for (final entry in currCatMap.entries) {
        final prevAmount = prevCatMap[entry.key];
        if (prevAmount != null &&
            prevAmount >= 500 &&
            entry.value.amount >= 500) {
          final diff = entry.value.amount - prevAmount;
          final percentChange = ((diff / prevAmount) * 100).round();

          if (percentChange.abs() >= 20) {
            final id =
                'insight_cat_change_${ref.year}_${ref.month}_${entry.key}';
            if (!dismissedInsightIds.contains(id)) {
              final isIncrease = percentChange > 0;
              insights.add(
                Insight(
                  id: id,
                  type: InsightType.spendingComparison,
                  title: '${entry.value.name} Spending Shift',
                  description:
                      isIncrease
                          ? 'You spent ${percentChange.abs()}% more on ${entry.value.name} (${CurrencyFormatter.format(entry.value.amount)}) compared to last month (${CurrencyFormatter.format(prevAmount)}).'
                          : 'You spent ${percentChange.abs()}% less on ${entry.value.name} (${CurrencyFormatter.format(entry.value.amount)}) compared to last month (${CurrencyFormatter.format(prevAmount)}).',
                  severity:
                      isIncrease
                          ? InsightSeverity.warning
                          : InsightSeverity.success,
                  dateRange: 'Month-over-month',
                  supportingValues: {
                    'categoryId': entry.key,
                    'categoryName': entry.value.name,
                    'percentChange': percentChange,
                    'currentAmount': entry.value.amount,
                    'previousAmount': prevAmount,
                  },
                  createdAt: ref,
                ),
              );
              break; // Limit to 1 category comparison to prevent card overload
            }
          }
        }
      }
    }

    // 4. Budget Pace / Exhaustion Insight
    for (final budget in activeBudgets) {
      if (budget.isArchived) continue;
      final summary = BudgetCalculator.calculateSummary(
        budget,
        currentMonthTransactions,
        referenceDate: ref,
      );

      // If budget is on pace to exhaust significantly early
      if (summary.daysElapsed >= 5 &&
          summary.daysRemaining > 0 &&
          !summary.isExceeded) {
        final dailyPace = summary.amountSpent / summary.daysElapsed;
        if (dailyPace > 0) {
          final projectedExhaustionDays =
              (summary.remainingAmount / dailyPace).round();
          if (projectedExhaustionDays < summary.daysRemaining &&
              projectedExhaustionDays <= 10) {
            final id =
                'insight_budget_pace_${ref.year}_${ref.month}_${budget.id}';
            if (!dismissedInsightIds.contains(id)) {
              insights.add(
                Insight(
                  id: id,
                  type: InsightType.budgetExhaustion,
                  title: '${budget.name} Pace',
                  description:
                      'At current spending pace, your ${budget.name} budget will reach its limit in approximately $projectedExhaustionDays days with ${summary.daysRemaining} days remaining in the month.',
                  severity: InsightSeverity.warning,
                  dateRange: 'This month',
                  supportingValues: {
                    'budgetId': budget.id,
                    'projectedDays': projectedExhaustionDays,
                    'remainingDays': summary.daysRemaining,
                  },
                  createdAt: ref,
                ),
              );
              break; // One budget pace insight is sufficient
            }
          }
        }
      }
    }

    // 5. Activity / Frequency Shift (e.g. Dining or Groceries transactions)
    if (currentExpenses.length >= 5 && previousExpenses.isNotEmpty) {
      final diningCurrent =
          currentExpenses
              .where(
                (t) =>
                    t.categoryId == 'cat_dining' || t.categoryId == 'cat_food',
              )
              .length;
      final diningPrev =
          previousExpenses
              .where(
                (t) =>
                    t.categoryId == 'cat_dining' || t.categoryId == 'cat_food',
              )
              .length;

      if (diningCurrent > 0 &&
          diningPrev > 0 &&
          (diningCurrent - diningPrev).abs() >= 5) {
        final diff = diningCurrent - diningPrev;
        final id = 'insight_freq_dining_${ref.year}_${ref.month}';
        if (!dismissedInsightIds.contains(id)) {
          insights.add(
            Insight(
              id: id,
              type: InsightType.frequencyChange,
              title: 'Dining Activity',
              description:
                  diff > 0
                      ? 'You made $diff more dining payments this month ($diningCurrent total) than last month ($diningPrev total).'
                      : 'You made ${diff.abs()} fewer dining payments this month ($diningCurrent total) than last month ($diningPrev total).',
              severity:
                  diff > 0 ? InsightSeverity.info : InsightSeverity.success,
              dateRange: 'Month-over-month',
              supportingValues: {
                'currentCount': diningCurrent,
                'previousCount': diningPrev,
                'difference': diff,
              },
              createdAt: ref,
            ),
          );
        }
      }
    }

    return insights;
  }
}
