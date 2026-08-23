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
import 'package:financeflow/shared/widgets/ff_chip.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
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

  Widget createWidgetUnderTest({ThemeData? theme}) {
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        filteredTransactionsProvider.overrideWith(
          (ref) => Stream.value([testTransaction]),
        ),
        allTransactionsStreamProvider.overrideWith(
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
        theme: theme ?? StillwaterTheme.daylight,
        home: TransactionsScreen(onOpenDetail: (_) {}, onAddTransaction: () {}),
      ),
    );
  }

  testWidgets(
    'TransactionsScreen renders app bar actions, summary card, and transaction rows without permanent search/chips',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify Title and App Bar action buttons
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

      // Verify search textfield is NOT permanently visible in initial state
      expect(find.byType(TextField), findsNothing);

      // Verify Cash Flow Summary Card
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Net'), findsOneWidget);

      // Verify Transaction Row
      expect(find.text('Swiggy Biryani'), findsOneWidget);
      expect(find.text('− ₹430'), findsWidgets);
    },
  );

  testWidgets(
    'Tapping search icon opens dynamic search bar in app bar and allows typing and closing',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Search TextField should now be visible in the AppBar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search transactions...'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Swiggy');
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      // Dismiss search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Should return to normal title state
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping filter icon opens filter bottom sheet with Type options and controls',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap filter icon
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      // Bottom sheet header and type options
      expect(find.text('Filter & sort'), findsOneWidget);
      expect(find.text('Transaction Type'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'Expenses'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'Income'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'Transfers'), findsOneWidget);

      // Verify Filter Dropdowns and Actions
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Payment method'), findsOneWidget);
      expect(find.text('Tag'), findsOneWidget);
      // Select 'Expenses' type in sheet
      await tester.tap(find.widgetWithText(FfChip, 'Expenses'));
      await tester.pumpAndSettle();

      // Scroll to and apply filter
      await tester.ensureVisible(find.text('Show transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show transactions'));
      await tester.pumpAndSettle();

      // Filter sheet closes, Active filter chip for Expense appears
      expect(find.text('Filter & sort'), findsNothing);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);

      // Clear all active filters
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsNothing);
    },
  );

  testWidgets('TransactionsScreen renders cleanly in Deep Water dark theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(theme: StillwaterTheme.deepWater),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });
}
