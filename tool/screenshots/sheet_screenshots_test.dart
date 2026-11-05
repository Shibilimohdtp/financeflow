// Screenshot capture for DS-4b (bottom sheets), not part of the test suite.
// Uses only APIs that exist before and after DS-4b, so the same file captures
// both commits. Sheets open the way showFfSheet opens them.
//
//   flutter test tool/screenshots/sheet_screenshots_test.dart --update-goldens
import 'package:financeflow/features/loans/add_edit_loan_sheet.dart';
import 'package:financeflow/features/loans/payment_account_picker.dart';
import 'package:financeflow/features/savings_goals/add_edit_savings_goal_sheet.dart';
import 'package:financeflow/features/transactions/widgets/transaction_pickers.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

final _t = DateTime(2026, 11, 1);
final _accounts = [
  Account(
    id: 'a1',
    name: 'HDFC Savings',
    type: AccountType.bank,
    institutionName: 'HDFC Bank',
    maskedIdentifier: '4521',
    currentBalance: 84250,
    createdAt: _t,
    updatedAt: _t,
  ),
  Account(
    id: 'a2',
    name: 'Cash wallet',
    type: AccountType.cash,
    currentBalance: 3200,
    createdAt: _t,
    updatedAt: _t,
  ),
  Account(
    id: 'a3',
    name: 'ICICI Credit Card',
    type: AccountType.creditCard,
    maskedIdentifier: '9910',
    currentBalance: -12480,
    createdAt: _t,
    updatedAt: _t,
  ),
];
final _categories = [
  for (final (id, name, icon, color) in [
    ('c1', 'Groceries', 'shopping_cart', 'grove'),
    ('c2', 'Dining', 'restaurant', 'clay'),
    ('c3', 'Fuel', 'local_gas_station', 'marigold'),
    ('c4', 'Rent', 'home', 'indigo'),
    ('c5', 'Utilities', 'bolt', 'teal'),
    ('c6', 'Shopping', 'shopping_bag', 'plum'),
    ('c7', 'Health', 'medical_services', 'slate'),
    ('c8', 'Travel', 'flight', 'shore'),
  ])
    Category(
      id: id,
      name: name,
      iconIdentifier: icon,
      colorTokenIdentifier: color,
      createdAt: _t,
      updatedAt: _t,
    ),
];

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Future<void> Function(BuildContext context) open,
) async {
  tester.view.physicalSize = const Size(390, 760);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        allAccountsStreamProvider.overrideWith(
          (ref) => Stream.value(_accounts),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          appBar: AppBar(title: const Text('Loans')),
          body: Builder(
            builder:
                (context) => Center(
                  child: TextButton(
                    onPressed: () => open(context),
                    child: const Text('open'),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('loan form, $mode', (tester) async {
      await _capture(tester, 'sheet_loan_$mode', theme, (context) async {
        await _sheet(context, (_) => const AddEditLoanSheet());
      });
    });

    testWidgets('savings goal form, $mode', (tester) async {
      await _capture(tester, 'sheet_goal_$mode', theme, (context) async {
        await _sheet(context, (_) => const AddEditSavingsGoalSheet());
      });
    });

    testWidgets('category picker, $mode', (tester) async {
      await _capture(tester, 'sheet_category_$mode', theme, (context) async {
        await _sheet(
          context,
          (_) => CategoryPickerSheet(
            categories: _categories,
            selected: _categories.first,
          ),
        );
      });
    });

    testWidgets('account picker, $mode', (tester) async {
      await _capture(tester, 'sheet_account_$mode', theme, (context) async {
        await _sheet(
          context,
          (_) => AccountPickerSheet(
            title: 'Paid from',
            accounts: _accounts,
            selected: _accounts.first,
          ),
        );
      });
    });

    testWidgets('payment account picker, $mode', (tester) async {
      await _capture(tester, 'sheet_payment_$mode', theme, (context) async {
        await showPaymentAccountPicker(
          context: context,
          accounts: _accounts,
          selectedAccountId: 'a1',
        );
      });
    });
  }
}
