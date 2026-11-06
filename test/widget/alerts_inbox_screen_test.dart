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
    fakeNotificationService.notificationsEnabled = false;
    fakeNotificationService.permissionStatus =
        NotificationPermissionStatus.denied;

    fakeSettingsRepo = FakeSettingsRepository(
      const AppSettings(
        isAlertsEnabled: true,
        isLocalNotificationsEnabled: false,
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
      expect(find.text('All caught up'), findsOneWidget);
      expect(
        find.textContaining('FinanceFlow monitors your local budgets'),
        findsOneWidget,
      );
      expect(
        find.textContaining('100% on-device local monitoring'),
        findsOneWidget,
      );
      expect(find.text('System Protected'), findsOneWidget);
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
        expect(find.text('Needs Attention'), findsOneWidget);
        expect(find.text('View Subscription'), findsOneWidget);
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
      expect(find.text('Pay EMI'), findsOneWidget);

      // Tap alert to mark as read
      await tester.tap(find.text('HDFC EMI due'));
      await tester.pumpAndSettle();

      final updated = await fakeAlertRepo.getAllAlerts();
      expect(updated.first.isRead, isTrue);
    });

    testWidgets('filter pills filter the alert list properly', (tester) async {
      final reminder = AlertItem(
        id: 'rem_1',
        type: AlertType.upcomingEmi,
        title: 'Car Loan EMI',
        message: 'Car Loan EMI due soon.',
        severity: AlertSeverity.attention,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final alert = AlertItem(
        id: 'alt_overrun',
        type: AlertType.budgetExceeded,
        title: 'Shopping Budget Exceeded',
        message: 'Shopping has exceeded 100%.',
        severity: AlertSeverity.urgent,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await fakeAlertRepo.saveAlert(reminder);
      await fakeAlertRepo.saveAlert(alert);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Car Loan EMI'), findsOneWidget);
      expect(find.text('Shopping Budget Exceeded'), findsOneWidget);

      // Select Reminders pill
      await tester.tap(find.text('Reminders (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Car Loan EMI'), findsOneWidget);
      expect(find.text('Shopping Budget Exceeded'), findsNothing);

      // Select Alerts pill
      await tester.tap(find.text('Alerts (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Car Loan EMI'), findsNothing);
      expect(find.text('Shopping Budget Exceeded'), findsOneWidget);

      // Back to All
      await tester.tap(find.text('All (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Car Loan EMI'), findsOneWidget);
      expect(find.text('Shopping Budget Exceeded'), findsOneWidget);
    });

    testWidgets('mark all read button updates unread alerts', (tester) async {
      final alert1 = AlertItem(
        id: 'unread_1',
        type: AlertType.backupReminder,
        title: 'Backup recommended',
        message: 'You have not backed up in 7 days.',
        severity: AlertSeverity.informational,
        isRead: false,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final alert2 = AlertItem(
        id: 'unread_2',
        type: AlertType.largeExpense,
        title: 'Large expense detected',
        message: '₹25,000 paid to Electronic Store.',
        severity: AlertSeverity.attention,
        isRead: false,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await fakeAlertRepo.saveAlert(alert1);
      await fakeAlertRepo.saveAlert(alert2);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Mark All Read'), findsOneWidget);
      await tester.tap(find.byTooltip('Mark All Read'));
      await tester.pumpAndSettle();

      final updated = await fakeAlertRepo.getAllAlerts();
      expect(updated.every((a) => a.isRead), isTrue);
    });

    testWidgets('dismissing alert dismisses it from repository', (
      tester,
    ) async {
      final alert = AlertItem(
        id: 'dismiss_target',
        type: AlertType.savingsGoalReminder,
        title: 'Vacation goal on track',
        message: 'Keep going to reach ₹50,000.',
        severity: AlertSeverity.informational,
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await fakeAlertRepo.saveAlert(alert);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Vacation goal on track'), findsOneWidget);

      // Swipe to dismiss
      await tester.drag(
        find.text('Vacation goal on track'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      final updated = await fakeAlertRepo.getActiveAlerts();
      expect(updated.isEmpty, isTrue);
    });
  });
}
