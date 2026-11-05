// Screenshot capture for DS-5b (list rows), not part of the test suite.
// Uses only APIs present before and after DS-5b.
//
//   flutter test tool/screenshots/row_screenshots_test.dart --update-goldens
import 'package:financeflow/features/security/security_settings_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/settings/settings_screen.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

const _settings = AppSettings(
  isNotificationDetectionEnabled: true,
  isSmsDetectionEnabled: false,
  isPrivacyBlurEnabled: true,
);

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home, {
  String? tapFirst,
}) async {
  tester.view.physicalSize = const Size(390, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(_settings)),
        filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
        pendingTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value([]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (tapFirst != null) {
    await tester.scrollUntilVisible(
      find.text(tapFirst),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(tapFirst));
    await tester.pumpAndSettle();
  }
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
    testWidgets('settings hub, $mode', (tester) async {
      await _capture(
        tester,
        'row_settings_$mode',
        theme,
        const SettingsScreen(),
      );
    });

    testWidgets('app settings, $mode', (tester) async {
      await _capture(
        tester,
        'row_app_settings_$mode',
        theme,
        const SettingsScreen(),
        tapFirst: 'App Settings',
      );
    });

    testWidgets('security, $mode', (tester) async {
      await _capture(
        tester,
        'row_security_$mode',
        theme,
        const SecuritySettingsScreen(),
      );
    });
  }
}
