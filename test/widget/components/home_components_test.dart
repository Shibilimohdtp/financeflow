// DS-B12: shared parts added for the Home widgets redesign, in every palette
// and mode, at 1× and 2× text.
import 'package:financeflow/shared/widgets/ff_section_header.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  ThemeData theme,
  Widget child, {
  double textScale = 1,
  double width = 360,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 900),
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

void main() {
  group('FfSectionHeader count and FfSectionLink', () {
    for (final palette in FfPalettes.all) {
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('${palette.id} ${brightness.name} ${scale}x', (
            tester,
          ) async {
            var taps = 0;
            await _pump(
              tester,
              FfTheme.build(palette, brightness),
              FfSectionHeader(
                title: 'Savings goals with a long title',
                count: 3,
                padding: FfSectionHeader.sectionPadding,
                trailing: FfSectionLink(
                  label: 'See all',
                  semanticLabel: 'See all savings goals',
                  onPressed: () => taps++,
                ),
              ),
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            expect(find.text('3'), findsOneWidget);
            final link = find.byType(FfSectionLink);
            final size = tester.getSize(link);
            expect(size.height, greaterThanOrEqualTo(48));
            expect(size.width, greaterThanOrEqualTo(48));
            await tester.tap(link);
            expect(taps, 1);
            expect(
              find.bySemanticsLabel('See all savings goals'),
              findsOneWidget,
            );
            expect(
              find.bySemanticsLabel('Savings goals with a long title, 3'),
              findsOneWidget,
            );
          });
        }
      }
    }
  });
}
