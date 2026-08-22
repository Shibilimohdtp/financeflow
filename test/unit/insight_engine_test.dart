import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/insight.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/insight_engine.dart';

void main() {
  group('InsightEngine Tests', () {
    final now = DateTime(2026, 8, 15);

    test('Generates savings rate insight when income and savings exist', () {
      final currentTxs = [
        Transaction(
          id: 't1',
          amount: 50000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          categoryName: 'Salary',
          categoryIcon: 'payments',
          categoryColor: 'grove',
          merchant: 'Salary',
          date: DateTime(2026, 8, 1),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 't2',
          amount: 10000.0,
          type: TransactionType.expense,
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Swiggy',
          date: DateTime(2026, 8, 5),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final insights = InsightEngine.generateInsights(
        currentMonthTransactions: currentTxs,
        previousMonthTransactions: [],
        activeBudgets: [],
        activeGoals: [],
        contributionsByGoal: {},
        referenceDate: now,
      );

      expect(insights.any((i) => i.type == InsightType.savingsRate), isTrue);
      final sr = insights.firstWhere((i) => i.type == InsightType.savingsRate);
      expect(sr.description, contains('80%'));
    });

    test('Generates top category insight accurately', () {
      final currentTxs = [
        Transaction(
          id: 't1',
          amount: 8000.0,
          type: TransactionType.expense,
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Swiggy',
          date: DateTime(2026, 8, 5),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 't2',
          amount: 2000.0,
          type: TransactionType.expense,
          categoryId: 'cat_groceries',
          categoryName: 'Groceries',
          categoryIcon: 'shopping_basket',
          categoryColor: 'moss',
          merchant: 'Blinkit',
          date: DateTime(2026, 8, 6),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final insights = InsightEngine.generateInsights(
        currentMonthTransactions: currentTxs,
        previousMonthTransactions: [],
        activeBudgets: [],
        activeGoals: [],
        contributionsByGoal: {},
        referenceDate: now,
      );

      final topCat = insights.firstWhere(
        (i) => i.type == InsightType.topCategory,
      );
      expect(topCat.description, contains('Dining'));
      expect(topCat.description, contains('₹8,000'));
    });

    test('Filters out dismissed insight IDs', () {
      final currentTxs = [
        Transaction(
          id: 't1',
          amount: 50000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          categoryName: 'Salary',
          categoryIcon: 'payments',
          categoryColor: 'grove',
          merchant: 'Salary',
          date: DateTime(2026, 8, 1),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final dismissed = {'insight_savings_rate_2026_8'};

      final insights = InsightEngine.generateInsights(
        currentMonthTransactions: currentTxs,
        previousMonthTransactions: [],
        activeBudgets: [],
        activeGoals: [],
        contributionsByGoal: {},
        dismissedInsightIds: dismissed,
        referenceDate: now,
      );

      expect(
        insights.any((i) => i.id == 'insight_savings_rate_2026_8'),
        isFalse,
      );
    });
  });
}
