// Screenshot capture of the Plan tab (Budgets), a budget's detail, the
// add-budget sheet and the empty state (DS-B7), not part of the test suite.
// Uses only APIs that exist before and after DS-B7, so compare.py can
// capture both commits.
//
//   flutter test tool/screenshots/plan_screenshots_test.dart --update-goldens
//
// Sample data: budgets in three groups (Essentials, Lifestyle, Other) derived
// from the categories, one over (Dining), one at risk (Groceries), a tracked
// subscription and loan for the Bills & EMIs line, and three earlier months
// of history so a closed month and the insights have data.
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/add_edit_budget_sheet.dart';
import 'package:financeflow/features/budgets/budget_detail_screen.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/budgets/budgets_screen.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

final _now = DateTime.now();
final _month = DateTime(_now.year, _now.month);
final _created = DateTime(_now.year, _now.month - 6, 1);

/// Day [d] of this month, never after today (so nothing is future-dated).
DateTime _day(int d, {int monthsAgo = 0}) {
  final m = DateTime(_month.year, _month.month - monthsAgo);
  final last = DateTime(m.year, m.month + 1, 0).day;
  final day = monthsAgo == 0 ? d.clamp(1, _now.day) : d.clamp(1, last);
  return DateTime(m.year, m.month, day, 12);
}

typedef _Cat = (String id, String name, String icon, String color);

const _groceries = ('cat_groceries', 'Groceries', 'shopping_cart', 'grove');
const _fuel = ('cat_fuel', 'Fuel', 'local_gas_station', 'marigold');
const _dining = ('cat_dining', 'Dining', 'restaurant', 'clay');
const _shopping = ('cat_shopping', 'Shopping', 'shopping_bag', 'plum');
const _gifts = ('cat_gifts', 'Gifts', 'card_giftcard', 'shore');
const _emi = ('cat_emi', 'EMI', 'account_balance', 'indigo');
const _subs = ('cat_subscriptions', 'Subscriptions', 'subscriptions', 'teal');

final _categories = [
  for (final c in [_groceries, _fuel, _dining, _shopping, _gifts, _emi, _subs])
    Category(
      id: c.$1,
      name: c.$2,
      iconIdentifier: c.$3,
      colorTokenIdentifier: c.$4,
      typeCompatibility: const ['expense'],
      createdAt: _created,
      updatedAt: _created,
    ),
];

Budget _budget(String id, _Cat c, double limit) => Budget(
  id: id,
  name: c.$2,
  categoryId: c.$1,
  categoryName: c.$2,
  categoryIcon: c.$3,
  categoryColor: c.$4,
  amountLimit: limit,
  startDate: _created,
  createdAt: _created,
  updatedAt: _created,
);

final _budgets = [
  _budget('b_groceries', _groceries, 12000),
  _budget('b_fuel', _fuel, 4000),
  _budget('b_dining', _dining, 6000),
  _budget('b_shopping', _shopping, 8000),
  _budget('b_gifts', _gifts, 3000),
];

var _seq = 0;
Transaction _tx(
  _Cat c,
  String merchant,
  double amount,
  DateTime date, {
  String? linkedLoanId,
  String? linkedSubscriptionId,
}) => Transaction(
  id: 'tx_${_seq++}',
  amount: amount,
  type: TransactionType.expense,
  categoryId: c.$1,
  categoryName: c.$2,
  categoryIcon: c.$3,
  categoryColor: c.$4,
  merchant: merchant,
  date: date,
  accountId: 'a1',
  linkedLoanId: linkedLoanId,
  linkedSubscriptionId: linkedSubscriptionId,
  createdAt: date,
  updatedAt: date,
);

