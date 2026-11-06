// Screenshot capture for DS-B11 (Add/Edit Account Sheet in Stillwater Bloom).
//
//   flutter test tool/screenshots/account_sheet_screenshots_test.dart --update-goldens
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/accounts/add_edit_account_sheet.dart';
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

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme, {
  Account? account,
  Future<void> Function(WidgetTester tester)? setup,
  bool isPrivacyBlur = false,
  TextScaler? textScaler,
  EdgeInsets? viewInsets,
}) async {
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
          (ref) => Stream.value(
            AppSettings(isPrivacyBlurEnabled: isPrivacyBlur),
          ),
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
        builder: (context, child) {
          var media = MediaQuery.of(context);
          if (textScaler != null) {
            media = media.copyWith(textScaler: textScaler);
          }
          if (viewInsets != null) {
            media = media.copyWith(viewInsets: viewInsets);
          }
          return MediaQuery(data: media, child: child!);
        },
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showAddEditAccountSheet(context, account: account);
                    },
                    child: const Text('Open'),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Tap button to open sheet
  await tester.tap(find.text('Open'));
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
    testWidgets('empty new account, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_empty_$mode', theme);
    });

    testWidgets('filled bank account, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_bank_$mode', theme, setup: (tester) async {
        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'Salary Account');

        final balanceFinder = find.widgetWithText(
          TextFormField,
          'Opening Balance',
        );
        await tester.enterText(balanceFinder, '45000');

        final disclosureFinder = find.text(
          'Bank and identifier details (optional)',
        );
        await tester.ensureVisible(disclosureFinder);
        await tester.tap(disclosureFinder);
        await tester.pumpAndSettle();

        final instFinder = find.widgetWithText(
          TextFormField,
          'Institution Name (Optional)',
        );
        await tester.enterText(instFinder, 'HDFC Bank');

        final maskedFinder = find.widgetWithText(
          TextFormField,
          'Masked Number / UPI ID (Optional)',
        );
        await tester.enterText(maskedFinder, '4521');
      });
    });

    testWidgets('credit card, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_card_$mode', theme, setup: (tester) async {
        await tester.tap(find.text('Card'));
        await tester.pumpAndSettle();

        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'ICICI Amazon Card');

        final balanceFinder = find.widgetWithText(
          TextFormField,
          'Current balance owed',
        );
        await tester.enterText(balanceFinder, '18500');
      });
    });

    testWidgets('upi account, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_upi_$mode', theme, setup: (tester) async {
        await tester.tap(find.text('UPI'));
        await tester.pumpAndSettle();

        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'PhonePe UPI');

        final balanceFinder = find.widgetWithText(
          TextFormField,
          'Opening Balance',
        );
        await tester.enterText(balanceFinder, '2500');
      });
    });

    testWidgets('cash account, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_cash_$mode', theme, setup: (tester) async {
        await tester.tap(find.text('Cash'));
        await tester.pumpAndSettle();

        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'Pocket Wallet');

        final balanceFinder = find.widgetWithText(
          TextFormField,
          'Opening Balance',
        );
        await tester.enterText(balanceFinder, '1200');
      });
    });

    testWidgets('validation errors, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_error_$mode', theme, setup: (tester) async {
        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'Test');

        final balanceFinder = find.widgetWithText(
          TextFormField,
          'Opening Balance',
        );
        await tester.enterText(balanceFinder, '');

        await tester.tap(find.text('Add Account'));
      });
    });

    testWidgets('duplicate warning, $mode', (tester) async {
      await _capture(tester, 'b11_sheet_duplicate_$mode', theme, setup: (
        tester,
      ) async {
        final nameFinder = find.widgetWithText(TextFormField, 'Account Name');
        await tester.enterText(nameFinder, 'HDFC Salary');
      });
    });

    testWidgets('edit mode, $mode', (tester) async {
      await _capture(
        tester,
        'b11_sheet_edit_$mode',
        theme,
        account: _existingAccount,
      );
    });

    testWidgets('keyboard open, $mode', (tester) async {
      await _capture(
        tester,
        'b11_sheet_keyboard_$mode',
        theme,
        viewInsets: const EdgeInsets.only(bottom: 280),
      );
    });

    testWidgets('2x text scale, $mode', (tester) async {
      await _capture(
        tester,
        'b11_sheet_2x_$mode',
        theme,
        textScaler: const TextScaler.linear(2.0),
      );
    });

    testWidgets('hidden amounts, $mode', (tester) async {
      await _capture(
        tester,
        'b11_sheet_hidden_$mode',
        theme,
        account: _existingAccount,
        isPrivacyBlur: true,
      );
    });
  }
}
