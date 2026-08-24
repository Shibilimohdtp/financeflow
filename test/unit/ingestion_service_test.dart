import 'package:financeflow/models/account.dart';
import 'package:financeflow/models/ingestion/parsed_transaction.dart';
import 'package:financeflow/models/transaction.dart';
import 'package:financeflow/repositories/pending_transaction_repository.dart';
import 'package:financeflow/repositories/transaction_repository.dart';
import 'package:financeflow/services/ingestion/ingestion_service.dart';
import 'package:flutter_test/flutter_test.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  final Map<String, Transaction> _store = {};

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    _store[transaction.id] = transaction;
  }

  @override
  Future<void> saveTransactions(List<Transaction> transactions) async {
    for (final t in transactions) {
      _store[t.id] = t;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> deleteTransactions(List<String> ids) async {
    for (final id in ids) {
      _store.remove(id);
    }
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _store.values.toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    return _store[id];
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 5}) async =>
      _store.values.take(limit).toList();

  @override
  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async =>
      _store.values.toList();

  @override
  Future<List<Transaction>> searchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => _store.values.toList();

  @override
  Stream<List<Transaction>> watchAllTransactions() =>
      Stream.value(_store.values.toList());

  @override
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) =>
      Stream.value(_store.values.take(limit).toList());

  @override
  Stream<List<Transaction>> watchSearchAndFilterTransactions({
    String? query,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) => Stream.value(_store.values.toList());

  @override
  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month) =>
      Stream.value(_store.values.toList());
}

class InMemoryPendingTransactionRepository
    implements PendingTransactionRepository {
  final Map<String, ParsedTransaction> _store = {};

  @override
  Future<void> savePendingTransaction(ParsedTransaction item) async {
    _store[item.tempId] = item;
  }

  @override
  Future<void> savePendingTransactions(List<ParsedTransaction> items) async {
    for (final it in items) {
      _store[it.tempId] = it;
    }
  }

  @override
  Future<void> removePendingTransaction(String tempId) async {
    _store.remove(tempId);
  }

  @override
  Future<void> removePendingTransactions(List<String> tempIds) async {
    for (final id in tempIds) {
      _store.remove(id);
    }
  }

  @override
  Future<void> clearAllPending() async {
    _store.clear();
  }

  @override
  Future<List<ParsedTransaction>> getPendingTransactions() async =>
      _store.values.toList();

  @override
  Future<ParsedTransaction?> getPendingTransactionById(String tempId) async =>
      _store[tempId];

  @override
  Stream<List<ParsedTransaction>> watchPendingTransactions() =>
      Stream.value(_store.values.toList());
}

