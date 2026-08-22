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
  });
}
