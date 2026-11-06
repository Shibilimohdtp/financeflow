import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/budget_detail_screen.dart';
import 'package:financeflow/features/budgets/plan_providers.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  final now = DateTime(2026, 8, 15);

  final testBudget = Budget(
    id: 'b1',
    name: 'Food & Dining',
    categoryId: 'cat_dining',
    categoryName: 'Dining',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    amountLimit: 10000.0,
    startDate: DateTime(2026, 8, 1),
    createdAt: now,
    updatedAt: now,
  );

  final testTransaction = Transaction(
    id: 'tx1',
    amount: 500.0,
    type: TransactionType.expense,
    categoryId: 'cat_dining',
    categoryName: 'Dining',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    merchant: 'Cafe Delight',
    date: DateTime(2026, 8, 10),
    accountId: 'acc1',
    createdAt: now,
    updatedAt: now,
  );

  testWidgets(
    'BudgetDetailScreen shows the hero, trend and the counted payments',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            planNowProvider.overrideWithValue(DateTime(2026, 8, 15, 12)),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: BudgetDetailScreen(budget: testBudget),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Food & Dining'), findsWidgets);
      expect(find.text('Left to spend'), findsOneWidget);
      expect(find.text('Per day'), findsOneWidget);
      expect(find.text('Forecast'), findsOneWidget);
      expect(find.byKey(const ValueKey('budget-trend')), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Cafe Delight'), 200);
      expect(find.text('Cafe Delight'), findsOneWidget);
      await tester.scrollUntilVisible(find.textContaining('1 payment'), 200);
    },
  );
}
