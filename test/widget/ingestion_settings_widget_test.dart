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
  testWidgets('SettingsScreen displays Transaction Ingestion & Sources section', (
    WidgetTester tester,
  ) async {
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
          settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
          filteredTransactionsProvider.overrideWith((ref) => Stream.value([])),
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

    // The More screen shows 'App Settings' navigation row
    expect(find.text('App Settings'), findsOneWidget);
    // Transaction ingestion items are already visible in the More hub nav rows
    expect(find.text('Import CSV Statement'), findsOneWidget);
    expect(find.text('Needs Review Queue'), findsOneWidget);

    // Tap App Settings to navigate into the detail screen
    await tester.tap(find.text('App Settings'));
    await tester.pumpAndSettle();

    // Notification Detection and Bank SMS Detection are only in the detail screen
    expect(find.text('Notification Detection'), findsOneWidget);
    expect(find.text('Bank SMS Detection'), findsOneWidget);
  });
}
