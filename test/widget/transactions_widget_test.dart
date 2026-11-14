import 'package:financeflow/shared/widgets/ff_sheet.dart';
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

import '../helpers/fake_repositories.dart';

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

  final incomeTransaction = Transaction(
    id: 't2',
    amount: 50000.0,
    type: TransactionType.income,
    categoryId: 'cat_salary',
    categoryName: 'Salary',
    categoryIcon: 'payments',
    categoryColor: 'grove',
    merchant: 'Employer',
    date: now,
    accountId: 'acc_1',
    createdAt: now,
    updatedAt: now,
  );

  final olderTransaction = Transaction(
    id: 't3',
    amount: 120.0,
    type: TransactionType.expense,
    categoryId: 'cat_food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    merchant: 'Chai Point',
    date: DateTime(now.year, now.month, now.day - 1, 9),
    accountId: 'acc_1',
    createdAt: now,
    updatedAt: now,
  );

  /// Uses the real query pipeline over an in-memory repository. All-time by
  /// default so the fixtures never fall outside the current month.
  Widget createWidgetUnderTest({
    ThemeData? theme,
    TransactionQuery query = const TransactionQuery(),
  }) {
    final all = [testTransaction, incomeTransaction, olderTransaction];
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        transactionRepositoryProvider.overrideWithValue(
          FakeTransactionRepository(all),
        ),
        transactionQueryProvider.overrideWith((ref) => query),
        allTransactionsStreamProvider.overrideWith((ref) => Stream.value(all)),
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

  testWidgets('renders period bar, totals, day headers and rows', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('All time'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    // Totals cover exactly the listed rows.
    expect(find.text('Spent'), findsOneWidget);
    // Summary figures are unsigned split amounts; rows keep their signs.
    expect(find.text('₹550'), findsOneWidget);
    expect(find.text('+ ₹50,000'), findsWidgets);
    expect(find.text('3 transactions'), findsOneWidget);

    // Day sections with that day's totals.
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('−₹430  +₹50,000'), findsOneWidget);
    expect(find.text('−₹120'), findsOneWidget);

    expect(find.text('Swiggy Biryani'), findsOneWidget);
    expect(find.text('− ₹430'), findsOneWidget);
  });

  testWidgets('defaults to the current month with prev/next navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(query: TransactionQuery.initial()),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Previous period'), findsOneWidget);
    // Cannot move into the future.
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
    );
    expect(next.onPressed, isNull);

    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();
    expect(find.text('Swiggy Biryani'), findsNothing);
  });

  testWidgets('search filters rows and closing search restores them', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'chai');
    await tester.pumpAndSettle();

    expect(find.text('Chai Point'), findsOneWidget);
    expect(find.text('Swiggy Biryani'), findsNothing);
    expect(find.byTooltip('Clear search text'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(find.text('Swiggy Biryani'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('filter sheet applies a kind, chips show it, Clear all resets', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter and sort'), findsOneWidget);
    // The sheet has its own kind chips (the list's kind pills sit behind it).
    for (final label in ['Spending', 'Income', 'Transfers']) {
      expect(
        find.descendant(
          of: find.byType(FfSheet),
          matching: find.widgetWithText(FfChip, label),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('kind-income')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(find.text('Filter and sort'), findsNothing);
    expect(find.widgetWithText(InputChip, 'Income'), findsOneWidget);
    expect(find.text('Employer'), findsOneWidget);
    expect(find.text('Swiggy Biryani'), findsNothing);
    expect(find.text('1 transaction'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear-all-filters')));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    expect(find.text('Swiggy Biryani'), findsOneWidget);
  });

  testWidgets('amount sort shows a flat list without day headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        query: const TransactionQuery(sort: TransactionSort.amountHigh),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsNothing);
    expect(find.widgetWithText(InputChip, 'Largest first'), findsOneWidget);
  });

  testWidgets('long-press enters selection mode with bulk actions', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Swiggy Biryani'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byTooltip('Change category'), findsOneWidget);
    expect(find.byTooltip('Delete selected'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('Chai Point'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('3 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel selection'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

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

  testWidgets('No review task card is rendered when pending count is 0', (
    WidgetTester tester,
  ) async {
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
  });
}
