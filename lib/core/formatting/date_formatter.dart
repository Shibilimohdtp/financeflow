import 'package:intl/intl.dart';

/// Stillwater Date Formatter
///
/// Principles:
/// - Relative dates for recent items ("Today", "Yesterday")
/// - Exact date and time when helpful ("12 Mar 2026 · 2:14 pm")
/// - Month headers for budgeting ("August 2026")
class DateFormatter {
  DateFormatter._();

  static String formatDayGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(itemDate).inDays;

    if (difference == 0) {
      return 'Today, ${DateFormat('d MMM').format(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${DateFormat('d MMM').format(date)}';
    } else if (difference == -1) {
      return 'Tomorrow, ${DateFormat('d MMM').format(date)}';
    } else if (date.year == now.year) {
      return DateFormat('EEEE, d MMM').format(date);
    } else {
      return DateFormat('EEEE, d MMM yyyy').format(date);
    }
  }

  static String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(itemDate).inDays;

    final timeStr = DateFormat('h:mm a').format(date).toLowerCase();

    if (difference == 0) {
      return 'Today, $timeStr';
    } else if (difference == 1) {
      return 'Yesterday, $timeStr';
    } else if (date.year == now.year) {
      return '${DateFormat('d MMM').format(date)} · $timeStr';
    } else {
      return '${DateFormat('d MMM yyyy').format(date)} · $timeStr';
    }
  }

  static String formatDetailDate(DateTime date) {
    return DateFormat('d MMMM yyyy, h:mm a').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }
}
