import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/loan.dart';
import '../../models/subscription.dart';

/// Manages timezone resolution and reminder date calculations.
class NotificationScheduler {
  NotificationScheduler._();

  static bool _timezoneInitialized = false;

  /// Initializes timezone database and sets local location.
  static Future<void> initializeTimezone() async {
    if (_timezoneInitialized) return;
    try {
      tz_data.initializeTimeZones();

      if (!kIsWeb) {
        try {
          final timeZoneName = await FlutterTimezone.getLocalTimezone();
          tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
        } catch (e) {
          developer.log(
            'Failed to get native device timezone, falling back to local: $e',
            name: 'NotificationScheduler',
          );
        }
      }
      _timezoneInitialized = true;
    } catch (e, st) {
      developer.log(
        'Timezone initialization failed: $e',
        name: 'NotificationScheduler',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Converts a standard [DateTime] into a [tz.TZDateTime] using the local timezone.
  static tz.TZDateTime toTZDateTime(DateTime dateTime) {
    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      _timezoneInitialized = true;
    }
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Calculate the scheduled reminder datetime for a subscription renewal.
  /// Returns null if the reminder time is in the past.
  static DateTime? calculateSubscriptionReminderDate(
    Subscription sub, {
    DateTime? referenceDate,
    int targetHour = 9,
    int targetMinute = 0,
  }) {
    if (!sub.isReminderEnabled || sub.status != SubscriptionStatus.active) {
      return null;
    }

    return _nextReminderSlot(
      dueDate: sub.nextRenewalDate,
      daysBefore: sub.reminderDaysBefore,
      now: referenceDate ?? DateTime.now(),
      hour: targetHour,
      minute: targetMinute,
    );
  }

  /// Calculate the scheduled reminder datetime for an upcoming loan EMI due date.
  /// Returns null if the reminder time is in the past.
  static DateTime? calculateLoanEmiReminderDate(
    Loan loan, {
    DateTime? referenceDate,
    int reminderDaysBefore = 2,
    int targetHour = 9,
    int targetMinute = 0,
  }) {
    if (loan.status != LoanStatus.active) {
      return null;
    }

    return _nextReminderSlot(
      dueDate: loan.nextDueDate,
      daysBefore: reminderDaysBefore,
      now: referenceDate ?? DateTime.now(),
      hour: targetHour,
      minute: targetMinute,
    );
  }

  /// The early reminder (`daysBefore` the due date) if it is still ahead,
  /// otherwise a reminder on the due date itself, so data synced late (the app
  /// opened after the early slot) still produces one reminder. Calendar-day
  /// arithmetic keeps the wall-clock time stable across DST changes.
  static DateTime? _nextReminderSlot({
    required DateTime dueDate,
    required int daysBefore,
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    final early = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - daysBefore,
      hour,
      minute,
    );
    if (!early.isBefore(now)) return early;

    final onDueDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      hour,
      minute,
    );
    if (!onDueDay.isBefore(now)) return onDueDay;

    return null;
  }
}
