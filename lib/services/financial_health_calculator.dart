import '../models/budget.dart';
import '../models/financial_health.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../models/savings_goal.dart';
import '../models/goal_contribution.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';
import 'balance_calculator.dart';
import 'budget_calculator.dart';
import 'savings_goal_calculator.dart';
import 'subscription_service.dart';

/// Pure domain service calculating explainable financial health score from on-device records
class FinancialHealthCalculator {
  FinancialHealthCalculator._();

  static FinancialHealthReport calculateReport({
    required List<Transaction> transactions,
    required List<Budget> activeBudgets,
    required List<SavingsGoal> activeGoals,
    required Map<String, List<GoalContribution>> contributionsByGoal,
    List<Loan> activeLoans = const [],
    List<Subscription> activeSubscriptions = const [],
    List<Investment> activeInvestments = const [],
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final cashFlow = BalanceCalculator.calculateMonthlyCashFlow(transactions);

    // 1. Savings Rate Component (Max 25 pts)
    final hasIncomeData = cashFlow.totalIncome > 0;
    final double savingsRate =
        hasIncomeData ? (cashFlow.netSavings / cashFlow.totalIncome) : 0.0;
    final double savingsRateScore;
    final String savingsRateSummary;
    final String savingsRateDetail;

    if (!hasIncomeData) {
      savingsRateScore = 0.0;
      savingsRateSummary = 'Not enough data';
      savingsRateDetail =
          'Add your income sources to calculate your monthly savings rate.';
    } else if (savingsRate >= 0.25) {
      savingsRateScore = 25.0;
      savingsRateSummary =
          '${(savingsRate * 100).toStringAsFixed(0)}% savings rate';
      savingsRateDetail =
          'You are saving more than 25% of your income this month.';
    } else if (savingsRate >= 0.10) {
      savingsRateScore = 15.0 + ((savingsRate - 0.10) / 0.15) * 10.0;
      savingsRateSummary =
          '${(savingsRate * 100).toStringAsFixed(0)}% savings rate';
      savingsRateDetail =
          'You are steadily saving between 10% and 25% of your income.';
    } else if (savingsRate > 0) {
      savingsRateScore = (savingsRate / 0.10) * 15.0;
      savingsRateSummary =
          '${(savingsRate * 100).toStringAsFixed(0)}% savings rate';
      savingsRateDetail = 'You have a positive savings margin this month.';
    } else {
      savingsRateScore = 0.0;
      savingsRateSummary = '0% savings rate';
      savingsRateDetail =
          'Monthly spending currently equals or exceeds recorded income.';
    }

    final compSavingsRate = HealthScoreComponent(
      key: 'savings_rate',
      title: 'Savings Rate',
      score: savingsRateScore,
      maxScore: 25.0,
      hasSufficientData: hasIncomeData,
      summary: savingsRateSummary,
      detail: savingsRateDetail,
    );

    // 2. Budget Discipline Component (Max 25 pts)
    final unarchivedBudgets =
        activeBudgets.where((b) => !b.isArchived).toList();
    final hasBudgetData = unarchivedBudgets.isNotEmpty;
    final double budgetScore;
    final String budgetSummary;
    final String budgetDetail;

    if (!hasBudgetData) {
      budgetScore = 0.0;
      budgetSummary = 'Not enough data';
      budgetDetail =
          'Set up category budgets to track how closely your spending aligns with your plans.';
    } else {
      int withinLimitCount = 0;
      for (final b in unarchivedBudgets) {
        final summary = BudgetCalculator.calculateSummary(
          b,
          transactions,
          referenceDate: ref,
        );
        if (!summary.isExceeded) {
          withinLimitCount++;
        }
      }
      final ratio = withinLimitCount / unarchivedBudgets.length;
      budgetScore = ratio * 25.0;
      budgetSummary =
          '$withinLimitCount of ${unarchivedBudgets.length} within limit';
      budgetDetail =
          ratio == 1.0
              ? 'All active budgets are currently within their planned limits.'
              : '$withinLimitCount out of ${unarchivedBudgets.length} budgets are on track this month.';
    }

    final compBudgetDiscipline = HealthScoreComponent(
      key: 'budget_discipline',
      title: 'Budget Discipline',
      score: budgetScore,
      maxScore: 25.0,
      hasSufficientData: hasBudgetData,
      summary: budgetSummary,
      detail: budgetDetail,
    );

    // 3. Cash Flow Stability Component (Max 25 pts)
    final hasTransactions = transactions.isNotEmpty;
    final double cashFlowScore;
    final String cashFlowSummary;
    final String cashFlowDetail;

    if (!hasTransactions) {
      cashFlowScore = 0.0;
      cashFlowSummary = 'Not enough data';
      cashFlowDetail =
          'Record your regular income and daily expenses to calculate cash flow stability.';
    } else if (cashFlow.totalIncome > 0 &&
        cashFlow.totalExpense <= cashFlow.totalIncome * 0.80) {
      cashFlowScore = 25.0;
      cashFlowSummary = 'Positive cash flow buffer';
      cashFlowDetail =
          'Expenses are well below income, maintaining a healthy cash cushion.';
    } else if (cashFlow.netSavings >= 0) {
      cashFlowScore = 18.0;
      cashFlowSummary = 'Balanced cash flow';
      cashFlowDetail = 'Inflow covers outflow with positive margin.';
    } else {
      cashFlowScore = 8.0;
      cashFlowSummary = 'Negative net cash flow';
      cashFlowDetail =
          'Outflow exceeded inflow this period. Consider reviewing top spending categories.';
    }

    final compCashFlow = HealthScoreComponent(
      key: 'cash_flow',
      title: 'Cash Flow Stability',
      score: cashFlowScore,
      maxScore: 25.0,
      hasSufficientData: hasTransactions,
      summary: cashFlowSummary,
      detail: cashFlowDetail,
    );

    // 4. Savings Goal Progress Component (Max 25 pts)
    final hasGoalData = activeGoals.isNotEmpty;
    final double goalScore;
    final String goalSummary;
    final String goalDetail;

    if (!hasGoalData) {
      goalScore = 0.0;
      goalSummary = 'Not enough data';
      goalDetail =
          'Create savings goals to monitor emergency preparedness and planned targets.';
    } else {
      double totalProgress = 0.0;
      for (final g in activeGoals) {
        final contribs = contributionsByGoal[g.id] ?? const [];
        final summary = SavingsGoalCalculator.calculateSummary(
          g,
          contribs,
          referenceDate: ref,
        );
        totalProgress += summary.progressPercentage;
      }
      final avgProgress = totalProgress / activeGoals.length;
      goalScore = avgProgress * 25.0;
      goalSummary =
          '${(avgProgress * 100).toStringAsFixed(0)}% average goal progress';
      goalDetail =
          'Your contributions are steadily moving active targets forward.';
    }

    final compGoalProgress = HealthScoreComponent(
      key: 'goal_progress',
      title: 'Goal Progress',
      score: goalScore,
      maxScore: 25.0,
      hasSufficientData: hasGoalData,
      summary: goalSummary,
      detail: goalDetail,
    );

    // 5. Debt & EMI Load Component (Phase 4, Max 15 pts)
    final unarchivedLoans =
        activeLoans.where((l) => l.status == LoanStatus.active).toList();
    final bool hasDebtEvaluated =
        unarchivedLoans.isNotEmpty || (hasIncomeData && hasTransactions);
    final double debtScore;
    final String debtSummary;
    final String debtDetail;

    if (!hasDebtEvaluated) {
      debtScore = 0.0;
      debtSummary = 'Not enough data';
      debtDetail =
          'Track your loans and EMIs to calculate your Debt-to-Income (DTI) ratio.';
    } else if (unarchivedLoans.isEmpty) {
      debtScore = 15.0;
      debtSummary = 'No active debt obligations';
      debtDetail = 'You have zero active loan or EMI obligations recorded.';
    } else if (!hasIncomeData) {
      debtScore = 8.0;
      debtSummary = '${unarchivedLoans.length} active loans';
      debtDetail =
          'Add your income to measure your exact Debt-to-Income (DTI) ratio.';
    } else {
      final totalMonthlyEmi = unarchivedLoans.fold<double>(
        0.0,
        (s, l) => s + l.emiAmount,
      );
      final dti = totalMonthlyEmi / cashFlow.totalIncome;
      if (dti <= 0.20) {
        debtScore = 15.0;
        debtSummary = '${(dti * 100).toStringAsFixed(0)}% EMI load (Healthy)';
        debtDetail =
            'Your EMI obligations are well within the recommended 20% limit.';
      } else if (dti <= 0.40) {
        debtScore = 10.0;
        debtSummary = '${(dti * 100).toStringAsFixed(0)}% EMI load (Moderate)';
        debtDetail =
            'Your EMI obligations take between 20% and 40% of your monthly income.';
      } else {
        debtScore = 4.0;
        debtSummary = '${(dti * 100).toStringAsFixed(0)}% EMI load (Heavy)';
        debtDetail =
            'EMI obligations exceed 40% of income. Plan repayments to reduce debt load.';
      }
    }

    final compDebtLoad = HealthScoreComponent(
      key: 'debt_load',
      title: 'Debt & EMI Load',
      score: debtScore,
      maxScore: 15.0,
      hasSufficientData: hasDebtEvaluated,
      summary: debtSummary,
      detail: debtDetail,
    );

    // 6. Subscription Load Component (Phase 4, Max 10 pts)
    final unarchivedSubs =
        activeSubscriptions
            .where((s) => s.status == SubscriptionStatus.active)
            .toList();
    final bool hasSubEvaluated =
        unarchivedSubs.isNotEmpty || (hasIncomeData && hasTransactions);
    final double subScore;
    final String subSummary;
    final String subDetail;

    if (!hasSubEvaluated) {
      subScore = 0.0;
      subSummary = 'Not enough data';
      subDetail =
          'Track your recurring subscriptions to analyze subscription burn rate.';
    } else if (unarchivedSubs.isEmpty) {
      subScore = 10.0;
      subSummary = 'No active subscriptions';
      subDetail = 'No recurring subscription commitments recorded.';
    } else if (!hasIncomeData) {
      final monthlySubs = SubscriptionService.calculateMonthlyTotal(
        unarchivedSubs,
      );
      subScore = 7.0;
      subSummary = '${unarchivedSubs.length} active subscriptions';
      subDetail =
          'Monthly subscription total is ₹${monthlySubs.toStringAsFixed(0)}.';
    } else {
      final monthlySubs = SubscriptionService.calculateMonthlyTotal(
        unarchivedSubs,
      );
      final subRatio = monthlySubs / cashFlow.totalIncome;
      if (subRatio <= 0.05) {
        subScore = 10.0;
        subSummary = '${(subRatio * 100).toStringAsFixed(0)}% of income (Lean)';
        subDetail =
            'Subscriptions represent a minimal and controlled portion of your income.';
      } else if (subRatio <= 0.15) {
        subScore = 7.0;
        subSummary =
            '${(subRatio * 100).toStringAsFixed(0)}% of income (Moderate)';
        subDetail =
            'Subscriptions consume between 5% and 15% of your monthly earnings.';
      } else {
        subScore = 3.0;
        subSummary =
            '${(subRatio * 100).toStringAsFixed(0)}% of income (Heavy)';
        subDetail =
            'Recurring services take a significant portion of income. Consider reviewing unused plans.';
      }
    }

    final compSubscriptionLoad = HealthScoreComponent(
      key: 'subscription_load',
      title: 'Subscription Load',
      score: subScore,
      maxScore: 10.0,
      hasSufficientData: hasSubEvaluated,
      summary: subSummary,
      detail: subDetail,
    );

    // 7. Investment Allocation Component (Phase 4, Max 10 pts)
    final unarchivedInvestments =
        activeInvestments.where((i) => !i.isArchived).toList();
    final bool hasInvestmentData = unarchivedInvestments.isNotEmpty;
    final double investmentScore;
    final String investmentSummary;
    final String investmentDetail;

    if (!hasInvestmentData) {
      investmentScore = 0.0;
      investmentSummary = 'Not enough data';
      investmentDetail =
          'Record your investments to analyze portfolio allocation and growth.';
    } else {
      final distinctAssetTypes =
          unarchivedInvestments.map((i) => i.assetType).toSet();
      if (distinctAssetTypes.length >= 2) {
        investmentScore = 10.0;
        investmentSummary =
            '${distinctAssetTypes.length} asset classes (Diversified)';
        investmentDetail =
            'Your portfolio spans across multiple asset classes.';
      } else {
        investmentScore = 7.0;
        investmentSummary = '${unarchivedInvestments.length} holdings recorded';
        investmentDetail = 'Active investment tracking is established.';
      }
    }

    final compInvestmentAllocation = HealthScoreComponent(
      key: 'investment_allocation',
      title: 'Investments',
      score: investmentScore,
      maxScore: 10.0,
      hasSufficientData: hasInvestmentData,
      summary: investmentSummary,
      detail: investmentDetail,
    );

    final components = [
      compSavingsRate,
      compBudgetDiscipline,
      compCashFlow,
      compGoalProgress,
      compDebtLoad,
      compSubscriptionLoad,
      compInvestmentAllocation,
    ];

    final availableComponents =
        components.where((c) => c.hasSufficientData).toList();
    final hasOverallData = availableComponents.length >= 2;

    double totalScore;
    if (!hasOverallData) {
      totalScore = 0.0;
    } else {
      final earned = availableComponents.fold<double>(
        0.0,
        (sum, c) => sum + c.score,
      );
      final maxEarnable = availableComponents.fold<double>(
        0.0,
        (sum, c) => sum + c.maxScore,
      );
      totalScore = maxEarnable > 0 ? (earned / maxEarnable) * 100.0 : 0.0;
    }

    final HealthScoreGrade grade;
    if (!hasOverallData) {
      grade = HealthScoreGrade.insufficientData;
    } else if (totalScore >= 80) {
      grade = HealthScoreGrade.excellent;
    } else if (totalScore >= 65) {
      grade = HealthScoreGrade.strong;
    } else if (totalScore >= 45) {
      grade = HealthScoreGrade.balanced;
    } else {
      grade = HealthScoreGrade.needsAttention;
    }

    return FinancialHealthReport(
      totalScore: totalScore,
      grade: grade,
      components: components,
      hasOverallSufficientData: hasOverallData,
      calculatedAt: ref,
    );
  }
}
