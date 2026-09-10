import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../services/financial_operation_service.dart';
import '../../services/ingestion/duplicate_matcher.dart';
import '../../services/ingestion/transaction_merge_service.dart';
import '../../services/notifications/notification_coordinator.dart';
import '../settings/settings_controller.dart';

class NeedsReviewController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ParsedTransaction? _lastDismissedItem;
  ParsedTransaction? _lastApprovedItem;
  String? _lastCommittedId;
  bool _lastApprovedWasMerge = false;
  Transaction? _lastPreMergeExistingTransaction;

  NeedsReviewController(this._ref) : super(const AsyncValue.data(null));

  /// Approve a single pending transaction
  Future<void> approveItem(ParsedTransaction item) async {
    state = const AsyncValue.loading();
    try {
      await _commitItem(item);
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Undo the last approved item, restoring it to the pending queue
  Future<void> undoLastApprove() async {
    final item = _lastApprovedItem;
    if (item == null) return;
    state = const AsyncValue.loading();
    try {
      final txRepo = _ref.read(transactionRepositoryProvider);
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      if (_lastApprovedWasMerge && _lastPreMergeExistingTransaction != null) {
        await txRepo.saveTransaction(_lastPreMergeExistingTransaction!);
      } else if (_lastCommittedId != null) {
        try {
          await _ref
              .read(financialOperationServiceProvider)
              .deleteTransaction(_lastCommittedId!);
        } catch (_) {
          await txRepo.deleteTransaction(_lastCommittedId!);
        }
      }
      await pendingRepo.savePendingTransaction(item);
      _lastApprovedItem = null;
      _lastCommittedId = null;
      _lastPreMergeExistingTransaction = null;
      _lastApprovedWasMerge = false;
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
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
      var count = 0;
      for (final item in items) {
        if (!item.isValid ||
            !item.isIncluded ||
            item.duplicateResolution == DuplicateResolution.ignore ||
            item.duplicateResolution == DuplicateResolution.exclude) {
          continue;
        }
        await _commitItem(item);
        count++;
      }
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
      state = const AsyncValue.data(null);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> _commitItem(ParsedTransaction item) async {
    if (!item.isValid) {
      throw StateError('Fix validation errors before approving.');
    }
    final txRepo = _ref.read(transactionRepositoryProvider);
    final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
    Transaction tx;
    if (item.duplicateResolution == DuplicateResolution.merge) {
      // Pending storage keeps the match ID, not the in-memory transaction.
      final existing =
          item.matchedTransactionId == null
              ? item.matchedTransaction
              : await txRepo.getTransactionById(item.matchedTransactionId!);
      if (existing == null) {
        throw StateError(
          'The duplicate match is no longer available. Review it again.',
        );
      }
      if (item.purpose != null && item.purpose != existing.effectivePurpose) {
        throw StateError(
          'The edited purpose differs from the existing transaction. Choose Keep Both or restore the purpose before merging.',
        );
      }
      if (item.merchantDisplayName != null &&
          !DuplicateMatcher.evaluateMatch(
            incoming: item,
            existing: existing,
          ).level.isDuplicate) {
        throw StateError(
          'Edited details no longer match this duplicate. Review the resolution.',
        );
      }
      _lastApprovedWasMerge = true;
      _lastPreMergeExistingTransaction = existing;
      tx = TransactionMergeService.mergeWithExisting(
        existing: existing,
        incoming: item,
      );
    } else {
      _lastApprovedWasMerge = false;
      _lastPreMergeExistingTransaction = null;
      // Stable ID makes retries safe if removing the pending row fails.
      tx = item.toTransaction(targetId: item.tempId);
    }
    _lastApprovedItem = item;
    _lastCommittedId = tx.id;
    // Rich edited transactions must use the same linked-operation boundary as
    // Add Transaction; unedited imports retain their existing repository path.
    if (item.purpose != null || tx.isLinkedOperation) {
      await _ref.read(financialOperationServiceProvider).postTransaction(tx);
    } else {
      await txRepo.saveTransaction(tx);
    }
    await pendingRepo.removePendingTransaction(item.tempId);
  }

  /// Dismiss or exclude a pending transaction
  Future<void> dismissItem(String tempId, {ParsedTransaction? item}) async {
    state = const AsyncValue.loading();
    try {
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      _lastDismissedItem =
          item ?? await pendingRepo.getPendingTransactionById(tempId);
      await pendingRepo.removePendingTransaction(tempId);
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Undo the last dismissed item, restoring it to the pending queue
  Future<void> undoLastDismiss() async {
    final item = _lastDismissedItem;
    if (item == null) return;
    state = const AsyncValue.loading();
    try {
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      await pendingRepo.savePendingTransaction(item);
      _lastDismissedItem = null;
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update an item in the pending queue
  Future<void> updateItem(ParsedTransaction item) async {
    state = const AsyncValue.loading();
    try {
      final pendingRepo = _ref.read(pendingTransactionRepositoryProvider);
      final previous = await pendingRepo.getPendingTransactionById(item.tempId);
      var updated = item;
      if (previous != null &&
          (previous.amount != item.amount ||
              previous.date != item.date ||
              previous.type != item.type ||
              previous.normalizedMerchant != item.normalizedMerchant ||
              previous.accountId != item.accountId)) {
        final match = DuplicateMatcher.findDuplicate(
          incoming: item,
          existingTransactions:
              await _ref
                  .read(transactionRepositoryProvider)
                  .getAllTransactions(),
        );
        if (item.duplicateResolution == DuplicateResolution.unresolved) {
          updated = item.copyWith(
            duplicateStatus: match.level,
            matchedTransactionId: match.matchedTransaction?.id,
            matchedTransaction: match.matchedTransaction,
            duplicateReasons: match.reasons,
            duplicateConfidence: match.confidence,
          );
        } else if (match.matchedTransaction?.id != item.matchedTransactionId ||
            match.level != item.duplicateStatus) {
          // Preserve the selected resolution and target. Never silently switch
          // an already selected merge to a different ledger transaction.
          updated = item.copyWith(
            warnings:
                {
                  ...item.warnings,
                  'Edited details changed the duplicate match. Review the resolution before approving.',
                }.toList(),
          );
        }
      }
      await pendingRepo.savePendingTransaction(updated);
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
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
      try {
        await _ref.read(notificationCoordinatorProvider).syncFromLocalState();
      } catch (_) {}
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

/// Session-level snooze provider for the Money-screen review task card
final reviewPromptSnoozedProvider = StateProvider<bool>((ref) => false);

