import 'period.dart';

/// "Today", "Yesterday", or e.g. "Mon, 3 Nov" (with the year when it is not
/// the current one).
String dayLabel(DateTime day, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  if (day == today) return 'Today';
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return 'Yesterday';
  }
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final base =
      '${weekdays[day.weekday - 1]}, ${day.day} ${months[day.month - 1]}';
  return day.year == today.year ? base : '$base ${day.year}';
}

/// Short label for a period, e.g. "November 2026", "This week", "2026".
String periodLabel(Period? period, {DateTime? now}) {
  if (period == null) return 'All time';
  final ref = now ?? DateTime.now();
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  switch (period.unit) {
    case PeriodUnit.day:
      return dayLabel(period.start, now: ref);
    case PeriodUnit.week:
      if (period.contains(ref)) return 'This week';
      return 'Week of ${dayLabel(period.start, now: ref)}';
    case PeriodUnit.month:
      return '${months[period.start.month - 1]} ${period.start.year}';
    case PeriodUnit.year:
      return '${period.start.year}';
    case PeriodUnit.custom:
      return '${dayLabel(period.start, now: ref)} – ${dayLabel(period.lastDay, now: ref)}';
  }
}
