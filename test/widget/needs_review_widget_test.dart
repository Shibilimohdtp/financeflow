import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/ingestion/needs_review_screen.dart';
import 'package:financeflow/features/transactions/add_edit_transaction_screen.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/services/financial_operation_service.dart';
import 'package:financeflow/services/ingestion/parsers/sms_parsers.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financeflow/shared/widgets/ff_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/fake_repositories.dart';

class _RecordingOperations implements FinancialOperationService {
  _RecordingOperations(this.repository);
  final TransactionRepository repository;
  @override
  Future<void> postTransaction(
    Transaction proposed, {
    MoneyRecord? moneyRecordDetails,
    int? preferredInstallmentNumber,
  }) => repository.saveTransaction(proposed);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _axisSms =
    'INR 2500.00 debited\nA/c no. XX5645\n27-08-26, 15:19:37\n'
    'UPI/P2A/412345678901/ANITHA\nMENON T\nNot you? SMS BLOCKUPI Cust ID to\n919951860002\nAxis Bank';

Future<ParsedTransaction> _pumpQueue(
  WidgetTester tester,
  FakePendingTransactionRepository pending,
  FakeTransactionRepository committed,
) async {
  final item =
      AxisSmsParser().parse(
        sender: 'AD-AXISBK-S',
        body: _axisSms,
        defaultAccountId: 'acc_1',
      )!;
  await pending.savePendingTransaction(item);
  final now = DateTime.now();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pendingTransactionRepositoryProvider.overrideWithValue(pending),
        transactionRepositoryProvider.overrideWithValue(committed),
        financialOperationServiceProvider.overrideWithValue(
          _RecordingOperations(committed),
        ),
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        allTransactionsStreamProvider.overrideWith((ref) => Stream.value([])),
        rawAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([
            Account(
              id: 'acc_1',
              name: 'Main Bank',
              type: AccountType.bank,
              createdAt: now,
              updatedAt: now,
            ),
            Account(
              id: 'acc_2',
              name: 'Savings',
              type: AccountType.bank,
              createdAt: now,
              updatedAt: now,
            ),
          ]),
        ),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value([
            Category(
              id: item.categoryId,
              name: item.categoryName,
              iconIdentifier: item.categoryIcon,
              colorTokenIdentifier: item.categoryColor,
              typeCompatibility: const ['expense', 'income', 'transfer'],
              createdAt: now,
              updatedAt: now,
            ),
          ]),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: const NeedsReviewScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return item;
}

Finder _payeeField() => find.descendant(
  of: find.widgetWithText(FfTextField, 'Payee (optional)'),
  matching: find.byType(TextField),
);

