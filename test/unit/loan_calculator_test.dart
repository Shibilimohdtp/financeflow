import 'package:financeflow/models/loan.dart';
import 'package:financeflow/services/loan_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoanCalculator Tests', () {
    test('calculateEmi calculates standard reducing balance EMI accurately', () {
      // Principal 10,00,000 (10 Lakhs), 8.5% annual interest, 60 months tenure
      final emi = LoanCalculator.calculateEmi(
        principal: 1000000.0,
        annualRate: 8.5,
        tenureMonths: 60,
        interestType: InterestType.reducingBalance,
      );

      expect(emi, closeTo(20516.5, 2.0));
    });

    test('calculateFlatRateEmi calculates flat interest EMI accurately', () {
      // Principal 1,00,000, 10% flat annual interest, 12 months tenure
      final emi = LoanCalculator.calculateEmi(
        principal: 100000.0,
        annualRate: 10.0,
        tenureMonths: 12,
        interestType: InterestType.flatRate,
      );

      expect(emi, closeTo(9166.67, 1.0));
    });

    test('generateSchedule produces complete amortization schedule', () {
      final now = DateTime(2026, 1, 1);
      final loan = Loan(
        id: 'l1',
        name: 'Auto Loan',
        lender: 'HDFC',
        loanType: LoanType.vehicleLoan,
        principalAmount: 500000.0,
        interestRate: 9.0,
        interestType: InterestType.reducingBalance,
        tenureMonths: 36,
        startDate: now,
        expectedEndDate: DateTime(2029, 1, 1),
        emiAmount: 15899.86,
        paymentDay: 5,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: 500000.0,
        nextDueDate: DateTime(2026, 2, 5),
        createdAt: now,
        updatedAt: now,
      );

      final schedule = LoanCalculator.generateSchedule(loan);

      expect(schedule.length, equals(36));
      expect(schedule.first.monthNumber, equals(1));
      expect(schedule.last.monthNumber, equals(36));
      expect(schedule.last.closingBalance, closeTo(0.0, 1.0));

      final totalPrincipal = schedule.fold<double>(
        0.0,
        (s, row) => s + row.principalPaid,
      );
      expect(totalPrincipal, closeTo(500000.0, 2.0));
    });

    test(
      'remainingBalance includes remaining interest, not just principal',
      () {
        final start = DateTime(2026, 1, 1);
        final loan = Loan(
          id: 'l_rem',
          name: 'Personal Loan',
          lender: 'SBI',
          loanType: LoanType.personalLoan,
          principalAmount: 100000.0,
          interestRate: 12.0,
          interestType: InterestType.reducingBalance,
          tenureMonths: 12,
          startDate: start,
          expectedEndDate: DateTime(2027, 1, 1),
          emiAmount: LoanCalculator.calculateEmi(
            principal: 100000.0,
            annualRate: 12.0,
            tenureMonths: 12,
            interestType: InterestType.reducingBalance,
          ),
          paymentDay: 5,
          totalPrincipalPaid: 0.0,
          totalInterestPaid: 0.0,
          outstandingPrincipal: 100000.0,
          nextDueDate: DateTime(2026, 2, 5),
          createdAt: start,
          updatedAt: start,
        );

        final schedule = LoanCalculator.generateSchedule(loan);
        final fresh = LoanCalculator.remainingBalance(schedule);
        final totalInterest = schedule.fold<double>(
          0,
          (sum, item) => sum + item.interestPaid,
        );

        // Nothing paid: everything is still owed, and interest is on top.
        expect(fresh.principal, closeTo(100000.0, 0.01));
        expect(fresh.interest, closeTo(totalInterest, 0.01));
        expect(fresh.interest, greaterThan(6000));
        expect(fresh.total, closeTo(100000.0 + totalInterest, 0.01));
        expect(fresh.paidFraction, closeTo(0, 1e-9));

        final first = schedule.first;
        final afterOne = LoanCalculator.remainingBalance(
          LoanCalculator.generateSchedule(
            loan,
            payments: [
              EmiPayment(
                id: 'p1',
                loanId: loan.id,
                installmentNumber: 1,
                dueDate: first.dueDate,
                paymentDate: first.dueDate,
                principalPaid: first.principalPaid,
                interestPaid: first.interestPaid,
                emiAmount: first.emiAmount,
                createdAt: first.dueDate,
                updatedAt: first.dueDate,
              ),
            ],
          ),
        );

        expect(
          afterOne.total,
          closeTo(fresh.total - first.principalPaid - first.interestPaid, 0.01),
        );
        expect(
          afterOne.paid,
          closeTo(first.principalPaid + first.interestPaid, 0.01),
        );
        expect(afterOne.totalPayable, closeTo(fresh.totalPayable, 0.01));
      },
    );
  });
}
