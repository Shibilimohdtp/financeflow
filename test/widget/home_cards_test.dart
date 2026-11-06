// DS-B12: Home's redesigned cards in their states (normal, empty, negative,
// hidden amounts, 2× text, light and dark) and their tap callbacks.
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/widgets/budget_overview_card.dart';
import 'package:financeflow/features/dashboard/widgets/cash_flow_card.dart';
import 'package:financeflow/features/dashboard/widgets/home_card_error.dart';
import 'package:financeflow/features/dashboard/widgets/savings_goals_overview_card.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/shared/widgets/ff_row.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCard(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    theme: FfTheme.build(FfPalettes.all.first, brightness),
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 1200),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  ),
);

const _flow = MonthlyCashFlow(
  totalIncome: 82000,
  totalExpense: 48210,
  netSavings: 33790,
);
const _bars = [
  BarChartItem(label: 'W1', value: 12000, secondaryValue: 82000),
  BarChartItem(label: 'W2', value: 18000, secondaryValue: 0),
  BarChartItem(label: 'W3', value: 18210, secondaryValue: 0),
];
const _down = PeriodComparisonMetric(
  expenseChangePct: -20,
  incomeChangePct: 0,
  hasPreviousData: true,
);

CashFlowCard _cashFlow({
  MonthlyCashFlow flow = _flow,
  List<BarChartItem>? bars = _bars,
  bool hidden = false,
  VoidCallback? onOpen,
}) => CashFlowCard(
  cashFlow: flow,
  month: DateTime(2026, 11),
  periodLabel: 'November 2026',
  isPrivacyBlur: hidden,
  chartItems: bars,
  trendMetric: _down,
  onOpenAnalytics: onOpen ?? () {},
);

