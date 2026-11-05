// Screenshot capture for design-system slices, not part of the test suite
// (it lives outside test/). It renders the shared feedback surfaces with the
// real bundled fonts in light and dark, using only APIs that also existed
// before DS-4a, so the same file captures "before" (run at the older commit)
// and "after".
//
//   flutter test tool/screenshots/feedback_screenshots_test.dart --update-goldens
//
// PNGs land in tool/screenshots/goldens/; copy the ones you want to keep
// into docs/design-system/screenshots/.
import 'package:financeflow/shared/widgets/ff_confirm_dialog.dart';
import 'package:financeflow/shared/widgets/ff_snackbar.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

const _size = Size(390, 640);

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Future<void> Function(BuildContext context) open,
) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: Builder(
          builder:
              (context) => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Groceries · Food'),
                  const SizedBox(height: 12),
                  const Text('Fuel · Transport'),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => open(context),
                    child: const Text('open'),
                  ),
                ],
              ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('toast with undo, $mode', (tester) async {
      await _capture(tester, 'toast_undo_$mode', theme, (context) async {
        FfSnackbar.show(
          context,
          message: 'Transaction deleted.',
          actionLabel: 'Undo',
          onAction: () {},
        );
      });
    });

    testWidgets('destructive confirm, $mode', (tester) async {
      await _capture(tester, 'confirm_delete_$mode', theme, (context) async {
        await FfConfirmDialog.show(
          context,
          title: 'Delete transaction?',
          message: 'This removes it from your history and balances.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
      });
    });

    testWidgets('date picker, $mode', (tester) async {
      await _capture(tester, 'date_picker_$mode', theme, (context) async {
        await showDatePicker(
          context: context,
          initialDate: DateTime(2026, 11, 5),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
      });
    });
  }
}
