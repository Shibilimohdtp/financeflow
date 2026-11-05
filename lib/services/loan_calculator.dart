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
  final EmiPaymentStatus status;
  final EmiPayment? payment;

  const AmortizationScheduleItem({
    required this.monthNumber,
    required this.dueDate,
    required this.openingBalance,
    required this.emiAmount,
    required this.principalPaid,
    required this.interestPaid,
    required this.closingBalance,
    this.status = EmiPaymentStatus.upcoming,
    this.payment,
  });

  bool get isPaid => status == EmiPaymentStatus.paid;
  bool get isOverdue => status == EmiPaymentStatus.overdue;
  bool get isUpcoming => status == EmiPaymentStatus.upcoming;

  int daysOverdue({DateTime? referenceDate}) {
    if (!isOverdue) return 0;
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = today.difference(due).inDays;
    return diff > 0 ? diff : 0;
  }
}

class LoanRemainingBalance {
  final double principal;
  final double interest;

  /// Principal plus interest over the whole schedule.
  final double totalPayable;

  const LoanRemainingBalance({
    required this.principal,
    required this.interest,
    required this.totalPayable,
  });

  /// Everything still to be paid: remaining principal plus remaining interest.
  double get total => principal + interest;

  double get paid => (totalPayable - total).clamp(0.0, totalPayable);

  double get paidFraction =>
      totalPayable <= 0 ? 1.0 : (paid / totalPayable).clamp(0.0, 1.0);
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

  /// Generate complete amortization schedule with payment statuses
  static List<AmortizationScheduleItem> generateSchedule(
    Loan loan, {
    List<EmiPayment> payments = const [],
    DateTime? asOfDate,
  }) {
    final List<AmortizationScheduleItem> schedule = [];
    double currentBalance = loan.principalAmount;
    final monthlyRate = (loan.interestRate / 12.0) / 100.0;
    final today = asOfDate ?? DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final paymentMap = {for (final p in payments) p.installmentNumber: p};

    for (int month = 1; month <= loan.tenureMonths; month++) {
      if (currentBalance <= 0) break;

      final dueDate = DateTime(
        loan.startDate.year,
        loan.startDate.month + month,
        loan.paymentDay.clamp(1, 28),
      );
      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

      final double interestForMonth;
      final double principalForMonth;
      final double emi = loan.emiAmount;

      if (month == loan.tenureMonths) {
        if (loan.interestType == InterestType.reducingBalance) {
          interestForMonth = currentBalance * monthlyRate;
        } else {
          final totalInterest =
              loan.principalAmount *
              (loan.interestRate / 100.0) *
              (loan.tenureMonths / 12.0);
          interestForMonth = totalInterest / loan.tenureMonths;
        }
        principalForMonth = currentBalance;
      } else if (loan.interestType == InterestType.reducingBalance) {
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

      final payment = paymentMap[month];
      final EmiPaymentStatus status;
      if (payment != null) {
        status = EmiPaymentStatus.paid;
      } else if (dueDateOnly.isBefore(todayDateOnly)) {
        status = EmiPaymentStatus.overdue;
      } else {
        status = EmiPaymentStatus.upcoming;
      }

      schedule.add(
        AmortizationScheduleItem(
          monthNumber: month,
          dueDate: dueDate,
          openingBalance: currentBalance,
          emiAmount: emi,
          principalPaid: principalForMonth,
          interestPaid: interestForMonth,
          closingBalance: closing,
          status: status,
          payment: payment,
        ),
      );

      currentBalance = closing;
    }

    return schedule;
  }

  /// What is still owed on a loan under its schedule: principal *and* the
  /// interest that the remaining installments will charge. Showing only the
  /// outstanding principal understates the money the user still has to pay.
  static LoanRemainingBalance remainingBalance(
    List<AmortizationScheduleItem> schedule,
  ) {
    var principal = 0.0;
    var interest = 0.0;
    var totalPayable = 0.0;
    for (final item in schedule) {
      totalPayable += item.principalPaid + item.interestPaid;
      if (item.isPaid) continue;
      principal += item.principalPaid;
      interest += item.interestPaid;
    }
    return LoanRemainingBalance(
      principal: principal,
      interest: interest,
      totalPayable: totalPayable,
    );
  }

  /// Identify all overdue/missed installments
  static List<AmortizationScheduleItem> getMissedInstallments(
    Loan loan, {
    List<EmiPayment> payments = const [],
    DateTime? asOfDate,
  }) {
    final schedule = generateSchedule(
      loan,
      payments: payments,
      asOfDate: asOfDate,
    );
    return schedule.where((item) => item.isOverdue).toList();
  }

  /// Recalculate loan summary figures (principal paid, interest paid, outstanding balance, next due date, status)
  static Loan recalculateLoanState({
    required Loan loan,
    required List<EmiPayment> payments,
    DateTime? asOfDate,
  }) {
    final schedule = generateSchedule(
      loan,
      payments: payments,
      asOfDate: asOfDate,
    );

    double totalPrincipalPaid = 0.0;
    double totalInterestPaid = 0.0;
    for (final p in payments) {
      totalPrincipalPaid += p.principalPaid;
      totalInterestPaid += p.interestPaid;
    }

    double outstandingPrincipal = (loan.principalAmount - totalPrincipalPaid)
        .clamp(0.0, double.infinity);

    final unpaid =
        schedule.where((item) => item.status != EmiPaymentStatus.paid).toList();

    final DateTime nextDueDate;
    final LoanStatus status;

    if (unpaid.isEmpty || outstandingPrincipal <= 0.50) {
      outstandingPrincipal = 0.0;
      totalPrincipalPaid = loan.principalAmount;
      nextDueDate =
          schedule.isNotEmpty ? schedule.last.dueDate : loan.expectedEndDate;
      status = LoanStatus.paidOff;
    } else {
      nextDueDate = unpaid.first.dueDate;
      status =
          (loan.status == LoanStatus.archived ||
                  loan.status == LoanStatus.paused)
              ? loan.status
              : LoanStatus.active;
    }

    return loan.copyWith(
      totalPrincipalPaid: totalPrincipalPaid,
      totalInterestPaid: totalInterestPaid,
      outstandingPrincipal: outstandingPrincipal,
      nextDueDate: nextDueDate,
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate principal & interest split for a specific installment number
  static ({double principal, double interest, double emi, DateTime dueDate})
  calculateInstallmentSplit({
    required Loan loan,
    required int installmentNumber,
  }) {
    final schedule = generateSchedule(loan);
    final item = schedule.firstWhere(
      (it) => it.monthNumber == installmentNumber,
      orElse:
          () =>
              schedule.isNotEmpty
                  ? schedule.last
                  : AmortizationScheduleItem(
                    monthNumber: installmentNumber,
                    dueDate: DateTime(
                      loan.startDate.year,
                      loan.startDate.month + installmentNumber,
                      loan.paymentDay.clamp(1, 28),
                    ),
                    openingBalance: loan.outstandingPrincipal,
                    emiAmount: loan.emiAmount,
                    principalPaid: loan.emiAmount,
                    interestPaid: 0.0,
                    closingBalance: 0.0,
                  ),
    );

    return (
      principal: item.principalPaid,
      interest: item.interestPaid,
      emi: item.emiAmount,
      dueDate: item.dueDate,
    );
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
