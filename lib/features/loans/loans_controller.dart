import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../services/loan_calculator.dart';
import '../../services/financial_operation_service.dart';
import '../../database/isar_service.dart';

/// Totals across active loans. `totalOutstanding` is everything left to pay
/// (remaining principal plus remaining interest), not just principal.
final loansSummaryProvider = Provider<
  ({double totalOutstanding, double totalMonthlyEmi, int activeLoansCount})
>((ref) {
  final loans = ref.watch(allLoansStreamProvider).value ?? const [];
  final active = loans.where((l) => l.status == LoanStatus.active).toList();

  final totalOutstanding = active.fold<double>(
    0.0,
    (s, l) => s + _remainingFor(ref, l).total,
  );
  final totalMonthlyEmi = active.fold<double>(0.0, (s, l) => s + l.emiAmount);

  return (
    totalOutstanding: totalOutstanding,
    totalMonthlyEmi: totalMonthlyEmi,
    activeLoansCount: active.length,
  );
});

/// Stream of EMI payment records for a specific loan
final loanPaymentsStreamProvider =
    StreamProvider.family<List<EmiPayment>, String>((ref, loanId) {
      try {
        final repo = ref.watch(loanRepositoryProvider);
        return repo.watchPaymentsForLoan(loanId);
      } catch (_) {
        return Stream.value(const []);
      }
    });

/// Complete Amortization Schedule including payment statuses for a loan
final loanScheduleProvider =
    Provider.family<List<AmortizationScheduleItem>, Loan>((ref, loan) {
      final payments =
          ref.watch(loanPaymentsStreamProvider(loan.id)).value ?? const [];
      return LoanCalculator.generateSchedule(loan, payments: payments);
    });

/// Remaining principal and interest for a loan, from its live schedule.
final loanRemainingBalanceProvider = Provider.autoDispose
    .family<LoanRemainingBalance, Loan>(_remainingFor);

LoanRemainingBalance _remainingFor(Ref ref, Loan loan) {
  final payments =
      ref.watch(loanPaymentsStreamProvider(loan.id)).value ?? const [];
  return LoanCalculator.remainingBalance(
    LoanCalculator.generateSchedule(loan, payments: payments),
  );
}

class LoansController extends StateNotifier<AsyncValue<void>> {
  final LoanRepository _repository;
  final FinancialOperationService? _coordinator;
  static const _uuid = Uuid();

  LoansController(this._repository, [this._coordinator])
    : super(const AsyncValue.data(null));

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
    bool markPastInstallmentsPaid = false,
    DateTime? asOfDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final expectedEnd = DateTime(
        startDate.year,
        startDate.month + tenureMonths,
        startDate.day,
      );

      final loanId = 'loan_${_uuid.v4()}';
      final firstInstallmentDueDate = DateTime(
        startDate.year,
        startDate.month + 1,
        paymentDay.clamp(1, 28),
      );

