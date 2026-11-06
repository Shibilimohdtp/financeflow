import 'package:financeflow/features/ingestion/permissions/notification_permission_screen.dart';
import 'package:financeflow/features/ingestion/permissions/sms_permission_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/services/ingestion/ingestion_coordinator.dart';
import 'package:financeflow/services/ingestion/ingestion_platform.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'NotificationPermissionScreen displays privacy rationale and app selection',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const NotificationPermissionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notification Detection'), findsOneWidget);
      expect(find.text('100% On-Device Reading'), findsOneWidget);
      expect(find.text('Zero Upload'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);
      expect(find.text('Paytm'), findsOneWidget);
      expect(find.text('Open Android Notification Access'), findsOneWidget);
    },
  );

  testWidgets(
    'SmsPermissionScreen displays privacy rationale and supported banks',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SmsPermissionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bank SMS Detection'), findsOneWidget);
      expect(find.text('Privacy & SMS Security'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);
      expect(find.text('HDFC Bank (HDFCBK)'), findsOneWidget);
      expect(find.text('ICICI Bank (ICICIB)'), findsOneWidget);
      expect(find.text('Enable On-Device SMS Detection'), findsOneWidget);
    },
  );

  group('SmsPermissionScreen action follows the app setting and OS grant', () {
    Future<void> pump(
      WidgetTester tester, {
      required AppSettings settings,
      required IngestionPermissionState smsPermission,
    }) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
            ingestionPlatformStatusProvider.overrideWith(
              (ref) => AsyncValue.data(
                IngestionPlatformStatus(
                  isAndroid: true,
                  smsAvailable: true,
                  smsPermission: smsPermission,
                  notificationAccess: false,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SmsPermissionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'OS permission granted but app setting off offers Enable, not Disable',
      (tester) async {
        await pump(
          tester,
          settings: const AppSettings(isSmsDetectionEnabled: false),
          smsPermission: IngestionPermissionState.granted,
        );
        expect(find.text('Enable On-Device SMS Detection'), findsOneWidget);
        expect(find.text('Disable On-Device SMS Detection'), findsNothing);
      },
    );

    testWidgets('app setting on with OS permission granted offers Disable', (
      tester,
    ) async {
      await pump(
        tester,
        settings: const AppSettings(isSmsDetectionEnabled: true),
        smsPermission: IngestionPermissionState.granted,
      );
      expect(find.text('Disable On-Device SMS Detection'), findsOneWidget);
      expect(find.text('Enable On-Device SMS Detection'), findsNothing);
    });

    testWidgets('app setting on but OS permission denied offers Enable', (
      tester,
    ) async {
      await pump(
        tester,
        settings: const AppSettings(isSmsDetectionEnabled: true),
        smsPermission: IngestionPermissionState.denied,
      );
      expect(find.text('Enable On-Device SMS Detection'), findsOneWidget);
      expect(find.text('Disable On-Device SMS Detection'), findsNothing);
    });
  });
}
