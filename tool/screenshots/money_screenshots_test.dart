// Screenshot capture of the Money tab (DS-B5), not part of the test suite.
// Uses only APIs that exist before and after DS-B5, so compare.py can
// capture both commits.
//
//   flutter test tool/screenshots/money_screenshots_test.dart --update-goldens
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

const _size = Size(390, 1000);

void main() {
  setUpAll(loadAppFonts);

  final today = DateTime.now();
  DateTime at(int daysAgo, int hour) =>
      DateTime(today.year, today.month, today.day - daysAgo, hour);
  final account = Account(
    id: 'a1',
    name: 'Salary account',
    type: AccountType.bank,
    createdAt: today,
    updatedAt: today,
  );
  Category cat(String id, String name, String icon, String color) => Category(
    id: id,
    name: name,
    iconIdentifier: icon,
    colorTokenIdentifier: color,
    createdAt: today,
    updatedAt: today,
  );
  final cats = [
    cat('groceries', 'Groceries', 'shopping_cart', 'clay'),
    cat('food', 'Eating out', 'restaurant', 'clay'),
    cat('salary', 'Salary', 'payments', 'grove'),
    cat('bills', 'Utilities', 'bolt', 'tide'),
    cat('fuel', 'Transport', 'local_gas_station', 'dusk'),
    cat('subs', 'Subscriptions', 'subscriptions', 'rose'),
  ];
  var n = 0;
  Transaction tx(
    String merchant,
    double amount,
    TransactionType type,
    Category c,
    DateTime date, {
    String? method,
  }) => Transaction(
    id: 't${n++}',
    amount: amount,
    type: type,
    categoryId: c.id,
    categoryName: c.name,
    categoryIcon: c.iconIdentifier,
    categoryColor: c.colorTokenIdentifier,
    merchant: merchant,
    date: date,
    accountId: 'a1',
    paymentMethod: method,
    createdAt: date,
    updatedAt: date,
  );
  final all = [
    tx('Weekly market', 2340, TransactionType.expense, cats[0], at(0, 18)),
    tx(
      'Corner café',
      454,
      TransactionType.expense,
      cats[1],
      at(0, 9),
      method: 'UPI',
    ),
    tx('Salary', 82000, TransactionType.income, cats[2], at(1, 10)),
    tx('Electricity board', 1118.5, TransactionType.expense, cats[3], at(1, 8)),
    tx(
      'Fuel station',
      2992.5,
      TransactionType.expense,
      cats[4],
      at(1, 7),
      method: 'Card',
    ),
    tx('Streaming', 649, TransactionType.expense, cats[5], at(2, 21)),
    tx(
      'Bakery',
      210,
      TransactionType.expense,
      cats[1],
      at(2, 8),
      method: 'Cash',
    ),
  ];

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('money, $mode', (tester) async {
      tester.view.physicalSize = _size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            transactionRepositoryProvider.overrideWithValue(
              FakeTransactionRepository(all),
            ),
            transactionQueryProvider.overrideWith(
              (ref) => const TransactionQuery(),
            ),
            allTransactionsStreamProvider.overrideWith(
              (ref) => Stream.value(all),
            ),
            categoriesStreamProvider.overrideWith((ref) => Stream.value(cats)),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([account]),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: TransactionsScreen(
              onOpenDetail: (_) {},
              onAddTransaction: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/money_$mode.png'),
      );
    });
  }
}