void main() {
  testWidgets(
    'Rich pending edit stays staged and approval preserves chosen name',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pending = FakePendingTransactionRepository();
      final committed = FakeTransactionRepository();
      addTearDown(pending.dispose);
      addTearDown(committed.dispose);
      final original = await _pumpQueue(tester, pending, committed);
      expect(find.text('Anitha Menon T'), findsOneWidget);
      expect(find.text('919951860002'), findsNothing);
      expect(find.text(_axisSms), findsNothing);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditTransactionScreen), findsOneWidget);
      expect(find.text('Purpose'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('More details'), findsOneWidget);
      await tester.ensureVisible(_payeeField());
      await tester.enterText(_payeeField(), 'MENON — Family');
      await tester.tap(find.text('More details'));
      await tester.pumpAndSettle();
      expect(find.text('Payment method'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditTransactionScreen), findsNothing);
      final updated = (await pending.getPendingTransactions()).single;
      expect(updated.toTransaction().merchant, 'MENON — Family');
      expect(updated.rawMerchant, original.rawMerchant);
      expect(updated.rawSource, _axisSms);
      expect(updated.sourceIdentifier, original.sourceIdentifier);
      expect(updated.importedAt, original.importedAt);
      expect(updated.detectedAt, original.detectedAt);
      expect(updated.fingerprint, isNot(original.fingerprint));
      expect(await committed.getAllTransactions(), isEmpty);
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(
        (await committed.getAllTransactions()).single.merchant,
        'MENON — Family',
      );
      expect(await pending.getPendingTransactions(), isEmpty);
      expect(find.text('All Clear'), findsOneWidget);
    },
  );

  testWidgets('Dismiss and unedited Approve retain queue behavior', (
    tester,
  ) async {
    final pending = FakePendingTransactionRepository();
    final committed = FakeTransactionRepository();
    addTearDown(pending.dispose);
    addTearDown(committed.dispose);
    final original = await _pumpQueue(tester, pending, committed);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(await pending.getPendingTransactions(), isEmpty);
    expect(await committed.getAllTransactions(), isEmpty);
    await pending.savePendingTransaction(original);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(
      (await committed.getAllTransactions()).single.merchant,
      'Anitha Menon T',
    );
  });

  testWidgets(
    'Small review sheet handles keyboard, long names, evidence and save errors',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final pending = FakePendingTransactionRepository();
      final committed = FakeTransactionRepository();
      addTearDown(pending.dispose);
      addTearDown(committed.dispose);
      final original = await _pumpQueue(tester, pending, committed);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text(_axisSms), findsNothing);
      await tester.tap(find.text('Source details'));
      await tester.pumpAndSettle();
      expect(find.text(_axisSms), findsOneWidget);
      await tester.tap(find.text('Source details'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        _payeeField(),
        160,
        scrollable:
            find
                .descendant(
                  of: find.byType(AddEditTransactionScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
      );
      await tester.enterText(
        _payeeField(),
        'A very long personal counterparty name with multiple family names',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomRight(find.text('Save Changes')).dy,
        lessThan(390),
      );
      tester.view.resetViewInsets();
      pending.failSaving = true;
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEditTransactionScreen), findsOneWidget);
      expect(find.textContaining('Could not save transaction'), findsOneWidget);
      expect(
        (await pending.getPendingTransactions()).single.normalizedMerchant,
        original.normalizedMerchant,
      );
      expect(await committed.getAllTransactions(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'NeedsReviewScreen displays pending review transactions and actions',
    (WidgetTester tester) async {
      final now = DateTime.now();

      final testAccount = Account(
        id: 'acc_1',
        name: 'Main Bank',
        type: AccountType.bank,
        createdAt: now,
        updatedAt: now,
      );

      final testCategory = Category(
        id: 'cat_food',
        name: 'Food & Dining',
        iconIdentifier: 'restaurant',
        colorTokenIdentifier: 'clay',
        createdAt: now,
        updatedAt: now,
      );

      final pendingTx = ParsedTransaction(
        tempId: 'temp_1',
        source: TransactionSource.sms,
        sourceName: 'HDFC Bank',
        amount: 430.0,
        type: TransactionType.expense,
        rawMerchant: 'SWIGGY BANGALORE',
        normalizedMerchant: 'Swiggy',
        date: now,
        accountId: 'acc_1',
        categoryId: 'cat_food',
        categoryName: 'Food & Dining',
        categoryIcon: 'restaurant',
        categoryColor: 'clay',
        fingerprint: 'fp_1',
        duplicateStatus: DuplicateMatchLevel.exact,
        duplicateReasons: ['Same amount and canonical merchant on same day'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
            pendingTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value([pendingTx]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const NeedsReviewScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title & Pending Items
      expect(
        find.text('Needs Review Queue', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('All (1)', skipOffstage: false), findsOneWidget);
      expect(find.text('Duplicates (1)', skipOffstage: false), findsOneWidget);
      expect(find.text('Swiggy', skipOffstage: false), findsOneWidget);
      expect(find.text('Dismiss', skipOffstage: false), findsOneWidget);
      expect(find.text('Edit', skipOffstage: false), findsOneWidget);
      expect(find.text('Approve', skipOffstage: false), findsOneWidget);
    },
  );

  testWidgets(
    'Dismissing an item triggers Undo snackbar and tapping Undo restores it',
    (tester) async {
      final pending = FakePendingTransactionRepository();
      final committed = FakeTransactionRepository();
      addTearDown(pending.dispose);
      addTearDown(committed.dispose);

      final original = await _pumpQueue(tester, pending, committed);
      expect(find.text('Anitha Menon T'), findsOneWidget);

      // Tap Dismiss
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Item is removed from pending repository
      expect(await pending.getPendingTransactions(), isEmpty);

      // Snackbar with Undo appears
      expect(find.text('Anitha Menon T dismissed.'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Item is restored back into pending repository
      final restored = await pending.getPendingTransactions();
      expect(restored.length, 1);
      expect(restored.single.tempId, original.tempId);
    },
  );

  testWidgets(
    'Approving an item triggers Undo snackbar and tapping Undo reverts approval',
    (tester) async {
      final pending = FakePendingTransactionRepository();
      final committed = FakeTransactionRepository();
      addTearDown(pending.dispose);
      addTearDown(committed.dispose);

      await _pumpQueue(tester, pending, committed);
      expect(find.text('Anitha Menon T'), findsOneWidget);

      // Tap Approve
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      // Item committed to ledger, removed from pending
      expect(await pending.getPendingTransactions(), isEmpty);
      expect(await committed.getAllTransactions(), isNotEmpty);

      // Snackbar with Undo appears
      expect(find.text('Anitha Menon T approved.'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Transaction reverted: back in pending, removed from committed
      expect(await pending.getPendingTransactions(), isNotEmpty);
      expect(await committed.getAllTransactions(), isEmpty);
    },
  );

  testWidgets(
    'Filter empty states display when switching to tab with 0 items and allow navigating back to All',
    (tester) async {
      final pending = FakePendingTransactionRepository();
      final committed = FakeTransactionRepository();
      addTearDown(pending.dispose);
      addTearDown(committed.dispose);

      await _pumpQueue(tester, pending, committed);

      // Switch to Duplicates (0)
      expect(find.text('Duplicates (0)'), findsOneWidget);
      await tester.tap(find.text('Duplicates (0)'));
      await tester.pumpAndSettle();

      // Duplicates empty state appears
      expect(find.text('No duplicate transactions'), findsOneWidget);
      expect(find.text('View all items'), findsOneWidget);

      // Tap View all items
      await tester.tap(find.text('View all items'));
      await tester.pumpAndSettle();

      // Item is visible again
      expect(find.text('Anitha Menon T'), findsOneWidget);
    },
  );
}
