// Screenshot capture for DS-B10 (Add/Edit Transaction Flow in Stillwater Bloom).
//
//   flutter test tool/screenshots/transaction_screenshots_test.dart --update-goldens
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/personal_debts/money_records_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/add_edit_transaction_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/money_advance.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/money_repayment.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

final _now = DateTime(2026, 11, 6);

final _salaryAccount = Account(
  id: 'acc_salary',
  name: 'Salary Account',
  type: AccountType.bank,
  institutionName: 'HDFC Bank',
  currentBalance: 52400.0,
  createdAt: _now,
  updatedAt: _now,
);

final _cashAccount = Account(
  id: 'acc_cash',
  name: 'Physical Wallet',
  type: AccountType.cash,
  currentBalance: 3200.0,
  createdAt: _now,
  updatedAt: _now,
);

final _foodCategory = Category(
  id: 'cat_food',
  name: 'Food & Dining',
  iconIdentifier: 'restaurant',
  colorTokenIdentifier: 'amber',
  createdAt: _now,
  updatedAt: _now,
);

final _groceriesCategory = Category(
  id: 'cat_groceries',
  name: 'Groceries',
  iconIdentifier: 'shopping_cart',
  colorTokenIdentifier: 'emerald',
  createdAt: _now,
  updatedAt: _now,
);

final _commuteCategory = Category(
  id: 'cat_commute',
  name: 'Transport',
  iconIdentifier: 'commute',
  colorTokenIdentifier: 'blue',
  createdAt: _now,
  updatedAt: _now,
);

final _salaryCategory = Category(
  id: 'cat_salary',
  name: 'Salary',
  iconIdentifier: 'payments',
  colorTokenIdentifier: 'emerald',
  typeCompatibility: ['income'],
  createdAt: _now,
  updatedAt: _now,
);

final _existingTx = Transaction(
  id: 'tx_edit_sample',
  amount: 850.0,
  merchant: 'Blue Tokai Coffee',
  date: DateTime(2026, 11, 4),
  type: TransactionType.expense,
  categoryId: 'cat_food',
  categoryName: 'Food & Dining',
  categoryIcon: 'restaurant',
  categoryColor: 'amber',
  accountId: 'acc_salary',
  notes: 'Cold brew and croissant',
  tags: ['coffee', 'work'],
  createdAt: DateTime(2026, 11, 4, 10, 30),
  updatedAt: DateTime(2026, 11, 4, 10, 30),
);

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme, {
  Transaction? initialTransaction,
  Future<void> Function(WidgetTester tester)? setup,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value([
            _foodCategory,
            _groceriesCategory,
            _commuteCategory,
            _salaryCategory,
          ]),
        ),
        rawAccountsStreamProvider.overrideWith(
          (ref) => Stream.value([_salaryAccount, _cashAccount]),
        ),
        allTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value([_existingTx]),
        ),
        allLoansStreamProvider.overrideWith(
          (ref) => Stream.value(const <Loan>[]),
        ),
        allSubscriptionsStreamProvider.overrideWith(
          (ref) => Stream.value(const <Subscription>[]),
        ),
        allMoneyRecordsStreamProvider.overrideWith(
          (ref) => Stream.value(const <MoneyRecord>[]),
        ),
        allMoneyRepaymentsStreamProvider.overrideWith(
          (ref) => Stream.value(const <MoneyRepayment>[]),
        ),
        allMoneyAdvancesStreamProvider.overrideWith(
          (ref) => Stream.value(const <MoneyAdvance>[]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: AddEditTransactionScreen(initialTransaction: initialTransaction),
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (setup != null) {
    await setup(tester);
    await tester.pumpAndSettle();
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('b10_add_expense_empty_$mode', (tester) async {
      await _capture(tester, 'b10_add_expense_empty_$mode', theme);
    });

    testWidgets('b10_add_expense_filled_$mode', (tester) async {
      await _capture(
        tester,
        'b10_add_expense_filled_$mode',
        theme,
        setup: (tester) async {
          final amountField = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.hintText == '0',
          );
          await tester.enterText(amountField, '1450');
          await tester.pumpAndSettle();

          final payeeField = find.byWidgetPredicate(
            (w) =>
                w is TextField && w.decoration?.labelText == 'Payee (optional)',
          );
          await tester.enterText(payeeField, 'Subway');
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('b10_add_income_$mode', (tester) async {
      await _capture(
        tester,
        'b10_add_income_$mode',
        theme,
        setup: (tester) async {
          await tester.tap(find.text('Income'));
          await tester.pumpAndSettle();

          final amountField = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.hintText == '0',
          );
          await tester.enterText(amountField, '65000');
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('b10_add_transfer_$mode', (tester) async {
      await _capture(
        tester,
        'b10_add_transfer_$mode',
        theme,
        setup: (tester) async {
          await tester.tap(find.text('Transfer'));
          await tester.pumpAndSettle();

          final amountField = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.hintText == '0',
          );
          await tester.enterText(amountField, '5000');
          await tester.pumpAndSettle();
        },
      );
    });

    testWidgets('b10_edit_transaction_$mode', (tester) async {
      await _capture(
        tester,
        'b10_edit_transaction_$mode',
        theme,
        initialTransaction: _existingTx,
      );
    });
  }
}
