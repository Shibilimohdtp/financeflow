import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_error.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../repositories/money_record_repository.dart';
import '../../services/money_lending_calculator.dart';

final allMoneyRecordsStreamProvider = StreamProvider<List<MoneyRecord>>((ref) {
  final repository = ref.watch(moneyRecordRepositoryProvider);
  return repository.watchAllRecords();
});

final allMoneyRepaymentsStreamProvider =
    StreamProvider<List<MoneyRepayment>>((ref) {
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
  final repayments =
      ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];
  return MoneyLendingCalculator.calculateSummary(records, repayments);
});

final filteredMoneyRecordsProvider = Provider<List<MoneyRecord>>((ref) {
  final records = ref.watch(allMoneyRecordsStreamProvider).value ?? const [];
  final repayments =
      ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];
  final filter = ref.watch(moneyRecordFilterProvider);
  return MoneyLendingCalculator.filterRecords(records, repayments, filter);
});

final moneyRecordsControllerProvider =
    StateNotifierProvider<MoneyRecordsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(moneyRecordRepositoryProvider);
  return MoneyRecordsController(repository);
});

class MoneyRecordsController extends StateNotifier<AsyncValue<void>> {
  final MoneyRecordRepository _repository;
  static const _uuid = Uuid();

  MoneyRecordsController(this._repository)
      : super(const AsyncValue.data(null));

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
  }) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final record = MoneyRecord(
        id: 'rec_${_uuid.v4()}',
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
      );

      record.validate();
      await _repository.saveRecord(record);
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
      final repayments =
          await _repository.getRepaymentsForRecord(record.id, userId: record.userId);
      final totalRepaid = record.calculateTotalRepaid(repayments);
      if (record.originalAmount < (totalRepaid - 0.001)) {
        throw ValidationError(
          message:
              'Original amount cannot be less than total repayments already made.',
          actionableStep:
              'Total repaid so far is ₹${totalRepaid.toStringAsFixed(2)}. Enter an amount >= ₹${totalRepaid.toStringAsFixed(2)}.',
        );
      }

      final now = DateTime.now();
      final isNowSettled = (record.originalAmount - totalRepaid) <= 0.001;

      final updated = record.copyWith(
        personName: record.personName.trim(),
        notes: record.notes?.trim().isNotEmpty == true ? record.notes!.trim() : null,
        updatedAt: now,
        settledAt: isNowSettled
            ? (record.settledAt ?? now)
            : (record.settledAt != null && !isNowSettled ? null : record.settledAt),
        clearSettledAt: !isNowSettled && record.settledAt != null,
      );

      await _repository.saveRecord(updated);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRecord(String id, {String userId = 'local_user'}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteRecord(id, userId: userId);
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
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await _repository.getRecordById(moneyRecordId, userId: userId);
      if (record == null) {
        throw const ValidationError(
          message: 'Record not found.',
          actionableStep: 'Please select an existing lending or borrowing record.',
        );
      }

      final repayments =
          await _repository.getRepaymentsForRecord(moneyRecordId, userId: userId);
      final remaining = record.calculateRemainingAmount(repayments);

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
      await _repository.addRepayment(repayment);

      // Auto-settle record if balance is 0
      final updatedRepayments = [...repayments, repayment];
      final newRemaining = record.calculateRemainingAmount(updatedRepayments);
      if (newRemaining <= 0.001 && record.settledAt == null) {
        final settledRecord = record.copyWith(
          settledAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.saveRecord(settledRecord);
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
      await _repository.deleteRepayment(repaymentId, userId: userId);

      // Check if record was settled; if remaining > 0, un-settle it
      final record = await _repository.getRecordById(moneyRecordId, userId: userId);
      if (record != null && record.settledAt != null) {
        final repayments =
            await _repository.getRepaymentsForRecord(moneyRecordId, userId: userId);
        final remaining = record.calculateRemainingAmount(repayments);
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
