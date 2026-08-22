import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../services/ingestion/transaction_merge_service.dart';
import '../settings/settings_controller.dart';

class NeedsReviewController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  NeedsReviewController(this._ref) : super(const AsyncValue.data(null));

  /// Approve a single pending transaction
  Future<void> approveItem(ParsedTransaction item) async {
    state = const AsyncValue.loading();
    try {
      final txRepo = _ref.read(transactionRepositoryProvider);
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);

      if (item.duplicateResolution == DuplicateResolution.merge &&
          item.matchedTransaction != null) {
        final merged = TransactionMergeService.mergeWithExisting(
          existing: item.matchedTransaction!,
          incoming: item,
        );
        await txRepo.saveTransaction(merged);
      } else {
        final tx = item.toTransaction();
        await txRepo.saveTransaction(tx);
      }

      await pendingRepo.removePendingTransaction(item.tempId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Approve all valid items in batch
  Future<int> approveAllValid(List<ParsedTransaction> items) async {
    state = const AsyncValue.loading();
    try {
      final txRepo = _ref.read(transactionRepositoryProvider);
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);

      final toSave = <Transaction>[];
      final toRemove = <String>[];

      for (final item in items) {
        if (!item.isValid) continue;

        if (item.duplicateResolution == DuplicateResolution.merge &&
            item.matchedTransaction != null) {
          final merged = TransactionMergeService.mergeWithExisting(
            existing: item.matchedTransaction!,
            incoming: item,
          );
          toSave.add(merged);
        } else {
          toSave.add(item.toTransaction());
        }
        toRemove.add(item.tempId);
      }

      if (toSave.isNotEmpty) {
        await txRepo.saveTransactions(toSave);
      }
      if (toRemove.isNotEmpty) {
        await pendingRepo.removePendingTransactions(toRemove);
      }

      state = const AsyncValue.data(null);
      return toSave.length;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Dismiss or exclude a pending transaction
  Future<void> dismissItem(String tempId) async {
    state = const AsyncValue.loading();
    try {
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      await pendingRepo.removePendingTransaction(tempId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Wipe all pending staged items
  Future<void> clearAll() async {
    state = const AsyncValue.loading();
    try {
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      await pendingRepo.clearAllPending();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final needsReviewControllerProvider =
    StateNotifierProvider<NeedsReviewController, AsyncValue<void>>((ref) {
      return NeedsReviewController(ref);
    });

final pendingReviewCountProvider = Provider<int>((ref) {
  final pendingAsync = ref.watch(pendingTransactionsStreamProvider);
  return pendingAsync.value?.length ?? 0;
});
