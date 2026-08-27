import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/alert_item.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/alert_repository.dart';
import 'package:financeflow/repositories/budget_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/services/notifications/notification_coordinator.dart';
import 'package:financeflow/services/notifications/notification_id.dart';
import 'package:financeflow/services/notifications/notification_payload.dart';

import '../helpers/fake_notification_service.dart';
import '../helpers/fake_repositories.dart';

ParsedTransaction _buildTestPending({
  required String tempId,
  required double amount,
  required String rawMerchant,
  String? merchantDisplayName,
}) {
  return ParsedTransaction(
    tempId: tempId,
    source: TransactionSource.sms,
    sourceName: 'HDFC',
    rawSource: 'HDFC SMS',
    amount: amount,
    type: TransactionType.expense,
    rawMerchant: rawMerchant,
    normalizedMerchant: rawMerchant.toLowerCase(),
    merchantDisplayName: merchantDisplayName ?? rawMerchant,
    date: DateTime.now(),
    accountId: 'acc_1',
    categoryId: 'food_dining',
    categoryName: 'Food & Dining',
    categoryIcon: 'restaurant',
    categoryColor: 'sage',
    fingerprint: 'fp_$tempId',
    importedAt: DateTime.now(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLocalNotificationService fakeNotificationService;
  late FakeSettingsRepository fakeSettingsRepo;
  late FakePendingTransactionRepository fakePendingRepo;
  late FakeAlertRepository fakeAlertRepo;
  late FakeSubscriptionRepository fakeSubRepo;
  late FakeLoanRepository fakeLoanRepo;
  late FakeBudgetRepository fakeBudgetRepo;
  late FakeTransactionRepository fakeTxRepo;
  late ProviderContainer container;

  setUp(() {
    fakeNotificationService = FakeLocalNotificationService();
    fakeSettingsRepo = FakeSettingsRepository(const AppSettings(
      isAlertsEnabled: true,
      isLocalNotificationsEnabled: true,
      isNeedsReviewNotificationsEnabled: true,
      isBudgetNotificationEnabled: true,
      isSubscriptionNotificationEnabled: true,
      isLoanNotificationEnabled: true,
      isBackupNotificationEnabled: true,
      hideSensitiveNotificationContent: false,
    ));
    fakePendingRepo = FakePendingTransactionRepository();
    fakeAlertRepo = FakeAlertRepository();
    fakeSubRepo = FakeSubscriptionRepository();
    fakeLoanRepo = FakeLoanRepository();
    fakeBudgetRepo = FakeBudgetRepository();
    fakeTxRepo = FakeTransactionRepository();

    container = ProviderContainer(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(fakeNotificationService),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        pendingTransactionRepositoryProvider.overrideWithValue(fakePendingRepo),
        alertRepositoryProvider.overrideWithValue(fakeAlertRepo),
        subscriptionRepositoryProvider.overrideWithValue(fakeSubRepo),
        loanRepositoryProvider.overrideWithValue(fakeLoanRepo),
        budgetRepositoryProvider.overrideWithValue(fakeBudgetRepo),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationCoordinator Tests', () {
    test('initializes and syncs upon startup', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      expect(fakeNotificationService.isInitialized, isTrue);
    });

    test('cancels all notifications when master toggle is disabled', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      // Disable master notification toggle
      await fakeSettingsRepo.updateSettings(
        const AppSettings(
          isAlertsEnabled: false,
          isLocalNotificationsEnabled: false,
        ),
      );

      await coordinator.syncFromLocalState();

      expect(fakeNotificationService.allCancelled, isTrue);
    });

    test('shows aggregated review notification when pending transactions exist', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      await fakePendingRepo.savePendingTransaction(
        _buildTestPending(
          tempId: 'temp_1',
          amount: 450.0,
          rawMerchant: 'SWIGGY',
          merchantDisplayName: 'Swiggy',
        ),
      );

      await coordinator.syncFromLocalState();

      final displayed = fakeNotificationService.displayedNotifications
          .where((n) => n.id == NotificationId.needsReviewBatch)
          .toList();

      expect(displayed.length, equals(1));
      expect(displayed.first.title, equals('Transaction needs review'));
      expect(displayed.first.body, contains('Swiggy'));
      expect(displayed.first.body, contains('450'));
    });

    test('cancels review notification when pending transactions are cleared', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      // 1. Stage item
      await fakePendingRepo.savePendingTransaction(
        _buildTestPending(
          tempId: 'temp_1',
          amount: 450.0,
          rawMerchant: 'SWIGGY',
        ),
      );
      await coordinator.syncFromLocalState();
      expect(fakeNotificationService.displayedNotifications.length, equals(1));

      // 2. Clear item
      await fakePendingRepo.clearAllPending();
      await coordinator.syncFromLocalState();

      expect(
        fakeNotificationService.cancelledNotificationIds,
        contains(NotificationId.needsReviewBatch),
      );
      expect(fakeNotificationService.displayedNotifications.isEmpty, isTrue);
    });

    test('formats privacy-safe review copy when hideSensitiveNotificationContent is true', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      await fakeSettingsRepo.updateSettings(
        const AppSettings(
          isAlertsEnabled: true,
          isLocalNotificationsEnabled: true,
          isNeedsReviewNotificationsEnabled: true,
          hideSensitiveNotificationContent: true,
        ),
      );

      await fakePendingRepo.savePendingTransaction(
        _buildTestPending(
          tempId: 'temp_secret',
          amount: 25000.0,
          rawMerchant: 'CONFIDENTIAL MERCHANT',
        ),
      );

      await coordinator.syncFromLocalState();

      final displayed = fakeNotificationService.displayedNotifications
          .where((n) => n.id == NotificationId.needsReviewBatch)
          .first;

      expect(displayed.body, equals('1 imported transaction is waiting for your review.'));
      expect(displayed.body, isNot(contains('CONFIDENTIAL MERCHANT')));
      expect(displayed.body, isNot(contains('25,000')));
    });

    test('syncs active budget in-app alerts correctly', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      final alert = AlertItem(
        id: 'alt_b1',
        type: AlertType.budgetApproachingLimit,
        title: 'Dining nearing budget limit',
        message: 'Dining has reached 80% of its planned budget.',
        severity: AlertSeverity.attention,
        relatedEntityType: 'budget',
        relatedEntityId: 'b_dining',
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await fakeAlertRepo.saveAlert(alert);
      await coordinator.syncFromLocalState();

      final alertNotifId = NotificationId.forAlertItem('alt_b1');
      final notif = fakeNotificationService.displayedNotifications
          .where((n) => n.id == alertNotifId)
          .toList();

      expect(notif.length, equals(1));
      expect(notif.first.title, contains('Dining'));
    });

    test('disabling budget category cancels budget notifications', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      final alert = AlertItem(
        id: 'alt_b1',
        type: AlertType.budgetApproachingLimit,
        title: 'Dining nearing budget limit',
        message: 'Dining has reached 80% of its planned budget.',
        relatedEntityId: 'b_dining',
        scheduledAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await fakeAlertRepo.saveAlert(alert);
      await coordinator.syncFromLocalState();

      // Disable budget notifications
      await fakeSettingsRepo.updateSettings(
        const AppSettings(
          isAlertsEnabled: true,
          isLocalNotificationsEnabled: true,
          isBudgetNotificationEnabled: false,
        ),
      );
      await coordinator.syncFromLocalState();

      final alertNotifId = NotificationId.forAlertItem('alt_b1');
      expect(
        fakeNotificationService.cancelledNotificationIds,
        contains(alertNotifId),
      );
    });

    test('idempotency: multiple sync passes do not multiply notifications', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      await fakePendingRepo.savePendingTransaction(
        _buildTestPending(
          tempId: 'temp_1',
          amount: 500.0,
          rawMerchant: 'UBER',
        ),
      );

      // Call sync multiple times
      await coordinator.syncFromLocalState();
      await coordinator.syncFromLocalState();
      await coordinator.syncFromLocalState();

      final displayed = fakeNotificationService.displayedNotifications
          .where((n) => n.id == NotificationId.needsReviewBatch)
          .toList();

      // Should only have 1 active record with ID 10001
      expect(displayed.length, equals(1));
    });

    test('notification tap invokes onNavigate callback', () async {
      final coordinator = container.read(notificationCoordinatorProvider);
      await coordinator.start();

      String? navigatedRoute;
      coordinator.onNavigate = (route, meta) {
        navigatedRoute = route;
      };

      coordinator.handleNotificationTap(
        NotificationPayload.needsReview(),
      );

      expect(navigatedRoute, equals('/needs-review'));
    });
  });
}
