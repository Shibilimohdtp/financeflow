import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/alert_item.dart';
import '../../models/app_settings.dart';
import '../../models/loan.dart';
import '../../models/subscription.dart';
import '../../repositories/alert_repository.dart';
import '../../repositories/loan_repository.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/subscription_repository.dart';
import 'local_notification_service.dart';
import 'notification_channels.dart';
import 'notification_formatter.dart';
import 'notification_id.dart';
import 'notification_payload.dart';
import 'notification_scheduler.dart';

final notificationCoordinatorProvider = Provider<NotificationCoordinator>((
  ref,
) {
  final notificationService = ref.watch(localNotificationServiceProvider);
  final coordinator = NotificationCoordinator(
    ref: ref,
    notificationService: notificationService,
  );

  ref.listen<AsyncValue<AppSettings>>(settingsStreamProvider, (prev, next) {
    next.whenData((settings) {
      coordinator.onSettingsChanged(settings);
    });
  });

  coordinator.start();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

class NotificationCoordinator with WidgetsBindingObserver {
  final Ref _ref;
  final LocalNotificationService _notificationService;
  Future<void>? _startFuture;
  Future<void>? _activeSyncFuture;
  bool _permissionRequested = false;
  void Function(String route, Map<String, dynamic> metadata)? onNavigate;

  NotificationCoordinator({
    required Ref ref,
    required LocalNotificationService notificationService,
  }) : _ref = ref,
       _notificationService = notificationService;

  Future<void> start() {
    return _startFuture ??= _doStart();
  }

  Future<void> _doStart() async {
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
    await _notificationService.initialize(
      onNotificationTapped: handleNotificationTap,
    );

    // Check cold-start launch payload
    final launchPayload = await _notificationService.getLaunchDetails();
    if (launchPayload != null) {
      handleNotificationTap(launchPayload);
    }

    await syncFromLocalState();
  }

  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncFromLocalState());
    }
  }

  /// Asks for the Android 13+ / iOS notification permission once per app
  /// process when reminders are switched on but the OS would hide them, then
  /// resynchronizes so pending reminders are posted. The OS itself stops
  /// showing the dialog after the user declines twice.
  Future<void> ensurePermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      final settings =
          await _ref.read(settingsRepositoryProvider).getSettings();
      if (!settings.isAlertsEnabled || !settings.isLocalNotificationsEnabled) {
        return;
      }
      await start();
      if (await _notificationService.areNotificationsEnabled()) return;
      final status = await _notificationService.requestNotificationPermission();
      if (status.isGranted) await syncFromLocalState();
    } catch (e) {
      developer.log(
        'Notification permission request failed',
        name: 'NotificationCoordinator',
      );
    }
  }

  void onSettingsChanged(AppSettings settings) {
    unawaited(syncFromLocalState(settingsOverride: settings));
  }

  void handleNotificationTap(NotificationPayload payload) {
    developer.log(
      'Notification tapped: route=${payload.route}, type=${payload.type}',
      name: 'NotificationCoordinator',
    );
    if (onNavigate != null) {
      onNavigate!(payload.route, payload.metadata);
    }
  }

  /// Synchronize notification state idempotently from on-device local state.
  Future<void> syncFromLocalState({AppSettings? settingsOverride}) async {
    while (_activeSyncFuture != null) {
      await _activeSyncFuture;
    }
    final completer = Completer<void>();
    _activeSyncFuture = completer.future;

    try {
      final settings =
          settingsOverride ??
          await _ref.read(settingsRepositoryProvider).getSettings();

      // Master switch disabled
      if (!settings.isAlertsEnabled || !settings.isLocalNotificationsEnabled) {
        await _notificationService.cancelAllManagedNotifications();
        return;
      }

      await _syncNeedsReviewNotifications(settings);
      await _syncActiveAlertNotifications(settings);
      await _syncSubscriptionReminders(settings);
      await _syncLoanEmiReminders(settings);
    } catch (e, st) {
      developer.log(
        'Failed to synchronize notifications: $e',
        name: 'NotificationCoordinator',
        error: e,
        stackTrace: st,
      );
    } finally {
      completer.complete();
      if (_activeSyncFuture == completer.future) {
        _activeSyncFuture = null;
      }
    }
  }

  Future<void> _syncNeedsReviewNotifications(AppSettings settings) async {
    try {
      final isEnabled =
          settings.isNeedsReviewNotificationsEnabled &&
          settings.isNeedsReviewAlertsEnabled;

      if (!isEnabled) {
        await _notificationService.cancelNotification(
          NotificationId.needsReviewBatch,
        );
        return;
      }

      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      final pendingItems = await pendingRepo.getPendingTransactions();

      if (pendingItems.isEmpty) {
        await _notificationService.cancelNotification(
          NotificationId.needsReviewBatch,
        );
        return;
      }

      final text = NotificationFormatter.formatNeedsReview(
        count: pendingItems.length,
        singleMerchant:
            pendingItems.first.merchantDisplayName ??
            pendingItems.first.rawMerchant,
        singleAmount: pendingItems.first.amount,
        hideSensitive: settings.hideSensitiveNotificationContent,
      );

      final payload = NotificationPayload.needsReview(
        pendingId: pendingItems.length == 1 ? pendingItems.first.tempId : null,
      );

      await _notificationService.showImmediateNotification(
        id: NotificationId.needsReviewBatch,
        title: text.title,
        body: text.body,
        channel: NotificationChannels.transactionReview,
        payload: payload,
      );
    } catch (e) {
      developer.log(
        'Error syncing review notifications: $e',
        name: 'NotificationCoordinator',
      );
    }
  }

  Future<void> _syncActiveAlertNotifications(AppSettings settings) async {
    try {
      final alertRepo = _ref.read(alertRepositoryProvider);
      final activeAlerts = await alertRepo.getActiveAlerts();
      // Without OS permission a shown notification is silently dropped, so
      // don't mark alerts as delivered until notifications can be displayed.
      final canDisplay = await _notificationService.areNotificationsEnabled();

      for (final alert in activeAlerts) {
        final alertNotifId = NotificationId.forAlertItem(alert.id);
        final isCategoryEnabled = _isCategoryEnabledForAlert(
          alert.type,
          settings,
        );

        if (!isCategoryEnabled) {
          await _notificationService.cancelNotification(alertNotifId);
          continue;
        }

        // Each alert notifies once; re-posting on every resume is noise.
        if (!canDisplay || alert.localNotificationId == alertNotifId) {
          continue;
        }

        final channel = NotificationChannels.getForType(alert.type.name);
        NotificationText text;
        NotificationPayload payload;

        switch (alert.type) {
          case AlertType.budgetApproachingLimit:
            text = NotificationFormatter.formatBudgetApproaching(
              categoryName: alert.title.split(' nearing').first,
              percentageUsed: 0.8,
              hideSensitive: settings.hideSensitiveNotificationContent,
            );
            payload = NotificationPayload.budget(
              budgetId: alert.relatedEntityId ?? 'budget',
            );
            break;
          case AlertType.budgetExceeded:
            text = NotificationFormatter.formatBudgetExceeded(
              categoryName: alert.title.split(' budget exceeded').first,
              amountOver: 0,
              hideSensitive: settings.hideSensitiveNotificationContent,
            );
            payload = NotificationPayload.budget(
              budgetId: alert.relatedEntityId ?? 'budget',
            );
            break;
          case AlertType.upcomingSubscriptionRenewal:
            text = NotificationFormatter.formatSubscriptionRenewal(
              merchant: alert.title.split(' renewal due').first,
              amount: 0,
              daysUntil: 1,
              hideSensitive: settings.hideSensitiveNotificationContent,
            );
            payload = NotificationPayload.subscription(
              subscriptionId: alert.relatedEntityId ?? 'subscription',
            );
            break;
          case AlertType.upcomingEmi:
            text = NotificationFormatter.formatLoanEmi(
              loanName: alert.title.split(' EMI due').first,
              emiAmount: 0,
              daysUntil: 1,
              hideSensitive: settings.hideSensitiveNotificationContent,
            );
            payload = NotificationPayload.loan(
              loanId: alert.relatedEntityId ?? 'loan',
            );
            break;
          case AlertType.backupReminder:
            text = NotificationFormatter.formatBackupReminder(
              daysSinceLastBackup: 30,
              hideSensitive: settings.hideSensitiveNotificationContent,
            );
            payload = NotificationPayload.backup();
            break;
          case AlertType.needsReviewCount:
            // Handled separately in _syncNeedsReviewNotifications
            continue;
          default:
            text = NotificationText(title: alert.title, body: alert.message);
            payload = NotificationPayload.inbox();
            break;
        }

        await _notificationService.showImmediateNotification(
          id: alertNotifId,
          title: text.title,
          body: text.body,
          channel: channel,
          payload: payload,
        );
        await alertRepo.saveAlert(
          alert.copyWith(localNotificationId: alertNotifId),
        );
      }
    } catch (e) {
      developer.log(
        'Error syncing active alerts: $e',
        name: 'NotificationCoordinator',
      );
    }
  }

  Future<void> _syncSubscriptionReminders(AppSettings settings) async {
    try {
      final isEnabled =
          settings.isSubscriptionNotificationEnabled &&
          settings.isSubscriptionAlertsEnabled;

      if (!isEnabled) return;

      final subRepo = _ref.read(subscriptionRepositoryProvider);
      final subscriptions = await subRepo.getAllSubscriptions();

      for (final sub in subscriptions) {
        if (sub.status != SubscriptionStatus.active || !sub.isReminderEnabled) {
          continue;
        }

        final scheduledDate =
            NotificationScheduler.calculateSubscriptionReminderDate(sub);
        if (scheduledDate == null) continue;

        final notifId = NotificationId.forSubscriptionRenewal(
          sub.id,
          sub.nextRenewalDate,
        );

        final daysUntil = sub.daysUntilRenewal();
        final text = NotificationFormatter.formatSubscriptionRenewal(
          merchant: sub.merchant,
          amount: sub.amount,
          daysUntil: daysUntil,
          hideSensitive: settings.hideSensitiveNotificationContent,
        );

        final payload = NotificationPayload.subscription(
          subscriptionId: sub.id,
        );

        await _notificationService.scheduleNotification(
          id: notifId,
          title: text.title,
          body: text.body,
          scheduledDate: scheduledDate,
          channel: NotificationChannels.paymentReminders,
          payload: payload,
        );
      }
    } catch (e) {
      developer.log(
        'Error scheduling subscription reminders: $e',
        name: 'NotificationCoordinator',
      );
    }
  }

  Future<void> _syncLoanEmiReminders(AppSettings settings) async {
    try {
      final isEnabled =
          settings.isLoanNotificationEnabled && settings.isLoanAlertsEnabled;

      if (!isEnabled) return;

      final loanRepo = _ref.read(loanRepositoryProvider);
      final loans = await loanRepo.getAllLoans();

      for (final loan in loans) {
        if (loan.status != LoanStatus.active) continue;

        final scheduledDate =
            NotificationScheduler.calculateLoanEmiReminderDate(loan);
        if (scheduledDate == null) continue;

        final notifId = NotificationId.forLoanEmi(loan.id, loan.nextDueDate);
        final daysUntil = loan.daysUntilDue();

        final text = NotificationFormatter.formatLoanEmi(
          loanName: loan.name,
          emiAmount: loan.emiAmount,
          daysUntil: daysUntil,
          hideSensitive: settings.hideSensitiveNotificationContent,
        );

        final payload = NotificationPayload.loan(loanId: loan.id);

        await _notificationService.scheduleNotification(
          id: notifId,
          title: text.title,
          body: text.body,
          scheduledDate: scheduledDate,
          channel: NotificationChannels.paymentReminders,
          payload: payload,
        );
      }
    } catch (e) {
      developer.log(
        'Error scheduling loan EMI reminders: $e',
        name: 'NotificationCoordinator',
      );
    }
  }

  bool _isCategoryEnabledForAlert(AlertType type, AppSettings settings) {
    switch (type) {
      case AlertType.budgetApproachingLimit:
      case AlertType.budgetExceeded:
        return settings.isBudgetNotificationEnabled &&
            settings.isBudgetAlertsEnabled;
      case AlertType.upcomingSubscriptionRenewal:
        return settings.isSubscriptionNotificationEnabled &&
            settings.isSubscriptionAlertsEnabled;
      case AlertType.upcomingEmi:
        return settings.isLoanNotificationEnabled &&
            settings.isLoanAlertsEnabled;
      case AlertType.needsReviewCount:
        return settings.isNeedsReviewNotificationsEnabled &&
            settings.isNeedsReviewAlertsEnabled;
      case AlertType.backupReminder:
        return settings.isBackupNotificationEnabled &&
            settings.isBackupReminderEnabled;
      default:
        return settings.isLocalNotificationsEnabled;
    }
  }

  /// Sends an immediate test notification for developer verification.
  Future<void> sendTestNotification({
    required String title,
    required String body,
    NotificationChannelConfig channel = NotificationChannels.transactionReview,
  }) async {
    final payload = NotificationPayload.inbox();
    await _notificationService.showImmediateNotification(
      id: 99999,
      title: title,
      body: body,
      channel: channel,
      payload: payload,
    );
  }
}
