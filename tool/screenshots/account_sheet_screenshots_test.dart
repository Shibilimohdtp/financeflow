// Screenshot capture for DS-B11 (Add/Edit Account Sheet).
// Uses showAddEditAccountSheet or opens through AccountsScreen.
//
//   flutter test tool/screenshots/account_sheet_screenshots_test.dart --update-goldens
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/accounts/accounts_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

final _t = DateTime(2026, 11, 1);
final _existingAccount = Account(
  id: 'acc_salary',
  name: 'HDFC Salary',
  type: AccountType.bank,
  institutionName: 'HDFC Bank',
  maskedIdentifier: '4521',
  openingBalance: 45000,
  currentBalance: 52400,
  currency: 'INR',
  createdAt: _t,
  updatedAt: _t,
);

Future<void> _captureAddSheet(
  WidgetTester tester,
  String name,
  ThemeData theme,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);

  final fakeAccountRepo = FakeAccountRepository([_existingAccount]);
  final fakeTxRepo = FakeTransactionRepository();
  final fakeSettingsRepo = FakeSettingsRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        accountsWithBalancesProvider.overrideWithValue(
          AsyncValue.data([_existingAccount]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const AccountsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Tap FAB to open Add Account sheet
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

Future<void> _captureEditSheet(
  WidgetTester tester,
  String name,
  ThemeData theme,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);

  final fakeAccountRepo = FakeAccountRepository([_existingAccount]);
  final fakeTxRepo = FakeTransactionRepository();
  final fakeSettingsRepo = FakeSettingsRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        accountRepositoryProvider.overrideWithValue(fakeAccountRepo),
        transactionRepositoryProvider.overrideWithValue(fakeTxRepo),
        accountsWithBalancesProvider.overrideWithValue(
          AsyncValue.data([_existingAccount]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const AccountsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Tap account row to open Edit Account sheet
  await tester.tap(find.text('HDFC Salary'));
  await tester.pumpAndSettle();

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
    testWidgets('add account empty, $mode', (tester) async {
      await _captureAddSheet(tester, 'b11_add_account_empty_$mode', theme);
    });

    testWidgets('edit account, $mode', (tester) async {
      await _captureEditSheet(tester, 'b11_edit_account_$mode', theme);
    });
  }
}
