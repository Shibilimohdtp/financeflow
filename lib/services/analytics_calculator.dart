import 'dart:math';
import '../models/transaction.dart';
import 'merchant_normalization_service.dart';

enum AnalyticsTimeRange {
  week,
  month,
  year,
  custom;

  String get displayName {
    switch (this) {
      case AnalyticsTimeRange.week:
        return 'Week';
      case AnalyticsTimeRange.month:
        return 'Month';
      case AnalyticsTimeRange.year:
        return 'Year';
      case AnalyticsTimeRange.custom:
        return 'Custom';
    }
  }
}

class CategorySpend {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final double percentage; // 0.0 to 1.0
  final int transactionCount;

  const CategorySpend({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

class MerchantSpend {
  final String normalizedMerchant;
  final double totalAmount;
  final int transactionCount;

  const MerchantSpend({
    required this.normalizedMerchant,
    required this.totalAmount,
    required this.transactionCount,
  });
}

class TimeSeriesPoint {
  final DateTime date;
  final String label;
  final double expense;
  final double income;

  const TimeSeriesPoint({
    required this.date,
    required this.label,
    required this.expense,
    required this.income,
  });
}

class DayOfWeekSpend {
  final int weekday; // 1 = Mon, 7 = Sun
  final String dayName;
  final double totalAmount;
  final int count;

  const DayOfWeekSpend({
    required this.weekday,
    required this.dayName,
    required this.totalAmount,
    required this.count,
  });
}

class AnalyticsReport {
  final DateTime startDate;
  final DateTime endDate;
  final AnalyticsTimeRange timeRange;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate; // 0.0 to 1.0
  final int transactionCount;
  final double averageTransactionAmount;
  final double highestTransactionAmount;
  final List<CategorySpend> categoryBreakdown; // Top 5 + Other
  final List<MerchantSpend> topMerchants;
  final List<TimeSeriesPoint> timeSeries;
  final List<DayOfWeekSpend> dayOfWeekBreakdown;
  final double? previousPeriodExpense;
  final double? previousPeriodIncome;

  const AnalyticsReport({
    required this.startDate,
    required this.endDate,
    required this.timeRange,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.transactionCount,
    required this.averageTransactionAmount,
    required this.highestTransactionAmount,
    required this.categoryBreakdown,
    required this.topMerchants,
    required this.timeSeries,
    required this.dayOfWeekBreakdown,
    this.previousPeriodExpense,
    this.previousPeriodIncome,
  });
}

/// Pure domain service calculating analytics and charts data from local transactions
class AnalyticsCalculator {
  AnalyticsCalculator._();

  static ({DateTime start, DateTime end}) getDateRangeForTimeRange(
    AnalyticsTimeRange range,
    DateTime referenceDate,
  ) {
    switch (range) {
      case AnalyticsTimeRange.week:
        final dayOfWeek = referenceDate.weekday;
        final start = DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day - (dayOfWeek - 1),
          0,
          0,
          0,
        );
        final end = DateTime(
          start.year,
          start.month,
          start.day + 6,
          23,
          59,
          59,
          999,
        );
        return (start: start, end: end);

      case AnalyticsTimeRange.month:
        final start = DateTime(
          referenceDate.year,
          referenceDate.month,
          1,
          0,
          0,
          0,
        );
        final nextMonth = DateTime(
          referenceDate.year,
          referenceDate.month + 1,
          1,
        );
        final end = nextMonth.subtract(const Duration(milliseconds: 1));
        return (start: start, end: end);

      case AnalyticsTimeRange.year:
        final start = DateTime(referenceDate.year, 1, 1, 0, 0, 0);
        final end = DateTime(referenceDate.year, 12, 31, 23, 59, 59, 999);
        return (start: start, end: end);

      case AnalyticsTimeRange.custom:
        final start = DateTime(referenceDate.year, referenceDate.month, 1);
        final end = DateTime.now();
        return (start: start, end: end);
    }
  }

  static AnalyticsReport calculateReport({
    required List<Transaction> allTransactions,
    required AnalyticsTimeRange timeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final DateTime start;
    final DateTime end;

    if (timeRange == AnalyticsTimeRange.custom &&
        customStartDate != null &&
        customEndDate != null) {
      start = customStartDate;
      end = customEndDate;
    } else {
      final bounds = getDateRangeForTimeRange(timeRange, ref);
      start = bounds.start;
      end = bounds.end;
    }

    // Filter transactions in range
    final inRangeTxs =
        allTransactions.where((t) {
          return !t.date.isBefore(start) && !t.date.isAfter(end);
        }).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double highestTx = 0.0;
    int expenseCount = 0;

    final Map<
      String,
      ({String name, String icon, String color, double amount, int count})
    >
    catMap = {};
    final Map<String, ({double amount, int count})> merchantMap = {};
    final Map<int, ({double amount, int count})> weekdayMap = {
      1: (amount: 0.0, count: 0),
      2: (amount: 0.0, count: 0),
      3: (amount: 0.0, count: 0),
      4: (amount: 0.0, count: 0),
      5: (amount: 0.0, count: 0),
      6: (amount: 0.0, count: 0),
      7: (amount: 0.0, count: 0),
    };

    for (final tx in inRangeTxs) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        expenseCount++;
        if (tx.amount > highestTx) {
          highestTx = tx.amount;
        }

        // Category breakdown
        final existingCat =
            catMap[tx.categoryId] ??
            (
              name: tx.categoryName,
              icon: tx.categoryIcon,
              color: tx.categoryColor,
              amount: 0.0,
              count: 0,
            );
        catMap[tx.categoryId] = (
          name: tx.categoryName,
          icon: tx.categoryIcon,
          color: tx.categoryColor,
          amount: existingCat.amount + tx.amount,
          count: existingCat.count + 1,
        );

        // Normalized merchant breakdown
        final normalizedMerchant = MerchantNormalizationService.normalize(
          tx.merchant,
        );
        final existingMerch =
            merchantMap[normalizedMerchant] ?? (amount: 0.0, count: 0);
        merchantMap[normalizedMerchant] = (
          amount: existingMerch.amount + tx.amount,
          count: existingMerch.count + 1,
        );

        // Day of week breakdown
        final w = tx.date.weekday;
        final existingW = weekdayMap[w]!;
        weekdayMap[w] = (
          amount: existingW.amount + tx.amount,
          count: existingW.count + 1,
        );
      }
    }

    final netSavings = totalIncome - totalExpense;
    final savingsRate =
        totalIncome > 0 ? max(0.0, (netSavings / totalIncome)) : 0.0;
    final avgTx = expenseCount > 0 ? (totalExpense / expenseCount) : 0.0;

    // Process Category Breakdown (Top 5 + Other)
    final sortedCats =
        catMap.entries.toList()
          ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

    final List<CategorySpend> categoryBreakdown = [];
    if (sortedCats.length <= 6) {
      for (final entry in sortedCats) {
        final pct = totalExpense > 0 ? entry.value.amount / totalExpense : 0.0;
        categoryBreakdown.add(
          CategorySpend(
            categoryId: entry.key,
            categoryName: entry.value.name,
            categoryIcon: entry.value.icon,
            categoryColor: entry.value.color,
            amount: entry.value.amount,
            percentage: pct,
            transactionCount: entry.value.count,
          ),
        );
      }
    } else {
      // Take top 5
      for (int i = 0; i < 5; i++) {
        final entry = sortedCats[i];
        final pct = totalExpense > 0 ? entry.value.amount / totalExpense : 0.0;
        categoryBreakdown.add(
          CategorySpend(
            categoryId: entry.key,
            categoryName: entry.value.name,
            categoryIcon: entry.value.icon,
            categoryColor: entry.value.color,
            amount: entry.value.amount,
            percentage: pct,
            transactionCount: entry.value.count,
          ),
        );
      }
      // Group remaining as Other
      double otherAmount = 0.0;
      int otherCount = 0;
      for (int i = 5; i < sortedCats.length; i++) {
        otherAmount += sortedCats[i].value.amount;
        otherCount += sortedCats[i].value.count;
      }
      categoryBreakdown.add(
        CategorySpend(
          categoryId: 'cat_other_grouped',
          categoryName: 'Other Categories',
          categoryIcon: 'category',
          categoryColor: 'slate',
          amount: otherAmount,
          percentage: totalExpense > 0 ? otherAmount / totalExpense : 0.0,
          transactionCount: otherCount,
        ),
      );
    }

    // Process Top Merchants
    final sortedMerchants =
        merchantMap.entries.toList()
          ..sort((a, b) => b.value.amount.compareTo(a.value.amount));

    final topMerchants =
        sortedMerchants.take(10).map((e) {
          return MerchantSpend(
            normalizedMerchant: e.key,
            totalAmount: e.value.amount,
            transactionCount: e.value.count,
          );
        }).toList();

    // Process Day of Week Breakdown
    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };

    final dayOfWeekBreakdown =
        [1, 2, 3, 4, 5, 6, 7].map((w) {
          final item = weekdayMap[w]!;
          return DayOfWeekSpend(
            weekday: w,
            dayName: dayNames[w]!,
            totalAmount: item.amount,
            count: item.count,
          );
        }).toList();

    // Time series points generation
    final timeSeries = _generateTimeSeries(inRangeTxs, timeRange, start, end);

    return AnalyticsReport(
      startDate: start,
      endDate: end,
      timeRange: timeRange,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      transactionCount: inRangeTxs.length,
      averageTransactionAmount: avgTx,
      highestTransactionAmount: highestTx,
      categoryBreakdown: categoryBreakdown,
      topMerchants: topMerchants,
      timeSeries: timeSeries,
      dayOfWeekBreakdown: dayOfWeekBreakdown,
    );
  }

