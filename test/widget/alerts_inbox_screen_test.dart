import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/alerts/alerts_inbox_screen.dart';
import 'package:financeflow/models/alert_item.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/alert_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../helpers/fake_notification_service.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeLocalNotificationService fakeNotificationService;
  late FakeSettingsRepository fakeSettingsRepo;
  late FakeAlertRepository fakeAlertRepo;

  setUp(() {
    fakeNotificationService = FakeLocalNotificationService();
    // Notification permission denied
    fakeNotificationService.notificationsEnabled = false;
    fakeNotificationService.permissionStatus =
        NotificationPermissionStatus.denied;

    fakeSettingsRepo = FakeSettingsRepository(
      const AppSettings(
        isAlertsEnabled: true,
        isLocalNotificationsEnabled: false, // Notifications disabled
      ),
    );
    fakeAlertRepo = FakeAlertRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(
          fakeNotificationService,
        ),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        alertRepositoryProvider.overrideWithValue(fakeAlertRepo),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: const AlertsInboxScreen(),
      ),
    );
  }

  group('AlertsInboxScreen Widget Tests', () {
    testWidgets('renders empty state when no alerts exist', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Alerts & Reminders'), findsOneWidget);
      expect(find.text('No active alerts'), findsOneWidget);
      expect(
        find.textContaining('FinanceFlow monitors your local budgets'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders in-app alerts correctly when notifications are disabled/denied',
      (tester) async {
        final alert1 = AlertItem(
          id: 'alt_1',
          type: AlertType.budgetApproachingLimit,
          title: 'Food nearing budget limit',
          message: 'Food has reached 80% of its planned budget.',
          severity: AlertSeverity.attention,
          scheduledAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final alert2 = AlertItem(
          id: 'alt_2',
          type: AlertType.upcomingSubscriptionRenewal,
          title: 'Netflix renewal due',
          message: 'Netflix (₹649.00) renews tomorrow.',
          severity: AlertSeverity.urgent,
          scheduledAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await fakeAlertRepo.saveAlert(alert1);
        await fakeAlertRepo.saveAlert(alert2);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Active Notifications (2)'), findsOneWidget);
        expect(find.text('Food nearing budget limit'), findsOneWidget);
        expect(find.text('Netflix renewal due'), findsOneWidget);
        expect(find.text('Netflix (₹649.00) renews tomorrow.'), findsOneWidget);
      },
    );

    testWidgets('marking alert as read works seamlessly', (tester) async {
      final alert = AlertItem(
        id: 'alt_unread',
        type: AlertType.upcomingEmi,
        title: 'HDFC EMI due',
        message: 'EMI of ₹15,000.00 is due in 2 days.',
        severity: AlertSeverity.urgent,
        isRead: false,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await fakeAlertRepo.saveAlert(alert);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('HDFC EMI due'), findsOneWidget);

      // Tap alert to mark as read
      await tester.tap(find.text('HDFC EMI due'));
      await tester.pumpAndSettle();

      final updated = await fakeAlertRepo.getAllAlerts();
      expect(updated.first.isRead, isTrue);
    });
  });
}
