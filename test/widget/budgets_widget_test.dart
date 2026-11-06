import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/budget_detail_screen.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
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
    'BudgetDetailScreen renders hero metrics, pace and transactions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDashboardMonthProvider.overrideWith(
              (ref) => DateTime(2026, 8, 1),
            ),
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
      expect(find.text('DAILY ALLOWANCE'), findsOneWidget);
      expect(find.text('PROJECTED SPEND'), findsOneWidget);
      expect(find.text('Budget Settings'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Cafe Delight'), findsOneWidget);
    },
  );
}
