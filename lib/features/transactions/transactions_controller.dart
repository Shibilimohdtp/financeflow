import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../settings/settings_controller.dart';

class TransactionFilterState {
  final String searchQuery;
  final TransactionType? selectedType;
  final String? selectedCategoryId;
  final String? selectedAccountId;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionFilterState({
    this.searchQuery = '',
    this.selectedType,
    this.selectedCategoryId,
    this.selectedAccountId,
    this.startDate,
    this.endDate,
  });

  TransactionFilterState copyWith({
    String? searchQuery,
    TransactionType? selectedType,
    bool clearType = false,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? selectedAccountId,
    bool clearAccount = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return TransactionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategoryId:
          clearCategory
              ? null
              : (selectedCategoryId ?? this.selectedCategoryId),
      selectedAccountId:
          clearAccount ? null : (selectedAccountId ?? this.selectedAccountId),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedType != null ||
      selectedCategoryId != null ||
      selectedAccountId != null ||
      startDate != null ||
      endDate != null;
}

final transactionFilterProvider = StateProvider<TransactionFilterState>((ref) {
  return const TransactionFilterState();
});

final filteredTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final repo = ref.watch(transactionRepositoryProvider);

  return repo.watchSearchAndFilterTransactions(
    query: filter.searchQuery,
    type: filter.selectedType,
    categoryId: filter.selectedCategoryId,
    accountId: filter.selectedAccountId,
    startDate: filter.startDate,
    endDate: filter.endDate,
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
  Transaction? _lastDeletedTransaction;

  TransactionsController(this._ref) : super(const AsyncValue.data(null));

  Transaction? get lastDeletedTransaction => _lastDeletedTransaction;

  Future<void> saveTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(transactionRepositoryProvider);
      await repo.saveTransaction(transaction);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      _lastDeletedTransaction = transaction;
      final repo = _ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(transaction.id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTransaction != null) {
      await saveTransaction(_lastDeletedTransaction!);
      _lastDeletedTransaction = null;
    }
  }
}
