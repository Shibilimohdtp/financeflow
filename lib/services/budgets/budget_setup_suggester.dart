import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/budget.dart';
import 'budget_ledger.dart';

/// One proposed budget from recent spending.
class SuggestedBudget {
  final String categoryId;

  /// Median monthly spending, rounded up to a friendly figure.
  final int suggestedMinor;

  /// The unrounded median, shown as "usually ₹X".
  final int medianMinor;
  final int monthsWithSpending;
  final BudgetGroup group;

  const SuggestedBudget({
    required this.categoryId,
    required this.suggestedMinor,
    required this.medianMinor,
    required this.monthsWithSpending,
    required this.group,
  });
}

class BudgetSetupSuggestion {
  final List<SuggestedBudget> budgets;

  /// Median monthly earned income over the months that had any; null when
  /// there is no recorded income.
  final int? estimatedMonthlyIncomeMinor;

  /// Full months of history that had any spending (0–3).
  final int monthsWithData;

  const BudgetSetupSuggestion({
    required this.budgets,
    required this.estimatedMonthlyIncomeMinor,
    required this.monthsWithData,
  });

  int get totalMinor => budgets.fold(0, (s, b) => s + b.suggestedMinor);
}

/// Suggests monthly budgets from the last full months of real spending.
///
/// Amounts are based on what the user actually spends, not on templates:
/// those are the budgets people keep. The 50/30/20 rule is shown as a guide
/// by the UI ([PlanSplit]) and never fills in amounts.
class BudgetSetupSuggester {
  BudgetSetupSuggester._();

  static const int monthsAnalysed = 3;

  /// Default categories by stable seed id. Custom categories start in Other.
  static const Map<String, BudgetGroup> defaultGroups = {
    'cat_food': BudgetGroup.essentials,
    'cat_groceries': BudgetGroup.essentials,
    'cat_transport': BudgetGroup.essentials,
    'cat_fuel': BudgetGroup.essentials,
    'cat_bills': BudgetGroup.essentials,
    'cat_utilities': BudgetGroup.essentials,
    'cat_healthcare': BudgetGroup.essentials,
    'cat_insurance': BudgetGroup.essentials,
    'cat_education': BudgetGroup.essentials,
    'cat_emi': BudgetGroup.essentials,
    'cat_loans': BudgetGroup.essentials,
    'cat_taxes': BudgetGroup.essentials,
    'cat_dining': BudgetGroup.lifestyle,
    'cat_shopping': BudgetGroup.lifestyle,
    'cat_travel': BudgetGroup.lifestyle,
    'cat_entertainment': BudgetGroup.lifestyle,
    'cat_subscriptions': BudgetGroup.lifestyle,
  };

  static BudgetGroup groupFor(String categoryId) =>
      defaultGroups[categoryId] ?? BudgetGroup.other;

  /// [eligibleCategoryIds] are the categories that may get a budget (active,
  /// usable for expenses, not already budgeted). The months used are the
  /// [monthsAnalysed] full calendar months before the one containing [now].
  static BudgetSetupSuggestion suggest({
    required BudgetLedger ledger,
    required Iterable<String> eligibleCategoryIds,
    required DateTime now,
  }) {
    final current = Period.containing(PeriodUnit.month, now);
    final months = [
      for (var i = 1; i <= monthsAnalysed; i++) current.shift(-i),
    ];
    final eligible = eligibleCategoryIds.toSet();

    final monthsWithData =
        months
            .where(
              (m) => ledger.spendingCategoryIds.any(
                (id) => ledger.hasSpending([id], m),
              ),
            )
            .length;
    // A newer user may have one month of history; ask for spending in at
    // least two months only once there are two to look at.
    final minMonths = monthsWithData >= 2 ? 2 : 1;

    final budgets = <SuggestedBudget>[];
    if (monthsWithData > 0) {
      for (final id in ledger.spendingCategoryIds) {
        if (!eligible.contains(id)) continue;
        final totals = [
          for (final m in months) ledger.spentMinor([id], m),
        ];
        final withSpend = totals.where((t) => t > 0).length;
        if (withSpend < minMonths) continue;
        // Median of the months with data, so months before the user started
        // recording do not drag it to zero.
        final considered =
            (monthsWithData >= monthsAnalysed
                  ? totals
                  : totals.where((t) => t > 0).toList())
              ..sort();
        final median = _median(considered);
        if (median <= 0) continue;
        budgets.add(
          SuggestedBudget(
            categoryId: id,
            suggestedMinor: MoneyMath.niceCeilMinor(median),
            medianMinor: median,
            monthsWithSpending: withSpend,
            group: groupFor(id),
          ),
        );
      }
    }
    budgets.sort((a, b) => b.suggestedMinor.compareTo(a.suggestedMinor));

    final incomes =
        [
            for (final m in months) ledger.incomeMinor(m),
          ].where((v) => v > 0).toList()
          ..sort();

    return BudgetSetupSuggestion(
      budgets: budgets,
      estimatedMonthlyIncomeMinor: incomes.isEmpty ? null : _median(incomes),
      monthsWithData: monthsWithData,
    );
  }

  static int _median(List<int> sorted) {
    if (sorted.isEmpty) return 0;
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) ~/ 2;
  }
}

/// How a monthly plan splits income, for the 50/30/20 guide line.
class PlanSplit {
  final int incomeMinor;
  final int essentialsMinor;
  final int lifestyleMinor;
  final int otherMinor;
  final int billsMinor;
  final int savingsMinor;

  const PlanSplit({
    required this.incomeMinor,
    required this.essentialsMinor,
    required this.lifestyleMinor,
    required this.otherMinor,
    required this.billsMinor,
    required this.savingsMinor,
  });

  /// Bills and EMIs are commitments, so they count as needs.
  double get needsShare => _share(essentialsMinor + billsMinor);
  double get wantsShare => _share(lifestyleMinor + otherMinor);
  double get savingsShare => _share(savingsMinor);

  /// Income not yet given a job; negative when the plan exceeds income.
  int get unplannedMinor =>
      incomeMinor -
      essentialsMinor -
      lifestyleMinor -
      otherMinor -
      billsMinor -
      savingsMinor;

  double _share(int minor) => incomeMinor > 0 ? minor / incomeMinor : 0;
}
