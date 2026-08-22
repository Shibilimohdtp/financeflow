import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/analytics_calculator.dart';

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
  });
}