final _transactions = [
  // This month: Dining over, Groceries running hot, the rest calm.
  _tx(_dining, 'Corner café', 1450, _day(1)),
  _tx(_dining, 'Spice route', 2380, _day(2)),
  _tx(_dining, 'Weekend brunch', 1920, _day(4)),
  _tx(_dining, 'Corner café', 1050, _day(5)),
  _tx(_groceries, 'Weekly market', 3240, _day(1)),
  _tx(_groceries, 'Fresh basket', 2860, _day(3)),
  _tx(_groceries, 'Weekly market', 2310, _day(6)),
  _tx(_fuel, 'Fuel station', 1200, _day(2)),
  _tx(_shopping, 'Bookstore', 860, _day(3)),
  // Bills & EMIs: one paid, linked to the loan (not a category budget).
  _tx(_emi, 'Home loan EMI', 29600, _day(5), linkedLoanId: 'l1'),
  // Three earlier months.
  for (var m = 1; m <= 3; m++) ...[
    _tx(_dining, 'Corner café', 2100, _day(6, monthsAgo: m)),
    _tx(_dining, 'Spice route', 2600, _day(14, monthsAgo: m)),
    _tx(_dining, 'Weekend brunch', 1900 + 300.0 * m, _day(23, monthsAgo: m)),
    _tx(_groceries, 'Weekly market', 3100, _day(3, monthsAgo: m)),
    _tx(_groceries, 'Fresh basket', 2900, _day(12, monthsAgo: m)),
    _tx(_groceries, 'Weekly market', 3300, _day(21, monthsAgo: m)),
    _tx(_fuel, 'Fuel station', 1500, _day(9, monthsAgo: m)),
    _tx(_fuel, 'Fuel station', 1400, _day(24, monthsAgo: m)),
    _tx(_shopping, 'Bookstore', 1200, _day(11, monthsAgo: m)),
    _tx(_shopping, 'Clothing', 2400, _day(19, monthsAgo: m)),
    _tx(_gifts, 'Gift shop', 900, _day(16, monthsAgo: m)),
  ],
];

final _loan = Loan(
  id: 'l1',
  name: 'Home loan',
  lender: 'Bank',
  loanType: LoanType.homeLoan,
  principalAmount: 2400000,
  interestRate: 8.4,
  interestType: InterestType.reducingBalance,
  tenureMonths: 120,
  startDate: DateTime(_now.year - 2, _now.month, 5),
  expectedEndDate: DateTime(_now.year + 8, _now.month, 5),
  emiAmount: 29600,
  paymentDay: 5,
  totalPrincipalPaid: 380000,
  totalInterestPaid: 0,
  outstandingPrincipal: 2020000,
  nextDueDate: DateTime(_now.year, _now.month + 1, 5),
  status: LoanStatus.active,
  createdAt: _created,
  updatedAt: _created,
);

final _streaming = Subscription(
  id: 's1',
  merchant: 'Streaming',
  normalizedMerchant: 'streaming',
  amount: 649,
  nextRenewalDate: DateTime(_now.year, _now.month, 24),
  createdAt: _created,
  updatedAt: _created,
);

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home, {
  List<Budget>? budgets,
  DateTime? month,
  double height = 1500,
  Future<void> Function(WidgetTester tester)? act,
}) async {
  tester.view.physicalSize = Size(390, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final shown = budgets ?? _budgets;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(shown)),
        allTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value(_transactions),
        ),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value(_categories),
        ),
        loanRepositoryProvider.overrideWithValue(FakeLoanRepository([_loan])),
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository([_streaming]),
        ),
        if (month != null)
          selectedDashboardMonthProvider.overrideWith((ref) => month),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (act != null) {
    await act(tester);
    await tester.pumpAndSettle();
  }
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Opens the add-budget sheet the way the screen's add button does.
Widget _sheetHost() => Scaffold(
  body: Builder(
    builder:
        (context) => Center(
          child: TextButton(
            onPressed:
                () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddEditBudgetSheet(),
                ),
            child: const Text('open'),
          ),
        ),
  ),
);

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', StillwaterTheme.daylight),
    ('dark', StillwaterTheme.deepWater),
  ]) {
    testWidgets('plan, $mode', (tester) async {
      await _capture(tester, 'b7_plan_$mode', theme, const BudgetsScreen());
    });
    testWidgets('plan closed month, $mode', (tester) async {
      await _capture(
        tester,
        'b7_plan_closed_$mode',
        theme,
        const BudgetsScreen(),
        month: DateTime(_month.year, _month.month - 1),
      );
    });
    testWidgets('plan empty, $mode', (tester) async {
      await _capture(
        tester,
        'b7_plan_empty_$mode',
        theme,
        const BudgetsScreen(),
        budgets: const [],
        height: 900,
      );
    });
    testWidgets('budget detail, $mode', (tester) async {
      await _capture(
        tester,
        'b7_detail_$mode',
        theme,
        BudgetDetailScreen(budget: _budgets[2]),
        height: 1700,
      );
    });
    testWidgets('add budget sheet, $mode', (tester) async {
      await _capture(
        tester,
        'b7_sheet_$mode',
        theme,
        _sheetHost(),
        height: 900,
        act: (tester) => tester.tap(find.text('open')),
      );
    });
  }
}
