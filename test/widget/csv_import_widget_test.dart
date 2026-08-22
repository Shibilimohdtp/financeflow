import 'package:financeflow/features/accounts/accounts_controller.dart';
import 'package:financeflow/features/categories/categories_controller.dart';
import 'package:financeflow/features/ingestion/csv_import_screen.dart';
import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/models/category.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTxRepo implements TransactionRepository {
  final List<Transaction> _txs = [];

  @override
  Future<Transaction?> getTransactionById(String id) async =>
      _txs.where((t) => t.id == id).firstOrNull;

  @override
  Future<void> saveTransaction(Transaction tx) async => _txs.add(tx);

  @override
  Future<void> saveTransactions(List<Transaction> txs) async =>
      _txs.addAll(txs);

  @override
  Future<void> deleteTransaction(String id) async =>
      _txs.removeWhere((t) => t.id == id);

  @override
  Future<void> deleteTransactions(List<String> ids) async =>
      _txs.removeWhere((t) => ids.contains(t.id));

  @override
  Stream<List<Transaction>> watchAllTransactions() => Stream.value(_txs);

  @override
  Future<List<Transaction>> getAllTransactions() async => _txs;

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month) =>
      Stream.value(_txs);

  @override
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) =>
      Stream.value(_txs.take(limit).toList());

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async =>
      _txs.take(limit).toList();

  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async =>
      _txs;

  @override
  Future<List<Transaction>> searchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => _txs;

  @override
  Stream<List<Transaction>> watchSearchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) => Stream.value(_txs);
}

class FakePendingRepo implements PendingTransactionRepository {
  final List<ParsedTransaction> _items = [];

  @override
  Future<void> savePendingTransaction(ParsedTransaction item) async =>
      _items.add(item);

  @override
  Future<void> savePendingTransactions(List<ParsedTransaction> items) async =>
      _items.addAll(items);

  @override
  Future<List<ParsedTransaction>> getPendingTransactions() async => _items;

  @override
  Future<ParsedTransaction?> getPendingTransactionById(String tempId) async =>
      _items.where((i) => i.tempId == tempId).firstOrNull;

  @override
  Stream<List<ParsedTransaction>> watchPendingTransactions() =>
      Stream.value(_items);

  @override
  Future<void> removePendingTransaction(String tempId) async =>
      _items.removeWhere((i) => i.tempId == tempId);

  @override
  Future<void> removePendingTransactions(List<String> tempIds) async =>
      _items.removeWhere((i) => tempIds.contains(i.tempId));

  @override
  Future<void> clearAllPending() async => _items.clear();
}

void main() {
  testWidgets(
    'CsvImportScreen renders file options and loads sample statement',
    (WidgetTester tester) async {
      final now = DateTime.now();
      final testAccount = Account(
        id: 'acc_1',
        name: 'HDFC Savings',
        type: AccountType.bank,
        createdAt: now,
        updatedAt: now,
      );

      final testCategory = Category(
        id: 'cat_food',
        name: 'Food & Dining',
        iconIdentifier: 'restaurant',
        colorTokenIdentifier: 'clay',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(const AppSettings()),
            ),
            transactionRepositoryProvider.overrideWithValue(FakeTxRepo()),
            pendingTransactionRepositoryProvider.overrideWithValue(
              FakePendingRepo(),
            ),
            rawAccountsStreamProvider.overrideWith(
              (ref) => Stream.value([testAccount]),
            ),
            categoriesStreamProvider.overrideWith(
              (ref) => Stream.value([testCategory]),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const CsvImportScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial file selection state
      expect(find.text('Import CSV Statement'), findsOneWidget);
      expect(find.text('Choose CSV File'), findsOneWidget);
      expect(find.text('HDFC Sample'), findsOneWidget);
      expect(find.text('ICICI Sample'), findsOneWidget);
      expect(find.text('General CSV'), findsOneWidget);

      // Tap HDFC Sample button to load sample transactions
      await tester.tap(find.text('HDFC Sample'));
      await tester.pumpAndSettle();

      // Verify review session is active
      expect(find.text('Edit Columns'), findsOneWidget);
      expect(find.text('Import Transactions'), findsOneWidget);
    },
  );
}
