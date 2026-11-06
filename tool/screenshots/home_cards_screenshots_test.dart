// DS-B12: Home's redesigned cards in every state, light and dark.
//
//   flutter test tool/screenshots/home_cards_screenshots_test.dart --update-goldens
//
// Writes goldens/home_cards_<state>_<mode>.png; copy them to
// docs/design-system/screenshots/ds-b12/.
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/widgets/actionable_items_section.dart';
import 'package:financeflow/features/dashboard/widgets/budget_overview_card.dart';
import 'package:financeflow/features/dashboard/widgets/cash_flow_card.dart';
import 'package:financeflow/features/dashboard/widgets/home_card_error.dart';
import 'package:financeflow/features/dashboard/widgets/savings_goals_overview_card.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

final _now = DateTime(2026, 11, 15);

BudgetSummary _budget(String name, String icon, double spent, double limit) {
  final used = spent / limit;
  return BudgetSummary(
    budget: Budget(
      id: name,
      name: name,
      categoryId: name,
      categoryName: name,
      categoryIcon: icon,
      categoryColor: 'clay',
      amountLimit: limit,
      startDate: DateTime(2026, 11),
      createdAt: _now,
      updatedAt: _now,
    ),
    amountSpent: spent,
    remainingAmount: limit - spent,
    percentageUsed: used,
    amountOverBudget: spent > limit ? spent - limit : 0,
    daysRemaining: 15,
    totalDaysInPeriod: 30,
    daysElapsed: 15,
    dailyAllowanceRemaining: 0,
    projectedPeriodEndSpending: spent * 2,
    isApproachingThreshold: used >= 0.8 && used <= 1,
    isExceeded: used > 1,
  );
}

SavingsGoalSummary _goal(String name, double saved, double target, int y) =>
    SavingsGoalSummary(
      goal: SavingsGoal(
        id: name,
        name: name,
        targetAmount: target,
        targetDate: DateTime(y, 4),
        createdAt: _now,
        updatedAt: _now,
      ),
      currentAmount: saved,
      remainingAmount: target - saved,
      progressPercentage: saved / target,
      suggestedMonthlyContribution: 0,
      suggestedWeeklyContribution: 0,
      estimatedCompletionDate: DateTime(y, 3),
      contributionCount: 3,
      isTargetReached: saved >= target,
    );

Widget _budgets(List<BudgetSummary> list, {bool hidden = false}) {
  final limit = list.fold<double>(0, (s, b) => s + b.budget.amountLimit);
  final spent = list.fold<double>(0, (s, b) => s + b.amountSpent);
  return BudgetOverviewCard(
    totalBudgeted: limit,
    totalSpent: spent,
    totalRemaining: limit - spent,
    overBudgetCount: list.where((b) => b.isExceeded).length,
    activeBudgets: list,
    isPrivacyBlur: hidden,
    onViewBudgets: () {},
  );
}

Widget _cashFlow(
  MonthlyCashFlow flow, {
  bool hidden = false,
  bool bars = true,
}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
  child: CashFlowCard(
    cashFlow: flow,
    month: DateTime(2026, 11),
    periodLabel: 'November 2026',
    isPrivacyBlur: hidden,
    trendMetric: const PeriodComparisonMetric(
      expenseChangePct: -12.4,
      incomeChangePct: 0,
      hasPreviousData: true,
    ),
    chartItems:
        bars
            ? const [
              BarChartItem(label: 'W1', value: 14200, secondaryValue: 82000),
              BarChartItem(label: 'W2', value: 9800, secondaryValue: 0),
              BarChartItem(label: 'W3', value: 16400, secondaryValue: 2500),
              BarChartItem(label: 'W4', value: 7810, secondaryValue: 0),
            ]
            : const [],
    onOpenAnalytics: () {},
  ),
);

const _flow = MonthlyCashFlow(
  totalIncome: 84500,
  totalExpense: 48210,
  netSavings: 36290,
);

Widget _goals({bool hidden = false}) => SavingsGoalsOverviewCard(
  totalTarget: 650000,
  totalSaved: 172000,
  totalRemaining: 478000,
  completedCount: 1,
  totalGoals: 3,
  isPrivacyBlur: hidden,
  goals: [
    _goal('Emergency fund', 92000, 200000, 2027),
    _goal('Goa trip', 30000, 60000, 2027),
    _goal('Car', 50000, 390000, 2029),
  ],
  onViewGoals: () {},
);

