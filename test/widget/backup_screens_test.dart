import 'dart:io';

import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/backup/backup_screen.dart';
import 'package:financeflow/features/backup/restore_preview_screen.dart';
import 'package:financeflow/features/export/export_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupScreen Widget Tests', () {
    testWidgets('renders all major backup sections and controls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const settings = AppSettings();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const BackupScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Full Backup & Migration'), findsOneWidget);
      expect(find.text('AES-256 CTR'), findsOneWidget);
      expect(find.text('Encrypted Backup Archive'), findsOneWidget);
      expect(find.text('Keep your passphrase safe'), findsOneWidget);
      expect(find.text('Create new backup'), findsOneWidget);
      expect(find.text('Encryption Passphrase'), findsOneWidget);
      expect(find.text('Confirm Passphrase'), findsOneWidget);
      expect(find.text('Generate Encrypted Backup'), findsOneWidget);
      expect(find.text('Restore from file'), findsOneWidget);
      expect(find.text('Browse & Select Backup File'), findsOneWidget);
    });
  });

  group('ExportScreen Widget Tests', () {
    testWidgets('renders export formats, scopes, and local guarantee', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const ExportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Export Reports'), findsOneWidget);
      expect(find.text('100% Local'), findsOneWidget);
      expect(find.text('Migrating to a New Phone?'), findsOneWidget);
      expect(find.text('On-Device Report Generator'), findsOneWidget);
      expect(find.text('Export format'), findsOneWidget);
      expect(find.text('CSV (Excel / Sheets)'), findsOneWidget);
      expect(find.text('JSON (Raw Data)'), findsOneWidget);
      expect(find.text('Data scope'), findsOneWidget);
      expect(find.text('All Recorded Transactions'), findsOneWidget);
      expect(find.text('Specific Date Range'), findsOneWidget);
      expect(find.text('Generate & Save Export'), findsOneWidget);
    });
  });

  group('RestorePreviewScreen Widget Tests', () {
    testWidgets('renders file card and passphrase prompt when locked', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyFile = File('dummy_backup.ffbackup');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            filteredTransactionsProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: RestorePreviewScreen(backupFile: dummyFile),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Restore Encrypted Backup'), findsOneWidget);
      expect(find.text('AES Decryption'), findsOneWidget);
      expect(find.text('dummy_backup.ffbackup'), findsOneWidget);
      expect(find.text('Enter passphrase to unlock'), findsOneWidget);
      expect(find.text('Decrypt & Inspect Contents'), findsOneWidget);
    });
  });
}
