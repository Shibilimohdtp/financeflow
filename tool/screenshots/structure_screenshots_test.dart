// Screenshot capture for DS-5a (app bars, dividers), not part of the test
// suite. Uses only APIs present before and after DS-5a.
//
//   flutter test tool/screenshots/structure_screenshots_test.dart --update-goldens
import 'package:financeflow/features/loans/loan_detail_screen.dart';
import 'package:financeflow/features/loans/loans_screen.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

Loan _loan() {
  final start = DateTime(2026, 6, 1);
  return Loan(
    id: 'shot_loan',
    name: 'Home Loan',
    lender: 'HDFC Bank',
    loanType: LoanType.homeLoan,
    principalAmount: 2500000,
    interestRate: 8.5,
    interestType: InterestType.reducingBalance,
    tenureMonths: 240,
    startDate: start,
    expectedEndDate: DateTime(2046, 6, 1),
    emiAmount: 21696,
    paymentDay: 5,
    totalPrincipalPaid: 0,
    totalInterestPaid: 0,
    outstandingPrincipal: 2500000,
    nextDueDate: DateTime(2026, 7, 5),
    status: LoanStatus.active,
    createdAt: start,
    updatedAt: start,
  );
}

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home,
) async {
  tester.view.physicalSize = const Size(390, 520);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final loan = _loan();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(FakeLoanRepository([loan])),
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
    testWidgets('loans list, $mode', (tester) async {
      await _capture(tester, 'bar_loans_$mode', theme, const LoansScreen());
    });

    testWidgets('loan detail, $mode', (tester) async {
      await _capture(
        tester,
        'bar_loan_detail_$mode',
        theme,
        LoanDetailScreen(loan: _loan()),
      );
    });
  }
}
