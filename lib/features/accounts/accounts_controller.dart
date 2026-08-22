import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../services/balance_calculator.dart';
import '../settings/settings_controller.dart';

// Raw accounts stream
final rawAccountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchAllAccounts(includeArchived: true);
});

// All transactions stream
final allTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAllTransactions();
});

// Accounts with calculated balances provider
final accountsWithBalancesProvider = Provider<AsyncValue<List<Account>>>((ref) {
  final accountsAsync = ref.watch(rawAccountsStreamProvider);
  final transactionsAsync = ref.watch(allTransactionsStreamProvider);

  if (accountsAsync.hasError) {
    return AsyncValue.error(accountsAsync.error!, accountsAsync.stackTrace!);
  }
  if (transactionsAsync.hasError) {
    return AsyncValue.error(
      transactionsAsync.error!,
      transactionsAsync.stackTrace!,
    );
  }

  if (!accountsAsync.hasValue || !transactionsAsync.hasValue) {
    return const AsyncValue.loading();
  }

  final accounts = accountsAsync.value!;
  final transactions = transactionsAsync.value!;

  final calculated =
      accounts.map((account) {
        final balance = BalanceCalculator.calculateAccountBalance(
          account: account,
          allTransactions: transactions,
        );
        return account.copyWith(currentBalance: balance);
      }).toList();

  return AsyncValue.data(calculated);
});

// Accounts Controller
final accountsControllerProvider =
    StateNotifierProvider<AccountsController, AsyncValue<void>>((ref) {
      return AccountsController(ref);
    });

class AccountsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AccountsController(this._ref) : super(const AsyncValue.data(null));

  Future<void> saveAccount(Account account) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(accountRepositoryProvider);
      await repo.saveAccount(account);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> archiveAccount(String id, bool archive) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(accountRepositoryProvider);
      await repo.archiveAccount(id, archive);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAccount(String id) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(accountRepositoryProvider);
      await repo.deleteAccount(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