Widget _attention() => ActionableItemsSection(
  pendingReviewCount: 3,
  upcomingSubscriptions: [
    Subscription(
      id: 's1',
      merchant: 'Netflix',
      normalizedMerchant: 'netflix',
      amount: 649,
      nextRenewalDate: _now.add(const Duration(days: 1)),
      createdAt: _now,
      updatedAt: _now,
    ),
  ],
  overBudgetCount: 1,
  isPrivacyBlur: false,
  onOpenNeedsReview: () {},
  onOpenLoanDetail: (_) {},
  onOpenLoans: () {},
  onOpenSubscriptions: () {},
  onOpenBudgets: () {},
  onOpenAlerts: () {},
);

Widget _label(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.fromLTRB(
    FfSpace.pageMargin,
    FfSpace.lg,
    FfSpace.pageMargin,
    FfSpace.xs,
  ),
  child: Text(
    text.toUpperCase(),
    style: context.ff.text.labelSm.copyWith(
      color: context.ff.color.textTertiary,
    ),
  ),
);

Widget _padded(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
  child: child,
);

void main() {
  setUpAll(loadAppFonts);

  final sheets = <String, (double, List<(String, Widget)>)>{
    'normal': (
      1,
      [
        ('Needs attention', _attention()),
        ('Cash flow', _cashFlow(_flow)),
        (
          'Budgets · spending fast',
          _budgets([
            _budget('Dining', 'restaurant', 7800, 9000),
            _budget('Groceries', 'shopping_cart', 6100, 12000),
            _budget('Fuel', 'local_gas_station', 3900, 5000),
          ]),
        ),
        ('Savings goals', _goals()),
      ],
    ),
    'states': (
      1,
      [
        (
          'Cash flow · negative net',
          _cashFlow(
            const MonthlyCashFlow(
              totalIncome: 12000,
              totalExpense: 1873450.5,
              netSavings: -1861450.5,
            ),
          ),
        ),
        (
          'Cash flow · empty period',
          _cashFlow(
            const MonthlyCashFlow(
              totalIncome: 0,
              totalExpense: 0,
              netSavings: 0,
            ),
            bars: false,
          ),
        ),
        (
          'Budgets · over plan',
          _budgets([
            _budget('Dining', 'restaurant', 11200, 9000),
            _budget('Groceries', 'shopping_cart', 5100, 12000),
          ]),
        ),
        (
          'Budgets · on pace',
          _budgets([_budget('Groceries', 'shopping_cart', 4100, 12000)]),
        ),
        (
          'Budgets · none yet',
          const BudgetOverviewCard(
            totalBudgeted: 0,
            totalSpent: 0,
            totalRemaining: 0,
            overBudgetCount: 0,
            onViewBudgets: _noop,
          ),
        ),
        ('Loading', _padded(const CashFlowCardSkeleton())),
        ('', _padded(const BudgetOverviewCardSkeleton())),
        ('', _padded(const SavingsGoalsCardSkeleton())),
        ('Error', _padded(HomeCardError(what: 'cash flow', onRetry: () {}))),
      ],
    ),
    'hidden': (
      1,
      [
        ('Cash flow · amounts hidden', _cashFlow(_flow, hidden: true)),
        (
          'Budgets · amounts hidden',
          _budgets([
            _budget('Dining', 'restaurant', 7800, 9000),
            _budget('Groceries', 'shopping_cart', 6100, 12000),
          ], hidden: true),
        ),
        ('Goals · amounts hidden', _goals(hidden: true)),
      ],
    ),
    'large_text': (
      2,
      [
        ('Needs attention · 2× text', _attention()),
        ('Cash flow · 2× text', _cashFlow(_flow)),
        (
          'Budgets · 2× text',
          _budgets([_budget('Dining', 'restaurant', 7800, 9000)]),
        ),
        ('Goals · 2× text', _goals()),
      ],
    ),
  };

  for (final MapEntry(key: name, value: (scale, items)) in sheets.entries) {
    for (final (mode, theme) in [
      ('light', StillwaterTheme.daylight),
      ('dark', StillwaterTheme.deepWater),
    ]) {
      testWidgets('home cards $name, $mode', (tester) async {
        tester.view.physicalSize = Size(390, scale > 1 ? 3400 : 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(390, scale > 1 ? 3400 : 2400),
                textScaler: TextScaler.linear(scale),
              ),
              child: FfAurora(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Builder(
                    builder:
                        (context) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (label, child) in items) ...[
                              if (label.isNotEmpty)
                                _label(context, label)
                              else
                                const SizedBox(height: FfSpace.xs),
                              child,
                            ],
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/home_cards_${name}_$mode.png'),
        );
      });
    }
  }
}

void _noop() {}
