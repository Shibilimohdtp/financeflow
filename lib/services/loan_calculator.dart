import 'dart:math';
import '../models/loan.dart';

class AmortizationScheduleItem {
  final int monthNumber;
  final DateTime dueDate;
  final double openingBalance;
  final double emiAmount;
  final double principalPaid;
  final double interestPaid;
  final double closingBalance;

  const AmortizationScheduleItem({
    required this.monthNumber,
    required this.dueDate,
    required this.openingBalance,
    required this.emiAmount,
    required this.principalPaid,
    required this.interestPaid,
    required this.closingBalance,
  });
}

class LoanCalculator {
  LoanCalculator._();

  /// Calculate monthly EMI for reducing balance loan
  static double calculateReducingBalanceEmi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    if (annualRate <= 0) return principal / tenureMonths;

    final monthlyRate = (annualRate / 12.0) / 100.0;
    final factor = pow(1.0 + monthlyRate, tenureMonths).toDouble();
    final emi = (principal * monthlyRate * factor) / (factor - 1.0);
    return double.parse(emi.toStringAsFixed(2));
  }

  /// Calculate monthly EMI for flat rate loan
  static double calculateFlatRateEmi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    final totalInterest =
        principal * (annualRate / 100.0) * (tenureMonths / 12.0);
    final totalAmount = principal + totalInterest;
    final emi = totalAmount / tenureMonths;
    return double.parse(emi.toStringAsFixed(2));
  }

  /// Calculate EMI based on interest type
  static double calculateEmi({
    required double principal,
    required double annualRate,
    required int tenureMonths,
    InterestType interestType = InterestType.reducingBalance,
  }) {
    if (interestType == InterestType.flatRate) {
      return calculateFlatRateEmi(
        principal: principal,
        annualRate: annualRate,
        tenureMonths: tenureMonths,
      );
    }
    return calculateReducingBalanceEmi(
      principal: principal,
      annualRate: annualRate,
      tenureMonths: tenureMonths,
    );
  }

  /// Total repayment estimate
  static double calculateTotalRepayment(Loan loan) {
    return loan.emiAmount * loan.tenureMonths;
  }

  /// Total estimated interest
  static double calculateTotalEstimatedInterest(Loan loan) {
    final total = calculateTotalRepayment(loan);
    return (total - loan.principalAmount).clamp(0.0, double.infinity);
  }

  /// Compute next EMI due date given paymentDay and reference date
  static DateTime computeNextDueDate({
    required int paymentDay,
    DateTime? fromDate,
  }) {
    final ref = fromDate ?? DateTime.now();
    final clampedDay = paymentDay.clamp(1, 28); // Safe day for all months

    DateTime candidate = DateTime(ref.year, ref.month, clampedDay);
    if (candidate.isBefore(DateTime(ref.year, ref.month, ref.day))) {
      candidate = DateTime(ref.year, ref.month + 1, clampedDay);
    }
    return candidate;
  }

  /// Generate complete amortization schedule
  static List<AmortizationScheduleItem> generateSchedule(Loan loan) {
    final List<AmortizationScheduleItem> schedule = [];
    double currentBalance = loan.principalAmount;
    final monthlyRate = (loan.interestRate / 12.0) / 100.0;

    for (int month = 1; month <= loan.tenureMonths; month++) {
      if (currentBalance <= 0) break;

      final dueDate = DateTime(
        loan.startDate.year,
        loan.startDate.month + month,
        loan.paymentDay.clamp(1, 28),
      );

      final double interestForMonth;
      final double principalForMonth;
      final double emi = loan.emiAmount;

      if (loan.interestType == InterestType.reducingBalance) {
        interestForMonth = currentBalance * monthlyRate;
        principalForMonth = (emi - interestForMonth).clamp(0.0, currentBalance);
      } else {
        final totalInterest =
            loan.principalAmount *
            (loan.interestRate / 100.0) *
            (loan.tenureMonths / 12.0);
        interestForMonth = totalInterest / loan.tenureMonths;
        principalForMonth = (loan.principalAmount / loan.tenureMonths).clamp(
          0.0,
          currentBalance,
        );
      }

      final closing = (currentBalance -
              principalPaidSafe(principalForMonth, currentBalance))
          .clamp(0.0, double.infinity);

      schedule.add(
        AmortizationScheduleItem(
          monthNumber: month,
          dueDate: dueDate,
          openingBalance: currentBalance,
          emiAmount: emi,
          principalPaid: principalForMonth,
          interestPaid: interestForMonth,
          closingBalance: closing,
        ),
      );

      currentBalance = closing;
    }

    return schedule;
  }

  static double principalPaidSafe(
    double calculatedPrincipal,
    double currentBalance,
  ) {
    return calculatedPrincipal > currentBalance
        ? currentBalance
        : calculatedPrincipal;
  }
}
