import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/more_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/settings/settings_detail_screen.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/shared/widgets/ff_theme_preview_card.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  Widget createMoreScreen({
    AppSettings settings = const AppSettings(),
    int pendingCount = 0,
    double textScale = 1.0,
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(settings),
        ),
        filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
        pendingTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value([]),
        ),
        pendingReviewCountProvider.overrideWithValue(pendingCount),
      ],
      child: MaterialApp(
        theme: theme ?? StillwaterTheme.daylight,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(1080, 2400),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const MoreScreen(),
        ),
      ),
    );
  }

  Widget createSettingsDetailScreen(AppSettings settings) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(settings),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: const SettingsDetailScreen(),
      ),
    );
  }

  group('MoreScreen (More Hub) Tests', () {
    testWidgets('renders on FfAurora with header, vault card, and sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle();

      // Top-level aurora
      expect(find.byType(FfAurora), findsOneWidget);

      // Header
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Modules & preferences'), findsOneWidget);

      // Vault card
      expect(find.text('Device Vault'), findsOneWidget);
      expect(find.text('No backup created yet'), findsOneWidget);
      expect(find.text('Back up now'), findsOneWidget);
      expect(find.text('All data stays on this device'), findsOneWidget);

      // Section titles (sentence case)
      expect(find.text('Your data'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Security and privacy'), findsOneWidget);
      expect(find.text('Backup and export'), findsOneWidget);
      expect(find.text('Appearance and preferences'), findsOneWidget);

      // Entries
      expect(find.text('Financial Accounts'), findsOneWidget);
      expect(find.text('Loans & EMI Tracker'), findsOneWidget);
      expect(find.text('Savings Goals'), findsOneWidget);
      expect(find.text('Subscriptions'), findsOneWidget);
      expect(find.text('Investment Portfolio'), findsOneWidget);
      expect(find.text('Lending & Borrowing'), findsOneWidget);
      expect(find.text('Needs Review Queue'), findsOneWidget);
      expect(find.text('Local Alerts Inbox'), findsOneWidget);
      expect(find.text('Encrypted Backup & Restore'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Import CSV Statement'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
    });

    testWidgets('vault card displays backup freshness when backup exists', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final settings = AppSettings(
        lastBackupDate: DateTime.now(),
        isPinEnabled: true,
        isBiometricEnabled: true,
      );

      await tester.pumpWidget(createMoreScreen(settings: settings));
      await tester.pumpAndSettle();

      expect(find.text('Backed up today'), findsOneWidget);
      expect(find.text('App lock active (PIN & Biometrics)'), findsOneWidget);
      // No "Back up now" warning button when up-to-date
      expect(find.text('Back up now'), findsNothing);
    });

    testWidgets('navigates to SettingsDetailScreen on tapping App Settings', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('App Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDetailScreen), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Ledger View'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Notification Detection'), findsOneWidget);
      expect(find.text('Bank SMS Detection'), findsOneWidget);
      expect(find.text('Wipe All App Data'), findsOneWidget);
    });

    testWidgets(
      'renders cleanly in dark mode and 2x text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createMoreScreen(theme: StillwaterTheme.deepWater, textScale: 2.0),
        );
        await tester.pumpAndSettle();

        expect(find.text('More'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('quick settings strip renders and interacts', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createMoreScreen());
      await tester.pumpAndSettle();

      expect(find.text('Amounts'), findsOneWidget);
      expect(find.text('App Lock'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Bank SMS'), findsOneWidget);

      await tester.tap(find.text('Amounts'));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'Settings search matches keywords and shows empty state on miss',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createMoreScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('App Settings'));
        await tester.pumpAndSettle();

        // Search for 'pin'
        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);
        await tester.enterText(searchField, 'pin');
        await tester.pumpAndSettle();

        expect(find.text('App PIN lock'), findsOneWidget);

        // Search for non-existent keyword
        await tester.enterText(searchField, 'xyznomatch999');
        await tester.pumpAndSettle();

        expect(find.text('No settings found'), findsOneWidget);

        // Clear query returns normal view
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Ledger View'), findsOneWidget);
      },
    );

    testWidgets('theme picker sheet displays FfThemePreviewCards', (
      tester,
    ) async {
      await tester.pumpWidget(createSettingsDetailScreen(const AppSettings()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Theme Preference'), findsOneWidget);
      expect(
        find.text('Live visual miniatures. Updates immediately.'),
        findsOneWidget,
      );
      expect(find.byType(FfThemePreviewCard), findsNWidgets(3));
    });

    testWidgets('currency picker sheet filters and selects', (tester) async {
      await tester.pumpWidget(createSettingsDetailScreen(const AppSettings()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text('POPULAR'), findsOneWidget);

      // Search for USD
      final searchField = find.descendant(
        of: find.byType(FfSheet),
        matching: find.byType(TextField),
      );
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'USD');
      await tester.pumpAndSettle();

      expect(find.text('US Dollar'), findsOneWidget);
      await tester.tap(find.text('US Dollar'));
      await tester.pumpAndSettle();

      // Sheet dismissed
      expect(find.text('Select Currency'), findsNothing);
    });

    testWidgets('density visualizer card toggles dense mode', (tester) async {
      await tester.pumpWidget(
        createSettingsDetailScreen(const AppSettings(isDenseMode: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Row Density'), findsOneWidget);
      expect(find.text('Swiggy'), findsOneWidget);

      // Tap 'Ledger View' option
      await tester.tap(find.text('Ledger View'));
      await tester.pumpAndSettle();
    });
  });
}
