import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/budget_calculator.dart';

void main() {
  group('BudgetCalculator Tests', () {
    final now = DateTime(2026, 8, 15, 12, 0); // 15 August 2026

    final foodBudget = Budget(
      id: 'b_food',
      name: 'Food & Dining',
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      amountLimit: 10000.0,
      period: BudgetPeriod.monthly,
      startDate: DateTime(2026, 8, 1),
      alertThreshold: 0.8,
      createdAt: now,
      updatedAt: now,
    );

    test(
      'Monthly period boundaries are exact from 1st 00:00 to last day 23:59:59',
      () {
        final bounds = BudgetCalculator.getPeriodBounds(foodBudget, now);
        expect(bounds.start, equals(DateTime(2026, 8, 1, 0, 0, 0)));
        expect(bounds.end.year, equals(2026));
        expect(bounds.end.month, equals(8));
        expect(bounds.end.day, equals(31));
        expect(bounds.end.hour, equals(23));
        expect(bounds.end.minute, equals(59));
        expect(bounds.end.second, equals(59));
      },
    );

    test('Leap year February monthly period boundary ends on Feb 29', () {
      final leapFebDate = DateTime(2028, 2, 10);
      final bounds = BudgetCalculator.getPeriodBounds(foodBudget, leapFebDate);
      expect(bounds.start, equals(DateTime(2028, 2, 1, 0, 0, 0)));
      expect(bounds.end.year, equals(2028));
      expect(bounds.end.month, equals(2));
      expect(bounds.end.day, equals(29));
    });

    test(
      'Weekly period boundaries start Monday 00:00 and end Sunday 23:59:59',
      () {
        // 15 August 2026 is Saturday (weekday = 6)
        // Monday is 10 August 2026, Sunday is 16 August 2026
        final weeklyBudget = foodBudget.copyWith(period: BudgetPeriod.weekly);
        final bounds = BudgetCalculator.getPeriodBounds(weeklyBudget, now);
        expect(bounds.start, equals(DateTime(2026, 8, 10, 0, 0, 0)));
        expect(bounds.end.day, equals(16));
        expect(bounds.end.hour, equals(23));
      },
    );

    test('Yearly period boundaries span Jan 1 to Dec 31', () {
      final yearlyBudget = foodBudget.copyWith(period: BudgetPeriod.yearly);
      final bounds = BudgetCalculator.getPeriodBounds(yearlyBudget, now);
      expect(bounds.start, equals(DateTime(2026, 1, 1, 0, 0, 0)));
      expect(bounds.end.year, equals(2026));
      expect(bounds.end.month, equals(12));
      expect(bounds.end.day, equals(31));
    });

    test(
      'Calculates spending correctly, strictly filtering for expense type and category',
      () {
        final transactions = [
          // Matching expense within period
          Transaction(
            id: 't1',
            amount: 2500.0,
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Restaurant',
            date: DateTime(2026, 8, 5),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          // Matching expense within period
          Transaction(
            id: 't2',
            amount: 1500.0,
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Swiggy',
            date: DateTime(2026, 8, 12),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          // Different category expense (Groceries) - MUST NOT BE COUNTED
          Transaction(
            id: 't3',
            amount: 3000.0,
            type: TransactionType.expense,
            categoryId: 'cat_groceries',
            categoryName: 'Groceries',
            categoryIcon: 'shopping_basket',
            categoryColor: 'moss',
            merchant: 'Blinkit',
            date: DateTime(2026, 8, 10),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          // Income with same category - MUST NOT BE COUNTED
          Transaction(
            id: 't4',
            amount: 5000.0,
            type: TransactionType.income,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Refund',
            date: DateTime(2026, 8, 8),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          // Transfer - MUST NOT BE COUNTED
          Transaction(
            id: 't5',
            amount: 1000.0,
            type: TransactionType.transfer,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Transfer to Wallet',
            date: DateTime(2026, 8, 14),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
          // Out of period (July) - MUST NOT BE COUNTED
          Transaction(
            id: 't6',
            amount: 4000.0,
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Old Dining',
            date: DateTime(2026, 7, 28),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final spent = BudgetCalculator.calculateSpending(
          foodBudget,
          transactions,
          referenceDate: now,
        );
        expect(spent, equals(4000.0)); // 2500 + 1500
      },
    );

    test(
      'Calculates summary with remaining amount, percentage, daily allowance and projection',
      () {
        final transactions = [
          Transaction(
            id: 't1',
            amount: 4000.0,
            type: TransactionType.expense,
            categoryId: 'cat_dining',
            categoryName: 'Dining',
            categoryIcon: 'restaurant',
            categoryColor: 'clay',
            merchant: 'Cafe',
            date: DateTime(2026, 8, 10),
            accountId: 'acc_1',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final summary = BudgetCalculator.calculateSummary(
          foodBudget,
          transactions,
          referenceDate: now,
        );
        expect(summary.amountSpent, equals(4000.0));
        expect(summary.remainingAmount, equals(6000.0));
        expect(summary.percentageUsed, equals(0.4)); // 40%
        expect(summary.amountOverBudget, equals(0.0));
        expect(summary.isExceeded, isFalse);
        expect(summary.isApproachingThreshold, isFalse);
        expect(
          summary.daysRemaining,
          equals(17),
        ); // Aug 15 to Aug 31 inclusive = 17 days
        expect(summary.dailyAllowanceRemaining, closeTo(6000.0 / 17, 0.01));
        // Projected spend: 4000 in 15 days * 31 days total = 8266.67
        expect(
          summary.projectedPeriodEndSpending,
          closeTo((4000.0 / 15) * 31, 0.1),
        );
      },
    );

    test('Identifies over budget and approaching alert threshold states', () {
      // 85% spent (8,500 of 10,000) -> approaching 80% threshold
      final nearTx = [
        Transaction(
          id: 't1',
          amount: 8500.0,
          type: TransactionType.expense,
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Buffet',
          date: DateTime(2026, 8, 10),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final nearSummary = BudgetCalculator.calculateSummary(
        foodBudget,
        nearTx,
        referenceDate: now,
      );
      expect(nearSummary.isApproachingThreshold, isTrue);
      expect(nearSummary.isExceeded, isFalse);
      expect(nearSummary.remainingAmount, equals(1500.0));

      // Over budget (11,200 of 10,000)
      final overTx = [
        Transaction(
          id: 't1',
          amount: 11200.0,
          type: TransactionType.expense,
          categoryId: 'cat_dining',
          categoryName: 'Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Feast',
          date: DateTime(2026, 8, 12),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final overSummary = BudgetCalculator.calculateSummary(
        foodBudget,
        overTx,
        referenceDate: now,
      );
      expect(overSummary.isExceeded, isTrue);
      expect(overSummary.amountOverBudget, equals(1200.0));
      expect(overSummary.remainingAmount, equals(0.0));
      expect(overSummary.dailyAllowanceRemaining, equals(0.0));
    });
  });
}
