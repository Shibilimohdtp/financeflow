// DS-B8a: shared restyled charts for Insights (Stillwater Bloom), in every
// palette and mode, with 1x and 2x text scale and reduced effects:
// FfBarChart and FfDonutChart.
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/shared/widgets/charts/ff_donut_chart.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  ThemeData theme,
  Widget child, {
  double textScale = 1,
  double width = 400,
  FfEffects effects = FfEffects.full,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 1000),
        textScaler: TextScaler.linear(textScale),
      ),
      child: FfEffectsScope(
        effects: effects,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  ),
);

final _barItems = [
  const BarChartItem(label: 'Mon', value: 1200, secondaryValue: 800),
  const BarChartItem(label: 'Tue', value: 3400, secondaryValue: 2100),
  const BarChartItem(label: 'Wed', value: 850, secondaryValue: 1500),
  const BarChartItem(label: 'Thu', value: 4200, secondaryValue: 3100),
  const BarChartItem(label: 'Fri', value: 2900, secondaryValue: 1900),
];

final _donutSlices = [
  const DonutSlice(label: 'Dining', value: 4500, colorToken: 'clay'),
  const DonutSlice(label: 'Groceries', value: 8200, colorToken: 'moss'),
  const DonutSlice(label: 'Shopping', value: 3100, colorToken: 'rose'),
  const DonutSlice(label: 'Bills', value: 6400, colorToken: 'dusk'),
];

Widget _chartsSuite({int? barIndex, int? donutIndex}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    FfBarChart(
      items: _barItems,
      selectedIndex: barIndex,
      showYAxis: true,
      semanticsSummary: 'Weekly Cash Flow',
    ),
    const SizedBox(height: 24),
    FfDonutChart(
      slices: _donutSlices,
      selectedSliceIndex: donutIndex,
      showSegmentNumbers: true,
      semanticsSummary: 'Category Spend Breakdown',
    ),
  ],
);

void main() {
  for (final mode in [Brightness.light, Brightness.dark]) {
    final modeName = mode == Brightness.light ? 'light' : 'dark';
    final theme = FfTheme.build(FfPalettes.lichen, mode);

    testWidgets('Bloom charts ($modeName) render at 1x and 2x text', (
      tester,
    ) async {
      await _pump(tester, theme, _chartsSuite(barIndex: 1, donutIndex: 0));
      await tester.pumpAndSettle();

      expect(find.byType(FfBarChart), findsOneWidget);
      expect(find.byType(FfDonutChart), findsOneWidget);
      expect(find.text('Tue'), findsWidgets);
      expect(find.text('Dining'), findsWidgets);

      // Large text 2x
      await _pump(
        tester,
        theme,
        _chartsSuite(barIndex: 1, donutIndex: 0),
        textScale: 2.0,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Bloom charts ($modeName) render with reduced effects', (
      tester,
    ) async {
      await _pump(
        tester,
        theme,
        _chartsSuite(barIndex: 2, donutIndex: 1),
        effects: FfEffects.reduced,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('FfBarChart tap updates selection and triggers callback', (
    tester,
  ) async {
    final theme = FfTheme.build(FfPalettes.lichen, Brightness.light);
    int? selected;

    await _pump(
      tester,
      theme,
      FfBarChart(items: _barItems, onSelected: (i) => selected = i),
    );
    await tester.pumpAndSettle();

    final plot = find.byKey(const ValueKey('cash-flow-plot'));
    expect(plot, findsOneWidget);

    await tester.tap(plot);
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
  });

  testWidgets('FfDonutChart tap updates selection and triggers callback', (
    tester,
  ) async {
    final theme = FfTheme.build(FfPalettes.lichen, Brightness.light);
    int? selected;

    await _pump(
      tester,
      theme,
      FfDonutChart(slices: _donutSlices, onSliceSelected: (i) => selected = i),
    );
    await tester.pumpAndSettle();

    final ring = find.byKey(const ValueKey('donut-ring'));
    expect(ring, findsOneWidget);

    final center = tester.getCenter(ring);
    // Tap on the right side of the ring (radius ~91 px out)
    await tester.tapAt(center + const Offset(91, 0));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
  });

  testWidgets('FfBarChart empty state renders clean message', (tester) async {
    final theme = FfTheme.build(FfPalettes.lichen, Brightness.light);

    await _pump(tester, theme, const FfBarChart(items: []));
    await tester.pumpAndSettle();

    expect(find.text('No data available for this chart.'), findsOneWidget);
  });

  testWidgets('FfDonutChart empty state renders clean message', (tester) async {
    final theme = FfTheme.build(FfPalettes.lichen, Brightness.light);

    await _pump(tester, theme, const FfDonutChart(slices: []));
    await tester.pumpAndSettle();

    expect(find.text('No expenses recorded for this period.'), findsOneWidget);
  });
}
