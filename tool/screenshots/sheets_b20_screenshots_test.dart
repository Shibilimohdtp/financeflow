// Screenshot capture for DS-B20 (one sheet skeleton, four archetypes).
//
//   python tool/screenshots/compare.py ds-b20 tool/screenshots/sheets_b20_screenshots_test.dart \
//     b20_loan b20_goal b20_contribution b20_investment b20_account b20_account_edit \
//     b20_notifications b20_filter b20_category b20_csv b20_loan_2x b20_account_keyboard \
//     --base 8a67cb9
//
// Uses only public APIs that exist before and after DS-B20, at 360 dp.
import 'package:financeflow/features/accounts/add_edit_account_sheet.dart';
import 'package:financeflow/features/alerts/alert_settings_sheet.dart';
import 'package:financeflow/features/ingestion/widgets/csv_column_mapper_sheet.dart';
import 'package:financeflow/features/investments/add_edit_investment_sheet.dart';
import 'package:financeflow/features/loans/add_edit_loan_sheet.dart';
import 'package:financeflow/features/savings_goals/add_edit_savings_goal_sheet.dart';
import 'package:financeflow/features/savings_goals/add_goal_contribution_sheet.dart';
import 'package:financeflow/features/savings_goals/savings_goals_controller.dart';
import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/features/transactions/widgets/transaction_filter_sheet.dart';
import 'package:financeflow/features/transactions/widgets/transaction_pickers.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/services/ingestion/parsers/csv_column_mapper.dart';
import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_notification_service.dart';
import '../../test/helpers/fake_repositories.dart';

final _t = DateTime(2026, 11, 1);

final _account = Account(
  id: 'acc_axis',
  name: 'Axis',
  type: AccountType.bank,
  institutionName: 'Axis Bank',
  maskedIdentifier: '5645',
  openingBalance: 3246.32,
  currentBalance: 18637.11,
  currency: 'INR',
  createdAt: _t,
  updatedAt: _t,
);

final _goal = SavingsGoal(
  id: 'g1',
  name: 'Japan trip',
  targetAmount: 150000,
  targetDate: DateTime(2027, 5, 13),
  createdAt: _t,
  updatedAt: _t,
);

List<Category> _categories() => [
  for (final (id, name, icon, color) in const [
    ('food', 'Food', 'restaurant', 'clay'),
    ('dining', 'Dining', 'restaurant', 'clay'),
    ('groceries', 'Groceries', 'shopping_cart', 'moss'),
    ('transport', 'Transport', 'directions_car', 'tide'),
    ('misc', 'Miscellaneous', 'more_horiz', 'sand'),
    ('subs', 'Subscriptions', 'autorenew', 'dusk'),
  ])
    Category(
      id: id,
      name: name,
      iconIdentifier: icon,
      colorTokenIdentifier: color,
      typeCompatibility: const ['expense'],
      createdAt: _t,
      updatedAt: _t,
    ),
];

List<Override> _overrides() => [
  settingsRepositoryProvider.overrideWithValue(
    FakeSettingsRepository(
      const AppSettings(
        isAlertsEnabled: true,
        isLocalNotificationsEnabled: true,
      ),
    ),
  ),
  localNotificationServiceProvider.overrideWithValue(
    FakeLocalNotificationService(),
  ),
  accountRepositoryProvider.overrideWithValue(
    FakeAccountRepository([_account]),
  ),
  transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository()),
  loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
  allAccountsStreamProvider.overrideWith((ref) => Stream.value([_account])),
  goalContributionsForGoalProvider(
    'g1',
  ).overrideWith((ref) => Stream.value([])),
];

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Future<void> Function(BuildContext context) open, {
  double textScale = 1,
  double keyboard = 0,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        builder: (context, child) {
          var media = MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale));
          if (keyboard > 0) {
            media = media.copyWith(
              viewInsets: EdgeInsets.only(bottom: keyboard),
            );
          }
          return MediaQuery(data: media, child: child!);
        },
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => open(context),
                    child: const Text('Open'),
                  ),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  // Overflow stripes are part of the picture; don't fail the capture.
  tester.takeException();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

Future<void> Function(BuildContext) _sheet(Widget sheet) =>
    (context) => showFfSheet<void>(context, builder: (_) => sheet);

void main() {
  setUpAll(loadAppFonts);

  final shots = <String, Future<void> Function(BuildContext)>{
    'b20_loan': _sheet(const AddEditLoanSheet()),
    'b20_goal': _sheet(const AddEditSavingsGoalSheet()),
    'b20_contribution': _sheet(AddGoalContributionSheet(goal: _goal)),
    'b20_investment': _sheet(const AddEditInvestmentSheet()),
    'b20_account': _sheet(const AddEditAccountSheet()),
    'b20_account_edit': _sheet(AddEditAccountSheet(account: _account)),
    'b20_notifications': _sheet(const AlertSettingsSheet()),
    'b20_filter':
        (context) => showTransactionFilterSheet(
          context,
          query: const TransactionQuery(),
          categories: _categories(),
          accounts: [_account],
          tags: const ['work'],
          paymentMethods: const ['UPI'],
        ),
    'b20_category': _sheet(
      CategoryPickerSheet(categories: _categories(), selected: null),
    ),
    'b20_csv': _sheet(
      CsvColumnMapperSheet(
        headers: const [
          'Txn Date',
          'Narration',
          'Withdrawal',
          'Deposit',
          'Ref',
        ],
        initialMapping: const CsvColumnMapping(dateIndex: 0, merchantIndex: 1),
        onApply: (_) {},
      ),
    ),
  };

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    for (final MapEntry(key: name, value: open) in shots.entries) {
      testWidgets('$name, $mode', (tester) async {
        await _capture(tester, '${name}_$mode', theme, open);
      });
    }

    testWidgets('loan at 2x text, $mode', (tester) async {
      await _capture(
        tester,
        'b20_loan_2x_$mode',
        theme,
        _sheet(const AddEditLoanSheet()),
        textScale: 2,
      );
    });

    testWidgets('account with keyboard open, $mode', (tester) async {
      await _capture(
        tester,
        'b20_account_keyboard_$mode',
        theme,
        _sheet(const AddEditAccountSheet()),
        keyboard: 300,
      );
    });
  }
}
