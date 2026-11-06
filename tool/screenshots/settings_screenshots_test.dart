import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/backup/backup_screen.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/export/export_screen.dart';
import 'package:financeflow/features/ingestion/csv_import_screen.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/security/security_settings_screen.dart';
import 'package:financeflow/features/settings/more_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/settings/settings_detail_screen.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
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
        allTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
        filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
        rawAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
        categoriesStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  if (searchQuery != null) {
    final searchFinder = find.byType(TextField);
    if (searchFinder.evaluate().isNotEmpty) {
      await tester.enterText(searchFinder.first, searchQuery);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
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

    testWidgets('security settings, $mode', (tester) async {
      await _capture(
        tester,
        'b16_security_settings_$mode',
        theme,
        const SecuritySettingsScreen(),
        settings: sampleSettings,
      );
    });

    testWidgets('csv import statement, $mode', (tester) async {
      await _capture(
        tester,
        'b16_csv_import_$mode',
        theme,
        const CsvImportScreen(),
        settings: sampleSettings,
      );
    });

    testWidgets('export reports, $mode', (tester) async {
      await _capture(
        tester,
        'b16_export_screen_$mode',
        theme,
        const ExportScreen(),
        settings: sampleSettings,
      );
    });

    testWidgets('backup screen, $mode', (tester) async {
      await _capture(
        tester,
        'b16_backup_screen_$mode',
        theme,
        const BackupScreen(),
        settings: sampleSettings,
      );
    });
  }
}
