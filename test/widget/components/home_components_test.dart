// DS-B12: shared parts added for the Home widgets redesign, in every palette
// and mode, at 1× and 2× text.
import 'package:financeflow/shared/widgets/ff_action_tile.dart';
import 'package:financeflow/shared/widgets/ff_corner_badge.dart';
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

  group('FfActionStrip', () {
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
              FfActionStrip(
                tiles: [
                  FfActionTile(
                    icon: Icons.rate_review_outlined,
                    corner: FfCorner.warning,
                    title: '4 to review',
                    subtitle: 'Imported transactions',
                    onTap: () => taps++,
                  ),
                  FfActionTile(
                    icon: Icons.repeat_rounded,
                    title: 'Renews tomorrow',
                    subtitle: 'A very long subscription merchant name',
                    onTap: () {},
                  ),
                ],
              ),
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            final tiles = find.byType(FfActionTile);
            expect(
              tester.getSize(tiles.first).height,
              tester.getSize(tiles.last).height,
            );
            expect(
              tester.getSize(tiles.first).height,
              greaterThanOrEqualTo(48),
            );
            await tester.tap(find.text('4 to review'));
            expect(taps, 1);
            expect(
              find.bySemanticsLabel('4 to review, Imported transactions'),
              findsOneWidget,
            );
          });
        }
      }
    }
  });
}
