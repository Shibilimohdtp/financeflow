import 'package:financeflow/features/ingestion/permissions/notification_permission_screen.dart';
import 'package:financeflow/features/ingestion/permissions/sms_permission_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
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
      expect(
        find.text('Open Android Notification Access'),
        findsOneWidget,
      );
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
}
