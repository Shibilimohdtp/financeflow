import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/personal_debts/money_records_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/add_edit_transaction_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/money_advance.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/shared/widgets/ff_button.dart';
import 'package:financeflow/shared/widgets/ff_chip.dart';
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

  final testGroceriesCategory = Category(
    id: 'cat_groceries',
    name: 'Groceries',
    iconIdentifier: 'shopping_cart',
    colorTokenIdentifier: 'leaf',
    typeCompatibility: const ['expense', 'cash'],
    createdAt: now,
    updatedAt: now,
  );

  final testShoppingCategory = Category(
    id: 'cat_shopping',
    name: 'Shopping',
    iconIdentifier: 'storefront',
    colorTokenIdentifier: 'slate',
    typeCompatibility: const ['expense', 'cash'],
    createdAt: now,
    updatedAt: now,
  );

  final testTransportCategory = Category(
    id: 'cat_transport',
    name: 'Transport',
    iconIdentifier: 'directions_car',
    colorTokenIdentifier: 'indigo',
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

  Widget createTestWidget({
    Transaction? initialTransaction,
    List<Category>? categories,
    List<Transaction>? history,
    List<MoneyRecord>? moneyRecords,
    Future<void> Function(Transaction)? onSave,
  }) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value(
            categories ??
                [
                  testFoodCategory,
                  testGroceriesCategory,
                  testShoppingCategory,
                  testTransportCategory,
                  testSalaryCategory,
                ],
          ),
        ),
        rawAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([testAccount1, testAccount2]),
        ),
        allTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value(history ?? []),
        ),
        allMoneyRecordsStreamProvider.overrideWith(
          (ref) => Stream.value(moneyRecords ?? []),
        ),
        allMoneyRepaymentsStreamProvider.overrideWith(
          (ref) => Stream.value(const <MoneyRepayment>[]),
        ),
        allMoneyAdvancesStreamProvider.overrideWith(
          (ref) => Stream.value(const <MoneyAdvance>[]),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: AddEditTransactionScreen(
          initialTransaction: initialTransaction,
          onSave: onSave,
        ),
      ),
    );
  }

  testWidgets('AddEditTransactionScreen validates amount and renders fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Type Selector (Stillwater Bloom segmented pill)
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsWidgets);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

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

    // Switch to Income (defaults to earned income)
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Payer / Source (optional)'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Save Income'), findsOneWidget);

    // Switch to moving between owned accounts (Transfer)
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    expect(find.text('Note (optional)'), findsOneWidget);
    expect(find.text('From Account'), findsOneWidget);
    expect(find.text('To Account'), findsOneWidget);
    expect(
      find.widgetWithText(FfButton, 'Save Between owned accounts'),
      findsOneWidget,
    );

    // Switch to Investment
    await tester.tap(find.text('Expense').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expense').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invest').last);
    await tester.pumpAndSettle();

    expect(find.text('Asset / Platform (optional)'), findsOneWidget);
    expect(find.widgetWithText(FfButton, 'Save Invest'), findsOneWidget);
  });

  testWidgets(
    '1. Only top 3 quick categories plus All Categories are visible in base screen',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // In expense mode with 4 expense categories (Food, Groceries, Shopping, Transport):
      // Only top 3 (Food, Groceries, Shopping) + 'All Categories' should be rendered on quick bar.
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      // 4th category (Transport) is not shown on the quick bar
      expect(find.text('Transport'), findsNothing);
    },
  );

  testWidgets(
    '2 & 3. All Categories opens searchable multi-column grid picker and selecting updates compact selection',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap All Categories button
      await tester.tap(find.text('All Categories'));
      await tester.pumpAndSettle();

      // Picker title and search field are visible
      expect(find.text('Choose category'), findsOneWidget);
      expect(find.text('Search categories...'), findsOneWidget);

      // All compatible categories are visible in the full grid
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Transport'),
        ),
        findsOneWidget,
      );

      // Test search filtering inside picker
      await tester.enterText(
        find.widgetWithText(TextField, 'Search categories...'),
        'Trans',
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Transport'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Groceries'),
        ),
        findsNothing,
      );

      // Select Transport from grid
      await tester.tap(
        find.descendant(
          of: find.byType(GridView),
          matching: find.text('Transport'),
        ),
      );
      await tester.pumpAndSettle();

      // Picker closed, Transport is now selected and visible on the quick bar
      expect(find.text('Choose category'), findsNothing);
      expect(find.text('Transport'), findsOneWidget);
    },
  );

  testWidgets('4. Recent payees are hidden until payee field is focused', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final history = [
      Transaction(
        id: 'tx_1',
        amount: 250,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        merchant: 'Zomato',
        date: now.subtract(const Duration(days: 1)),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: 'tx_2',
        amount: 400,
        type: TransactionType.expense,
        categoryId: 'cat_groceries',
        categoryName: 'Groceries',
        categoryIcon: 'shopping_cart',
        categoryColor: 'leaf',
        merchant: 'Lulu Hypermarket',
        date: now.subtract(const Duration(days: 2)),
        accountId: 'acc_1',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(createTestWidget(history: history));
    await tester.pumpAndSettle();

    // Payee suggestions are NOT visible while the field is unfocused
    expect(find.text('Recent payees'), findsNothing);
    expect(find.text('Zomato'), findsNothing);
    expect(find.text('Lulu Hypermarket'), findsNothing);

    // Focus payee field
    final payeeField = find.descendant(
      of: find.widgetWithText(FfTextField, 'Payee (optional)'),
      matching: find.byType(TextField),
    );
    await tester.tap(payeeField);
    await tester.pumpAndSettle();

    // Suggestions now appear in the dynamic panel
    expect(find.text('Zomato'), findsOneWidget);
    expect(find.text('Lulu Hypermarket'), findsOneWidget);

    // Scrolling/dragging inside suggestions list isolates events
    await tester.drag(find.text('Zomato'), const Offset(0, -30));
    await tester.pumpAndSettle();
    expect(find.text('Zomato'), findsOneWidget);
    expect(find.text('Lulu Hypermarket'), findsOneWidget);
  });

  testWidgets(
    '5. Selecting and filtering payee suggestion works, arbitrary text remains valid',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final history = [
        Transaction(
          id: 'tx_1',
          amount: 300,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          categoryName: 'Food & Dining',
          categoryIcon: 'restaurant',
          categoryColor: 'clay',
          merchant: 'Swiggy',
          date: now.subtract(const Duration(days: 1)),
          accountId: 'acc_1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(createTestWidget(history: history));
      await tester.pumpAndSettle();

      final payeeField = find.descendant(
        of: find.widgetWithText(FfTextField, 'Payee (optional)'),
        matching: find.byType(TextField),
      );
      await tester.tap(payeeField);
      await tester.pumpAndSettle();

      // Tap suggestion 'Swiggy'
      await tester.tap(find.text('Swiggy'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Swiggy'), findsOneWidget);

      // Enter arbitrary new payee name
      await tester.enterText(payeeField, 'Brand New Boutique');
      await tester.pumpAndSettle();

      expect(find.text('Use "Brand New Boutique"'), findsOneWidget);
      await tester.tap(find.text('Use "Brand New Boutique"'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Brand New Boutique'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '6. Today, Yesterday, and calendar/date are presented in a single responsive row',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);

      // Switch to Yesterday (Stillwater Bloom FfChip)
      await tester.tap(find.text('Yesterday'));
      await tester.pumpAndSettle();

      final yesterdayChip = tester.widget<FfChip>(
        find.widgetWithText(FfChip, 'Yesterday'),
      );
      expect(yesterdayChip.isSelected, isTrue);

      // Switch back to Today
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      final todayChip = tester.widget<FfChip>(
        find.widgetWithText(FfChip, 'Today'),
      );
      expect(todayChip.isSelected, isTrue);
    },
  );

  testWidgets(
    '7. Edit mode loads initial transaction and expands advanced details',
    (WidgetTester tester) async {
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

      // More details auto-expanded because notes/tags/paymentMethod exist
      expect(find.widgetWithText(TextField, 'Meeting coffee'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'work, coffee'), findsOneWidget);
    },
  );

  testWidgets(
    '8. Special transaction flow (Transfer) saves successfully with distinct accounts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      Transaction? savedTransaction;

      await tester.pumpWidget(
        createTestWidget(
          onSave: (tx) async {
            savedTransaction = tx;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Transfer
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      // Enter Amount
      final amountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '0',
      );
      await tester.enterText(amountField, '5000');

      // Enter Transfer reference
      final merchantField = find.descendant(
        of: find.widgetWithText(FfTextField, 'Note (optional)'),
        matching: find.byType(TextField),
      );
      await tester.enterText(merchantField, 'Transfer to Cash');

      // Choose destination account (Cash Wallet)
      await tester.tap(find.text('Select To Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cash Wallet').last);
      await tester.pumpAndSettle();

      // Tap Save
      final saveButton = find.widgetWithText(
        FfButton,
        'Save Between owned accounts',
      );
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(savedTransaction, isNotNull);
      expect(savedTransaction!.amount, 5000.0);
      expect(savedTransaction!.type, TransactionType.transfer);
      expect(savedTransaction!.accountId, 'acc_1');
      expect(savedTransaction!.toAccountId, 'acc_2');
      expect(savedTransaction!.merchant, 'Transfer to Cash');
    },
  );

  testWidgets(
    '9. Full-screen route push and back navigation pops untouched form cleanly',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testFoodCategory]),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount1]),
            ),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => AddEditTransactionScreen.push(context),
                        child: const Text('Open Form'),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open full-screen route
      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditTransactionScreen), findsOneWidget);
      expect(find.text('Add Transaction'), findsOneWidget);

      // Tap Close button without editing anything -> pops immediately
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditTransactionScreen), findsNothing);
      expect(find.text('Open Form'), findsOneWidget);
    },
  );

  testWidgets(
    '10. Modified form prompts with discard confirmation dialog on close',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testFoodCategory]),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount1]),
            ),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: Builder(
              builder:
                  (context) => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => AddEditTransactionScreen.push(context),
                        child: const Text('Open Form'),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Form'));
      await tester.pumpAndSettle();

      // Enter an amount to dirty the form
      final amountField = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == '0',
      );
      await tester.enterText(amountField, '999');
      await tester.pumpAndSettle();

      // Tap Close button -> discard dialog should appear
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Discard Changes?'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel -> stays on form
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditTransactionScreen), findsOneWidget);

      // Tap Close again and confirm Discard -> pops screen
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditTransactionScreen), findsNothing);
      expect(find.text('Open Form'), findsOneWidget);
    },
  );

  testWidgets(
    '11. Edit mode populates fields, shows provenance, update action and destructive delete dialog',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final existingTx = Transaction(
        id: 'tx_edit_1',
        amount: 450.0,
        merchant: 'Blue Tokai Coffee',
        date: DateTime(2026, 11, 4),
        type: TransactionType.expense,
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'amber',
        accountId: 'acc_1',
        notes: 'Cold brew and croissant',
        tags: ['coffee', 'work'],
        createdAt: DateTime(2026, 11, 4, 10, 30),
        updatedAt: DateTime(2026, 11, 4, 10, 30),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testFoodCategory]),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount1]),
            ),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([existingTx]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: AddEditTransactionScreen(initialTransaction: existingTx),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddEditTransactionScreen), findsOneWidget);
      expect(find.text('Edit Transaction'), findsOneWidget);
      expect(find.text('Recorded transaction · Edited'), findsOneWidget);
      expect(find.text('Blue Tokai Coffee'), findsOneWidget);
      expect(find.text('Update Expense'), findsOneWidget);

      // Verify destructive delete button is visible
      final deleteBtn = find.text('Delete transaction');
      expect(deleteBtn, findsOneWidget);

      // Tap delete button -> triggers confirmation dialog
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delete Transaction?'), findsOneWidget);
      expect(
        find.textContaining(
          'Are you sure you want to delete this transaction for "Blue Tokai Coffee"?',
        ),
        findsOneWidget,
      );
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel -> dialog closes, screen remains
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditTransactionScreen), findsOneWidget);
    },
  );
}
