import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../repositories/transaction_repository.dart';
import 'duplicate_matcher.dart';
import 'parsers/csv_column_mapper.dart';
import 'parsers/csv_parser.dart';
import 'parsers/notification_parser_registry.dart';
import 'parsers/sms_parser_registry.dart';
import 'transaction_merge_service.dart';

class IngestionService {
  final TransactionRepository _transactionRepository;
  final PendingTransactionRepository _pendingTransactionRepository;
  final NotificationParserRegistry _notificationRegistry;
  final SmsParserRegistry _smsRegistry;

  IngestionService({
    required TransactionRepository transactionRepository,
    required PendingTransactionRepository pendingTransactionRepository,
    NotificationParserRegistry? notificationRegistry,
    SmsParserRegistry? smsRegistry,
  }) : _transactionRepository = transactionRepository,
       _pendingTransactionRepository = pendingTransactionRepository,
       _notificationRegistry =
           notificationRegistry ?? NotificationParserRegistry(),
       _smsRegistry = smsRegistry ?? SmsParserRegistry();

  /// Process CSV content, identify duplicates against existing database, and return a staged review session
  Future<ImportReviewSession> processCsv({
    required String csvContent,
    String? sourceFileName,
    CsvColumnMapping? customMapping,
    String defaultAccountId = 'acc_primary_cash',
  }) async {
    // 1. Parse CSV rows
    final result = CsvParser.parse(
      csvContent,
      customMapping: customMapping,
      defaultAccountId: defaultAccountId,
      sourceFileName: sourceFileName,
    );

    // 2. Fetch all existing transactions for duplicate detection
    final existingTransactions =
        await _transactionRepository.getAllTransactions();

    // 3. Match each row against existing transactions
    final evaluatedItems = <ParsedTransaction>[];
    for (final item in result.parsedTransactions) {
      final duplicateMatch = DuplicateMatcher.findDuplicate(
        incoming: item,
        existingTransactions: existingTransactions,
      );

      evaluatedItems.add(
        item.copyWith(
          duplicateStatus: duplicateMatch.level,
          matchedTransactionId: duplicateMatch.matchedTransaction?.id,
          matchedTransaction: duplicateMatch.matchedTransaction,
          duplicateReasons: duplicateMatch.reasons,
          duplicateConfidence: duplicateMatch.confidence,
          duplicateResolution: duplicateMatch.recommendedAction,
        ),
      );
    }

    return ImportReviewSession(
      sourceName: sourceFileName ?? 'CSV Statement',
      source: TransactionSource.csv,
      items: evaluatedItems,
    );
  }

  /// Process an incoming notification on-device
  Future<ParsedTransaction?> processNotification({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
    bool autoStagePending = true,
    String? sourceIdentifier,
  }) async {
    final parsed = _notificationRegistry.parse(
      packageName: packageName,
      title: title,
      text: text,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );

    if (parsed == null) return null;

    // Check duplicate
    final existingTransactions =
        await _transactionRepository.getAllTransactions();
    final duplicateMatch = DuplicateMatcher.findDuplicate(
      incoming: parsed,
      existingTransactions: existingTransactions,
    );

    final resolved = parsed.copyWith(
      sourceIdentifier: sourceIdentifier,
      duplicateStatus: duplicateMatch.level,
      matchedTransactionId: duplicateMatch.matchedTransaction?.id,
      matchedTransaction: duplicateMatch.matchedTransaction,
      duplicateReasons: duplicateMatch.reasons,
      duplicateConfidence: duplicateMatch.confidence,
      duplicateResolution: duplicateMatch.recommendedAction,
    );

    if (autoStagePending) {
      await _pendingTransactionRepository.savePendingTransaction(resolved);
    }

    return resolved;
  }

  /// Process an incoming SMS on-device
  Future<ParsedTransaction?> processSms({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
    bool autoStagePending = true,
    String? sourceIdentifier,
  }) async {
    final parsed = _smsRegistry.parse(
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );

    if (parsed == null) return null;

    // Check duplicate
    final existingTransactions =
        await _transactionRepository.getAllTransactions();
    final duplicateMatch = DuplicateMatcher.findDuplicate(
      incoming: parsed,
      existingTransactions: existingTransactions,
    );

    final resolved = parsed.copyWith(
      sourceIdentifier: sourceIdentifier,
      duplicateStatus: duplicateMatch.level,
      matchedTransactionId: duplicateMatch.matchedTransaction?.id,
      matchedTransaction: duplicateMatch.matchedTransaction,
      duplicateReasons: duplicateMatch.reasons,
      duplicateConfidence: duplicateMatch.confidence,
      duplicateResolution: duplicateMatch.recommendedAction,
    );

    if (autoStagePending) {
      await _pendingTransactionRepository.savePendingTransaction(resolved);
    }

    return resolved;
  }

