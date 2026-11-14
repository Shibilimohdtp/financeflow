import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/alerts/alert_settings_sheet.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

import '../helpers/fake_notification_service.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeLocalNotificationService fakeNotificationService;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    fakeNotificationService = FakeLocalNotificationService();
    fakeSettingsRepo = FakeSettingsRepository(
      const AppSettings(
        isAlertsEnabled: true,
        isLocalNotificationsEnabled: true,
        isNeedsReviewNotificationsEnabled: true,
        isBudgetNotificationEnabled: true,
        isSubscriptionNotificationEnabled: true,
        isLoanNotificationEnabled: true,
        isBackupNotificationEnabled: true,
        hideSensitiveNotificationContent: false,
      ),
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(
          fakeNotificationService,
        ),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: const Scaffold(body: AlertSettingsSheet()),
      ),
    );
  }

  group('AlertSettingsSheet Widget Tests', () {
    testWidgets('renders all major sections and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Alerts and notifications'), findsOneWidget);
      expect(find.text('Remind me about'), findsOneWidget);
      expect(find.text('Items to review'), findsOneWidget);
      expect(find.text('Budget limits'), findsOneWidget);
      expect(find.text('Subscription renewals'), findsOneWidget);
      expect(find.text('Loan and EMI due dates'), findsOneWidget);
      expect(find.text('Backup reminders'), findsOneWidget);
      expect(find.text('Lock screen'), findsOneWidget);
      expect(find.text('Hide amounts and payees'), findsOneWidget);
      expect(find.textContaining('Scheduled on this device'), findsOneWidget);
    });

    testWidgets('toggling category switch updates settings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find Budget Limits row and tap its switch
      final budgetLimitsText = find.text('Budget limits');
      expect(budgetLimitsText, findsOneWidget);

      final switchWidgets = find.byType(Switch);
      expect(switchWidgets, findsWidgets);

      // Tap the second switch (Needs Review is 1st category)
      await tester.tap(switchWidgets.at(1));
      await tester.pumpAndSettle();

      final updated = await fakeSettingsRepo.getSettings();
      expect(updated.isNeedsReviewNotificationsEnabled, isFalse);
    });

    testWidgets('privacy toggle updates preview text', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Swiggy · ₹450'), findsOneWidget);

      // Toggle privacy switch
      await fakeSettingsRepo.updateSettings(
        const AppSettings(
          isAlertsEnabled: true,
          isLocalNotificationsEnabled: true,
          hideSensitiveNotificationContent: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          '1 imported transaction is waiting for your review.',
        ),
        findsOneWidget,
      );
    });
  });
}
