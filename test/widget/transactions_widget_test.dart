import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transactions_controller.dart';
import 'package:financeflow/features/transactions/transactions_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
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
      expect(find.text('Net'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'Income'), findsOneWidget);
      expect(find.widgetWithText(FfChip, 'Expenses'), findsOneWidget);

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

      // Clear button in search bar should appear
      expect(find.byTooltip('Clear search text'), findsOneWidget);

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
      final sheetFinder = find.byType(BottomSheet);
      expect(
        find.descendant(of: sheetFinder, matching: find.widgetWithText(FfChip, 'All')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetFinder, matching: find.widgetWithText(FfChip, 'Expenses')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetFinder, matching: find.widgetWithText(FfChip, 'Income')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetFinder, matching: find.widgetWithText(FfChip, 'Transfers')),
        findsOneWidget,
      );

      // Verify Filter Dropdowns and Actions
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Payment method'), findsOneWidget);
      expect(find.text('Tag'), findsOneWidget);
      // Select 'Expenses' type in sheet
      await tester.tap(
        find.descendant(of: sheetFinder, matching: find.widgetWithText(FfChip, 'Expenses')),
      );
      await tester.pumpAndSettle();

      // Scroll to and apply filter
      await tester.ensureVisible(find.text('Show transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show transactions'));
      await tester.pumpAndSettle();

      // Filter sheet closes
      expect(find.text('Filter & sort'), findsNothing);
      expect(find.widgetWithText(FfChip, 'Expenses'), findsWidgets);
      expect(find.text('Clear'), findsWidgets);

      // Clear all active filters
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsNothing);
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

  testWidgets(
    'TransactionsScreen displays PendingReviewTaskCard when pending reviews exist, and Review now navigates',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
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
            pendingReviewCountProvider.overrideWithValue(2),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
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

      // Verify task card content
      expect(find.text('2 imported transactions need review'), findsOneWidget);
      expect(find.text('NEEDS REVIEW · 2 ITEMS'), findsOneWidget);
      expect(
        find.text(
          'Verify merchant and category so your ledger balances and spending trends stay accurate.',
        ),
        findsOneWidget,
      );
      expect(find.text('Review now'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);

      // Tap Review now
      await tester.tap(find.text('Review now'));
      await tester.pumpAndSettle();

      // Should navigate to NeedsReviewScreen
      expect(find.text('Needs Review Queue'), findsOneWidget);
    },
  );

  testWidgets(
    'Tapping Later on PendingReviewTaskCard snoozes inline card and displays App Bar badge',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
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
            pendingReviewCountProvider.overrideWithValue(1),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
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

      // Inline card is visible initially
      expect(find.text('1 imported transaction needs review'), findsOneWidget);
      expect(find.byIcon(Icons.pending_actions_rounded), findsWidgets);

      // Tap Later to snooze
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      // Inline card is hidden
      expect(find.text('1 imported transaction needs review'), findsNothing);

      // App bar has the snoozed review queue badge
      final badgeFinder = find.byTooltip('Review queue (1 pending)');
      expect(badgeFinder, findsOneWidget);

      // Tapping badge navigates to NeedsReviewScreen
      await tester.tap(badgeFinder);
      await tester.pumpAndSettle();
      expect(find.text('Needs Review Queue'), findsOneWidget);
    },
  );

  testWidgets(
    'No review task card is rendered when pending count is 0',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
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
            pendingReviewCountProvider.overrideWithValue(0),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([]),
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

      expect(find.textContaining('imported transaction'), findsNothing);
      expect(find.text('Review now'), findsNothing);
    },
  );
}


