import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/shared/widgets/charts/ff_donut_chart.dart';
import 'package:financeflow/shared/widgets/ff_button.dart';
import 'package:financeflow/shared/widgets/ff_chip.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  group('Accessibility & Semantics Widget Tests', () {
    testWidgets('FfButton maintains minimum 48dp touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: Center(
              child: FfButton(
                label: 'Save Transaction',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(FfButton);
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('FfChip maintains accessible touch target and tap callback', (tester) async {
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

    testWidgets('FfBarChart includes accessible semantics label', (tester) async {
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

    testWidgets('FfDonutChart includes accessible semantics label', (tester) async {
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

    testWidgets('Renders with large text scale factor (2.0x) without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: FfButton(
                  label: 'Submit',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });
  });
}
