import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Central configuration for Android notification channels in FinanceFlow.
/// Channel IDs must remain stable across app updates and launches.
class NotificationChannelConfig {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final Priority priority;
  final bool playSound;
  final bool enableVibration;
  final bool showBadge;

  const NotificationChannelConfig({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
    this.playSound = true,
    this.enableVibration = false,
    this.showBadge = true,
  });

  AndroidNotificationChannel toAndroidChannel() {
    return AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: playSound,
      enableVibration: enableVibration,
      showBadge: showBadge,
    );
  }
}

class NotificationChannels {
  NotificationChannels._();

  static const transactionReview = NotificationChannelConfig(
    id: 'transaction_review',
    name: 'Transaction Review',
    description:
        'Notifications for imported transactions waiting for your review.',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: false,
    showBadge: true,
  );

  static const budgetAlerts = NotificationChannelConfig(
    id: 'budget_alerts',
    name: 'Budget Limits',
    description:
        'Alerts when category spending approaches limits or exceeds budgets.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: true,
    enableVibration: false,
    showBadge: true,
  );

  static const paymentReminders = NotificationChannelConfig(
    id: 'payment_reminders',
    name: 'Payment Reminders',
    description:
        'Reminders for upcoming EMI payments and subscription renewals.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: true,
    enableVibration: false,
    showBadge: true,
  );

  static const backupAndSystem = NotificationChannelConfig(
    id: 'backup_and_system',
    name: 'Backup & System',
    description: 'Encrypted backup reminders and important system notices.',
    importance: Importance.low,
    priority: Priority.low,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  static const List<NotificationChannelConfig> all = [
    transactionReview,
    budgetAlerts,
    paymentReminders,
    backupAndSystem,
  ];

  static NotificationChannelConfig getForType(String type) {
    switch (type.toLowerCase()) {
      case 'needs_review':
      case 'transaction_review':
      case 'pending_review':
        return transactionReview;
      case 'budget':
      case 'budget_limit':
      case 'budget_exceeded':
      case 'budget_approaching_limit':
        return budgetAlerts;
      case 'subscription':
      case 'subscription_renewal':
      case 'loan':
      case 'upcoming_emi':
      case 'emi':
        return paymentReminders;
      case 'backup':
      case 'backup_reminder':
      case 'system':
      default:
        return backupAndSystem;
    }
  }
}