  /// Product policy for real-time sources: trustworthy new transactions are
  /// committed immediately; uncertain and duplicate items remain reviewable.
  Future<IngestionResult> ingestSms({
    required String sender,
    required String body,
    DateTime? timestamp,
    String? sourceIdentifier,
    String defaultAccountId = 'acc_primary_cash',
  }) async {
    final parsed = await processSms(
      sender: sender,
      body: body,
      timestamp: timestamp,
      sourceIdentifier: sourceIdentifier,
      defaultAccountId: defaultAccountId,
      autoStagePending: false,
    );
    return _persistRealtime(
      parsed ??
          _unparsedRealtimeCandidate(
            source: TransactionSource.sms,
            sourceName: 'Bank SMS',
            rawContent: body,
            timestamp: timestamp,
            sourceIdentifier: sourceIdentifier,
            defaultAccountId: defaultAccountId,
          ),
    );
  }

  Future<IngestionResult> ingestNotification({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String? sourceIdentifier,
    String defaultAccountId = 'acc_primary_cash',
  }) async {
    final parsed = await processNotification(
      packageName: packageName,
      title: title,
      text: text,
      timestamp: timestamp,
      sourceIdentifier: sourceIdentifier,
      defaultAccountId: defaultAccountId,
      autoStagePending: false,
    );
    return _persistRealtime(
      parsed ??
          _unparsedRealtimeCandidate(
            source: TransactionSource.notification,
            sourceName: packageName,
            rawContent: '$title $text',
            timestamp: timestamp,
            sourceIdentifier: sourceIdentifier,
            defaultAccountId: defaultAccountId,
          ),
    );
  }

