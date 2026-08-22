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
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('AddEditTransactionSheet validates amount and renders fields', (
    WidgetTester tester,
  ) async {
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
            (ref) => Stream.value([testCategory]),
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

    // Verify Title & Type Selector
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

    // Scroll to Save Transaction and tap with empty amount
    final saveButton = find.text('Save Transaction');
    await tester.scrollUntilVisible(
      saveButton,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final errorFinder = find.text('Please enter an amount greater than zero.');
    await tester.scrollUntilVisible(
      errorFinder,
      -100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(errorFinder, findsOneWidget);
  });
}
