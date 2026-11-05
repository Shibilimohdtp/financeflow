import 'dart:math';
import '../core/period/period.dart';
import '../models/transaction.dart';
import 'ledger_totals.dart';
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

class AccountSpend {
  final String accountId;
  final String accountName;
  final double totalExpense;
  final double totalIncome;
  final int transactionCount;

  const AccountSpend({
    required this.accountId,
    required this.accountName,
    required this.totalExpense,
    required this.totalIncome,
    required this.transactionCount,
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
  final List<AccountSpend> accountBreakdown;
  final List<Transaction> largestTransactions;
  final List<CategorySpend> incomeSources;
  final Map<String, List<Transaction>> categoryTransactions;
  final double? previousPeriodExpense;
  final double? previousPeriodIncome;
  final double? expenseChangePercentage;
  final double? incomeChangePercentage;

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
    this.accountBreakdown = const [],
    this.largestTransactions = const [],
    this.incomeSources = const [],
    this.categoryTransactions = const {},
    this.previousPeriodExpense,
    this.previousPeriodIncome,
    this.expenseChangePercentage,
    this.incomeChangePercentage,
  });
}

/// Pure domain service calculating analytics and charts data from local transactions
class AnalyticsCalculator {
  AnalyticsCalculator._();

  /// Chart bucketing for a period: months for a year, days otherwise.
  static AnalyticsTimeRange rangeFor(PeriodUnit unit) => switch (unit) {
    PeriodUnit.week => AnalyticsTimeRange.week,
    PeriodUnit.month => AnalyticsTimeRange.month,
    PeriodUnit.year => AnalyticsTimeRange.year,
    PeriodUnit.day || PeriodUnit.custom => AnalyticsTimeRange.custom,
  };

  static PeriodUnit _unitFor(AnalyticsTimeRange range) => switch (range) {
    AnalyticsTimeRange.week => PeriodUnit.week,
    AnalyticsTimeRange.month => PeriodUnit.month,
    AnalyticsTimeRange.year => PeriodUnit.year,
    AnalyticsTimeRange.custom => PeriodUnit.custom,
  };

  /// The reporting period for [range] around [referenceDate]. A custom range
  /// without explicit dates falls back to the month containing the reference.
  static Period periodFor(
    AnalyticsTimeRange range,
    DateTime referenceDate, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    if (range == AnalyticsTimeRange.custom) {
      if (customStart != null && customEnd != null) {
        return Period.custom(customStart, customEnd);
      }
      return Period.containing(PeriodUnit.month, referenceDate);
    }
    return Period.containing(_unitFor(range), referenceDate);
  }

  static ({DateTime start, DateTime end}) getDateRangeForTimeRange(
    AnalyticsTimeRange range,
    DateTime referenceDate,
  ) {
    final period = periodFor(range, referenceDate);
    return (start: period.start, end: period.endInclusive);
  }

  static AnalyticsReport calculateReport({
    required List<Transaction> allTransactions,
    required AnalyticsTimeRange timeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DateTime? referenceDate,
    Period? forPeriod,
    DateTime? now,
  }) {
    // [forPeriod] wins when given (Home/Insights pass the shared period);
    // otherwise it is derived from [timeRange] around [referenceDate].
    // [now] decides how much of an in-progress period has elapsed.
    final clock = now ?? referenceDate ?? DateTime.now();
    final period =
        forPeriod ??
        periodFor(
          timeRange,
          referenceDate ?? clock,
          customStart: customStartDate,
          customEnd: customEndDate,
        );
    final start = period.start;
    final end = period.endInclusive;

    final inRangeTxs =
        allTransactions.where((t) => period.contains(t.date)).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double highestTx = 0.0;
    int expenseCount = 0;

    final Map<
      String,
      ({String name, String icon, String color, double amount, int count})
    >
    catMap = {};
    final Map<
      String,
      ({String name, String icon, String color, double amount, int count})
    >
    incomeCatMap = {};
    final Map<String, ({double amount, int count})> merchantMap = {};
    final Map<String, ({String name, double expense, double income, int count})>
    accountMap = {};
    final Map<String, List<Transaction>> categoryTransactions = {};

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
      // Map category transactions
      categoryTransactions.putIfAbsent(tx.categoryId, () => []).add(tx);

      // Account breakdown
      final accId = tx.accountId.isNotEmpty ? tx.accountId : 'acc_default';
      final currentAcc =
          accountMap[accId] ??
          (name: 'Account', expense: 0.0, income: 0.0, count: 0);
      accountMap[accId] = (
        name: currentAcc.name,
        expense: currentAcc.expense + tx.consumptionExpenseAmount,
        income: currentAcc.income + tx.earnedIncomeAmount,
        count: currentAcc.count + 1,
      );

      if (tx.earnedIncomeAmount > 0) {
        totalIncome += tx.earnedIncomeAmount;

        final existingIncCat =
            incomeCatMap[tx.categoryId] ??
            (
              name: tx.categoryName.isNotEmpty ? tx.categoryName : 'Income',
              icon: tx.categoryIcon,
              color: tx.categoryColor,
              amount: 0.0,
              count: 0,
            );
        incomeCatMap[tx.categoryId] = (
          name: tx.categoryName.isNotEmpty ? tx.categoryName : 'Income',
          icon: tx.categoryIcon,
          color: tx.categoryColor,
          amount: existingIncCat.amount + tx.earnedIncomeAmount,
          count: existingIncCat.count + 1,
        );
      }
      if (tx.consumptionExpenseAmount > 0) {
        final expenseAmount = tx.consumptionExpenseAmount;
        totalExpense += expenseAmount;
        expenseCount++;
        if (expenseAmount > highestTx) {
          highestTx = expenseAmount;
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
          amount: existingCat.amount + expenseAmount,
          count: existingCat.count + 1,
        );

        // Normalized merchant breakdown
        final normalizedMerchant = MerchantNormalizationService.normalize(
          tx.merchant,
        );
        final existingMerch =
            merchantMap[normalizedMerchant] ?? (amount: 0.0, count: 0);
        merchantMap[normalizedMerchant] = (
          amount: existingMerch.amount + expenseAmount,
          count: existingMerch.count + 1,
        );

        // Day of week breakdown
        final w = tx.date.weekday;
        final existingW = weekdayMap[w]!;
        weekdayMap[w] = (
          amount: existingW.amount + expenseAmount,
          count: existingW.count + 1,
        );
      }
    }

