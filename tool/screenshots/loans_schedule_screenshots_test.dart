// Screenshot capture of a loan's full payment schedule and its entry card on
// loan detail (DS-B19), not part of the test suite. Uses only APIs that exist
// before and after DS-B19, so compare.py can capture both commits.
//
//   flutter test tool/screenshots/loans_schedule_screenshots_test.dart --update-goldens
import 'package:financeflow/features/loans/loan_detail_screen.dart';
import 'package:financeflow/features/loans/widgets/emi_schedule_view.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
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
// Two years back: most installments are paid, a few are overdue, and the
// rest are upcoming, so every row state appears in one capture.
final _start = DateTime(_now.year - 2, _now.month, 6);

final _home = Loan(
  id: 'l1',
  name: 'Home loan',
  lender: 'HDFC Bank',
  loanType: LoanType.homeLoan,
  principalAmount: 2400000,
  interestRate: 8.4,
  interestType: InterestType.reducingBalance,
  tenureMonths: 120,
  startDate: _start,
  expectedEndDate: DateTime(_start.year + 10, _start.month, 6),
  emiAmount: 29600,
  paymentDay: 6,
  totalPrincipalPaid: 380000,
  totalInterestPaid: 0,
  outstandingPrincipal: 2020000,
  nextDueDate: DateTime(_start.year, _start.month + 23, 6),
  status: LoanStatus.active,
  createdAt: _start,
  updatedAt: _start,
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

Future<void> _capture(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget home, {
  double scrollBy = 0,
}) async {
  tester.view.physicalSize = const Size(390, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith(
          (ref) => Stream.value(const AppSettings()),
        ),
        loanRepositoryProvider.overrideWithValue(
          FakeLoanRepository([_home], [..._payments(_home, 21, skip: 19)]),
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
  if (scrollBy != 0) {
    // Bring the lower part of a long screen (the schedule entry) into frame.
    await tester.drag(find.byType(Scrollable).first, Offset(0, -scrollBy));
    await tester.pumpAndSettle();
  }
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
    testWidgets('loan schedule, $mode', (tester) async {
      await _capture(
        tester,
        'b19_schedule_$mode',
        theme,
        EmiScheduleView(loan: _home),
      );
    });
    testWidgets('loan detail entry, $mode', (tester) async {
      await _capture(
        tester,
        'b19_loan_detail_$mode',
        theme,
        LoanDetailScreen(loan: _home),
        scrollBy: 900,
      );
    });
  }
}
