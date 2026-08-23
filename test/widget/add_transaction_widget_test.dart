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
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/shared/widgets/ff_button.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  final now = DateTime.now();

  final testFoodCategory = Category(
    id: 'cat_food',
    name: 'Food & Dining',
    iconIdentifier: 'restaurant',
    colorTokenIdentifier: 'clay',
    typeCompatibility: const ['expense', 'cash'],
    createdAt: now,
    updatedAt: now,
  );

  final testSalaryCategory = Category(
    id: 'cat_salary',
    name: 'Salary',
    iconIdentifier: 'payments',
    colorTokenIdentifier: 'grove',
    typeCompatibility: const ['income'],
    createdAt: now,
    updatedAt: now,
  );

  final testAccount1 = Account(
    id: 'acc_1',
    name: 'HDFC Bank',
    type: AccountType.bank,
    institutionName: 'HDFC',
    maskedIdentifier: '••4321',
    currentBalance: 50000,
    createdAt: now,
    updatedAt: now,
  );

  final testAccount2 = Account(
    id: 'acc_2',
    name: 'Cash Wallet',
    type: AccountType.cash,
    currentBalance: 3500,
    createdAt: now,
    updatedAt: now,
  );

  Widget createTestWidget({Transaction? initialTransaction}) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value([testFoodCategory, testSalaryCategory]),
        ),
        rawAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([testAccount1, testAccount2]),
        ),
        allTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: Scaffold(
          body: AddEditTransactionSheet(initialTransaction: initialTransaction),
        ),
      ),
    );
  }

  testWidgets('AddEditTransactionSheet validates amount and renders fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Type Selector
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Investment'), findsOneWidget);
    expect(find.text('Loan EMI'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);

    // Verify default save button
    final saveButton = find.widgetWithText(FfButton, 'Save Expense');
    expect(saveButton, findsOneWidget);

    // Tap save with empty amount -> validation error
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter an amount greater than zero.'),
      findsOneWidget,
    );
  });

  testWidgets('Type switching updates visible fields and button label', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Switch to Income
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Payer / Source'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Save Income'), findsOneWidget);

    // Switch to Transfer
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    expect(find.text('Transfer Reference / Recipient'), findsOneWidget);
    expect(find.text('From Account'), findsOneWidget);
    expect(find.text('To Account'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Save Transfer'), findsOneWidget);

    // Switch to Investment
    await tester.tap(find.text('Investment'));
    await tester.pumpAndSettle();

    expect(find.text('Asset / Platform'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Save Investment'), findsOneWidget);
  });

  testWidgets('Quick date chips allow switching between Today and Yesterday', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);

    await tester.tap(find.text('Yesterday'));
    await tester.pumpAndSettle();

    final yesterdayChoiceChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Yesterday'),
    );
    expect(yesterdayChoiceChip.selected, isTrue);
  });

  testWidgets('More details expansion tile toggles optional fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('More details'), findsOneWidget);
    expect(find.text('Notes'), findsNothing);

    // Expand More details
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Payment method'), findsOneWidget);
  });

  testWidgets('Edit mode loads initial transaction details accurately', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final existingTx = Transaction(
      id: 'tx_123',
      amount: 1450.0,
      type: TransactionType.expense,
      categoryId: 'cat_food',
      categoryName: 'Food & Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      merchant: 'Blue Tokai Coffee',
      date: now,
      notes: 'Meeting coffee',
      paymentMethod: 'Credit Card',
      accountId: 'acc_1',
      tags: const ['work', 'coffee'],
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(createTestWidget(initialTransaction: existingTx));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.text('1450'), findsOneWidget);
    expect(find.text('Blue Tokai Coffee'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Update Expense'), findsOneWidget);
  });

  testWidgets('Category-aware Payee suggestions update dynamically on category change', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testGroceriesCategory = Category(
      id: 'cat_groceries',
      name: 'Groceries',
      iconIdentifier: 'shopping_cart',
      colorTokenIdentifier: 'leaf',
      typeCompatibility: const ['expense', 'cash'],
      createdAt: now,
      updatedAt: now,
    );

    final history = [
      Transaction(
        id: 'tx_g1',
        amount: 500,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColor: 'leaf',
        merchant: 'Lulu Hypermarket',
        date: now.subtract(const Duration(days: 1)),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_f1',
        amount: 300,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Zomato',
        date: now.subtract(const Duration(days: 2)),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_i1',
        amount: 50000,
        type: TransactionType.income,
        categoryId: 'cat_salary',
        categoryName: 'Salary',
        categoryIcon: 'payments',
        categoryColor: 'grove',
        merchant: 'Tech Corp Salary',
        date: now.subtract(const Duration(days: 5)),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    Widget buildWithHistory() {
      return ProviderScope(
        overrides: [
          settingsStreamProvider.overrideWith(
            (ref) => Stream.value(const AppSettings()),
          ),
          categoriesStreamProvider.overrideWith(
            (ref) => Stream.value([testFoodCategory, testGroceriesCategory, testSalaryCategory]),
          ),
          rawAccountsStreamProvider.overrideWith(
            (ref) => Stream.value([testAccount1, testAccount2]),
          ),
          allTransactionsStreamProvider.overrideWith((ref) => Stream.value(history)),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: AddEditTransactionSheet(),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWithHistory());
    await tester.pumpAndSettle();

    // Default category selected is Food & Dining -> Zomato is top suggestion
    expect(find.text('Zomato'), findsOneWidget);

    // Switch category to Groceries
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    // Groceries payees prioritized -> Lulu Hypermarket is visible
    expect(find.text('Lulu Hypermarket'), findsOneWidget);

    // Tap on suggestion chip 'Lulu Hypermarket' to fill payee field
    await tester.tap(find.text('Lulu Hypermarket'));
    await tester.pumpAndSettle();

    // Payee field now contains Lulu Hypermarket
    expect(find.widgetWithText(TextField, 'Lulu Hypermarket'), findsOneWidget);

    // Changing category to Food & Dining after entering payee does NOT erase the entered payee
    await tester.tap(find.text('Food & Dining'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Lulu Hypermarket'), findsOneWidget);

    // Clear payee field
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();

    // Switch type to Income -> shows income payer Tech Corp Salary
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Tech Corp Salary'), findsOneWidget);
  });
}
