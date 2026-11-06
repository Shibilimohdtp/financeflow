// Screenshot capture of Accounts, Loans and a loan's detail (DS-B6), not
// part of the test suite. Uses only APIs that exist before and after DS-B6,
// so compare.py can capture both commits.
//
//   flutter test tool/screenshots/accounts_loans_screenshots_test.dart --update-goldens
import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/accounts/accounts_screen.dart';
import 'package:financeflow/features/loans/loan_detail_screen.dart';
import 'package:financeflow/features/loans/loans_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

final _now = DateTime.now();
final _start = DateTime(_now.year - 2, _now.month, 6);

Loan _loan(
  String id,
  String name,
  LoanType type,
  double principal,
  int months,
  double emi, {
  int paidMonths = 0,
  double paidPrincipal = 0,
}) {
  return Loan(
    id: id,
    name: name,
    lender: 'Bank',
    loanType: type,
    principalAmount: principal,
    interestRate: 8.4,
    interestType: InterestType.reducingBalance,
    tenureMonths: months,
    startDate: _start,
    expectedEndDate: DateTime(_start.year, _start.month + months, 6),
    emiAmount: emi,
    paymentDay: 6,
    totalPrincipalPaid: paidPrincipal,
    totalInterestPaid: 0,
    outstandingPrincipal: principal - paidPrincipal,
    nextDueDate: DateTime(_start.year, _start.month + paidMonths + 1, 6),
    status: LoanStatus.active,
    createdAt: _start,
    updatedAt: _start,
  );
}

final _home = _loan(
  'l1',
  'Home loan',
  LoanType.homeLoan,
  2400000,
  120,
  29600,
  paidMonths: 22,
  paidPrincipal: 380000,
);
final _car = _loan(
  'l2',
  'Car loan',
  LoanType.vehicleLoan,
  600000,
  48,
  14900,
  paidMonths: 24,
  paidPrincipal: 290000,
);

/// Paid EMIs for the first [count] months, except [skip] (a missed month).
List<EmiPayment> _payments(Loan loan, int count, {int? skip}) => [
  for (var i = 1; i <= count; i++)
    if (i != skip)
      EmiPayment(
        id: '${loan.id}_$i',
        loanId: loan.id,
        installmentNumber: i,
        dueDate: DateTime(_start.year, _start.month + i, 6),
        paymentDate: DateTime(_start.year, _start.month + i, 5),
        principalPaid: loan.emiAmount * 0.6,
        interestPaid: loan.emiAmount * 0.4,
        emiAmount: loan.emiAmount,
        createdAt: _start,
        updatedAt: _start,
      ),
];

Account _account(String id, String name, AccountType type, double balance) =>
    Account(
      id: id,
      name: name,
      type: type,
      openingBalance: balance,
      currentBalance: balance,
      createdAt: _start,
      updatedAt: _start,
    );

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home,
) async {
  tester.view.physicalSize = const Size(390, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final accounts = [
    _account('a1', 'Salary account', AccountType.bank, 124500),
    _account('a2', 'Cash wallet', AccountType.cash, 6200),
    _account('a3', 'Credit card', AccountType.creditCard, -18450),
  ];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        accountsWithBalancesProvider.overrideWithValue(
          AsyncValue.data(accounts),
        ),
        loanRepositoryProvider.overrideWithValue(
          FakeLoanRepository(
            [_home, _car],
            [..._payments(_home, 23, skip: 21), ..._payments(_car, 24)],
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: home,
      ),
    ),
  );
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
    testWidgets('accounts, $mode', (tester) async {
      await _capture(
        tester,
        'b6_accounts_$mode',
        theme,
        const AccountsScreen(),
      );
    });
    testWidgets('loans, $mode', (tester) async {
      await _capture(tester, 'b6_loans_$mode', theme, const LoansScreen());
    });
    testWidgets('loan detail, $mode', (tester) async {
      await _capture(
        tester,
        'b6_loan_detail_$mode',
        theme,
        LoanDetailScreen(loan: _home),
      );
    });
  }
}
