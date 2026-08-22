import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/financial_health/financial_health_controller.dart';
import 'package:financeflow/features/financial_health/financial_health_screen.dart';
import 'package:financeflow/models/financial_health.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('FinancialHealthScreen renders score and component details', (
    WidgetTester tester,
  ) async {
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
}
