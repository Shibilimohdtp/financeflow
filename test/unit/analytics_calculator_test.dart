import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';
import 'package:financeflow/features/analytics/cash_flow_chart_data.dart';

void main() {
  group('AnalyticsCalculator Tests', () {
    final now = DateTime(2026, 8, 15);

    final transactions = [
      Transaction(
        id: 't1',
        amount: 50000.0,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'payments',
        categoryColor: 'grove',
        merchant: 'Employer',
        date: DateTime(2026, 8, 1),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 't2',
        amount: 3000.0,
        type: TransactionType.expense,
        categoryId: 'cat_dining',
        categoryName: 'Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'SWIGGY',
        date: DateTime(2026, 8, 5),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 't3',
        amount: 2000.0,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_basket',
        categoryColor: 'moss',
        merchant: 'BLINKIT',
        date: DateTime(2026, 8, 10),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 't4',
        amount: 1000.0,
        type: TransactionType.expense,
        categoryId: 'cat_transport',
        categoryName: 'Transport',
        categoryIcon: 'directions_car',
        categoryColor: 'slate',
        merchant: 'UBER INDIA',
        date: DateTime(2026, 8, 12),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test(
      'Calculates monthly analytics totals, net savings, and savings rate',
      () {
        final report = AnalyticsCalculator.calculateReport(
          allTransactions: transactions,
          timeRange: AnalyticsTimeRange.month,
          referenceDate: now,
        );

        expect(report.totalIncome, equals(50000.0));
        expect(report.totalExpense, equals(6000.0)); // 3000 + 2000 + 1000
        expect(report.netSavings, equals(44000.0));
        expect(report.savingsRate, equals(44000.0 / 50000.0));
        expect(report.transactionCount, equals(4));
        expect(report.averageTransactionAmount, equals(2000.0)); // 6000 / 3
        expect(report.highestTransactionAmount, equals(3000.0));
      },
    );

    test('Custom ranges retain every day and reconcile with report totals', () {
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: transactions,
        timeRange: AnalyticsTimeRange.custom,
        customStartDate: DateTime(2026, 8, 1),
        customEndDate: DateTime(2026, 9, 30, 23, 59),
      );
      expect(report.timeSeries.length, 61);
      expect(
        report.timeSeries.fold<double>(0, (v, p) => v + p.expense),
        report.totalExpense,
      );
      expect(
        report.timeSeries.fold<double>(0, (v, p) => v + p.income),
        report.totalIncome,
      );
      final chart = CashFlowChartData.fromPoints(
        points: report.timeSeries,
        range: report.timeRange,
        start: report.startDate,
        end: report.endDate,
      );
      expect(chart.buckets.length, lessThanOrEqualTo(7));
      expect(chart.buckets.fold<double>(0, (v, b) => v + b.expense), 6000);
      expect(chart.buckets.fold<double>(0, (v, b) => v + b.income), 50000);
      expect(chart.buckets.last.end, DateTime.utc(2026, 9, 30));
    });

    test('Monthly chart groups all days including the short final group', () {
      final points = List.generate(
        31,
        (i) => TimeSeriesPoint(
          date: DateTime(2026, 8, i + 1),
          label: '${i + 1}',
          expense: 10,
          income: i == 30 ? 1000 : 0,
        ),
      );
      final chart = CashFlowChartData.fromPoints(
        points: points,
        range: AnalyticsTimeRange.month,
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 31),
      );
      expect(chart.buckets.map((b) => b.label), [
        '1–7',
        '8–14',
        '15–21',
        '22–28',
        '29–31',
      ]);
      expect(chart.buckets.last.expense, 30);
      expect(chart.buckets.last.income, 1000);
      expect(chart.buckets.fold<double>(0, (v, b) => v + b.expense), 310);
      final leap = CashFlowChartData.fromPoints(
        points: [],
        range: AnalyticsTimeRange.month,
        start: DateTime(2024, 2, 1),
        end: DateTime(2024, 2, 29),
      );
      expect(leap.buckets.last.end, DateTime.utc(2024, 2, 29));
      expect(
        leap.buckets.every((b) => b.income == 0 && b.expense == 0),
        isTrue,
      );
    });

    test('Year and cross-year custom chart buckets preserve boundaries', () {
      final chart = CashFlowChartData.fromPoints(
        points: [
          TimeSeriesPoint(
            date: DateTime(2026, 12, 1),
            label: 'Dec',
            income: 200,
            expense: 100,
          ),
        ],
        range: AnalyticsTimeRange.year,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 12, 31),
      );
      expect(chart.buckets.length, 12);
      expect(chart.buckets.last.net, 100);
      expect(chart.buckets.last.dateLabel, '1–31 Dec 2026');
      final custom = CashFlowChartData.fromPoints(
        points: [
          TimeSeriesPoint(
            date: DateTime(2027, 1, 1),
            label: '1',
            income: 200,
            expense: 100,
          ),
        ],
        range: AnalyticsTimeRange.custom,
        start: DateTime(2026, 12, 29),
        end: DateTime(2027, 1, 12),
      );
      expect(custom.buckets.fold<double>(0, (v, b) => v + b.net), 100);
      for (var i = 1; i < custom.buckets.length; i++) {
        expect(
          custom.buckets[i].start.difference(custom.buckets[i - 1].end).inDays,
          1,
        );
      }
    });

    test('Category breakdown calculates shares accurately', () {
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: transactions,
        timeRange: AnalyticsTimeRange.month,
        referenceDate: now,
      );

      expect(report.categoryBreakdown.length, equals(3));
      final dining = report.categoryBreakdown.firstWhere(
        (c) => c.categoryId == 'cat_dining',
      );
      expect(dining.amount, equals(3000.0));
      expect(dining.percentage, equals(0.5)); // 3000 / 6000 = 50%
    });

    test('Normalizes top merchants in analytics', () {
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: transactions,
        timeRange: AnalyticsTimeRange.month,
        referenceDate: now,
      );

      expect(
        report.topMerchants.any((m) => m.normalizedMerchant == 'Swiggy'),
        isTrue,
      );
      expect(
        report.topMerchants.any((m) => m.normalizedMerchant == 'Blinkit'),
        isTrue,
      );
      expect(
        report.topMerchants.any((m) => m.normalizedMerchant == 'Uber'),
        isTrue,
      );
    });
  
    Transaction spend(String id, double amount, DateTime date) => Transaction(
      id: id,
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      merchant: 'Cafe',
      date: date,
      accountId: 'acc_1',
      createdAt: date,
      updatedAt: date,
    );

    test('month-to-date is compared with the same days of last month', () {
      // On 5 Nov: 1-5 Nov (₹1,000) vs 1-5 Oct (₹1,000). The rest of
      // October (₹9,000) must not make November look 90% cheaper.
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: [
          spend('a', 1000, DateTime(2026, 11, 3)),
          spend('b', 1000, DateTime(2026, 10, 2)),
          spend('c', 9000, DateTime(2026, 10, 20)),
        ],
        timeRange: AnalyticsTimeRange.month,
        referenceDate: DateTime(2026, 11, 5, 18),
      );

      expect(report.totalExpense, 1000);
      expect(report.previousPeriodExpense, 1000);
      expect(report.expenseChangePercentage, 0);
    });

    test('transactions at the last instant of the month are included', () {
      final report = AnalyticsCalculator.calculateReport(
        allTransactions: [
          spend('edge', 500, DateTime(2026, 10, 31, 23, 59, 59, 999)),
          spend('next', 700, DateTime(2026, 11, 1)),
        ],
        timeRange: AnalyticsTimeRange.month,
        referenceDate: DateTime(2026, 10, 15),
      );

      expect(report.totalExpense, 500);
    });
  });
}
