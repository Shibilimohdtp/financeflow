import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../models/money_advance.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../models/transaction.dart';
import '../../repositories/money_record_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/financial_operation_service.dart';
import '../../database/isar_service.dart';
import '../../services/money_lending_calculator.dart';
import '../../core/formatting/currency_formatter.dart';

final allMoneyRecordsStreamProvider = StreamProvider<List<MoneyRecord>>((ref) {
  final repository = ref.watch(moneyRecordRepositoryProvider);
  return repository.watchAllRecords();
});

final allMoneyAdvancesStreamProvider = StreamProvider<List<MoneyAdvance>>((
  ref,
) {
  final repository = ref.watch(moneyRecordRepositoryProvider);
  return repository.watchAllAdvances();
});

final moneyRecordAdvancesProvider =
    StreamProvider.family<List<MoneyAdvance>, String>((ref, recordId) {
      final repository = ref.watch(moneyRecordRepositoryProvider);
      return repository.watchAdvancesForRecord(recordId);
    });

final allMoneyRepaymentsStreamProvider = StreamProvider<List<MoneyRepayment>>((
  ref,
) {
  final repository = ref.watch(moneyRecordRepositoryProvider);
  return repository.watchAllRepayments();
});

final moneyRecordRepaymentsProvider =
    StreamProvider.family<List<MoneyRepayment>, String>((ref, recordId) {
      final repository = ref.watch(moneyRecordRepositoryProvider);
      return repository.watchRepaymentsForRecord(recordId);
    });

final moneyRecordFilterProvider = StateProvider<MoneyRecordFilter>((ref) {
  return MoneyRecordFilter.all;
});

final moneyLendingSummaryProvider = Provider<MoneyLendingSummary>((ref) {
  final records = ref.watch(allMoneyRecordsStreamProvider).value ?? const [];
  final advances = ref.watch(allMoneyAdvancesStreamProvider).value ?? const [];
  final repayments =
      ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];
  return MoneyLendingCalculator.calculateSummary(
    records,
    repayments,
    advances: advances,
  );
});

final filteredMoneyRecordsProvider = Provider<List<MoneyRecord>>((ref) {
  final records = ref.watch(allMoneyRecordsStreamProvider).value ?? const [];
  final advances = ref.watch(allMoneyAdvancesStreamProvider).value ?? const [];
  final repayments =
      ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];
  final filter = ref.watch(moneyRecordFilterProvider);
  return MoneyLendingCalculator.filterRecords(
    records,
    repayments,
    filter,
    advances: advances,
  );
});

final moneyRecordsControllerProvider =
    StateNotifierProvider<MoneyRecordsController, AsyncValue<void>>((ref) {
      final repository = ref.watch(moneyRecordRepositoryProvider);
      final hasDatabase = IsarService.isInitialized;
      return MoneyRecordsController(
        repository,
        hasDatabase ? ref.watch(financialOperationServiceProvider) : null,
        hasDatabase ? ref.watch(transactionRepositoryProvider) : null,
      );
    });

class MoneyRecordsController extends StateNotifier<AsyncValue<void>> {
  final MoneyRecordRepository _repository;
  final FinancialOperationService? _coordinator;
  final TransactionRepository? _transactions;
  static const _uuid = Uuid();

  MoneyRecordsController(
    this._repository, [
    this._coordinator,
    this._transactions,
  ]) : super(const AsyncValue.data(null));