      Loan loan = Loan(
        id: loanId,
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
        nextDueDate: firstInstallmentDueDate,
        status: LoanStatus.active,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.saveLoan(loan);

      if (markPastInstallmentsPaid) {
        final missed = LoanCalculator.getMissedInstallments(
          loan,
          asOfDate: asOfDate ?? now,
        );
        if (missed.isNotEmpty) {
          final pastPayments =
              missed.map((item) {
                return EmiPayment(
                  id: 'emi_${_uuid.v4()}',
                  loanId: loan.id,
                  installmentNumber: item.monthNumber,
                  dueDate: item.dueDate,
                  paymentDate: item.dueDate,
                  principalPaid: item.principalPaid,
                  interestPaid: item.interestPaid,
                  emiAmount: item.emiAmount,
                  accountId: accountId,
                  isHistoricalStatusOnly: true,
                  notes: 'Marked paid on loan setup',
                  createdAt: now,
                  updatedAt: now,
                );
              }).toList();

          await _repository.recordMultipleEmiPayments(pastPayments);
        }
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLoan(Loan loan) async {
    state = const AsyncValue.loading();
    try {
      final payments = await _repository.getPaymentsForLoan(loan.id);
      final updated = LoanCalculator.recalculateLoanState(
        loan: loan,
        payments: payments,
      );
      await _repository.saveLoan(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLoan(String id) async {
    state = const AsyncValue.loading();
    try {
      if (_coordinator != null) {
        await _coordinator.deleteLoanKeepingHistory(id);
      } else {
        await _repository.deleteLoan(id);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark a specific installment number as paid
  Future<void> markInstallmentPaid({
    required Loan loan,
    required int installmentNumber,
    DateTime? paymentDate,
    String? accountId,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payingAccountId = accountId ?? loan.accountId;
      if (_coordinator != null && payingAccountId != null) {
        await _coordinator.postTrackedInstallment(
          loan: loan,
          installmentNumber: installmentNumber,
          accountId: payingAccountId,
          paymentDate: paymentDate ?? DateTime.now(),
        );
      } else {
        final split = LoanCalculator.calculateInstallmentSplit(
          loan: loan,
          installmentNumber: installmentNumber,
        );
        final payment = EmiPayment(
          id: 'emi_${_uuid.v4()}',
          loanId: loan.id,
          installmentNumber: installmentNumber,
          dueDate: split.dueDate,
          paymentDate: paymentDate ?? DateTime.now(),
          principalPaid: split.principal,
          interestPaid: split.interest,
          emiAmount: split.emi,
          accountId: payingAccountId,
          notes: notes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.recordEmiPayment(payment);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Mark the next unpaid installment as paid
  Future<void> markEmiPaid({
    required Loan loan,
    double? emiAmount,
    int? installmentNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payments = await _repository.getPaymentsForLoan(loan.id);
      final schedule = LoanCalculator.generateSchedule(
        loan,
        payments: payments,
      );
      final unpaid =
          schedule.where((it) => it.status != EmiPaymentStatus.paid).toList();

      if (unpaid.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final targetInstallment =
          installmentNumber != null
              ? schedule.firstWhere(
                (it) => it.monthNumber == installmentNumber,
                orElse: () => unpaid.first,
              )
              : unpaid.first;

      if (_coordinator != null && loan.accountId != null && emiAmount == null) {
        await _coordinator.postTrackedInstallment(
          loan: loan,
          installmentNumber: targetInstallment.monthNumber,
          accountId: loan.accountId!,
          paymentDate: DateTime.now(),
        );
        state = const AsyncValue.data(null);
        return;
      }

      final payment = EmiPayment(
        id: 'emi_${_uuid.v4()}',
        loanId: loan.id,
        installmentNumber: targetInstallment.monthNumber,
        dueDate: targetInstallment.dueDate,
        paymentDate: DateTime.now(),
        principalPaid: targetInstallment.principalPaid,
        interestPaid: targetInstallment.interestPaid,
        emiAmount: emiAmount ?? targetInstallment.emiAmount,
        accountId: loan.accountId,
        notes: 'EMI Payment #${targetInstallment.monthNumber}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.recordEmiPayment(payment);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Mark all overdue/missed installments as paid
  Future<void> markAllOverduePaid({
    required Loan loan,
    DateTime? paymentDate,
    String? accountId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final payments = await _repository.getPaymentsForLoan(loan.id);
      final overdue = LoanCalculator.getMissedInstallments(
        loan,
        payments: payments,
      );

      if (overdue.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final now = DateTime.now();
      final payingAccountId = accountId ?? loan.accountId;
      if (_coordinator != null && payingAccountId != null) {
        for (final item in overdue) {
          await _coordinator.postTrackedInstallment(
            loan: loan,
            installmentNumber: item.monthNumber,
            accountId: payingAccountId,
            paymentDate: paymentDate ?? now,
          );
        }
      } else {
        final newPayments =
            overdue.map((item) {
              return EmiPayment(
                id: 'emi_${_uuid.v4()}',
                loanId: loan.id,
                installmentNumber: item.monthNumber,
                dueDate: item.dueDate,
                paymentDate: paymentDate ?? now,
                principalPaid: item.principalPaid,
                interestPaid: item.interestPaid,
                emiAmount: item.emiAmount,
                accountId: accountId ?? loan.accountId,
                notes: 'Bulk overdue payment',
                createdAt: now,
                updatedAt: now,
              );
            }).toList();
        await _repository.recordMultipleEmiPayments(newPayments);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Mark a specific installment as unpaid / remove payment record and recalculate loan state
  Future<void> markInstallmentUnpaid({
    required Loan loan,
    required int installmentNumber,
    String? paymentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (paymentId != null && paymentId.isNotEmpty) {
        if (_coordinator != null) {
          await _coordinator.deleteEmiPayment(paymentId);
        } else {
          await _repository.deleteEmiPayment(paymentId);
        }
      } else {
        final payments = await _repository.getPaymentsForLoan(loan.id);
        final match =
            payments
                .where((p) => p.installmentNumber == installmentNumber)
                .firstOrNull;
        if (match != null) {
          if (_coordinator != null) {
            await _coordinator.deleteEmiPayment(match.id);
          } else {
            await _repository.deleteEmiPayment(match.id);
          }
        }
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete a recorded EMI payment and recalculate
  Future<void> deletePayment(String paymentId) async {
    state = const AsyncValue.loading();
    try {
      if (_coordinator != null) {
        await _coordinator.deleteEmiPayment(paymentId);
      } else {
        await _repository.deleteEmiPayment(paymentId);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final loansControllerProvider =
    StateNotifierProvider<LoansController, AsyncValue<void>>((ref) {
      final repo = ref.watch(loanRepositoryProvider);
      final coordinator =
          IsarService.isInitialized
              ? ref.watch(financialOperationServiceProvider)
              : null;
      return LoansController(repo, coordinator);
    });
