// The add/edit budget sheet (DS-B7, recipe E), on a fixed "today":
// 15 November 2026 (a 30-day month).
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/budget_sheets.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/budgets/plan_providers.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/shared/widgets/ff_sheet.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

final _now = DateTime(2026, 11, 15, 14, 30);
final _t = DateTime(2026, 5, 1);

final _dining = Category(
  id: 'cat_dining',
  name: 'Dining',
  iconIdentifier: 'restaurant',
  colorTokenIdentifier: 'clay',
  typeCompatibility: const ['expense'],
  createdAt: _t,
  updatedAt: _t,
);
final _fuel = Category(
  id: 'cat_fuel',
  name: 'Fuel',
  iconIdentifier: 'local_gas_station',
  colorTokenIdentifier: 'marigold',
  typeCompatibility: const ['expense'],
  createdAt: _t,
  updatedAt: _t,
);
final _salary = Category(
  id: 'cat_salary',
  name: 'Salary',
  iconIdentifier: 'payments',
  colorTokenIdentifier: 'grove',
  typeCompatibility: const ['income'],
  createdAt: _t,
  updatedAt: _t,
);

/// Dining: ₹6,800, ₹7,000 and ₹7,300 in the last three months.
final _history = [
  for (final (m, amount) in [(8, 6800.0), (9, 7000.0), (10, 7300.0)])
    Transaction(
      id: 'h$m',
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      merchant: 'Café',
      date: DateTime(2026, m, 12),
      accountId: 'a1',
      createdAt: _t,
      updatedAt: _t,
    ),
];

Future<FakeBudgetRepository> _open(
  WidgetTester tester, {
  Budget? initial,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeBudgetRepository(initial == null ? [] : [initial]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        planNowProvider.overrideWithValue(_now),
        budgetRepositoryProvider.overrideWithValue(repo),
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value([_dining, _fuel, _salary]),
        ),
        allTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value(_history),
        ),
      ],
      child: MaterialApp(
        theme: StillwaterTheme.daylight,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 900),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Builder(
              builder:
                  (context) => Center(
                    child: TextButton(
                      onPressed:
                          () => openBudgetSheet(context, initial: initial),
                      child: const Text('open'),
                    ),
                  ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repo;
}

Finder get _limit => find.descendant(
  of: find.byKey(const ValueKey('budget-limit')),
  matching: find.byType(EditableText),
);

void main() {
  testWidgets('opens in the shared sheet frame, limit first', (tester) async {
    await _open(tester);
    expect(find.byType(FfSheet), findsOneWidget);
    expect(find.text('New budget'), findsOneWidget);
    expect(find.text('Limit'), findsOneWidget);
    expect(find.text('How much for a month?'), findsOneWidget);
    for (final label in ['Category', 'Repeats', 'Alert me at']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Create budget'), findsOneWidget);
    // Only spending categories are offered.
    expect(find.text('Salary'), findsNothing);
    final top = tester.getTopLeft(find.text('Limit')).dy;
    expect(top, lessThan(tester.getTopLeft(find.text('Category')).dy));
  });

  testWidgets('a live preview says what the limit means per day', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(_limit, '6500');
    await tester.pump();
    expect(find.text('₹6,500 a month · about ₹217 a day'), findsOneWidget);
    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(find.text('₹6,500 a week · about ₹929 a day'), findsOneWidget);
    await tester.tap(find.text('Yearly'));
    await tester.pump();
    expect(find.text('₹6,500 a year · about ₹542 a month'), findsOneWidget);
  });

  testWidgets('choosing a category offers what it usually costs', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byKey(const ValueKey('budget-use-usual')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('budget-category-cat_dining')));
    await tester.pumpAndSettle();
    expect(find.text('Usually ₹7,000 · use ₹7,000'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('budget-use-usual')));
    await tester.pump();
    expect(tester.widget<EditableText>(_limit).controller.text, '7000');
  });

  testWidgets('missing fields are explained in words; nothing is saved', (
    tester,
  ) async {
    final repo = await _open(tester);
    await tester.tap(find.text('Create budget'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a limit above zero.'), findsOneWidget);
    expect(find.text('Choose a category.'), findsOneWidget);
    expect(await repo.getAllBudgets(), isEmpty);
  });

  testWidgets('creates a budget named after its category, from this month', (
    tester,
  ) async {
    final repo = await _open(tester);
    await tester.enterText(_limit, '6500');
    await tester.tap(find.byKey(const ValueKey('budget-category-cat_dining')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('90%'));
    await tester.tap(find.text('Create budget'));
    await tester.pumpAndSettle();
    final saved = (await repo.getAllBudgets()).single;
    expect(saved.name, 'Dining');
    expect(saved.categoryId, 'cat_dining');
    expect(saved.amountLimit, 6500);
    expect(saved.period, BudgetPeriod.monthly);
    expect(saved.startDate, DateTime(2026, 11, 1));
    expect(saved.alertThreshold, 0.9);
    expect(find.byType(FfSheet), findsNothing);
  });

  testWidgets('a one-off budget needs its dates', (tester) async {
    final repo = await _open(tester);
    await tester.enterText(_limit, '20000');
    await tester.tap(find.byKey(const ValueKey('budget-category-cat_fuel')));
    await tester.tap(find.text('Once'));
    await tester.pumpAndSettle();
    expect(find.text('Choose dates'), findsOneWidget);
    await tester.tap(find.text('Create budget'));
    await tester.pumpAndSettle();
    expect(find.text('Choose the dates this budget covers.'), findsOneWidget);
    expect(await repo.getAllBudgets(), isEmpty);
  });

  testWidgets('editing keeps the budget and its own alert level', (
    tester,
  ) async {
    final initial = Budget(
      id: 'b1',
      name: 'Eating out',
      categoryId: 'cat_dining',
      categoryName: 'Dining',
      categoryIcon: 'restaurant',
      categoryColor: 'clay',
      amountLimit: 6000,
      startDate: DateTime(2026, 6, 1),
      alertThreshold: 0.85,
      createdAt: _t,
      updatedAt: _t,
    );
    final repo = await _open(tester, initial: initial);
    expect(find.text('Edit budget'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    // An older budget's 85% stays a choice instead of being changed.
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Eating out'), findsOneWidget);
    await tester.enterText(_limit, '7000');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    final saved = (await repo.getAllBudgets()).single;
    expect(saved.id, 'b1');
    expect(saved.name, 'Eating out');
    expect(saved.amountLimit, 7000);
    expect(saved.startDate, DateTime(2026, 6, 1));
    expect(saved.alertThreshold, 0.85);
    expect(saved.createdAt, _t);
  });

  testWidgets('no overflow at 2× text', (tester) async {
    await _open(tester, textScale: 2);
    await tester.enterText(_limit, '6500');
    await tester.tap(find.byKey(const ValueKey('budget-category-cat_dining')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
