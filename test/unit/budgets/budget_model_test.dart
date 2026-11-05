import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/core/money/money_math.dart';
import 'package:financeflow/models/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyMath minor units', () {
    test('sums exactly where doubles drift', () {
      final values = List.filled(10, 0.1);
      expect(values.fold<double>(0, (a, b) => a + b), isNot(1.0));
      expect(MoneyMath.sumMinor(values), 100);
      expect(MoneyMath.toMinor(0.1 + 0.2), 30);
      expect(MoneyMath.fromMinor(123456), 1234.56);
    });

    test('nice rounding goes up to a friendly figure', () {
      expect(MoneyMath.niceCeilMinor(635000), 650000); // 6,350 → 6,500
      expect(MoneyMath.niceCeilMinor(270000), 280000); // 2,700 → 2,800
      expect(MoneyMath.niceCeilMinor(123400), 130000); // 1,234 → 1,300
      expect(MoneyMath.niceCeilMinor(4500000), 4600000); // 45,000 → 46,000
      expect(MoneyMath.niceCeilMinor(8500), 8500); // 85 → 85
      expect(MoneyMath.niceCeilMinor(700), 700); // 7 → 7
      expect(MoneyMath.niceCeilMinor(650), 700); // 6.50 → 7
      expect(MoneyMath.niceCeilMinor(0), 0);
    });
  });

  group('Budget compatibility', () {
    final legacy = Budget(
      id: 'b',
      name: 'Dining',
      categoryId: 'cat_dining',
      amountLimit: 6000,
      startDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('old budgets read as one category, minor-unit limit, no rollover', () {
      expect(legacy.categoryIds, ['cat_dining']);
      expect(legacy.limitMinor, 600000);
      expect(legacy.rolloverMode, RolloverMode.off);
      expect(legacy.group, BudgetGroup.other);
    });

    test('copyWith keeps the double and minor limits in step', () {
      final a = legacy.copyWith(limitMinor: 750050);
      expect(a.limitMinor, 750050);
      expect(a.amountLimit, 7500.5);

      final b = legacy.copyWith(amountLimit: 12.34);
      expect(b.limitMinor, 1234);
    });

    test('the first of several categories stays the legacy categoryId', () {
      final multi = legacy.copyWith(categoryIds: ['cat_food', 'cat_dining']);
      expect(multi.categoryId, 'cat_food');
      expect(multi.categoryIds, ['cat_food', 'cat_dining']);
    });

    test('validation copy does not assume a currency', () {
      final zero = legacy.copyWith(limitMinor: 0);
      expect(
        zero.validate,
        throwsA(
          isA<ValidationError>().having(
            (e) => '${e.message} ${e.actionableStep}'.toLowerCase(),
            'copy',
            isNot(contains('rupee')),
          ),
        ),
      );
    });

    test('enum parsing falls back safely', () {
      expect(BudgetGroup.fromString(null), BudgetGroup.other);
      expect(BudgetGroup.fromString('lifestyle'), BudgetGroup.lifestyle);
      expect(RolloverMode.fromString('nonsense'), RolloverMode.off);
      expect(RolloverMode.fromString('both'), RolloverMode.both);
    });
  });
}
