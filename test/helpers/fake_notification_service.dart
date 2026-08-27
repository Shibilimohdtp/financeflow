import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/services/notifications/notification_channels.dart';
import 'package:financeflow/services/notifications/notification_payload.dart';

class ScheduledNotificationRecord {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final NotificationChannelConfig channel;
  final NotificationPayload? payload;
  final bool exact;

  const ScheduledNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.channel,
    this.payload,
    this.exact = false,
  });
}

class DisplayedNotificationRecord {
  final int id;
  final String title;
  final String body;
  final NotificationChannelConfig channel;
  final NotificationPayload? payload;

  const DisplayedNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    this.payload,
  });
}

class FakeLocalNotificationService implements LocalNotificationService {
  bool isInitialized = false;
  NotificationPermissionStatus permissionStatus =
      NotificationPermissionStatus.granted;
  bool notificationsEnabled = true;
  bool exactNotificationsEnabled = true;

  final List<DisplayedNotificationRecord> displayedNotifications = [];
  final List<ScheduledNotificationRecord> scheduledNotifications = [];
  final List<int> cancelledNotificationIds = [];
  bool allCancelled = false;

  void Function(NotificationPayload payload)? onNotificationTapped;
  NotificationPayload? launchPayload;

  @override
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  }) async {
    isInitialized = true;
    this.onNotificationTapped = onNotificationTapped;
  }

  @override
  Future<NotificationPermissionStatus> requestNotificationPermission() async {
    return permissionStatus;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return notificationsEnabled;
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    return exactNotificationsEnabled;
  }

  @override
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required NotificationChannelConfig channel,
    NotificationPayload? payload,
  }) async {
    displayedNotifications.removeWhere((n) => n.id == id);
    displayedNotifications.add(
      DisplayedNotificationRecord(
        id: id,
        title: title,
        body: body,
        channel: channel,
        payload: payload,
      ),
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannelConfig channel,
    NotificationPayload? payload,
    bool exact = false,
  }) async {
    scheduledNotifications.removeWhere((n) => n.id == id);
    scheduledNotifications.add(
      ScheduledNotificationRecord(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        channel: channel,
        payload: payload,
        exact: exact,
      ),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledNotificationIds.add(id);
    displayedNotifications.removeWhere((n) => n.id == id);
    scheduledNotifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> cancelAllManagedNotifications() async {
    allCancelled = true;
    displayedNotifications.clear();
    scheduledNotifications.clear();
  }

  @override
  Future<NotificationPayload?> getLaunchDetails() async {
    return launchPayload;
  }

  @override
  Future<void> openSystemNotificationSettings() async {}

  @override
  Future<void> openExactAlarmSettings() async {}

  void clear() {
    displayedNotifications.clear();
    scheduledNotifications.clear();
    cancelledNotificationIds.clear();
    allCancelled = false;
  }
}
