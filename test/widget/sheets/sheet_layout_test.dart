// DS-B20: every migrated sheet lays out at 360 dp with 2x text, in light
// and dark, all the way down, and follows the skeleton (no Cancel button).
import 'package:financeflow/features/accounts/add_edit_account_sheet.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/alerts/alert_settings_sheet.dart';
import 'package:financeflow/features/ingestion/widgets/csv_column_mapper_sheet.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/investments/add_edit_investment_sheet.dart';
import 'package:financeflow/features/personal_debts/add_advance_sheet.dart';
import 'package:financeflow/features/personal_debts/add_edit_money_record_sheet.dart';
import 'package:financeflow/features/personal_debts/add_repayment_sheet.dart';
import 'package:financeflow/features/personal_debts/money_records_controller.dart';
import 'package:financeflow/features/budgets/add_edit_budget_sheet.dart';
import 'package:financeflow/features/savings_goals/add_edit_savings_goal_sheet.dart';
import 'package:financeflow/features/savings_goals/add_goal_contribution_sheet.dart';
import 'package:financeflow/features/savings_goals/savings_goals_controller.dart';
import 'package:financeflow/features/subscriptions/add_edit_subscription_sheet.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/money_record.dart';
import 'package:financeflow/models/savings_goal.dart';
import 'package:financeflow/repositories/account_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/services/ingestion/parsers/csv_column_mapper.dart';
import 'package:financeflow/services/notifications/local_notification_service.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_notification_service.dart';
import '../../helpers/fake_repositories.dart';

final _record = MoneyRecord(
  id: 'r1',
  type: MoneyRecordType.lent,
  personName: 'Ahmed',
  normalizedPersonName: 'ahmed',
  originalAmount: 10000,
  transactionDate: DateTime(2026, 10, 1),
  dueDate: DateTime(2026, 12, 1),
  createdAt: DateTime(2026, 10, 1),
  updatedAt: DateTime(2026, 10, 1),
);

List<Override> _lendingOverrides() => [
  allMoneyRecordsStreamProvider.overrideWith((ref) => Stream.value([])),
  rawAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
  accountsWithBalancesProvider.overrideWithValue(const AsyncValue.data([])),
];

final _goal = SavingsGoal(
  id: 'g1',
  name: 'Japan trip',
  targetAmount: 150000,
  targetDate: DateTime(2027, 5, 13),
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

/// The sheets under test, each with the provider overrides it needs to
/// render (no saving happens here).
final Map<String, (Widget, List<Override>)> sheets = {
  'savings goal': (
    const AddEditSavingsGoalSheet(),
    [allAccountsStreamProvider.overrideWith((ref) => Stream.value([]))],
  ),
  'goal contribution': (
    AddGoalContributionSheet(goal: _goal),
    [
      allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
      goalContributionsForGoalProvider(
        'g1',
      ).overrideWith((ref) => Stream.value([])),
    ],
  ),
  'investment': (
    const AddEditInvestmentSheet(),
    [allAccountsStreamProvider.overrideWith((ref) => Stream.value([]))],
  ),
  'account': (
    const AddEditAccountSheet(),
    [
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      accountRepositoryProvider.overrideWithValue(FakeAccountRepository()),
      transactionRepositoryProvider.overrideWithValue(
        FakeTransactionRepository(),
      ),
    ],
  ),
  'notifications': (
    const AlertSettingsSheet(),
    [
      localNotificationServiceProvider.overrideWithValue(
        FakeLocalNotificationService(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        FakeSettingsRepository(
          const AppSettings(
            isAlertsEnabled: true,
            isLocalNotificationsEnabled: true,
          ),
        ),
      ),
    ],
  ),
  'CSV column mapper': (
    CsvColumnMapperSheet(
      headers: const ['Txn Date', 'Narration', 'Withdrawal', 'Deposit', 'Ref'],
      initialMapping: const CsvColumnMapping(dateIndex: 0, merchantIndex: 1),
      onApply: (_) {},
    ),
    const [],
  ),
  'budget': (
    const AddEditBudgetSheet(),
    [
      categoriesStreamProvider.overrideWith((ref) => Stream.value([])),
      allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
    ],
  ),
  'subscription': (
    const AddEditSubscriptionSheet(),
    [
      allAccountsStreamProvider.overrideWith((ref) => Stream.value([])),
      accountRepositoryProvider.overrideWithValue(FakeAccountRepository()),
      allSubscriptionsStreamProvider.overrideWith((ref) => Stream.value([])),
      subscriptionRepositoryProvider.overrideWithValue(
        FakeSubscriptionRepository(),
      ),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
    ],
  ),
  'lending record': (const AddEditMoneyRecordSheet(), _lendingOverrides()),
  'repayment': (
    AddRepaymentSheet(record: _record, remainingBalance: 7000),
    _lendingOverrides(),
  ),
  'advance': (AddAdvanceSheet(record: _record), _lendingOverrides()),
};

Future<void> _open(
  WidgetTester tester,
  Widget sheet,
  List<Override> overrides,
  ThemeData theme,
) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showFfSheet<void>(context, builder: (_) => sheet),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final MapEntry(key: name, value: (sheet, overrides)) in sheets.entries) {
    for (final (mode, theme) in [
      ('light', FfTheme.light()),
      ('dark', FfTheme.dark()),
    ]) {
      testWidgets('$name: 360 dp, 2x text, $mode', (tester) async {
        await _open(tester, sheet, overrides, theme);
        expect(tester.takeException(), isNull);
        expect(find.text('Cancel'), findsNothing);
        final body =
            find
                .descendant(
                  of: find.byType(FfSheet),
                  matching: find.byType(Scrollable),
                )
                .first;
        for (var i = 0; i < 8; i++) {
          await tester.drag(body, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