  /// Native Android code has already removed OTP and promotional messages.
  /// This second check also protects callers such as the developer injector.
  /// A candidate that no parser understands is still saved locally for review,
  /// never silently acknowledged as a rejection.
  ParsedTransaction? _unparsedRealtimeCandidate({
    required TransactionSource source,
    required String sourceName,
    required String rawContent,
    required DateTime? timestamp,
    required String? sourceIdentifier,
    required String defaultAccountId,
  }) {
    final lower = rawContent.toLowerCase();
    const blocked = [
      'otp',
      'one time password',
      'verification code',
      'login code',
      'mpin',
      'cvv',
      'promo code',
      'offer',
      'pre-approved',
      'apply now',
      'cashback offer',
      'limited time offer',
      'discount',
      'sale',
    ];
    if (blocked.any(lower.contains)) return null;

    final hasAction = RegExp(
      r'\b(debited|debit|credited|credit|spent|paid|payment|sent|received|withdrawn|withdrawal|purchase|purchased|refunded|refund|deposited|used|txn|transaction|upi transfer|upi mandate|mandate|transferred)\b',
    ).hasMatch(lower);
    final money = RegExp(
      r'(?:rs\.?|inr|₹)\s*:?\s*([0-9][0-9,]*(?:\.\d{1,2})?)(?:/-)?',
      caseSensitive: false,
    ).firstMatch(rawContent);
    final labelledMoney = RegExp(
      r'(?:amount|amt)\s*(?:of|:)?\s*([0-9][0-9,]*(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(rawContent);
    final hasFinancialContext = RegExp(
      r'\b(upi|card|account|acct|bank|wallet|mandate|merchant|pos)\b',
      caseSensitive: false,
    ).hasMatch(rawContent);
    final amountText =
        money?.group(1) ??
        (hasFinancialContext ? labelledMoney?.group(1) : null);
    if (!hasAction || amountText == null) return null;

    final amount = double.tryParse(amountText.replaceAll(',', '')) ?? 0;
    final isCredit = RegExp(
      r'\b(credited|credit|received|deposited|refunded|refund)\b',
    ).hasMatch(lower);
    final type = isCredit ? TransactionType.income : TransactionType.expense;
    final date = timestamp ?? DateTime.now();
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final sourceKey =
        sourceIdentifier?.isNotEmpty == true ? sourceIdentifier! : sourceName;
    final errors = <String>[
      if (amount <= 0) 'Could not extract positive transaction amount',
    ];

    return ParsedTransaction(
      source: source,
      sourceName: sourceName,
      rawSource: rawContent,
      sourceIdentifier: sourceIdentifier,
      amount: amount,
      type: type,
      rawMerchant: 'Bank Transaction',
      normalizedMerchant: 'Bank Transaction',
      date: date,
      time: date,
      accountId: defaultAccountId,
      paymentMethod:
          source == TransactionSource.sms ? 'Bank / SMS' : 'UPI / Notification',
      categoryId: 'cat_miscellaneous',
      categoryName: 'Miscellaneous',
      categoryIcon: 'more_horiz',
      categoryColor: 'clay',
      categorizationConfidence: 0,
      categorizationReason: 'Candidate needs manual review',
      fingerprint:
          '$dateKey|${amount.toStringAsFixed(2)}|unparsed|${type.toDbString()}|$sourceKey',
      warnings: const [
        'Could not fully parse transaction details; review the local source.',
      ],
      validationErrors: errors,
      isIncluded: true,
      reviewStatus: ReviewStatus.pending,
    );
  }

  Future<IngestionResult> _persistRealtime(ParsedTransaction? parsed) async {
    if (parsed == null) {
      return const IngestionResult(IngestionDisposition.rejected);
    }

    final pending =
        await _pendingTransactionRepository.getPendingTransactions();
    final alreadyPending = pending.any(
      (item) =>
          (parsed.sourceIdentifier?.isNotEmpty == true &&
              item.sourceIdentifier == parsed.sourceIdentifier) ||
          item.fingerprint == parsed.fingerprint,
    );
    if (alreadyPending) {
      return IngestionResult(IngestionDisposition.duplicate, parsed: parsed);
    }

    final canAutoCommit =
        parsed.isValid &&
        !parsed.hasWarnings &&
        !parsed.isDuplicate &&
        parsed.reviewStatus == ReviewStatus.confirmed &&
        parsed.categorizationConfidence >= 0.7;
    if (canAutoCommit) {
      await _transactionRepository.saveTransaction(parsed.toTransaction());
      return IngestionResult(IngestionDisposition.committed, parsed: parsed);
    }

    await _pendingTransactionRepository.savePendingTransaction(parsed);
    return IngestionResult(
      parsed.isDuplicate
          ? IngestionDisposition.duplicate
          : IngestionDisposition.pending,
      parsed: parsed,
    );
  }

  /// Commit an ImportReviewSession to the database
  /// Returns the list of created and modified Transaction IDs for undo/audit
  Future<List<String>> commitSession(ImportReviewSession session) async {
    final toSave = <Transaction>[];
    final createdIds = <String>[];
    final pendingToRemove = <String>[];

    for (final item in session.items) {
      pendingToRemove.add(item.tempId);

      if (!item.isIncluded) {
        continue;
      }

      if (item.duplicateResolution == DuplicateResolution.merge &&
          item.matchedTransaction != null) {
        // Merge with existing transaction
        final mergedTx = TransactionMergeService.mergeWithExisting(
          existing: item.matchedTransaction!,
          incoming: item,
        );
        toSave.add(mergedTx);
        createdIds.add(mergedTx.id);
      } else if (item.duplicateResolution == DuplicateResolution.exclude ||
          item.duplicateResolution == DuplicateResolution.ignore) {
        // Excluded
        continue;
      } else if (item.isValid) {
        // Add as new transaction
        final newTx = item.toTransaction();
        toSave.add(newTx);
        createdIds.add(newTx.id);
      }
    }

    if (toSave.isNotEmpty) {
      await _transactionRepository.saveTransactions(toSave);
    }

    // Clean up from pending staging if any existed
    if (pendingToRemove.isNotEmpty) {
      await _pendingTransactionRepository.removePendingTransactions(
        pendingToRemove,
      );
    }

    return createdIds;
  }

  /// Revert an imported batch of transactions (Undo Import)
  Future<void> undoImport(List<String> transactionIds) async {
    if (transactionIds.isEmpty) return;
    await _transactionRepository.deleteTransactions(transactionIds);
  }
}

final ingestionServiceProvider = Provider<IngestionService>((ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  final pendingRepo = ref.watch(pendingTransactionRepositoryProvider);
  return IngestionService(
    transactionRepository: txRepo,
    pendingTransactionRepository: pendingRepo,
  );
});

enum IngestionDisposition { committed, pending, duplicate, rejected }

class IngestionResult {
  final IngestionDisposition disposition;
  final ParsedTransaction? parsed;

  const IngestionResult(this.disposition, {this.parsed});
}
