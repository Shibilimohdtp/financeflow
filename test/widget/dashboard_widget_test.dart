import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/core/period/report_period_provider.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_screen.dart';
import 'package:financeflow/features/dashboard/widgets/total_balance_hero.dart';
import 'package:financeflow/features/dashboard/widgets/cash_flow_card.dart';
import 'package:financeflow/features/ingestion/needs_review_controller.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/repositories/subscription_repository.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets('Compact balance card preserves account and privacy controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    var hidden = false;
    var accountTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: StillwaterTheme.deepWater,
        home: Scaffold(
          body: StatefulBuilder(
            builder:
                (context, setState) => TotalBalanceHero(
                  totalBalance: 48500,
                  activeAccountsCount: 3,
                  isPrivacyBlur: hidden,
                  onToggleBlur: () => setState(() => hidden = !hidden),
                  onManageAccounts: () => accountTaps++,
                ),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('total-balance-card'))).height,
      lessThan(140),
    );
    final accounts = find.byKey(const ValueKey('balance-accounts'));
    final privacy = find.byKey(const ValueKey('balance-privacy'));
    expect(tester.getSize(accounts).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(privacy).height, greaterThanOrEqualTo(48));
    await tester.tap(accounts);
    expect(accountTaps, 1);
    expect(find.text('₹48,500'), findsOneWidget);
    await tester.tap(privacy);
    await tester.pump();
    expect(find.text('₹48,500'), findsNothing);
    expect(find.text('₹ ••••••'), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('balance-amount'))).label,
      'Total balance hidden for privacy',
    );
    await tester.tap(privacy);
    await tester.pump();
    expect(find.text('₹48,500'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Compact balance supports large negative amounts and enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final theme in [
        StillwaterTheme.daylight,
        StillwaterTheme.deepWater,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Scaffold(
                body: TotalBalanceHero(
                  totalBalance: -12345678.90,
                  activeAccountsCount: 1,
                  isPrivacyBlur: false,
                  onToggleBlur: () {},
                  onManageAccounts: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('− ₹1,23,45,678.90'), findsOneWidget);
        expect(find.text('1 account'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  final now = DateTime.now();

  final testAccount = Account(
    id: 'acc_1',
    name: 'HDFC Salary',
    type: AccountType.bank,
    maskedIdentifier: '••4321',
    openingBalance: 50000.0,
    currentBalance: 48500.0,
    createdAt: now,
    updatedAt: now,
  );

  final testTransaction = Transaction(
    id: 't1',
    amount: 1500.0,
    type: TransactionType.expense,
    categoryId: 'cat_food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 'clay',
    merchant: 'Swiggy Food',
    date: now,
    accountId: 'acc_1',
    createdAt: now,
    updatedAt: now,
  );

  final testCashFlow = const MonthlyCashFlow(
    totalIncome: 75000.0,
    totalExpense: 1500.0,
    netSavings: 73500.0,
  );

  testWidgets(
    'DashboardScreen renders Total Balance Hero, Add button, Cash Flow and Recent Transactions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            monthlyCashFlowProvider.overrideWithValue(
              AsyncValue.data(testCashFlow),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              AsyncValue.data([testAccount]),
            ),
            totalNetWorthProvider.overrideWithValue(
              const AsyncValue.data(48500.0),
            ),
            recentTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: DashboardScreen(
              onAddTransaction: () {},
              onViewAllTransactions: () {},
              onManageAccounts: () {},
              onAddAccount: () {},
              onOpenTransactionDetail: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Header Action
      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify Total Balance Hero
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('1 account'), findsOneWidget);
      expect(find.text('₹48,500'), findsWidgets);

      // Logging is the primary action
      expect(find.widgetWithText(FloatingActionButton, 'Add'), findsOneWidget);

      // Verify Cash Flow Values
      expect(find.text('Net this period'), findsOneWidget);
      expect(find.text('+ ₹73,500'), findsOneWidget);
      expect(find.text('+ ₹75,000'), findsOneWidget);
      expect(find.text('− ₹1,500'), findsWidgets);

      // Verify Recent Transaction
      expect(find.text('Recent transactions'), findsOneWidget);
      expect(find.text('Swiggy Food'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
    },
  );

  testWidgets('DashboardScreen respects privacy blur mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStreamProvider.overrideWith(
            (ref) =>
                Stream.value(const AppSettings(isPrivacyBlurEnabled: true)),
          ),
          monthlyCashFlowProvider.overrideWithValue(
            AsyncValue.data(testCashFlow),
          ),
          accountsWithBalancesProvider.overrideWithValue(
            AsyncValue.data([testAccount]),
          ),
          totalNetWorthProvider.overrideWithValue(
            const AsyncValue.data(48500.0),
          ),
          recentTransactionsProvider.overrideWith(
            (ref) => Stream.value([testTransaction]),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: DashboardScreen(
            onAddTransaction: () {},
            onViewAllTransactions: () {},
            onManageAccounts: () {},
            onAddAccount: () {},
            onOpenTransactionDetail: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure blurred amounts are displayed
    expect(find.text('₹ ••••••'), findsWidgets);
    expect(find.text('₹48,500'), findsNothing);
  });

  testWidgets(
    'DashboardScreen renders Actionable & Upcoming items (Needs Review, Loans, Subscriptions)',
    (WidgetTester tester) async {
      final testLoan = Loan(
        id: 'loan_1',
        name: 'HDFC Home Loan',
        lender: 'HDFC Bank',
        loanType: LoanType.homeLoan,
        principalAmount: 2500000.0,
        interestRate: 8.5,
        tenureMonths: 240,
        startDate: now.subtract(const Duration(days: 60)),
        expectedEndDate: now.add(const Duration(days: 7200)),
        emiAmount: 21700.0,
        paymentDay: now.day + 2,
        outstandingPrincipal: 2450000.0,
        nextDueDate: now.add(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      final testSub = Subscription(
        id: 'sub_1',
        merchant: 'Netflix Premium',
        normalizedMerchant: 'Netflix',
        amount: 649.0,
        billingFrequency: SubscriptionFrequency.monthly,
        nextRenewalDate: now.add(const Duration(days: 3)),
        status: SubscriptionStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            pendingReviewCountProvider.overrideWith((ref) => 2),
            allLoansStreamProvider.overrideWith(
              (ref) => Stream.value([testLoan]),
            ),
            allSubscriptionsStreamProvider.overrideWith(
              (ref) => Stream.value([testSub]),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              AsyncValue.data([testAccount]),
            ),
            totalNetWorthProvider.overrideWithValue(
              const AsyncValue.data(48500.0),
            ),
            monthlyCashFlowProvider.overrideWithValue(
              AsyncValue.data(testCashFlow),
            ),
            recentTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: DashboardScreen(
              onAddTransaction: () {},
              onViewAllTransactions: () {},
              onManageAccounts: () {},
              onAddAccount: () {},
              onOpenTransactionDetail: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Actionable Items Header & Content
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('2 imported transactions need review'), findsOneWidget);
      expect(find.text('HDFC Home Loan (HDFC Bank)'), findsOneWidget);
      expect(find.text('Netflix Premium'), findsOneWidget);

      // Verify Loans & EMI Section
      expect(find.text('Loans & EMI'), findsWidgets);
      expect(find.text('Next EMI Due'), findsOneWidget);
      expect(find.text('Left to pay'), findsOneWidget);
    },
  );

  testWidgets(
    'DashboardScreen renders empty states for accounts and transactions gracefully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              const AsyncValue.data([]),
            ),
            totalNetWorthProvider.overrideWithValue(const AsyncValue.data(0.0)),
            monthlyCashFlowProvider.overrideWithValue(
              const AsyncValue.data(
                MonthlyCashFlow(
                  totalIncome: 0.0,
                  totalExpense: 0.0,
                  netSavings: 0.0,
                ),
              ),
            ),
            recentTransactionsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: DashboardScreen(
              onAddTransaction: () {},
              onViewAllTransactions: () {},
              onManageAccounts: () {},
              onAddAccount: () {},
              onOpenTransactionDetail: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Total Balance with 0 accounts
      expect(find.text('0 accounts'), findsOneWidget);

      // Verify Add first account empty state
      expect(find.text('Add your first account'), findsOneWidget);

      // Verify No transactions empty state
      expect(find.text('No transactions yet'), findsOneWidget);
    },
  );

  testWidgets(
    'DashboardScreen add button, accounts link and transaction taps trigger callbacks',
    (WidgetTester tester) async {
      bool addTapped = false;
      bool manageAccountsTapped = false;
      bool viewAllTapped = false;
      Transaction? openedTransaction;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            monthlyCashFlowProvider.overrideWithValue(
              AsyncValue.data(testCashFlow),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              AsyncValue.data([testAccount]),
            ),
            totalNetWorthProvider.overrideWithValue(
              const AsyncValue.data(48500.0),
            ),
            recentTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: DashboardScreen(
              onAddTransaction: () => addTapped = true,
              onViewAllTransactions: () => viewAllTapped = true,
              onManageAccounts: () => manageAccountsTapped = true,
              onAddAccount: () {},
              onOpenTransactionDetail: (tx) => openedTransaction = tx,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Add Entry
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
      await tester.pumpAndSettle();
      expect(addTapped, isTrue);

      // Tap Accounts quick action
      await tester.tap(find.byKey(const ValueKey('balance-accounts')));
      await tester.pumpAndSettle();
      expect(manageAccountsTapped, isTrue);

      // Tap See all on Recent transactions (the last section with a link)
      final viewAllFinder = find.text('See all').last;
      await tester.ensureVisible(viewAllFinder);
      await tester.pumpAndSettle();
      await tester.tap(viewAllFinder);
      await tester.pumpAndSettle();
      expect(viewAllTapped, isTrue);

      // Tap Transaction
      final txFinder = find.text('Swiggy Food');
      await tester.ensureVisible(txFinder);
      await tester.pumpAndSettle();
      await tester.tap(txFinder);
      await tester.pumpAndSettle();
      expect(openedTransaction?.id, equals('t1'));
    },
  );

  testWidgets(
    'DashboardScreen renders cleanly on small viewport without overflow and supports Deep Water dark theme',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 2, 568 * 2);
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            monthlyCashFlowProvider.overrideWithValue(
              AsyncValue.data(testCashFlow),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              AsyncValue.data([testAccount]),
            ),
            totalNetWorthProvider.overrideWithValue(
              const AsyncValue.data(48500.0),
            ),
            recentTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.deepWater,
            home: DashboardScreen(
              onAddTransaction: () {},
              onViewAllTransactions: () {},
              onManageAccounts: () {},
              onAddAccount: () {},
              onOpenTransactionDetail: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure zero overflow errors and correct rendering
      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('Net this period'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home period bar steps through the shared report period', (
    WidgetTester tester,
  ) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStreamProvider.overrideWith(
            (ref) => Stream.value(const AppSettings()),
          ),
          monthlyCashFlowProvider.overrideWithValue(
            AsyncValue.data(testCashFlow),
          ),
          accountsWithBalancesProvider.overrideWithValue(
            AsyncValue.data([testAccount]),
          ),
          totalNetWorthProvider.overrideWithValue(
            const AsyncValue.data(48500.0),
          ),
          recentTransactionsProvider.overrideWith(
            (ref) => Stream.value([testTransaction]),
          ),
        ],
        child: MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return DashboardScreen(
                onAddTransaction: () {},
                onViewAllTransactions: () {},
                onManageAccounts: () {},
                onAddAccount: () {},
                onOpenTransactionDetail: (_) {},
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final start = capturedRef.read(reportPeriodProvider);
    expect(start, Period.containing(PeriodUnit.month, DateTime.now()));

    final previous = find.byTooltip('Previous period');
    await tester.ensureVisible(previous);
    await tester.tap(previous);
    await tester.pumpAndSettle();

    expect(capturedRef.read(reportPeriodProvider), start.previous());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'DashboardScreen places spending comparison in Cash Flow instead of balance',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            monthlyCashFlowProvider.overrideWithValue(
              const AsyncValue.data(
                MonthlyCashFlow(
                  totalIncome: 80000.0,
                  totalExpense: 1200.0,
                  netSavings: 78800.0,
                ),
              ),
            ),
            previousPeriodCashFlowProvider.overrideWithValue(
              const AsyncValue.data(
                MonthlyCashFlow(
                  totalIncome: 75000.0,
                  totalExpense: 1500.0,
                  netSavings: 73500.0,
                ),
              ),
            ),
            accountsWithBalancesProvider.overrideWithValue(
              AsyncValue.data([testAccount]),
            ),
            totalNetWorthProvider.overrideWithValue(
              const AsyncValue.data(48500.0),
            ),
            recentTransactionsProvider.overrideWith(
              (ref) => Stream.value([testTransaction]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: DashboardScreen(
              onAddTransaction: () {},
              onViewAllTransactions: () {},
              onManageAccounts: () {},
              onAddAccount: () {},
              onOpenTransactionDetail: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final comparison = find.text('Spending down 20.0% vs previous period');
      expect(
        find.descendant(of: find.byType(CashFlowCard), matching: comparison),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TotalBalanceHero),
          matching: comparison,
        ),
        findsNothing,
      );
    },
  );
}