void main() {
  group('IngestionService Pipeline Tests', () {
    late IngestionService service;
    late InMemoryTransactionRepository txRepo;
    late InMemoryPendingTransactionRepository pendingRepo;

    final now = DateTime.now();
    final defaultAcc = Account(
      id: 'acc_1',
      name: 'Main Account',
      type: AccountType.bank,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() {
      txRepo = InMemoryTransactionRepository();
      pendingRepo = InMemoryPendingTransactionRepository();
      service = IngestionService(
        transactionRepository: txRepo,
        pendingTransactionRepository: pendingRepo,
      );
    });

    test(
      'CSV parsing through IngestionService builds review session and categories',
      () async {
        const csv = '''Date,Narration,Withdrawal Amt.,Deposit Amt.
15/08/2026,UPI-SWIGGY-BANGALORE,450.00,
16/08/2026,SALARY CREDIT,,85000.00
''';

        final session = await service.processCsv(
          csvContent: csv,
          sourceFileName: 'statement.csv',
          defaultAccountId: defaultAcc.id,
        );

        expect(session.items.length, equals(2));
        expect(session.newCount, equals(2));
        expect(session.items[0].normalizedMerchant, equals('Swiggy'));
        expect(session.items[0].categoryName, equals('Dining'));
        expect(session.items[1].type, equals(TransactionType.income));
      },
    );

    test(
      'Committing review session writes to TransactionRepository and supports undo',
      () async {
        const csv = '''Date,Narration,Withdrawal Amt.
15/08/2026,SWIGGY,450.00
16/08/2026,UBER RIDE,320.00
''';

        final session = await service.processCsv(
          csvContent: csv,
          sourceFileName: 'statement.csv',
          defaultAccountId: defaultAcc.id,
        );

        final committedIds = await service.commitSession(session);
        expect(committedIds.length, equals(2));

        final allCommitted = await txRepo.getAllTransactions();
        expect(allCommitted.length, equals(2));
        expect(allCommitted.any((t) => t.merchant == 'Swiggy'), isTrue);
        expect(allCommitted.any((t) => t.merchant == 'Uber'), isTrue);

        // Test Undo
        await service.undoImport(committedIds);
        final afterUndo = await txRepo.getAllTransactions();
        expect(afterUndo.isEmpty, isTrue);
      },
    );

    test(
      'Ingestion stages unconfirmed incoming SMS in PendingReview queue without touching committed repository',
      () async {
        const smsBody =
            'Sent Rs.430.00 from HDFC Bank A/C **1234 to SWIGGY on 15-AUG-26. Ref 622819283921.';

        final pending = await service.processSms(
          sender: 'HDFCBK',
          body: smsBody,
          timestamp: now,
          defaultAccountId: defaultAcc.id,
        );

        expect(pending, isNotNull);

        // Committed repository must remain 0 (zero balance pollution!)
        final committed = await txRepo.getAllTransactions();
        expect(committed.isEmpty, isTrue);

        // Pending repository has 1 item
        final pendingList = await pendingRepo.getPendingTransactions();
        expect(pendingList.length, equals(1));
        expect(pendingList.first.normalizedMerchant, equals('Swiggy'));
      },
    );

    test('high-confidence realtime SMS is committed automatically', () async {
      final result = await service.ingestSms(
        sender: 'HDFCBK',
        body:
            'HDFC Bank: Rs 1500.00 debited from a/c **4321 on 22-AUG-26 to SWIGGY. UPI Ref 42352345.',
        timestamp: DateTime(2026, 8, 22, 12),
        sourceIdentifier: 'sms-1',
        defaultAccountId: defaultAcc.id,
      );

      expect(result.disposition, IngestionDisposition.committed);
      expect(await txRepo.getAllTransactions(), hasLength(1));
      expect(await pendingRepo.getPendingTransactions(), isEmpty);
    });

    test('uncertain realtime SMS is routed to Needs Review', () async {
      final result = await service.ingestSms(
        sender: 'HDFCBK',
        body:
            'HDFC Bank: Rs 999.00 debited from a/c **4321 on 22-AUG-26. Ref 111222.',
        timestamp: DateTime(2026, 8, 22, 12),
        sourceIdentifier: 'sms-uncertain',
        defaultAccountId: defaultAcc.id,
      );

      expect(result.disposition, IngestionDisposition.pending);
      expect(await txRepo.getAllTransactions(), isEmpty);
      expect(await pendingRepo.getPendingTransactions(), hasLength(1));
    });

    test('cross-source duplicate is not automatically committed twice', () async {
      await service.ingestSms(
        sender: 'HDFCBK',
        body:
            'HDFC Bank: Rs 325.00 debited from a/c **4321 on 22-AUG-26 to UBER. UPI Ref 42352345.',
        timestamp: DateTime(2026, 8, 22, 12),
        sourceIdentifier: 'sms-original',
        defaultAccountId: defaultAcc.id,
      );

      final notification = await service.ingestNotification(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Google Pay',
        text: 'Paid ₹325 to Uber successfully',
        timestamp: DateTime(2026, 8, 22, 12, 1),
        sourceIdentifier: 'notification-copy',
        defaultAccountId: defaultAcc.id,
      );

      expect(notification.disposition, IngestionDisposition.duplicate);
      expect(await txRepo.getAllTransactions(), hasLength(1));
      expect(await pendingRepo.getPendingTransactions(), hasLength(1));
    });
  });
}
