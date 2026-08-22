import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/add_edit_transaction_sheet.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/services/categorization_service.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  setUp(() {
    CategorizationService.clearUserOverrides();
  });

  testWidgets(
    'AddEditTransactionSheet shows category suggestion when typing merchant',
    (WidgetTester tester) async {
      final now = DateTime.now();

      final diningCat = Category(
        id: 'cat_dining',
        name: 'Dining',
        iconIdentifier: 'restaurant',
        colorTokenIdentifier: 'clay',
        createdAt: now,
        updatedAt: now,
      );

      final groceryCat = Category(
        id: 'cat_groceries',
        name: 'Groceries',
        iconIdentifier: 'shopping_basket',
        colorTokenIdentifier: 'moss',
        createdAt: now,
        updatedAt: now,
      );

      final testAccount = Account(
        id: 'acc_1',
        name: 'Cash Wallet',
        type: AccountType.cash,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([diningCat, groceryCat]),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const Scaffold(
              body: SizedBox(
                height: 900,
                width: 500,
                child: AddEditTransactionSheet(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type Swiggy in merchant field
      final merchantField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Payee / Merchant',
      );
      expect(merchantField, findsOneWidget);

      await tester.enterText(merchantField, 'Swiggy Food');
      await tester.pumpAndSettle();

      // Suggestion banner should appear
      expect(find.textContaining('Suggested: Dining'), findsOneWidget);
      expect(find.textContaining('Matched keyword "swiggy"'), findsOneWidget);
    },
  );
}
