// DS-4b: every bottom sheet goes through showFfSheet + FfSheet, which own
// the background, rounded top, maximum height, keyboard lift and bottom
// safe area.
import 'dart:io';

import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/shared/widgets/ff_sheet_header.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/tokens/ff_component_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _screen = Size(400, 800);

Future<void> _open(
  WidgetTester tester,
  ThemeData theme,
  WidgetBuilder builder, {
  void Function(Object?)? onResult,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  final r = await showFfSheet<Object>(
                    context,
                    builder: builder,
                  );
                  onResult?.call(r);
                },
                child: const Text('open'),
              ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Widget _longSheet(BuildContext context) => FfSheet(
  children: [
    const FfSheetHeader(title: 'Choose category'),
    Flexible(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (var i = 0; i < 100; i++) ListTile(title: Text('Row $i')),
        ],
      ),
    ),
  ],
);

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final colors = theme.extension<FfColors>()!;

    group('FfSheet ($mode)', () {
      testWidgets('paints the sheet colour with a rounded top', (tester) async {
        await _open(
          tester,
          theme,
          (_) => const FfSheet(
            children: [FfSheetHeader(title: 'Add account'), Text('body')],
          ),
        );
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(FfSheet),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(material.color, colors.surfaceSheet);
        expect(
          material.shape,
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(FfSheetTokens.radius),
            ),
          ),
        );
      });

      testWidgets('long content is capped at the max height and scrolls', (
        tester,
      ) async {
        await _open(tester, theme, _longSheet);
        expect(tester.takeException(), isNull);
        final height = tester.getSize(find.byType(FfSheet)).height;
        expect(
          height,
          lessThanOrEqualTo(_screen.height * FfSheetTokens.maxHeightFraction),
        );
        expect(find.text('Row 0'), findsOneWidget);
        expect(find.text('Row 99'), findsNothing);
        await tester.scrollUntilVisible(find.text('Row 99'), 400);
        expect(find.text('Row 99'), findsOneWidget);
      });

      testWidgets('short content stays short', (tester) async {
        await _open(
          tester,
          theme,
          (_) => const FfSheet(
            children: [FfSheetHeader(title: 'Paying account'), Text('one')],
          ),
        );
        expect(
          tester.getSize(find.byType(FfSheet)).height,
          lessThan(_screen.height / 3),
        );
      });

      testWidgets('rises above the keyboard', (tester) async {
        await _open(
          tester,
          theme,
          (_) => const FfSheet(
            children: [FfSheetHeader(title: 'Set PIN'), TextField()],
          ),
        );
        final restingBottom = tester.getBottomLeft(find.byType(TextField)).dy;

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        final liftedBottom = tester.getBottomLeft(find.byType(TextField)).dy;

        expect(liftedBottom, lessThanOrEqualTo(_screen.height - 300));
        expect(restingBottom - liftedBottom, closeTo(300, 1));
      });

      testWidgets('keeps content clear of the system navigation bar', (
        tester,
      ) async {
        tester.view.padding = const FakeViewPadding(bottom: 40);
        tester.view.viewPadding = const FakeViewPadding(bottom: 40);
        await _open(
          tester,
          theme,
          (_) => const FfSheet(
            children: [FfSheetHeader(title: 'Filter'), Text('last line')],
          ),
        );
        final textBottom = tester.getBottomLeft(find.text('last line')).dy;
        expect(textBottom, lessThanOrEqualTo(_screen.height - 40));
      });

      testWidgets('returns the value it was closed with', (tester) async {
        Object? result = 'unset';
        await _open(
          tester,
          theme,
          (context) => FfSheet(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cash'),
                child: const Text('Cash'),
              ),
            ],
          ),
          onResult: (r) => result = r,
        );
        await tester.tap(find.text('Cash'));
        await tester.pumpAndSettle();
        expect(result, 'cash');
      });
    });
  }

  test('no feature opens a raw bottom sheet', () {
    // Budgets is owned by another chat until its redesign lands (see
    // docs/design-system/CHANGELOG.md); it migrates in DS-7h.
    final offenders =
        Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) {
              final path = f.path.replaceAll(r'\', '/');
              return !path.startsWith('lib/features/budgets/') &&
                  !path.endsWith('lib/shared/widgets/ff_sheet.dart');
            })
            .where(
              (f) => RegExp(
                r'\bshowModalBottomSheet\b',
              ).hasMatch(f.readAsStringSync()),
            )
            .map((f) => f.path)
            .toList();
    expect(offenders, isEmpty, reason: 'Use showFfSheet with an FfSheet.');
  });
}
