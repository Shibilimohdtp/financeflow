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
    'EmiScheduleView renders without any RenderFlex overflow on narrow screens',
    (WidgetTester tester) async {
      // Set a narrow viewport like small phones
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final startDate = DateTime(2025, 6, 1);
      final loan = Loan(
        id: 'bike_loan_schedule_test',
        name: 'Bike Loan',
        lender: 'Bajaj Finance',
        loanType: LoanType.vehicleLoan,
        principalAmount: 250000.0,
        interestRate: 11.5,
        interestType: InterestType.reducingBalance,
        tenureMonths: 36,
        startDate: startDate,
        expectedEndDate: DateTime(2028, 6, 1),
        emiAmount: 9047.92,
        paymentDay: 3,
        totalPrincipalPaid: 100000.0,
        totalInterestPaid: 25000.0,
        outstandingPrincipal: 150000.0,
        nextDueDate: DateTime(2026, 9, 3),
        status: LoanStatus.active,
        createdAt: startDate,
        updatedAt: startDate,
      );

      final fakeRepo = FakeLoanRepository([loan]);

      // Seed 15 paid EMI payments to recreate the user's exact screen scenario
      final payments = <EmiPayment>[];
      for (int m = 1; m <= 15; m++) {
        final dueDate = DateTime(2025, 6 + m, 3);
        payments.add(
          EmiPayment(
            id: 'emi_bike_$m',
            loanId: loan.id,
            installmentNumber: m,
            dueDate: dueDate,
            paymentDate: dueDate,
            principalPaid: 7166.67,
            interestPaid: 1881.25,
            emiAmount: 9047.92,
            createdAt: dueDate,
            updatedAt: dueDate,
          ),
        );
      }
      await fakeRepo.recordMultipleEmiPayments(payments);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [loanRepositoryProvider.overrideWithValue(fakeRepo)],
          child: MaterialApp(
            theme: StillwaterTheme.deepWater,
            home: EmiScheduleView(loan: loan),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header stats
      expect(find.text('15 Paid'), findsOneWidget);
      expect(find.textContaining('Upcoming'), findsWidgets);

      // Verify that initially visible schedule items are rendered
      expect(find.textContaining('July 2025'), findsWidgets);
      expect(find.textContaining('Paid 3 Jul 2025'), findsWidgets);

      // Verify undo icon button is present for paid items
      expect(find.byIcon(Icons.undo_rounded), findsWidgets);

      // Scroll down to see November items
      await tester.scrollUntilVisible(
        find.textContaining('November 2025'),
        100,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('November 2025'), findsWidgets);
      expect(find.textContaining('Paid 3 Nov 2025'), findsWidgets);

      // Scroll down further to see unpaid items
      await tester.scrollUntilVisible(
        find.byIcon(Icons.check_circle_outline_rounded),
        100,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      // Verify unpaid checkmark buttons exist
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsWidgets);
    },
  );

  testWidgets('EmiScheduleView allows marking a paid installment as unpaid', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 3, 1);

    final loan = Loan(
      id: 'unmark_loan_test',
      name: 'Personal Loan',
      lender: 'SBI',
      loanType: LoanType.personalLoan,
      principalAmount: 30000.0,
      interestRate: 10.0,
      interestType: InterestType.flatRate,
      tenureMonths: 3,
      startDate: startDate,
      expectedEndDate: DateTime(now.year, now.month, 1),
      emiAmount: 10250.0,
      paymentDay: 5,
      totalPrincipalPaid: 20000.0,
      totalInterestPaid: 500.0,
      outstandingPrincipal: 10000.0,
      nextDueDate: DateTime(now.year, now.month, 5),
      status: LoanStatus.active,
      createdAt: startDate,
      updatedAt: startDate,
    );

    final fakeRepo = FakeLoanRepository([loan]);

    // Record payments for installments #1 and #2
    final payment1 = EmiPayment(
      id: 'emi_p1',
      loanId: loan.id,
      installmentNumber: 1,
      dueDate: DateTime(startDate.year, startDate.month + 1, 5),
      paymentDate: DateTime(startDate.year, startDate.month + 1, 5),
      principalPaid: 10000.0,
      interestPaid: 250.0,
      emiAmount: 10250.0,
      createdAt: startDate,
      updatedAt: startDate,
    );
    final payment2 = EmiPayment(
      id: 'emi_p2',
      loanId: loan.id,
      installmentNumber: 2,
      dueDate: DateTime(startDate.year, startDate.month + 2, 5),
      paymentDate: DateTime(startDate.year, startDate.month + 2, 5),
      principalPaid: 10000.0,
      interestPaid: 250.0,
      emiAmount: 10250.0,
      createdAt: startDate,
      updatedAt: startDate,
    );
    await fakeRepo.recordMultipleEmiPayments([payment1, payment2]);

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

    expect(find.text('2 Paid'), findsOneWidget);

    // Find undo button for paid installments
    final undoButtons = find.byIcon(Icons.undo_rounded);
    expect(undoButtons, findsNWidgets(2));

    // Tap undo button on installment #1
    await tester.tap(undoButtons.first);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Mark Installment #1 as Unpaid?'), findsOneWidget);
    expect(find.text('Mark Unpaid'), findsOneWidget);

    // Confirm unmark
    await tester.tap(find.text('Mark Unpaid'));
    await tester.pumpAndSettle();

    // Verify status changed to 1 Paid
    expect(find.text('1 Paid'), findsOneWidget);
    expect(find.byIcon(Icons.undo_rounded), findsNWidgets(1));
  });
}
