import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/more_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/settings/settings_detail_screen.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home, {
  AppSettings settings = const AppSettings(),
  String? searchQuery,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(settings),
        ),
        pendingReviewCountProvider.overrideWith((ref) => 2),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (searchQuery != null) {
    final searchFinder = find.byType(TextField);
    if (searchFinder.evaluate().isNotEmpty) {
      await tester.enterText(searchFinder.first, searchQuery);
      await tester.pumpAndSettle();
    }
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  final sampleSettings = AppSettings(
    themePreference: AppThemePreference.system,
    isDenseMode: false,
    currencyCode: 'INR',
    isPinEnabled: true,
    isBiometricEnabled: true,
    isAlertsEnabled: true,
    isLocalNotificationsEnabled: true,
    isSmsDetectionEnabled: true,
    isNotificationDetectionEnabled: true,
    lastBackupDate: DateTime.now().subtract(const Duration(hours: 4)),
  );

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('more hub, $mode', (tester) async {
      await _capture(
        tester,
        'b16_more_hub_$mode',
        theme,
        const MoreScreen(),
        settings: sampleSettings,
      );
    });

    testWidgets('settings detail, $mode', (tester) async {
      await _capture(
        tester,
        'b16_settings_detail_$mode',
        theme,
        const SettingsDetailScreen(),
        settings: sampleSettings,
      );
    });

    testWidgets('settings search active, $mode', (tester) async {
      await _capture(
        tester,
        'b16_settings_search_$mode',
        theme,
        const SettingsDetailScreen(),
        settings: sampleSettings,
        searchQuery: 'pin',
      );
    });
  }
}
