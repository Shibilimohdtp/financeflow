import 'package:financeflow/features/loans/loan_detail_screen.dart';
import 'package:financeflow/features/loans/widgets/emi_schedule_view.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/repositories/loan_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  testWidgets(
    'LoanDetailScreen renders overdue banner and quick pay action for old loan',
    (WidgetTester tester) async {
      final now = DateTime.now();
      // Loan started 3 months ago, 12 months tenure, EMI on the 5th. An EMI
      // due today is not overdue yet, so the count depends on today's date.
      final pastStartDate = DateTime(now.year, now.month - 3, 1);
      final expectedOverdue = now.day > 5 ? 3 : 2;

      final loan = Loan(
        id: 'loan_widget_test',
        name: 'HDFC Home Loan',
        lender: 'HDFC Bank',
        loanType: LoanType.homeLoan,
        principalAmount: 500000.0,
        interestRate: 8.5,
        interestType: InterestType.reducingBalance,
        tenureMonths: 12,
        startDate: pastStartDate,
        expectedEndDate: DateTime(
          pastStartDate.year + 1,
          pastStartDate.month,
          1,
        ),
        emiAmount: 43614.0,
        paymentDay: 5,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: 500000.0,
        nextDueDate: DateTime(pastStartDate.year, pastStartDate.month + 1, 5),
        status: LoanStatus.active,
        createdAt: pastStartDate,
        updatedAt: pastStartDate,
      );

      final fakeRepo = FakeLoanRepository([loan]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [loanRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: LoanDetailScreen(loan: loan),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify loan title and hero card
      expect(find.text('HDFC Home Loan'), findsWidgets);
      expect(find.text('Left to pay'), findsOneWidget);

      // Verify Overdue banner is displayed because loan has past due installments
      expect(find.textContaining('Overdue EMI'), findsWidgets);
      expect(find.text('Pay All ($expectedOverdue) Overdue'), findsOneWidget);
      expect(find.text('Pay #1'), findsOneWidget);
    },
  );

  testWidgets(
    'EmiScheduleView renders status pills and allows recording payment',
    (WidgetTester tester) async {
      final now = DateTime.now();
      final pastStartDate = DateTime(now.year, now.month - 2, 1);
      // EMIs fall on the 5th; one due today is not overdue yet.
      final expectedOverdue = now.day > 5 ? 2 : 1;

      final loan = Loan(
        id: 'loan_schedule_test',
        name: 'Macbook EMI',
        lender: 'Bajaj',
        loanType: LoanType.personalLoan,
        principalAmount: 60000.0,
        interestRate: 10.0,
        interestType: InterestType.flatRate,
        tenureMonths: 6,
        startDate: pastStartDate,
        expectedEndDate: DateTime(
          pastStartDate.year,
          pastStartDate.month + 6,
          1,
        ),
        emiAmount: 10500.0,
        paymentDay: 5,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: 60000.0,
        nextDueDate: DateTime(pastStartDate.year, pastStartDate.month + 1, 5),
        status: LoanStatus.active,
        createdAt: pastStartDate,
        updatedAt: pastStartDate,
      );

      final fakeRepo = FakeLoanRepository([loan]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [loanRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: EmiScheduleView(loan: loan),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Macbook EMI Schedule'), findsOneWidget);
      expect(find.textContaining('Overdue'), findsWidgets);
      expect(find.textContaining('Upcoming'), findsWidgets);
      expect(find.text('Mark All Paid'), findsOneWidget);

      // Tap "Mark All Paid"
      await tester.tap(find.text('Mark All Paid'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Mark All Overdue EMIs Paid?'), findsOneWidget);
      expect(find.text('Mark All ($expectedOverdue) Paid'), findsOneWidget);

      // Confirm payment
      await tester.tap(find.text('Mark All ($expectedOverdue) Paid'));
      await tester.pumpAndSettle();

      // Verify payments recorded and paid count matches the overdue count
      expect(find.text('$expectedOverdue Paid'), findsOneWidget);
      expect(find.text('0 Overdue'), findsNothing); // Overdue banner is gone!
    },
  );
}
