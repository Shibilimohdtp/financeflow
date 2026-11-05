import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/money_record.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/financial_operation_service.dart';
import '../accounts/accounts_controller.dart';
import 'transaction_list_utils.dart';

export 'transaction_list_utils.dart' show TransactionQuery, TransactionSort;

/// What the transaction list shows. Global, so it survives tab switches and
/// returning from detail/edit screens.
final transactionQueryProvider = StateProvider<TransactionQuery>(
  (ref) => TransactionQuery.initial(),
);

/// The transaction list's results: only the selected period is read from the
/// database (date index), then the remaining filters and sort are applied.
///
/// This is the Transactions screen's view. Budgets, export and other features
/// must use [allTransactionsStreamProvider] instead, so a search on this screen
/// never changes their numbers.
final filteredTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final query = ref.watch(transactionQueryProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  final accounts = ref.watch(rawAccountsStreamProvider).value ?? const [];
  final period = query.period;

  final source =
      period == null
          ? repo.watchAllTransactions()
          : repo.watchTransactionsBetween(period.start, period.endExclusive);
  return source.map(
    (transactions) => applyTransactionQuery(
      transactions: transactions,
      query: query,
      accounts: accounts,
    ),
  );
});

final transactionByIdProvider = Provider.family<Future<Transaction?>, String>((
  ref,
  id,
) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionById(id);
});

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsController, AsyncValue<void>>((ref) {
      return TransactionsController(ref);
    });

class TransactionsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  List<FinancialOperationSnapshot> _lastDeleted = const [];

  TransactionsController(this._ref) : super(const AsyncValue.data(null));

  Transaction? get lastDeletedTransaction =>
      _lastDeleted.isEmpty ? null : _lastDeleted.first.transaction;

  FinancialOperationService get _operations =>
      _ref.read(financialOperationServiceProvider);

  Future<void> saveTransaction(
    Transaction transaction, {
    MoneyRecord? moneyRecordDetails,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _operations.postTransaction(
        transaction,
        moneyRecordDetails: moneyRecordDetails,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTransaction(Transaction transaction) =>
      deleteTransactions([transaction]);

  /// Deletes through the operation service so linked EMI/debt allocations are
  /// reversed too. The whole batch can be undone with [undoDelete].
  Future<void> deleteTransactions(List<Transaction> transactions) async {
    state = const AsyncValue.loading();
    try {
      final snapshots = <FinancialOperationSnapshot>[];
      for (final tx in transactions) {
        final snapshot = await _operations.deleteTransaction(tx.id);
        if (snapshot != null) snapshots.add(snapshot);
      }
      _lastDeleted = snapshots;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> undoDelete() async {
    final snapshots = _lastDeleted;
    _lastDeleted = const [];
    for (final snapshot in snapshots.reversed) {
      await _operations.restore(snapshot);
    }
  }

  /// Moves transactions to [category]. Transactions whose kind cannot carry a
  /// category (transfers, lending, loan links) are skipped; returns how many
  /// were changed.
  Future<int> recategorize(
    List<Transaction> transactions,
    Category category,
  ) async {
    state = const AsyncValue.loading();
    try {
      var changed = 0;
      final now = DateTime.now();
      for (final tx in transactions) {
        if (!canRecategorize(tx)) continue;
        await _operations.postTransaction(
          tx.copyWith(
            categoryId: category.id,
            categoryName: category.name,
            categoryIcon: category.iconIdentifier,
            categoryColor: category.colorTokenIdentifier,
            updatedAt: now,
          ),
        );
        changed++;
      }
      state = const AsyncValue.data(null);
      return changed;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  static bool canRecategorize(Transaction tx) {
    final kind = TransactionKind.of(tx);
    return (kind == TransactionKind.spending ||
            kind == TransactionKind.income) &&
        !tx.isLinkedOperation;
  }
}
