import 'dart:math';
import 'package:intl/intl.dart';
import '../../services/analytics_calculator.dart';

class CashFlowBucket {
  final DateTime start;
  final DateTime end;
  final String label;
  final double income;
  final double expense;

  const CashFlowBucket({
    required this.start,
    required this.end,
    required this.label,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;

  String get dateLabel {
    if (start == end) return DateFormat('d MMM yyyy').format(start);
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${DateFormat('d MMM yyyy').format(end)}';
    }
    return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
  }
}

/// Presentation-only aggregation: retain every day's values and empty periods.
/// A month uses 7-day groups; custom ranges use at most seven date groups.
class CashFlowChartData {
  final List<CashFlowBucket> buckets;
  final String groupingLabel;

  const CashFlowChartData({required this.buckets, required this.groupingLabel});

  factory CashFlowChartData.fromPoints({
    required List<TimeSeriesPoint> points,
    required AnalyticsTimeRange range,
    required DateTime start,
    required DateTime end,
  }) {
    final first = DateTime.utc(start.year, start.month, start.day);
    final last = DateTime.utc(end.year, end.month, end.day);
    if (last.isBefore(first)) {
      return const CashFlowChartData(buckets: [], groupingLabel: 'No periods');
    }
    final days = last.difference(first).inDays + 1;
    final step =
        range == AnalyticsTimeRange.month
            ? 7
            : range == AnalyticsTimeRange.week
            ? 1
            : max(1, (days / 7).ceil());
    final monthly = range == AnalyticsTimeRange.year;
    final count = monthly ? 12 : (days / step).ceil();
    final income = List<double>.filled(count, 0);
    final expense = List<double>.filled(count, 0);
    for (final point in points) {
      final date = DateTime.utc(
        point.date.year,
        point.date.month,
        point.date.day,
      );
      if (date.isBefore(first) || date.isAfter(last)) continue;
      final index =
          monthly
              ? point.date.month - 1
              : date.difference(first).inDays ~/ step;
      if (index < 0 || index >= count) continue;
      income[index] += point.income;
      expense[index] += point.expense;
    }
    return CashFlowChartData(
      groupingLabel:
          monthly
              ? 'Monthly totals'
              : step == 1
              ? 'Daily totals'
              : '$step-day totals',
      buckets: List.generate(count, (i) {
        final bucketStart =
            monthly
                ? DateTime.utc(start.year, i + 1)
                : first.add(Duration(days: step * i));
        final candidateEnd =
            monthly
                ? DateTime.utc(start.year, i + 2, 0)
                : bucketStart.add(Duration(days: step - 1));
        final bucketEnd = candidateEnd.isAfter(last) ? last : candidateEnd;
        final label =
            monthly
                ? DateFormat('MMM').format(bucketStart)
                : range == AnalyticsTimeRange.week
                ? DateFormat('EEE').format(bucketStart)
                : range == AnalyticsTimeRange.month
                ? bucketStart == bucketEnd
                    ? '${bucketStart.day}'
                    : '${bucketStart.day}–${bucketEnd.day}'
                : DateFormat('d MMM').format(bucketStart);
        return CashFlowBucket(
          start: bucketStart,
          end: bucketEnd,
          label: label,
          income: income[i],
          expense: expense[i],
        );
      }),
    );
  }
}