BudgetSummary _budget(String id, double spent, double limit) {
  final now = DateTime(2026, 11, 15);
  final used = spent / limit;
  return BudgetSummary(
    budget: Budget(
      id: id,
      name: 'Budget $id',
      categoryId: 'cat_$id',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      amountLimit: limit,
      startDate: DateTime(2026, 11, 1),
      createdAt: now,
      updatedAt: now,
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

BudgetOverviewCard _budgets(
  List<BudgetSummary> list, {
  bool hidden = false,
  VoidCallback? onOpen,
}) {
  final limit = list.fold<double>(0, (s, b) => s + b.budget.amountLimit);
  final spent = list.fold<double>(0, (s, b) => s + b.amountSpent);
  return BudgetOverviewCard(
    totalBudgeted: limit,
    totalSpent: spent,
    totalRemaining: limit - spent,
    overBudgetCount: list.where((b) => b.isExceeded).length,
    activeBudgets: list,
    isPrivacyBlur: hidden,
    onViewBudgets: onOpen ?? () {},
  );
}

SavingsGoalSummary _goal(
  String name,
  double saved,
  double target,
  DateTime due,
) {
  final now = DateTime(2026, 11, 6);
  return SavingsGoalSummary(
    goal: SavingsGoal(
      id: name,
      name: name,
      targetAmount: target,
      targetDate: due,
      createdAt: now,
      updatedAt: now,
    ),
    currentAmount: saved,
    remainingAmount: target - saved,
    progressPercentage: saved / target,
    suggestedMonthlyContribution: 0,
    suggestedWeeklyContribution: 0,
    estimatedCompletionDate: DateTime(2027, 3),
    contributionCount: 2,
    isTargetReached: saved >= target,
  );
}

void main() {
  group('SavingsGoalsOverviewCard', () {
    final goals = [
      _goal('Car', 20000, 400000, DateTime(2028)),
      _goal('Trip', 30000, 60000, DateTime(2027, 4)),
      _goal('Laptop', 90000, 90000, DateTime(2026, 12)),
    ];
    SavingsGoalsOverviewCard card({
      bool hidden = false,
      VoidCallback? onOpen,
    }) => SavingsGoalsOverviewCard(
      totalTarget: 550000,
      totalSaved: 140000,
      totalRemaining: 410000,
      completedCount: 1,
      totalGoals: 3,
      isPrivacyBlur: hidden,
      goals: goals,
      onViewGoals: onOpen ?? () {},
    );

    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('normal, ${brightness.name}, ${scale}x', (tester) async {
          await pumpCard(
            tester,
            card(),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.textContaining('1 of 3 reached'), findsOneWidget);
          // The open goal due soonest, not the reached one.
          expect(find.text('Trip'), findsOneWidget);
          expect(find.text('50%'), findsOneWidget);
          expect(find.text('On track for March 2027'), findsOneWidget);
        });
      }
    }

    testWidgets('taps open goals; hidden amounts keep only shares', (
      tester,
    ) async {
      var opened = 0;
      final handle = tester.ensureSemantics();
      await pumpCard(tester, card(hidden: true, onOpen: () => opened++));
      expect(find.bySemanticsLabel(RegExp('1,40,000')), findsNothing);
      expect(find.textContaining('25% of'), findsOneWidget);
      await tester.tap(find.text('Trip'));
      await tester.tap(find.text('See all'));
      expect(opened, 2);
      handle.dispose();
    });

    testWidgets('skeleton renders', (tester) async {
      await pumpCard(tester, const SavingsGoalsCardSkeleton());
      expect(tester.takeException(), isNull);
    });
  });

  group('BudgetOverviewCard', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('on pace, ${brightness.name}, ${scale}x', (tester) async {
          await pumpCard(
            tester,
            _budgets([_budget('a', 2000, 10000), _budget('b', 1000, 6000)]),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('Left to spend'), findsOneWidget);
          expect(find.text('On pace'), findsOneWidget);
          expect(find.byType(FfRow), findsNothing);
        });
      }
    }

    testWidgets('spending fast lists the budgets near their limit', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _budgets([_budget('a', 9000, 10000), _budget('b', 1000, 6000)]),
      );
      expect(find.text('Spending fast'), findsOneWidget);
      expect(find.text('Budget a'), findsOneWidget);
      expect(find.text('Near limit'), findsOneWidget);
      expect(find.text('Budget b'), findsNothing);
    });

    testWidgets('over plan leads with the overspend, worst first', (
      tester,
    ) async {
      var opened = 0;
      await pumpCard(
        tester,
        _budgets([
          _budget('a', 8500, 10000),
          _budget('b', 9000, 6000),
        ], onOpen: () => opened++),
      );
      expect(find.text('Over plan by'), findsOneWidget);
      expect(find.text('Over plan'), findsOneWidget);
      expect(find.text('Over'), findsOneWidget);
      final rows = tester.widgetList<FfRow>(find.byType(FfRow)).toList();
      expect(rows.first.title, 'Budget b');
      await tester.tap(find.text('Budget b'));
      await tester.tap(find.text('See all'));
      expect(opened, 2);
    });

    testWidgets('one budget over while the total is not says so', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _budgets([_budget('a', 11000, 9000), _budget('b', 1000, 12000)]),
      );
      expect(find.text('Left to spend'), findsOneWidget);
      expect(find.text('1 over plan'), findsOneWidget);
    });

    testWidgets('hidden amounts show percentages, never figures', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCard(
        tester,
        _budgets([_budget('a', 9000, 10000)], hidden: true),
      );
      expect(find.textContaining('₹9,000'), findsNothing);
      expect(find.text('90% used'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('9,000')), findsNothing);
      handle.dispose();
    });

    testWidgets('no budgets leads into setup', (tester) async {
      var opened = 0;
      await pumpCard(
        tester,
        BudgetOverviewCard(
          totalBudgeted: 0,
          totalSpent: 0,
          totalRemaining: 0,
          overBudgetCount: 0,
          onViewBudgets: () => opened++,
        ),
      );
      expect(find.text('Plan this month'), findsOneWidget);
      await tester.tap(find.text('Set up budgets'));
      expect(opened, 1);
    });

    testWidgets('skeleton renders', (tester) async {
      await pumpCard(tester, const BudgetOverviewCardSkeleton());
      expect(tester.takeException(), isNull);
    });
  });
  group('CashFlowCard', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('normal, ${brightness.name}, ${scale}x', (tester) async {
          await pumpCard(
            tester,
            _cashFlow(),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('Net this period'), findsOneWidget);
          expect(find.text('+ ₹82,000'), findsOneWidget);
          expect(find.text('− ₹48,210'), findsOneWidget);
          expect(
            find.text('Spending down 20.0% vs previous period'),
            findsOneWidget,
          );
          expect(find.byType(FfBarChart), findsOneWidget);
        });
      }
    }

    testWidgets('tapping the card opens Insights', (tester) async {
      var opened = 0;
      await pumpCard(tester, _cashFlow(onOpen: () => opened++));
      await tester.tap(find.text('Net this period'));
      expect(opened, 1);
      await tester.tap(find.byTooltip('Open Insights'));
      expect(opened, 2);
    });

    testWidgets('negative net says so in words', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(
          flow: const MonthlyCashFlow(
            totalIncome: 1000,
            totalExpense: 5000,
            netSavings: -4000,
          ),
        ),
      );
      expect(find.text('More went out than came in'), findsOneWidget);
    });

    testWidgets('one active point draws no chart', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(bars: const [BarChartItem(label: 'Today', value: 300)]),
      );
      expect(find.byType(FfBarChart), findsNothing);
    });

    testWidgets('empty period explains itself', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(
          flow: const MonthlyCashFlow(
            totalIncome: 0,
            totalExpense: 0,
            netSavings: 0,
          ),
          bars: const [],
        ),
      );
      expect(find.text('No money in or out in this period yet.'), findsOne);
    });

    testWidgets('hidden amounts: no figures, trend or spoken values', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _cashFlow(hidden: true));
      expect(find.text('+ ₹82,000'), findsNothing);
      expect(find.textContaining('Spending down'), findsNothing);
      expect(
        find.bySemanticsLabel('Cash flow for November 2026, amounts hidden'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('82,000')), findsNothing);
      handle.dispose();
    });

    testWidgets('skeleton and error render', (tester) async {
      var retried = 0;
      await pumpCard(
        tester,
        Column(
          children: [
            const CashFlowCardSkeleton(),
            HomeCardError(what: 'cash flow', onRetry: () => retried++),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Try again'));
      expect(retried, 1);
    });
  });
}
