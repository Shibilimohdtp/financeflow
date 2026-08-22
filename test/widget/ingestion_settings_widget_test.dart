import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/settings/settings_screen.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SettingsScreen displays Transaction Ingestion & Sources section',
    (WidgetTester tester) async {
      const settings = AppSettings(
        isNotificationDetectionEnabled: true,
        isSmsDetectionEnabled: false,
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
            filteredTransactionsProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Transaction Ingestion & Sources'), findsOneWidget);
      expect(find.text('Import CSV Statement'), findsOneWidget);
      expect(find.text('Needs Review Queue'), findsOneWidget);
      expect(find.text('Notification Detection'), findsOneWidget);
      expect(find.text('Bank SMS Detection'), findsOneWidget);
    },
  );
}
