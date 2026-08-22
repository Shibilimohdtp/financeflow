import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/dashboard_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  testWidgets(
    'DashboardScreen renders Cash Flow card, Accounts and Recent Transactions',
    (WidgetTester tester) async {
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

      // Verify Title & Privacy Badge
      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('On-device'), findsOneWidget);

      // Verify Cash Flow Values
      expect(find.text('Net Savings'), findsOneWidget);
      expect(find.text('+ ₹73,500'), findsOneWidget);
      expect(find.text('+ ₹75,000'), findsOneWidget);
      expect(find.text('− ₹1,500'), findsWidgets);

      // Verify Account Strip
      expect(find.text('HDFC Salary'), findsOneWidget);
      expect(find.text('••4321'), findsOneWidget);
      expect(find.text('₹48,500'), findsOneWidget);

      // Verify Recent Transaction
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Swiggy Food'), findsOneWidget);
      expect(find.text('Manual'), findsOneWidget);
    },
  );
}
