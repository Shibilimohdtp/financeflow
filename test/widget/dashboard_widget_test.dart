import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_screen.dart';
import 'package:financeflow/features/dashboard/insights_controller.dart';
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
    'DashboardScreen renders Total Balance Hero, Quick Actions, Cash Flow, Accounts and Recent Transactions',
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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

      // Verify Title & Privacy Badge
      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('On-device'), findsOneWidget);

      // Verify Total Balance Hero
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('1 account'), findsOneWidget);
      expect(find.text('₹48,500'), findsWidgets);

      // Verify Quick Actions
      expect(find.text('Add Entry'), findsOneWidget);
      expect(find.text('Accounts'), findsWidgets);

      // Verify Cash Flow Values
      expect(find.text('Net Savings'), findsOneWidget);
      expect(find.text('+ ₹73,500'), findsOneWidget);
      expect(find.text('+ ₹75,000'), findsOneWidget);
      expect(find.text('− ₹1,500'), findsWidgets);

      // Verify Account Strip
      expect(find.text('HDFC Salary'), findsOneWidget);
      expect(find.text('••4321'), findsOneWidget);

      // Verify Recent Transaction
      expect(find.text('Recent Transactions'), findsOneWidget);
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
          dashboardInsightsProvider.overrideWithValue(
            const AsyncValue.data([]),
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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
      expect(find.text('Actionable & Upcoming'), findsOneWidget);
      expect(find.text('2 imported transactions need review'), findsOneWidget);
      expect(find.text('HDFC Home Loan (HDFC Bank)'), findsOneWidget);
      expect(find.text('Netflix Premium'), findsOneWidget);

      // Verify Loans & EMI Section
      expect(find.text('Loans & EMI'), findsWidgets);
      expect(find.text('Next EMI Due'), findsOneWidget);
      expect(find.text('Total Outstanding'), findsOneWidget);
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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

      // Verify Total Balance with 0 accounts
      expect(find.text('0 accounts'), findsOneWidget);

      // Verify Add first account empty state
      expect(find.text('Add your first account'), findsOneWidget);

      // Verify No transactions empty state
      expect(find.text('No transactions yet'), findsOneWidget);
    },
  );

  testWidgets(
    'DashboardScreen quick actions and transaction taps trigger callbacks',
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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
      await tester.tap(find.text('Add Entry'));
      await tester.pumpAndSettle();
      expect(addTapped, isTrue);

      // Tap Accounts quick action
      await tester.tap(find.text('Accounts').first);
      await tester.pumpAndSettle();
      expect(manageAccountsTapped, isTrue);

      // Tap View all transactions
      final viewAllFinder = find.text('View all').first;
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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
      expect(find.text('Net Savings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'DashboardScreen period selector supports This Week, This Month, Last Month, This Year and triggers updates',
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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

      // Verify all period pills are present
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsWidgets);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Tap This Week
      await tester.tap(find.text('This Week'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tap This Year
      await tester.tap(find.text('This Year'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'DashboardScreen renders period comparison trend badge when comparison data exists',
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
            dashboardInsightsProvider.overrideWithValue(
              const AsyncValue.data([]),
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

      // -20.0% spend trend badge should be displayed
      expect(find.text('20.0% spend'), findsOneWidget);
    },
  );
}
