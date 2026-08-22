import 'package:financeflow/core/errors/app_error.dart';
import 'package:financeflow/features/loans/loans_controller.dart';
import 'package:financeflow/models/loan.dart';
import 'package:financeflow/services/loan_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';

void main() {
  group('EMI Tracker & Overdue Installment Tests', () {
    final asOfDate = DateTime(2026, 8, 23); // August 23, 2026

    // Sample Loan started 6 months ago (Feb 1, 2026), 12 months tenure, EMI on 5th
    late Loan reducingLoan;

    setUp(() {
      final startDate = DateTime(2026, 2, 1);
      final tenureMonths = 12;
      final principal = 120000.0;
      final rate = 12.0; // 12% p.a.
      final emi = LoanCalculator.calculateEmi(
        principal: principal,
        annualRate: rate,
        tenureMonths: tenureMonths,
        interestType: InterestType.reducingBalance,
      );

      reducingLoan = Loan(
        id: 'loan_old_1',
        name: 'Personal Loan',
        lender: 'HDFC Bank',
        loanType: LoanType.personalLoan,
        principalAmount: principal,
        interestRate: rate,
        interestType: InterestType.reducingBalance,
        tenureMonths: tenureMonths,
        startDate: startDate,
        expectedEndDate: DateTime(2027, 2, 1),
        emiAmount: emi,
        paymentDay: 5,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: principal,
        nextDueDate: DateTime(2026, 3, 5), // Installment 1 due date
        status: LoanStatus.active,
        createdAt: startDate,
        updatedAt: startDate,
      );
    });

    test('1. Loan started several months ago detects all installments and identifies missed ones', () {
      final schedule = LoanCalculator.generateSchedule(
        reducingLoan,
        payments: const [],
        asOfDate: asOfDate,
      );

      expect(schedule.length, equals(12));

      // Installments 1 to 6 (March 5, April 5, May 5, June 5, July 5, Aug 5) are overdue
      final overdue = LoanCalculator.getMissedInstallments(
        reducingLoan,
        payments: const [],
        asOfDate: asOfDate,
      );
      expect(overdue.length, equals(6));
      expect(overdue.first.monthNumber, equals(1));
      expect(overdue.first.dueDate, equals(DateTime(2026, 3, 5)));
      expect(overdue.last.monthNumber, equals(6));
      expect(overdue.last.dueDate, equals(DateTime(2026, 8, 5)));

      // Installments 7 to 12 are upcoming
      final upcoming = schedule.where((it) => it.isUpcoming).toList();
      expect(upcoming.length, equals(6));
      expect(upcoming.first.monthNumber, equals(7));
      expect(upcoming.first.dueDate, equals(DateTime(2026, 9, 5)));

      // Initial state has full principal outstanding and zero principal paid
      expect(reducingLoan.outstandingPrincipal, equals(120000.0));
      expect(reducingLoan.totalPrincipalPaid, equals(0.0));
      expect(reducingLoan.nextDueDate, equals(DateTime(2026, 3, 5)));
    });

    test('2. Multiple overdue installments accurately report days overdue', () {
      final schedule = LoanCalculator.generateSchedule(
        reducingLoan,
        payments: const [],
        asOfDate: asOfDate,
      );

      final inst1 = schedule.firstWhere((it) => it.monthNumber == 1);
      expect(inst1.isOverdue, isTrue);
      expect(inst1.daysOverdue(referenceDate: asOfDate), equals(asOfDate.difference(DateTime(2026, 3, 5)).inDays));

      final inst6 = schedule.firstWhere((it) => it.monthNumber == 6);
      expect(inst6.isOverdue, isTrue);
      expect(inst6.daysOverdue(referenceDate: asOfDate), equals(asOfDate.difference(DateTime(2026, 8, 5)).inDays));

      final inst7 = schedule.firstWhere((it) => it.monthNumber == 7);
      expect(inst7.isOverdue, isFalse);
      expect(inst7.isUpcoming, isTrue);
      expect(inst7.daysOverdue(referenceDate: asOfDate), equals(0));
    });

    test('3. Marking one previous EMI paid advances nextDueDate to next unpaid installment (not +1 month from now)', () {
      final schedule = LoanCalculator.generateSchedule(reducingLoan);
      final inst1 = schedule.first;

      final payment1 = EmiPayment(
        id: 'emi_p1',
        loanId: reducingLoan.id,
        installmentNumber: 1,
        dueDate: inst1.dueDate,
        paymentDate: DateTime(2026, 3, 5),
        principalPaid: inst1.principalPaid,
        interestPaid: inst1.interestPaid,
        emiAmount: inst1.emiAmount,
        createdAt: asOfDate,
        updatedAt: asOfDate,
      );

      final updatedLoan = LoanCalculator.recalculateLoanState(
        loan: reducingLoan,
        payments: [payment1],
        asOfDate: asOfDate,
      );

      // Principal paid and outstanding balance updated accurately
      expect(updatedLoan.totalPrincipalPaid, equals(inst1.principalPaid));
      expect(updatedLoan.totalInterestPaid, equals(inst1.interestPaid));
      expect(updatedLoan.outstandingPrincipal, closeTo(120000.0 - inst1.principalPaid, 0.01));

      // CRITICAL: Next due date advances to installment #2 (April 5, 2026), NOT September 2026
      expect(updatedLoan.nextDueDate, equals(DateTime(2026, 4, 5)));

      // Overdue installments reduced from 6 to 5
      final remainingOverdue = LoanCalculator.getMissedInstallments(
        updatedLoan,
        payments: [payment1],
        asOfDate: asOfDate,
      );
      expect(remainingOverdue.length, equals(5));
      expect(remainingOverdue.first.monthNumber, equals(2));
    });

    test('4. Marking all overdue EMIs paid advances nextDueDate to the first upcoming future installment', () {
      final schedule = LoanCalculator.generateSchedule(reducingLoan);
      final overdueItems = schedule.sublist(0, 6); // Installments 1 to 6

      final payments = overdueItems.map((item) {
        return EmiPayment(
          id: 'emi_p${item.monthNumber}',
          loanId: reducingLoan.id,
          installmentNumber: item.monthNumber,
          dueDate: item.dueDate,
          paymentDate: item.dueDate,
          principalPaid: item.principalPaid,
          interestPaid: item.interestPaid,
          emiAmount: item.emiAmount,
          createdAt: asOfDate,
          updatedAt: asOfDate,
        );
      }).toList();

      final updatedLoan = LoanCalculator.recalculateLoanState(
        loan: reducingLoan,
        payments: payments,
        asOfDate: asOfDate,
      );

      final totalPrincipal = overdueItems.fold<double>(0.0, (s, it) => s + it.principalPaid);
      final totalInterest = overdueItems.fold<double>(0.0, (s, it) => s + it.interestPaid);

      expect(updatedLoan.totalPrincipalPaid, closeTo(totalPrincipal, 0.01));
      expect(updatedLoan.totalInterestPaid, closeTo(totalInterest, 0.01));
      expect(updatedLoan.outstandingPrincipal, closeTo(120000.0 - totalPrincipal, 0.01));

      // Overdue is now 0
      final overdueRemaining = LoanCalculator.getMissedInstallments(
        updatedLoan,
        payments: payments,
        asOfDate: asOfDate,
      );
      expect(overdueRemaining.isEmpty, isTrue);

      // Next due date advances to Installment #7 (Sept 5, 2026)
      expect(updatedLoan.nextDueDate, equals(DateTime(2026, 9, 5)));
    });

    test('5. Duplicate payment prevention blocks paying the same installment twice', () async {
      final repo = FakeLoanRepository([reducingLoan]);

      final split1 = LoanCalculator.calculateInstallmentSplit(loan: reducingLoan, installmentNumber: 1);
      final payment1 = EmiPayment(
        id: 'p_1',
        loanId: reducingLoan.id,
        installmentNumber: 1,
        dueDate: split1.dueDate,
        paymentDate: asOfDate,
        principalPaid: split1.principal,
        interestPaid: split1.interest,
        emiAmount: split1.emi,
        createdAt: asOfDate,
        updatedAt: asOfDate,
      );

      // First payment succeeds
      await repo.recordEmiPayment(payment1);
      final paymentsAfterFirst = await repo.getPaymentsForLoan(reducingLoan.id);
      expect(paymentsAfterFirst.length, equals(1));

      // Second payment for installment #1 with a new ID must throw ValidationError
      final duplicatePayment = EmiPayment(
        id: 'p_duplicate',
        loanId: reducingLoan.id,
        installmentNumber: 1,
        dueDate: split1.dueDate,
        paymentDate: asOfDate,
        principalPaid: split1.principal,
        interestPaid: split1.interest,
        emiAmount: split1.emi,
        createdAt: asOfDate,
        updatedAt: asOfDate,
      );

      expect(
        () => repo.recordEmiPayment(duplicatePayment),
        throwsA(isA<ValidationError>()),
      );

      // Verify no duplicate record was added
      final paymentsAfterDuplicate = await repo.getPaymentsForLoan(reducingLoan.id);
      expect(paymentsAfterDuplicate.length, equals(1));
    });

    test('6. Paying all tenure installments marks loan as Paid Off', () {
      final schedule = LoanCalculator.generateSchedule(reducingLoan);
      final allPayments = schedule.map((item) {
        return EmiPayment(
          id: 'emi_p${item.monthNumber}',
          loanId: reducingLoan.id,
          installmentNumber: item.monthNumber,
          dueDate: item.dueDate,
          paymentDate: item.dueDate,
          principalPaid: item.principalPaid,
          interestPaid: item.interestPaid,
          emiAmount: item.emiAmount,
          createdAt: asOfDate,
          updatedAt: asOfDate,
        );
      }).toList();

      final paidOffLoan = LoanCalculator.recalculateLoanState(
        loan: reducingLoan,
        payments: allPayments,
        asOfDate: asOfDate,
      );

      expect(paidOffLoan.outstandingPrincipal, closeTo(0.0, 0.01));
      expect(paidOffLoan.status, equals(LoanStatus.paidOff));
      expect(paidOffLoan.progressPercentage, equals(1.0));
    });

    test('7. Flat rate loan calculations correctly split principal and interest and track schedule', () {
      final startDate = DateTime(2026, 1, 1);
      final flatLoan = Loan(
        id: 'flat_loan_1',
        name: 'Bike Loan',
        lender: 'Bajaj Finserv',
        loanType: LoanType.vehicleLoan,
        principalAmount: 60000.0,
        interestRate: 10.0, // 10% flat
        interestType: InterestType.flatRate,
        tenureMonths: 6,
        startDate: startDate,
        expectedEndDate: DateTime(2026, 7, 1),
        emiAmount: LoanCalculator.calculateEmi(
          principal: 60000.0,
          annualRate: 10.0,
          tenureMonths: 6,
          interestType: InterestType.flatRate,
        ),
        paymentDay: 10,
        outstandingPrincipal: 60000.0,
        nextDueDate: DateTime(2026, 2, 10),
        createdAt: startDate,
        updatedAt: startDate,
      );

      final schedule = LoanCalculator.generateSchedule(
        flatLoan,
        asOfDate: DateTime(2026, 4, 15),
      );

      expect(schedule.length, equals(6));
      // In flat rate, monthly principal is 60000 / 6 = 10000.0
      expect(schedule.first.principalPaid, equals(10000.0));
      // Total flat interest is 60000 * 0.1 * 0.5 = 3000 -> 500 per month
      expect(schedule.first.interestPaid, equals(500.0));
      expect(schedule.first.emiAmount, equals(10500.0));

      // As of April 15, Feb 10, Mar 10, Apr 10 are overdue (3 installments)
      final missed = LoanCalculator.getMissedInstallments(
        flatLoan,
        asOfDate: DateTime(2026, 4, 15),
      );
      expect(missed.length, equals(3));
    });

    test('8. LoansController correctly handles past loan creation with and without markPastPaid flag', () async {
      final repo = FakeLoanRepository();
      final controller = LoansController(repo);

      // A) Create past loan with markPastInstallmentsPaid: false
      await controller.addLoan(
        name: 'Car Loan',
        lender: 'SBI',
        principalAmount: 200000.0,
        interestRate: 9.0,
        interestType: InterestType.reducingBalance,
        tenureMonths: 24,
        startDate: DateTime(2026, 1, 1),
        emiAmount: 9136.0,
        paymentDay: 5,
        markPastInstallmentsPaid: false,
        asOfDate: asOfDate,
      );

      final loans = await repo.getAllLoans();
      expect(loans.length, equals(1));
      final savedLoan = loans.first;

      // No payments recorded automatically without confirmation
      final payments = await repo.getPaymentsForLoan(savedLoan.id);
      expect(payments.isEmpty, isTrue);

      // Missed installments are identified
      final missed = LoanCalculator.getMissedInstallments(savedLoan, asOfDate: asOfDate);
      expect(missed.isNotEmpty, isTrue);

      // B) Create another past loan with markPastInstallmentsPaid: true
      await controller.addLoan(
        name: 'Home Renovation',
        lender: 'HDFC',
        principalAmount: 100000.0,
        interestRate: 10.0,
        interestType: InterestType.reducingBalance,
        tenureMonths: 12,
        startDate: DateTime(2026, 3, 1),
        emiAmount: 8791.59,
        paymentDay: 5,
        markPastInstallmentsPaid: true,
        asOfDate: asOfDate,
      );

      final allLoans = await repo.getAllLoans();
      final confirmedLoan = allLoans.firstWhere((l) => l.name == 'Home Renovation');
      final confirmedPayments = await repo.getPaymentsForLoan(confirmedLoan.id);

      // March, April, May, June, July, August -> 5 past installments paid (due on Apr 5, May 5, Jun 5, Jul 5, Aug 5)
      expect(confirmedPayments.length, equals(5));
      expect(confirmedLoan.totalPrincipalPaid, greaterThan(0));
      expect(confirmedLoan.nextDueDate, equals(DateTime(2026, 9, 5)));
    });
  });
}