    // Sort category transactions by date descending
    for (final entry in categoryTransactions.entries) {
      entry.value.sort((a, b) => b.date.compareTo(a.date));
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

    // Process Income Sources
    final sortedIncCats =
        incomeCatMap.entries.toList()
          ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final incomeSources =
        sortedIncCats
            .map(
              (e) => CategorySpend(
                categoryId: e.key,
                categoryName: e.value.name,
                categoryIcon: e.value.icon,
                categoryColor: e.value.color,
                amount: e.value.amount,
                percentage:
                    totalIncome > 0 ? (e.value.amount / totalIncome) : 0.0,
                transactionCount: e.value.count,
              ),
            )
            .toList();

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

    // Process Account Breakdown
    final sortedAccounts =
        accountMap.entries.toList()
          ..sort((a, b) => b.value.expense.compareTo(a.value.expense));
    final accountBreakdown =
        sortedAccounts
            .map(
              (e) => AccountSpend(
                accountId: e.key,
                accountName: e.value.name,
                totalExpense: e.value.expense,
                totalIncome: e.value.income,
                transactionCount: e.value.count,
              ),
            )
            .toList();

    // Process Largest Transactions
    final largestTransactions = List<Transaction>.from(
      inRangeTxs.where((t) => t.consumptionExpenseAmount > 0),
    )..sort((a, b) => b.amount.compareTo(a.amount));
    final topLargest = largestTransactions.take(5).toList();

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
    final timeSeries = _generateTimeSeries(
      inRangeTxs,
      forPeriod == null ? timeRange : rangeFor(forPeriod.unit),
      start,
      end,
    );

    // Like-for-like comparison: a period in progress is compared with the
    // same number of elapsed days of the previous period.
    final comparison = period.comparison(clock);
    final soFar = LedgerTotals.of(
      inRangeTxs.where((t) => comparison.current.contains(t.date)),
    );
    final before = LedgerTotals.of(
      allTransactions.where((t) => comparison.previous.contains(t.date)),
    );
    final prevExpense = before.spending;
    final prevIncome = before.income;
    final expenseChangePct = LedgerTotals.percentChange(
      soFar.spending,
      prevExpense,
    );
    final incomeChangePct = LedgerTotals.percentChange(
      soFar.income,
      prevIncome,
    );

    return AnalyticsReport(
      startDate: start,
      endDate: end,
      timeRange: forPeriod == null ? timeRange : rangeFor(forPeriod.unit),
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
      accountBreakdown: accountBreakdown,
      largestTransactions: topLargest,
      incomeSources: incomeSources,
      categoryTransactions: categoryTransactions,
      previousPeriodExpense: prevExpense > 0 ? prevExpense : null,
      previousPeriodIncome: prevIncome > 0 ? prevIncome : null,
      expenseChangePercentage: expenseChangePct,
      incomeChangePercentage: incomeChangePct,
    );
  }

  static List<TimeSeriesPoint> _generateTimeSeries(
    List<Transaction> transactions,
    AnalyticsTimeRange range,
    DateTime start,
    DateTime end,
  ) {
    final List<TimeSeriesPoint> points = [];

    if (range == AnalyticsTimeRange.week || range == AnalyticsTimeRange.month) {
      final period = Period.custom(start, end);
      final totals = <DateTime, ({double expense, double income})>{};
      for (final tx in transactions) {
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final previous = totals[day] ?? (expense: 0.0, income: 0.0);
        totals[day] = (
          expense: previous.expense + tx.consumptionExpenseAmount,
          income: previous.income + tx.earnedIncomeAmount,
        );
      }
      const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (final d in period.days) {
        final values = totals[d];
        points.add(
          TimeSeriesPoint(
            date: d,
            label:
                range == AnalyticsTimeRange.week
                    ? weekdayLabels[d.weekday - 1]
                    : '${d.day}',
            expense: values?.expense ?? 0,
            income: values?.income ?? 0,
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
            mExp += tx.consumptionExpenseAmount;
            mInc += tx.earnedIncomeAmount;
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
      // Keep every day. Sampling dates discarded transactions on skipped days;
      // the presentation layer may aggregate these complete daily totals.
      final totals = <DateTime, ({double expense, double income})>{};
      for (final tx in transactions) {
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final previous = totals[day] ?? (expense: 0.0, income: 0.0);
        totals[day] = (
          expense: previous.expense + tx.consumptionExpenseAmount,
          income: previous.income + tx.earnedIncomeAmount,
        );
      }
      for (final d in Period.custom(start, end).days) {
        final values = totals[d];
        points.add(
          TimeSeriesPoint(
            date: d,
            label: '${d.day}/${d.month}',
            expense: values?.expense ?? 0,
            income: values?.income ?? 0,
          ),
        );
      }
    }

    return points;
  }
}
