import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../services/loan_calculator.dart';

final loansSummaryProvider = Provider<
  ({double totalOutstanding, double totalMonthlyEmi, int activeLoansCount})
>((ref) {
  final loans = ref.watch(allLoansStreamProvider).value ?? const [];
  final active = loans.where((l) => l.status == LoanStatus.active).toList();

  final totalOutstanding = active.fold<double>(
    0.0,
    (s, l) => s + l.outstandingPrincipal,
  );
  final totalMonthlyEmi = active.fold<double>(0.0, (s, l) => s + l.emiAmount);

  return (
    totalOutstanding: totalOutstanding,
    totalMonthlyEmi: totalMonthlyEmi,
    activeLoansCount: active.length,
  );
});

class LoansController extends StateNotifier<AsyncValue<void>> {
  final LoanRepository _repository;
  static const _uuid = Uuid();

  LoansController(this._repository) : super(const AsyncValue.data(null));

  Future<void> addLoan({
    required String name,
    required String lender,
    LoanType loanType = LoanType.personalLoan,
    String? accountId,
    required double principalAmount,
    required double interestRate,
    InterestType interestType = InterestType.reducingBalance,
    required int tenureMonths,
    required DateTime startDate,
    required double emiAmount,
    int paymentDay = 5,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final expectedEnd = DateTime(
        startDate.year,
        startDate.month + tenureMonths,
        startDate.day,
      );
      final nextDue = LoanCalculator.computeNextDueDate(
        paymentDay: paymentDay,
        fromDate: startDate,
      );

      final loan = Loan(
        id: 'loan_${_uuid.v4()}',
        name: name,
        lender: lender,
        loanType: loanType,
        accountId: accountId,
        principalAmount: principalAmount,
        interestRate: interestRate,
        interestType: interestType,
        tenureMonths: tenureMonths,
        startDate: startDate,
        expectedEndDate: expectedEnd,
        emiAmount: emiAmount,
        paymentDay: paymentDay,
        totalPrincipalPaid: 0.0,
        totalInterestPaid: 0.0,
        outstandingPrincipal: principalAmount,
        nextDueDate: nextDue,
        status: LoanStatus.active,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.saveLoan(loan);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLoan(Loan loan) async {
    state = const AsyncValue.loading();
    try {
      final updated = loan.copyWith(updatedAt: DateTime.now());
      await _repository.saveLoan(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLoan(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteLoan(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markEmiPaid({
    required Loan loan,
    required double emiAmount,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Calculate split for this installment
      final monthlyRate = (loan.interestRate / 12.0) / 100.0;
      final interest = (loan.outstandingPrincipal * monthlyRate).clamp(
        0.0,
        emiAmount,
      );
      final principal = (emiAmount - interest).clamp(
        0.0,
        loan.outstandingPrincipal,
      );
      final nextDue = LoanCalculator.computeNextDueDate(
        paymentDay: loan.paymentDay,
        fromDate: loan.nextDueDate.add(const Duration(days: 28)),
      );

      await _repository.recordEmiPayment(
        loanId: loan.id,
        principalPaid: principal,
        interestPaid: interest,
        nextDueDate: nextDue,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final loansControllerProvider =
    StateNotifierProvider<LoansController, AsyncValue<void>>((ref) {
      final repo = ref.watch(loanRepositoryProvider);
      return LoansController(repo);
    });
