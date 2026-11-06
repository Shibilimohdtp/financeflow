// DS-B7b: the Plan tab (Budgets) on BudgetBoard, with a fixed "today".
//
// Sunday 15 November 2026, 14:30: 15 of 30 days elapsed, 16 left including
// today. Budgets: Groceries ₹12,000 (Essentials, running hot), Dining ₹6,000
// (Lifestyle, over, and over in each of the last 3 months), Gifts ₹3,000
// (Other, untouched). A ₹29,600 EMI linked to a loan sits in the Dining
// category and must not count against Dining.
import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/budgets/budgets_controller.dart';
import 'package:financeflow/features/budgets/budgets_screen.dart';
import 'package:financeflow/features/budgets/plan_providers.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/features/transactions/transaction_list_utils.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/budget.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

final _now = DateTime(2026, 11, 15, 14, 30);
final _created = DateTime(2026, 5, 1);

typedef _Cat = (String id, String name, String icon, String color);
const _groceries = ('cat_groceries', 'Groceries', 'shopping_cart', 'grove');
const _dining = ('cat_dining', 'Dining', 'restaurant', 'clay');
const _gifts = ('cat_gifts', 'Gifts', 'card_giftcard', 'shore');

final _categories = [
  for (final c in [_groceries, _dining, _gifts])
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

Budget _budget(_Cat c, double limit) => Budget(
  id: 'b_${c.$1}',
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
  _budget(_groceries, 12000),
  _budget(_dining, 6000),
  _budget(_gifts, 3000),
];

var _seq = 0;
Transaction _tx(_Cat c, double amount, DateTime date, {String? loanId}) =>
    Transaction(
      id: 't${_seq++}',
      amount: amount,
      type: TransactionType.expense,
      categoryId: c.$1,
      categoryName: c.$2,
      categoryIcon: c.$3,
      categoryColor: c.$4,
      merchant: 'Shop',
      date: date,
      accountId: 'a1',
      linkedLoanId: loanId,
      createdAt: date,
      updatedAt: date,
    );

final _ledger = [
  _tx(_dining, 6800, DateTime(2026, 11, 4)),
  _tx(_dining, 29600, DateTime(2026, 11, 5), loanId: 'l1'),
  // Groceries in everyday amounts, so they set the pace (a single payment
  // of 40% of the limit or more is a one-off and doesn't).
  for (final d in [2, 5, 8, 11, 14])
    _tx(_groceries, 1600, DateTime(2026, 11, d)),
  for (final m in [8, 9, 10]) ...[
    _tx(_dining, 3500, DateTime(2026, m, 6)),
    _tx(_dining, 3500, DateTime(2026, m, 20)),
    for (final d in [3, 10, 17, 24])
      _tx(_groceries, 2250, DateTime(2026, m, d)),
  ],
];

class _Harness {
  _Harness({
    List<Budget>? budgets,
    List<Transaction>? ledger,
    this.hidden = false,
  }) : repo = FakeBudgetRepository(budgets ?? _budgets),
       ledger = ledger ?? _ledger;

  final FakeBudgetRepository repo;
  final List<Transaction> ledger;
  final bool hidden;
  final queries = <TransactionQuery>[];

  Future<void> pump(WidgetTester tester, {double textScale = 1}) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planNowProvider.overrideWithValue(_now),
          settingsStreamProvider.overrideWith(
            (ref) => Stream.value(AppSettings(isPrivacyBlurEnabled: hidden)),
          ),
          budgetRepositoryProvider.overrideWithValue(repo),
          allTransactionsStreamProvider.overrideWith(
            (ref) => Stream.value(ledger),
          ),
          categoriesStreamProvider.overrideWith(
            (ref) => Stream.value(_categories),
          ),
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          subscriptionRepositoryProvider.overrideWithValue(
            FakeSubscriptionRepository(),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 2400),
              textScaler: TextScaler.linear(textScale),
            ),
            child: BudgetsScreen(onShowTransactions: queries.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('safe to spend, the hero and the status in words', (
    tester,
  ) async {
    await _Harness().pump(tester);
    expect(find.text('Safe to spend today'), findsOneWidget);
    // Left = 4,000 (Groceries) + 0 (Dining) + 3,000 (Gifts) over 16 days,
    // rounded down to whole rupees: ₹437.
    expect(find.text('₹7,000 left of ₹21,000 · 16 days to go'), findsOneWidget);
    expect(find.text('November plan'), findsOneWidget);
    expect(find.text('3 budgets · 2 need attention'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Plan'), findsWidgets);
  });

  testWidgets('a linked EMI never counts against a category budget', (
    tester,
  ) async {
    await _Harness().pump(tester);
    expect(find.text('₹6,800 of ₹6,000 · 113%'), findsOneWidget);
  });

  testWidgets('groups in order, statuses as badges with words', (tester) async {
    await _Harness().pump(tester);
    double y(String key) => tester.getTopLeft(find.byKey(ValueKey(key))).dy;
    expect(y('group-essentials'), lessThan(y('group-lifestyle')));
    expect(y('group-lifestyle'), lessThan(y('group-other')));
    expect(find.text('At risk'), findsOneWidget);
    expect(find.text('Over'), findsOneWidget);
    expect(find.text('₹16,800 of ₹21,000'), findsNothing);
    expect(find.text('₹8,000 of ₹12,000'), findsOneWidget);
  });

  testWidgets('each budget row is one labelled button', (tester) async {
    final handle = tester.ensureSemantics();
    await _Harness().pump(tester);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Dining, over, ₹6,800 of ₹6,000 spent, 113% used, ₹800 over'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Groceries, at risk, .*67% used, ₹4,000 left, ahead of pace'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('one suggestion with a one-tap raise and undo', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    expect(find.text('Dining keeps going over'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('plan-insight-action')));
    await tester.pumpAndSettle();
    final saved = await h.repo.getBudgetById('b_cat_dining');
    expect(saved!.amountLimit, 7000);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await h.repo.getBudgetById('b_cat_dining'))!.amountLimit, 6000);
  });

  testWidgets('the hero opens Money filtered to exactly the plan', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    await tester.tap(find.byTooltip('See this plan\'s spending in Money'));
    expect(h.queries, hasLength(1));
    final q = h.queries.single;
    expect(q.period, Period.containing(PeriodUnit.month, _now));
    expect(q.budgetScope!.categoryIds, {
      'cat_groceries',
      'cat_dining',
      'cat_gifts',
    });
    expect(q.budgetScope!.label, 'November plan');
  });

  testWidgets('a closed month shows its result, not safe to spend', (
    tester,
  ) async {
    await _Harness().pump(tester);
    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();
    expect(find.text('Safe to spend today'), findsNothing);
    expect(find.text('Left at the end of October'), findsOneWidget);
    expect(find.text('October plan'), findsOneWidget);
    expect(find.textContaining('days to go'), findsNothing);
    expect(find.textContaining('pace'), findsNothing);
  });

  testWidgets('hidden amounts hide every figure', (tester) async {
    final handle = tester.ensureSemantics();
    await _Harness(hidden: true).pump(tester);
    expect(find.textContaining('₹7,000'), findsNothing);
    expect(find.textContaining('of ₹'), findsNothing);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Safe to spend today, hidden for privacy'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('first run suggests budgets from real spending', (tester) async {
    final h = _Harness(budgets: const []);
    await h.pump(tester);
    expect(find.text('Start with a plan from your spending'), findsOneWidget);
    expect(find.text('Create 2 budgets'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('setup-create')));
    await tester.pumpAndSettle();
    final created = await h.repo.getAllBudgets();
    expect(created.map((b) => b.categoryId).toSet(), {
      'cat_groceries',
      'cat_dining',
    });
    // Median of the three months, rounded up to a friendly figure.
    expect(
      created.firstWhere((b) => b.categoryId == 'cat_dining').amountLimit,
      7000,
    );
  });

  testWidgets('first run without history explains and offers to add', (
    tester,
  ) async {
    await _Harness(budgets: const [], ledger: const []).pump(tester);
    expect(find.text('Plan your spending'), findsOneWidget);
    expect(find.text('Add budget'), findsOneWidget);
  });

  testWidgets('no overflow at 2× text', (tester) async {
    await _Harness().pump(tester, textScale: 2);
    for (final e in tester.allElements) {
      final ro = e.renderObject;
      if (ro is RenderFlex && ro.hasSize) {
        var main = 0.0;
        ro.visitChildren((c) {
          if (c is RenderBox && c.hasSize) {
            main +=
                ro.direction == Axis.horizontal ? c.size.width : c.size.height;
          }
        });
        final avail =
            ro.direction == Axis.horizontal ? ro.size.width : ro.size.height;
        if (main > avail + 0.5) {
          final chain = <String>[];
          e.visitAncestorElements((a) {
            if (chain.length < 14) chain.add(a.widget.runtimeType.toString());
            return true;
          });
          // ignore: avoid_print
          print(
            'OVERFLOW ${ro.direction} ${main - avail} <- ${chain.join(' < ')}',
          );
        }
      }
    }
    expect(tester.takeException(), isNull);
  });
}
