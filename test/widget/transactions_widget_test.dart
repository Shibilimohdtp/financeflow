import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/features/transactions/transactions_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets(
    'TransactionsScreen renders search bar, filters and transaction rows',
    (WidgetTester tester) async {
      final now = DateTime.now();

      final testCategory = Category(
        id: 'cat_food',
        name: 'Food',
        iconIdentifier: 'restaurant',
        colorTokenIdentifier: 'clay',
        createdAt: now,
        updatedAt: now,
      );

      final testAccount = Account(
        id: 'acc_1',
        name: 'Main Cash',
        type: AccountType.cash,
        createdAt: now,
        updatedAt: now,
      );

      final testTransaction = Transaction(
        id: 't1',
        amount: 430.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Swiggy Biryani',
        date: now,
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            filteredTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: TransactionsScreen(
              onOpenDetail: (_) {},
              onAddTransaction: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Search and Filters
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfers'), findsOneWidget);

      // Verify Transaction Row
      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('− ₹430'), findsWidgets);
    },
  );
}
