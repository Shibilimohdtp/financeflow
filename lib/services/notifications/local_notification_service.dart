import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_channels.dart';
import 'notification_payload.dart';
import 'notification_scheduler.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  notRequested,
  unsupported;

  bool get isGranted => this == NotificationPermissionStatus.granted;
}

abstract class LocalNotificationService {
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  });

  Future<NotificationPermissionStatus> requestNotificationPermission();

  Future<bool> areNotificationsEnabled();

  Future<bool> canScheduleExactNotifications();

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required NotificationChannelConfig channel,
    NotificationPayload? payload,
  });

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannelConfig channel,
    NotificationPayload? payload,
    bool exact = false,
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllManagedNotifications();

  Future<NotificationPayload?> getLaunchDetails();

  Future<void> openSystemNotificationSettings();

  Future<void> openExactAlarmSettings();
}

class FlutterLocalNotificationService implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  void Function(NotificationPayload payload)? _onNotificationTapped;

  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;
    _onNotificationTapped = onNotificationTapped;

    try {
      await NotificationScheduler.initializeTimezone();

      const androidSettings = AndroidInitializationSettings(
        '@drawable/ic_notification',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open FinanceFlow',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Create stable Android notification channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        if (androidImpl != null) {
          for (final channel in NotificationChannels.all) {
            await androidImpl.createNotificationChannel(
              channel.toAndroidChannel(),
            );
          }
        }
      }

      _isInitialized = true;
      developer.log(
        'LocalNotificationService initialized successfully',
        name: 'NotificationService',
      );
    } catch (e, st) {
      developer.log(
        'Failed to initialize LocalNotificationService: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final raw = response.payload;
    if (raw != null && raw.isNotEmpty) {
      final payload = NotificationPayload.tryDecode(raw);
      if (payload != null && _onNotificationTapped != null) {
        _onNotificationTapped!(payload);
      }
    }
  }

  @override
  Future<NotificationPermissionStatus> requestNotificationPermission() async {
    try {
      if (kIsWeb) return NotificationPermissionStatus.unsupported;

      if (Platform.isAndroid) {
        final androidImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        if (androidImpl != null) {
          final granted = await androidImpl.requestNotificationsPermission();
          if (granted == true) {
            return NotificationPermissionStatus.granted;
          }
          final areEnabled = await androidImpl.areNotificationsEnabled();
          if (areEnabled == false) {
            return NotificationPermissionStatus.permanentlyDenied;
          }
          return NotificationPermissionStatus.denied;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        final darwinImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
        if (darwinImpl != null) {
          final granted = await darwinImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted == true
              ? NotificationPermissionStatus.granted
              : NotificationPermissionStatus.denied;
        }
      }
      return NotificationPermissionStatus.granted;
    } catch (e, st) {
      developer.log(
        'Failed to request notification permission: $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
      return NotificationPermissionStatus.denied;
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid) {
        final androidImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        if (androidImpl != null) {
          return await androidImpl.areNotificationsEnabled() ?? false;
        }
      }
      return true;
    } catch (e) {
      developer.log(
        'Error checking if notifications are enabled: $e',
        name: 'NotificationService',
      );
      return false;
    }
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        if (androidImpl != null) {
          return await androidImpl.canScheduleExactNotifications() ?? false;
        }
      }
      return true;
    } catch (e) {
      developer.log(
        'Error checking exact notification capability: $e',
        name: 'NotificationService',
      );
      return false;
    }
  }

  @override
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required NotificationChannelConfig channel,
    NotificationPayload? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
        playSound: channel.playSound,
        enableVibration: channel.enableVibration,
        showWhen: true,
        // Updating an existing notification (e.g. the review count) must not
        // buzz again.
        onlyAlertOnce: true,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF535B36),
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: channel.showBadge,
        presentSound: channel.playSound,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(id, title, body, details, payload: payload?.encode());
    } catch (e, st) {
      developer.log(
        'Failed to show immediate notification (id: $id): $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
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
    try {
      final tzDate = NotificationScheduler.toTZDateTime(scheduledDate);
      if (tzDate.isBefore(DateTime.now())) {
        return; // Skip past reminders safely
      }

      final androidScheduleMode =
          exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle;

      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
        playSound: channel.playSound,
        enableVibration: channel.enableVibration,
        showWhen: true,
        icon: '@drawable/ic_notification',
        color: const Color(0xFF535B36),
      );

      final darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: channel.showBadge,
        presentSound: channel.playSound,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: androidScheduleMode,
        payload: payload?.encode(),
      );
    } catch (e, st) {
      developer.log(
        'Failed to schedule notification (id: $id): $e',
        name: 'NotificationService',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      developer.log(
        'Failed to cancel notification (id: $id): $e',
        name: 'NotificationService',
      );
    }
  }

  @override
  Future<void> cancelAllManagedNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      developer.log(
        'Failed to cancel all notifications: $e',
        name: 'NotificationService',
      );
    }
  }

  @override
  Future<NotificationPayload?> getLaunchDetails() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final raw = details.notificationResponse?.payload;
        return NotificationPayload.tryDecode(raw);
      }
      return null;
    } catch (e) {
      developer.log(
        'Error getting notification launch details: $e',
        name: 'NotificationService',
      );
      return null;
    }
  }

  @override
  Future<void> openSystemNotificationSettings() async {
    // Handled in platform or settings controller
  }

  @override
  Future<void> openExactAlarmSettings() async {
    // Handled in platform or settings controller
  }
}

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return FlutterLocalNotificationService();
});