  Future<void> addRecord({
    required String personName,
    required MoneyRecordType type,
    required double originalAmount,
    required DateTime transactionDate,
    required DateTime dueDate,
    String? notes,
    bool isReminderEnabled = true,
    int reminderDaysBefore = 1,
    String userId = 'local_user',
    String? accountId,
    bool recordInTransactions = false,
    bool isCustomSeparateObligation = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final recordId = 'rec_${_uuid.v4()}';
      final record = MoneyRecord(
        id: recordId,
        userId: userId,
        type: type,
        personName: personName.trim(),
        originalAmount: originalAmount,
        transactionDate: transactionDate,
        dueDate: dueDate,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        isReminderEnabled: isReminderEnabled,
        reminderDaysBefore: reminderDaysBefore,
        createdAt: now,
        updatedAt: now,
        isCustomSeparateObligation: isCustomSeparateObligation,
      );

      record.validate();
      if (recordInTransactions && accountId != null && _coordinator != null) {
        final transactionId = 'debt_origin_$recordId';
        await _coordinator.postTransaction(
          Transaction(
            id: transactionId,
            amount: originalAmount,
            type:
                type == MoneyRecordType.lent
                    ? TransactionType.expense
                    : TransactionType.income,
            purpose:
                type == MoneyRecordType.lent
                    ? TransactionPurpose.lending
                    : TransactionPurpose.borrowing,
            categoryId: 'cat_personal_debt',
            categoryName: 'Personal debt',
            categoryIcon: 'person',
            categoryColor: 'debt',
            merchant: personName.trim(),
            externalCounterpartyName: personName.trim(),
            date: transactionDate,
            notes: notes,
            accountId: accountId,
            linkedMoneyRecordId: recordId,
            createdAt: now,
            updatedAt: now,
          ),
          moneyRecordDetails: record.copyWith(
            originTransactionId: transactionId,
          ),
        );
      } else {
        await _repository.saveRecord(record);
        // Save initial advance event
        final advance = MoneyAdvance(
          id: 'adv_$recordId',
          moneyRecordId: recordId,
          userId: userId,
          amount: originalAmount,
          date: transactionDate,
          dueDate: dueDate,
          notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
          accountId: accountId,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.saveAdvance(advance);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addAdvance({
    required String moneyRecordId,
    required double amount,
    required DateTime date,
    required DateTime dueDate,
    String? notes,
    String? accountId,
    bool recordInTransactions = false,
    String userId = 'local_user',
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(
        moneyRecordId,
        userId: userId,
      );
      if (record == null) {
        throw const ValidationError(
          message: 'Relationship record not found.',
          actionableStep: 'Select a valid active debt relationship.',
        );
      }

      final now = DateTime.now();
      final advanceId = 'adv_${_uuid.v4()}';

      if (recordInTransactions && accountId != null && _coordinator != null) {
        final transactionId = 'debt_adv_$advanceId';
        await _coordinator.postTransaction(
          Transaction(
            id: transactionId,
            amount: amount,
            type:
                record.type == MoneyRecordType.lent
                    ? TransactionType.expense
                    : TransactionType.income,
            purpose:
                record.type == MoneyRecordType.lent
                    ? TransactionPurpose.lending
                    : TransactionPurpose.borrowing,
            categoryId: 'cat_personal_debt',
            categoryName: 'Personal debt',
            categoryIcon: 'person',
            categoryColor: 'debt',
            merchant: record.personName,
            externalCounterpartyName: record.personName,
            date: date,
            notes: notes,
            accountId: accountId,
            linkedMoneyRecordId: record.id,
            createdAt: now,
            updatedAt: now,
          ),
          moneyRecordDetails: record.copyWith(dueDate: dueDate),
        );
      } else {
        final advance = MoneyAdvance(
          id: advanceId,
          moneyRecordId: moneyRecordId,
          userId: userId,
          amount: amount,
          date: date,
          dueDate: dueDate,
          notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
          accountId: accountId,
          createdAt: now,
          updatedAt: now,
        );
        advance.validate();
        await _repository.saveAdvance(advance);

        // Update relationship aggregate total & un-settle if needed
        final advances = await _repository.getAdvancesForRecord(
          moneyRecordId,
          userId: userId,
        );
        final totalAdv = advances.fold<double>(0.0, (sum, a) => sum + a.amount);
        final updatedRecord = record.copyWith(
          originalAmount: totalAdv,
          clearSettledAt: true,
          updatedAt: now,
        );
        await _repository.saveRecord(updatedRecord);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateRecord(MoneyRecord record) async {
    state = const AsyncValue.loading();
    try {
      record.validate();

      // Safe update check: ensure originalAmount is not less than total repaid
      final repayments = await _repository.getRepaymentsForRecord(
        record.id,
        userId: record.userId,
      );
      final totalRepaid = record.calculateTotalRepaid(repayments);
      if (record.originalAmount < (totalRepaid - 0.001)) {
        throw ValidationError(
          message:
              'Original amount cannot be less than total repayments already made.',
          actionableStep:
              'Total repaid so far is ${CurrencyFormatter.formatAmount(totalRepaid)}. Enter an amount >= ${CurrencyFormatter.formatAmount(totalRepaid)}.',
        );
      }

      final now = DateTime.now();
      final isNowSettled = (record.originalAmount - totalRepaid) <= 0.001;

      final updated = record.copyWith(
        personName: record.personName.trim(),
        notes:
            record.notes?.trim().isNotEmpty == true
                ? record.notes!.trim()
                : null,
        updatedAt: now,
        settledAt:
            isNowSettled
                ? (record.settledAt ?? now)
                : (record.settledAt != null && !isNowSettled
                    ? null
                    : record.settledAt),
        clearSettledAt: !isNowSettled && record.settledAt != null,
      );

      if (record.originTransactionId != null &&
          _coordinator != null &&
          _transactions != null) {
        final origin = await _transactions.getTransactionById(
          record.originTransactionId!,
        );
        if (origin != null) {
          await _coordinator.postTransaction(
            origin.copyWith(
              amount: updated.originalAmount,
              merchant: updated.personName,
              externalCounterpartyName: updated.personName,
              date: updated.transactionDate,
              notes: updated.notes,
              updatedAt: now,
            ),
            moneyRecordDetails: updated,
          );
        } else {
          await _repository.saveRecord(
            updated.copyWith(clearOriginTransactionId: true),
          );
        }
      } else {
        await _repository.saveRecord(updated);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRecord(String id, {String userId = 'local_user'}) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(id, userId: userId);
      if (record?.originTransactionId != null && _coordinator != null) {
        await _coordinator.deleteTransaction(record!.originTransactionId!);
      } else {
        await _repository.deleteRecord(id, userId: userId);
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addRepayment({
    required String moneyRecordId,
    required double amount,
    required DateTime repaymentDate,
    String? notes,
    String userId = 'local_user',
    String? accountId,
    bool recordInTransactions = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(
        moneyRecordId,
        userId: userId,
      );
      if (record == null) {
        throw const ValidationError(
          message: 'Record not found.',
          actionableStep:
              'Please select an existing lending or borrowing record.',
        );
      }

      final repayments = await _repository.getRepaymentsForRecord(
        moneyRecordId,
        userId: userId,
      );
      final advances = await _repository.getAdvancesForRecord(
        moneyRecordId,
        userId: userId,
      );
      final remaining = record.calculateRemainingAmount(
        repayments,
        advances: advances,
      );

      final repayment = MoneyRepayment(
        id: 'rep_${_uuid.v4()}',
        moneyRecordId: moneyRecordId,
        userId: userId,
        amount: amount,
        repaymentDate: repaymentDate,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        createdAt: DateTime.now(),
      );

      repayment.validate(remainingBalance: remaining);
      if (recordInTransactions && accountId != null && _coordinator != null) {
        await _coordinator.postTransaction(
          Transaction(
            id: 'debt_repayment_${repayment.id}',
            amount: amount,
            type:
                record.type == MoneyRecordType.lent
                    ? TransactionType.income
                    : TransactionType.expense,
            purpose:
                record.type == MoneyRecordType.lent
                    ? TransactionPurpose.personalDebtRepaymentReceived
                    : TransactionPurpose.personalDebtRepaymentMade,
            categoryId: 'cat_personal_debt',
            categoryName: 'Personal debt repayment',
            categoryIcon: 'payments',
            categoryColor: 'debt',
            merchant: record.personName,
            externalCounterpartyName: record.personName,
            date: repaymentDate,
            notes: notes,
            accountId: accountId,
            linkedMoneyRecordId: record.id,
            principalComponent: amount,
            createdAt: repayment.createdAt,
            updatedAt: repayment.createdAt,
          ),
        );
      } else {
        await _repository.addRepayment(repayment);
      }

      if (!(recordInTransactions &&
          accountId != null &&
          _coordinator != null)) {
        // Legacy/status-only repayment path.
        final updatedRepayments = [...repayments, repayment];
        final newRemaining = record.calculateRemainingAmount(
          updatedRepayments,
          advances: advances,
        );
        if (newRemaining <= 0.001 && record.settledAt == null) {
          final settledRecord = record.copyWith(
            settledAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _repository.saveRecord(settledRecord);
        }
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRepayment(
    String repaymentId,
    String moneyRecordId, {
    String userId = 'local_user',
  }) async {
    state = const AsyncValue.loading();
    try {
      final repayment =
          (await _repository.getAllRepayments(
            userId: userId,
          )).where((item) => item.id == repaymentId).firstOrNull;
      if (repayment?.transactionId != null && _coordinator != null) {
        await _coordinator.deleteTransaction(repayment!.transactionId!);
      } else {
        await _repository.deleteRepayment(repaymentId, userId: userId);
      }

      // Check if record was settled; if remaining > 0, un-settle it
      final record = await _repository.getRecordById(
        moneyRecordId,
        userId: userId,
      );
      if (record != null && record.settledAt != null) {
        final repayments = await _repository.getRepaymentsForRecord(
          moneyRecordId,
          userId: userId,
        );
        final advances = await _repository.getAdvancesForRecord(
          moneyRecordId,
          userId: userId,
        );
        final remaining = record.calculateRemainingAmount(
          repayments,
          advances: advances,
        );
        if (remaining > 0.001) {
          final unSettledRecord = record.copyWith(
            clearSettledAt: true,
            updatedAt: DateTime.now(),
          );
          await _repository.saveRecord(unSettledRecord);
        }
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markRecordSettled(
    String recordId, {
    String userId = 'local_user',
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(recordId, userId: userId);
      if (record == null) return;

      final updated = record.copyWith(
        settledAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveRecord(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markRecordUnsettled(
    String recordId, {
    String userId = 'local_user',
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(recordId, userId: userId);
      if (record == null) return;

      final updated = record.copyWith(
        clearSettledAt: true,
        updatedAt: DateTime.now(),
      );
      await _repository.saveRecord(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
