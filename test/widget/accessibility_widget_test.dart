import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/shared/widgets/charts/ff_donut_chart.dart';
import 'package:financeflow/shared/widgets/ff_button.dart';
import 'package:financeflow/shared/widgets/ff_chip.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:financeflow/features/analytics/widgets/expense_category_breakdown.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/features/analytics/widgets/analytics_cash_flow_card.dart';

void main() {
  testWidgets(
    'Cash flow groups dates, exposes exact values and isolates expenses',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.deepWater,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsCashFlowCard(
                points: List.generate(
                  31,
                  (i) => TimeSeriesPoint(
                    date: DateTime(2026, 8, i + 1),
                    label: '${i + 1}',
                    expense: 100,
                    income: i == 19 ? 25000 : 0,
                  ),
                ),
                range: AnalyticsTimeRange.month,
                start: DateTime(2026, 8, 1),
                end: DateTime(2026, 8, 31),
              ),
            ),
          ),
        ),
      );
      final chartFinder = find.byType(FfBarChart);
      expect(tester.widget<FfBarChart>(chartFinder).items.length, 5);
      expect(find.text('15–21 Aug 2026'), findsOneWidget);
      expect(find.text('₹25,000'), findsOneWidget);
      expect(find.text('₹700'), findsOneWidget);
      expect(find.text('Net + ₹24,300'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('flow-previous')));
      await tester.tap(find.byKey(const ValueKey('flow-previous')));
      await tester.pump();
      expect(find.text('8–14 Aug 2026'), findsOneWidget);
      expect(find.text('Net − ₹700'), findsOneWidget);
      final expenses = find.byKey(const ValueKey('flow-view-expenses'));
      await tester.ensureVisible(expenses);
      await tester.tap(expenses);
      await tester.pumpAndSettle();
      final chart = tester.widget<FfBarChart>(chartFinder);
      expect(chart.items.every((i) => i.secondaryValue == null), isTrue);
      expect(chart.items.first.value, 700);
      expect(
        find.text('Expense scale · Tap a period for exact values'),
        findsOneWidget,
      );
      // Tapping the chart's far-right group selects the final partial week.
      final plot = find.byKey(const ValueKey('cash-flow-plot'));
      await tester.ensureVisible(plot);
      await tester.tapAt(tester.getTopRight(plot) + const Offset(-15, 80));
      await tester.pump();
      expect(find.text('29–31 Aug 2026'), findsOneWidget);
      expect(find.text('₹300'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('flow-next')))
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Cash flow fits large text and resets after data changes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<void> show(List<TimeSeriesPoint> points) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnalyticsCashFlowCard(
                    points: points,
                    range: AnalyticsTimeRange.year,
                    start: DateTime(2026, 1, 1),
                    end: DateTime(2026, 12, 31),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await show([
      TimeSeriesPoint(
        date: DateTime(2026, 12, 1),
        label: 'Dec',
        income: 12345678.99,
        expense: 1234567.89,
      ),
    ]);
    expect(find.text('1–31 Dec 2026'), findsOneWidget);
    await show([
      TimeSeriesPoint(
        date: DateTime(2026, 1, 1),
        label: 'Jan',
        income: 0,
        expense: 10,
      ),
    ]);
    expect(find.text('1–31 Jan 2026'), findsOneWidget);
    await show([]);
    expect(find.text('No income or expenses in this period.'), findsOneWidget);
    expect(find.byType(FfBarChart), findsNothing);
  });

  const categories = [
    CategorySpend(
      categoryId: 'bills',
      categoryName: 'Bills',
      categoryIcon: 'receipt',
      categoryColor: 'slate',
      amount: 600,
      percentage: .6,
      transactionCount: 3,
    ),
    CategorySpend(
      categoryId: 'loans',
      categoryName: 'Loans',
      categoryIcon: 'credit_card',
      categoryColor: 'slate',
      amount: 400,
      percentage: .4,
      transactionCount: 1,
    ),
  ];

  testWidgets('Numbered breakdown exposes amounts and share without color', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    CategorySpend? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: StillwaterTheme.deepWater,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExpenseCategoryBreakdown(
              categories: categories,
              onOpenCategory: (c) => opened = c,
            ),
          ),
        ),
      ),
    );
    expect(find.text('₹1,000'), findsOneWidget);
    expect(find.text('Largest category · Bills · 60.0%'), findsOneWidget);
    expect(find.text('1 payment'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Loans, ₹400, 40.0% of total, 1 payment'),
      findsOneWidget,
    );
    // Same-color categories still have separate numbers and direct data labels.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    final center = tester.getCenter(find.byKey(const ValueKey('donut-ring')));
    await tester.tapAt(center + const Offset(-91, 0));
    await tester.pump();
    expect(find.text('Selected category · Loans · 40.0%'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('view-category-payments')));
    expect(opened?.categoryId, 'loans');
    final row = find.byKey(const ValueKey('category-row-bills'));
    await tester.ensureVisible(row);
    expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    await tester.tap(row);
    expect(opened?.categoryId, 'bills');
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Breakdown handles narrow screens, large text and period changes',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> show(List<CategorySpend> data, ThemeData theme) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ExpenseCategoryBreakdown(
                      categories: data,
                      onOpenCategory: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await show(categories, StillwaterTheme.daylight);
      final center = tester.getCenter(find.byKey(const ValueKey('donut-ring')));
      await tester.tapAt(center + const Offset(-91, 0));
      await tester.pump();
      expect(find.text('Selected category · Loans · 40.0%'), findsOneWidget);
      await show(const [
        CategorySpend(
          categoryId: 'long',
          categoryName: 'Household maintenance and subscriptions',
          categoryIcon: 'receipt',
          categoryColor: 'slate',
          amount: 12345678.99,
          percentage: 1,
          transactionCount: 1,
        ),
      ], StillwaterTheme.deepWater);
      expect(find.text('100.0% of total'), findsOneWidget);
      expect(find.text('₹1,23,45,678.99'), findsWidgets);
      await show(const [], StillwaterTheme.daylight);
      expect(
        find.text('No expenses recorded for this period.'),
        findsOneWidget,
      );
      expect(find.byType(FfDonutChart), findsNothing);
    },
  );

  testWidgets(
    'Donut uses real gaps, ignores hole taps, and keeps tiny slices',
    (tester) async {
      Future<void> show(List<DonutSlice> slices) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FfDonutChart(slices: slices, showSegmentNumbers: true),
            ),
          ),
        );
      }

      await show(const [
        DonutSlice(label: 'A', value: 50),
        DonutSlice(label: 'B', value: 50),
      ]);
      final center = tester.getCenter(find.byKey(const ValueKey('donut-ring')));
      await tester.tapAt(center);
      await tester.pump();
      expect(find.text('Total'), findsOneWidget);
      await tester.tapAt(center + const Offset(0, -91));
      await tester.pump();
      expect(find.text('Total'), findsOneWidget);
      await tester.tapAt(center + const Offset(91, 0));
      await tester.pump();
      expect(find.text('A'), findsOneWidget);

      Future<int> topAlpha() async {
        final paint = tester.widget<CustomPaint>(
          find
              .descendant(
                of: find.byType(FfDonutChart),
                matching: find.byType(CustomPaint),
              )
              .first,
        );
        final recorder = ui.PictureRecorder();
        paint.painter!.paint(Canvas(recorder), const Size(220, 220));
        final picture = recorder.endRecording();
        final image = await picture.toImage(220, 220);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final alpha = bytes!.getUint8((19 * 220 + 110) * 4 + 3);
        image.dispose();
        picture.dispose();
        return alpha;
      }

      expect(
        await tester.runAsync(topAlpha),
        0,
        reason: 'Boundary gap must not be covered by rounded caps',
      );
      await show(const [DonutSlice(label: 'Only', value: 100)]);
      expect(
        await tester.runAsync(topAlpha),
        255,
        reason: 'A single category should be a continuous ring',
      );
      await show(const [
        DonutSlice(label: 'Large', value: 9999),
        DonutSlice(label: 'Tiny', value: 1),
      ]);
      final semantics = tester.ensureSemantics();
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(FfDonutChart)).value,
        contains('Tiny, ₹1, <0.1%'),
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  group('Accessibility & Semantics Widget Tests', () {
    testWidgets('FfButton maintains minimum 48dp touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: Center(
              child: FfButton(label: 'Save Transaction', onPressed: () {}),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(FfButton);
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('FfChip maintains accessible touch target and tap callback', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: Center(
              child: FfChip(
                label: 'Dining',
                isSelected: true,
                onSelected: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      final chipFinder = find.byType(FfChip);
      expect(chipFinder, findsOneWidget);

      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('FfBarChart includes accessible semantics label', (
      tester,
    ) async {
      final items = [
        const BarChartItem(label: 'Mon', value: 450.0),
        const BarChartItem(label: 'Tue', value: 1200.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfBarChart(
              items: items,
              semanticsSummary: 'Weekly spending breakdown chart',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Weekly spending breakdown chart'),
        findsOneWidget,
      );
    });

    testWidgets('FfDonutChart includes accessible semantics label', (
      tester,
    ) async {
      final slices = [
        const DonutSlice(label: 'Dining', value: 1500.0, colorToken: 'clay'),
        const DonutSlice(label: 'Groceries', value: 3000.0, colorToken: 'sand'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfDonutChart(
              slices: slices,
              semanticsSummary: 'Category distribution donut chart',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Category distribution donut chart'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Renders with large text scale factor (2.0x) without crashing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: Center(
                  child: FfButton(label: 'Submit', onPressed: () {}),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Submit'), findsOneWidget);
      },
    );
  });
}