  static List<TimeSeriesPoint> _generateTimeSeries(
    List<Transaction> transactions,
    AnalyticsTimeRange range,
    DateTime start,
    DateTime end,
  ) {
    final List<TimeSeriesPoint> points = [];

    if (range == AnalyticsTimeRange.week) {
      // 7 daily points Mon-Sun
      for (int i = 0; i < 7; i++) {
        final d = start.add(Duration(days: i));
        double dayExp = 0.0;
        double dayInc = 0.0;

        for (final tx in transactions) {
          if (tx.date.year == d.year &&
              tx.date.month == d.month &&
              tx.date.day == d.day) {
            if (tx.type == TransactionType.expense) dayExp += tx.amount;
            if (tx.type == TransactionType.income) dayInc += tx.amount;
          }
        }

        const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        points.add(
          TimeSeriesPoint(
            date: d,
            label: weekdayLabels[d.weekday - 1],
            expense: dayExp,
            income: dayInc,
          ),
        );
      }
    } else if (range == AnalyticsTimeRange.month) {
      // 4 weekly chunks or daily intervals
      final totalDays = end.difference(start).inDays + 1;
      for (int day = 1; day <= totalDays; day++) {
        final d = DateTime(start.year, start.month, day);
        double dayExp = 0.0;
        double dayInc = 0.0;

        for (final tx in transactions) {
          if (tx.date.year == d.year &&
              tx.date.month == d.month &&
              tx.date.day == d.day) {
            if (tx.type == TransactionType.expense) dayExp += tx.amount;
            if (tx.type == TransactionType.income) dayInc += tx.amount;
          }
        }

        points.add(
          TimeSeriesPoint(
            date: d,
            label: '$day',
            expense: dayExp,
            income: dayInc,
          ),
        );
      }
    } else if (range == AnalyticsTimeRange.year) {
      // 12 monthly points
      const monthNames = [
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
      for (int m = 1; m <= 12; m++) {
        final d = DateTime(start.year, m, 1);
        double mExp = 0.0;
        double mInc = 0.0;

        for (final tx in transactions) {
          if (tx.date.year == start.year && tx.date.month == m) {
            if (tx.type == TransactionType.expense) mExp += tx.amount;
            if (tx.type == TransactionType.income) mInc += tx.amount;
          }
        }

        points.add(
          TimeSeriesPoint(
            date: d,
            label: monthNames[m - 1],
            expense: mExp,
            income: mInc,
          ),
        );
      }
    } else {
      // Custom: daily points
      final totalDays = end.difference(start).inDays + 1;
      final step = max(1, (totalDays / 15).floor());
      for (int i = 0; i < totalDays; i += step) {
        final d = start.add(Duration(days: i));
        double dExp = 0.0;
        double dInc = 0.0;

        for (final tx in transactions) {
          if (tx.date.year == d.year &&
              tx.date.month == d.month &&
              tx.date.day == d.day) {
            if (tx.type == TransactionType.expense) dExp += tx.amount;
            if (tx.type == TransactionType.income) dInc += tx.amount;
          }
        }

        points.add(
          TimeSeriesPoint(
            date: d,
            label: '${d.day}/${d.month}',
            expense: dExp,
            income: dInc,
          ),
        );
      }
    }

    return points;
  }
}
