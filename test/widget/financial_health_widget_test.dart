import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/financial_health/financial_health_controller.dart';
import 'package:financeflow/features/financial_health/financial_health_screen.dart';
import 'package:financeflow/models/financial_health.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  final now = DateTime(2026, 8, 15);

  final testReport = FinancialHealthReport(
    totalScore: 88.0,
    grade: HealthScoreGrade.excellent,
    components: const [
      HealthScoreComponent(
        key: 'savings_rate',
        title: 'Savings Rate',
        score: 25.0,
        hasSufficientData: true,
        summary: '35% savings rate',
        detail: 'You are saving more than 25% of your income this month.',
      ),
      HealthScoreComponent(
        key: 'budget_discipline',
        title: 'Budget Discipline',
        score: 25.0,
        hasSufficientData: true,
        summary: 'All budgets on track',
        detail: 'All active budgets are currently within limit.',
      ),
      HealthScoreComponent(
        key: 'goal_progress',
        title: 'Goal Progress',
        score: 18.0,
        hasSufficientData: true,
        summary: '72% average goal progress',
        detail: 'Your contributions are moving your goals forward.',
      ),
      HealthScoreComponent(
        key: 'cash_flow',
        title: 'Cash Flow Stability',
        score: 20.0,
        hasSufficientData: true,
        summary: 'Positive cash flow buffer',
        detail: 'Expenses are well below income.',
      ),
    ],
    hasOverallSufficientData: true,
    calculatedAt: now,
  );

  testWidgets('FinancialHealthScreen renders score and component details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialHealthReportProvider.overrideWithValue(
            AsyncValue.data(testReport),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const FinancialHealthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Financial Health'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);
    expect(find.text('Savings Rate'), findsOneWidget);
    expect(find.text('Budget Discipline'), findsOneWidget);
    expect(find.text('Goal Progress'), findsOneWidget);
    expect(find.text('Cash Flow Stability'), findsOneWidget);
    expect(find.text('On-Device Analysis'), findsOneWidget);
  });

  testWidgets('FinancialHealthScreen renders insufficient data state', (
    WidgetTester tester,
  ) async {
    final buildingReport = FinancialHealthReport(
      totalScore: 0.0,
      grade: HealthScoreGrade.insufficientData,
      components: const [
        HealthScoreComponent(
          key: 'savings_rate',
          title: 'Savings Rate',
          score: 0.0,
          hasSufficientData: false,
          summary: 'Not enough data yet',
          detail: 'Log more transactions to see your savings rate score.',
        ),
      ],
      hasOverallSufficientData: false,
      calculatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialHealthReportProvider.overrideWithValue(
            AsyncValue.data(buildingReport),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const FinancialHealthScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Building History'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Not enough data'), findsOneWidget);
  });

  testWidgets('FinancialHealthScreen scales to 2.0x text without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialHealthReportProvider.overrideWithValue(
            AsyncValue.data(testReport),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.deepWater,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: const FinancialHealthScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('88'), findsOneWidget);
  });
}
