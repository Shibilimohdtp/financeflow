import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/ff_tone.dart';
import 'ff_badge.dart';

/// An honest due-status badge pairing words with an icon (never colour alone).
///
/// Handles all standard boundary wordings:
/// - Settled: "Settled 3 Mar" or "Settled"
/// - Overdue: "Overdue 1 day" / "Overdue 12 days" (icon: warning)
/// - Due today: "Due today" (icon: clock)
/// - Due tomorrow: "Due tomorrow" (icon: clock)
/// - Due soon (2–7 days): "Due in 3 days" (icon: clock)
/// - Due later (> 7 days): "Due 12 Dec" (icon: calendar)
class FfDueChip extends StatelessWidget {
  const FfDueChip({
    super.key,
    required this.dueDate,
    this.settledAt,
    this.isSettled = false,
    this.asOfDate,
    this.compact = false,
  });

  /// Due date for the payment or obligation.
  final DateTime dueDate;

  /// Optional date when the item was settled.
  final DateTime? settledAt;

  /// Whether the item is settled.
  final bool isSettled;

  /// Reference date for computing relative differences (defaults to today).
  final DateTime? asOfDate;

  /// When true, renders shorter tokens like "12d overdue", "Due in 3d".
  final bool compact;

  /// Formats date concisely (e.g. "3 Mar" or "3 Mar 2027" if cross-year).
  static String formatShortDayMonth(DateTime date, {DateTime? asOfDate}) {
    final refYear = (asOfDate ?? DateTime.now()).year;
    if (date.year == refYear) {
      return DateFormat('d MMM').format(date);
    }
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Computes the exact label string for given dates and status.
  static String formatLabel({
    required DateTime dueDate,
    DateTime? settledAt,
    bool isSettled = false,
    DateTime? asOfDate,
    bool compact = false,
  }) {
    if (settledAt != null) {
      return 'Settled ${formatShortDayMonth(settledAt, asOfDate: asOfDate)}';
    }
    if (isSettled) {
      return 'Settled';
    }

    final now = asOfDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) {
      final days = -diff;
      if (compact) return 'Overdue ${days}d';
      return days == 1 ? 'Overdue 1 day' : 'Overdue $days days';
    }
    if (diff == 0) {
      return 'Due today';
    }
    if (diff == 1) {
      return 'Due tomorrow';
    }
    if (diff <= 7) {
      if (compact) return 'Due in ${diff}d';
      return 'Due in $diff days';
    }
    return 'Due ${formatShortDayMonth(dueDate, asOfDate: asOfDate)}';
  }

  /// Resolves the semantic [FfTone] for the status.
  static FfTone resolveTone({
    required DateTime dueDate,
    DateTime? settledAt,
    bool isSettled = false,
    DateTime? asOfDate,
  }) {
    if (settledAt != null || isSettled) {
      return FfTone.income;
    }

    final now = asOfDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) {
      return FfTone.expense;
    }
    if (diff <= 1) {
      return FfTone.warning;
    }
    if (diff <= 7) {
      return FfTone.debt;
    }
    return FfTone.neutral;
  }

  /// Resolves the semantic icon for the status.
  static IconData resolveIcon({
    required DateTime dueDate,
    DateTime? settledAt,
    bool isSettled = false,
    DateTime? asOfDate,
  }) {
    if (settledAt != null || isSettled) {
      return Icons.check_rounded;
    }

    final now = asOfDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = dueDay.difference(today).inDays;

    if (diff < 0) {
      return Icons.warning_amber_rounded;
    }
    if (diff <= 7) {
      return Icons.schedule_rounded;
    }
    return Icons.calendar_today_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final label = formatLabel(
      dueDate: dueDate,
      settledAt: settledAt,
      isSettled: isSettled,
      asOfDate: asOfDate,
      compact: compact,
    );
    final tone = resolveTone(
      dueDate: dueDate,
      settledAt: settledAt,
      isSettled: isSettled,
      asOfDate: asOfDate,
    );
    final icon = resolveIcon(
      dueDate: dueDate,
      settledAt: settledAt,
      isSettled: isSettled,
      asOfDate: asOfDate,
    );

    return FfBadge(label: label, tone: tone, icon: icon);
  }
}
