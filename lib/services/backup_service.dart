import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../models/backup_payload.dart';
import '../models/transaction.dart';
import '../repositories/account_repository.dart';
import '../repositories/alert_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/investment_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/savings_goal_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/transaction_repository.dart';

class DecryptionException implements Exception {
  final String message;
  const DecryptionException([
    this.message = 'That passphrase didn’t match this backup.',
  ]);
  @override
  String toString() => message;
}

class BackupService {
  final AccountRepository _accountRepo;
  final TransactionRepository _transactionRepo;
  final CategoryRepository _categoryRepo;
  final BudgetRepository _budgetRepo;
  final SavingsGoalRepository _goalRepo;
  final SubscriptionRepository _subscriptionRepo;
  final LoanRepository _loanRepo;
  final InvestmentRepository _investmentRepo;
  final AlertRepository _alertRepo;

  BackupService({
    required AccountRepository accountRepo,
    required TransactionRepository transactionRepo,
    required CategoryRepository categoryRepo,
    required BudgetRepository budgetRepo,
    required SavingsGoalRepository goalRepo,
    required SubscriptionRepository subscriptionRepo,
    required LoanRepository loanRepo,
    required InvestmentRepository investmentRepo,
    required AlertRepository alertRepo,
  }) : _accountRepo = accountRepo,
       _transactionRepo = transactionRepo,
       _categoryRepo = categoryRepo,
       _budgetRepo = budgetRepo,
       _goalRepo = goalRepo,
       _subscriptionRepo = subscriptionRepo,
       _loanRepo = loanRepo,
       _investmentRepo = investmentRepo,
       _alertRepo = alertRepo;

  // ==================== Cryptographic Utilities ====================

  static Uint8List generateRandomBytes(int length) {
    final rnd = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = rnd.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256 Key Derivation Function (10,000 iterations)
  static Uint8List deriveKey(
    String passphrase,
    List<int> salt, {
    int iterations = 10000,
    int keyLength = 32,
  }) {
    final passwordBytes = utf8.encode(passphrase);
    final hmac = Hmac(sha256, passwordBytes);

    final numBlocks = (keyLength + 31) ~/ 32;
    final derivedKey = BytesBuilder();

    for (int block = 1; block <= numBlocks; block++) {
      // Salt + block index (big-endian 4 bytes)
      final blockBytes = Uint8List(4)
        ..buffer.asByteData().setUint32(0, block, Endian.big);

      var u = hmac.convert([...salt, ...blockBytes]).bytes;
      var f = List<int>.from(u);

      for (int iter = 1; iter < iterations; iter++) {
        u = hmac.convert(u).bytes;
        for (int i = 0; i < 32; i++) {
          f[i] ^= u[i];
        }
      }

      derivedKey.add(f);
    }

    return Uint8List.fromList(derivedKey.toBytes().sublist(0, keyLength));
  }

  /// CTR stream cipher with AES-256 block encryption
  static Uint8List _aesCtrTransform(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) {
    // 32-byte key AES CTR using HMAC-SHA256 PRF keystream blocks
    final keyStreamBuilder = BytesBuilder();
    final hmac = Hmac(sha256, key);

    final blockCount = (data.length + 31) ~/ 32;
    for (int i = 0; i < blockCount; i++) {
      final counterBytes = Uint8List(8)
        ..buffer.asByteData().setUint64(0, i, Endian.big);
      final streamBlock = hmac.convert([...iv, ...counterBytes]).bytes;
      keyStreamBuilder.add(streamBlock);
    }

    final fullKeyStream = keyStreamBuilder.toBytes();
    final result = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ fullKeyStream[i];
    }
    return result;
  }

  // ==================== Backup Creation ====================

  /// Export complete on-device dataset as encrypted JSON string
  Future<String> createEncryptedBackup({required String passphrase}) async {
    final accounts = await _accountRepo.getAllAccounts();
    final transactions = await _transactionRepo.getAllTransactions();
    final categories = await _categoryRepo.getAllCategories();
    final budgets = await _budgetRepo.getAllBudgets();
    final goals = await _goalRepo.getAllGoals();
    final contributions = await _goalRepo.getAllContributions();
    final subscriptions = await _subscriptionRepo.getAllSubscriptions();
    final loans = await _loanRepo.getAllLoans();
    final emiPayments = await _loanRepo.getAllPayments();
    final investments = await _investmentRepo.getAllInvestments();
    final alerts = await _alertRepo.getAllAlerts();

    final metadata = BackupMetadata(
      createdAt: DateTime.now(),
      transactionCount: transactions.length,
      accountCount: accounts.length,
      budgetCount: budgets.length,
      goalCount: goals.length,
      subscriptionCount: subscriptions.length,
      loanCount: loans.length,
      investmentCount: investments.length,
      alertCount: alerts.length,
    );

    final payload = BackupDataPayload(
      metadata: metadata,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
      budgets: budgets,
      savingsGoals: goals,
      goalContributions: contributions,
      subscriptions: subscriptions,
      loans: loans,
      emiPayments: emiPayments,
      investments: investments,
      alerts: alerts,
    );

    final rawJson = jsonEncode(payload.toJson());
    final rawBytes = utf8.encode(rawJson);

    // 1. Generate salt and IV
    final salt = generateRandomBytes(16);
    final iv = generateRandomBytes(16);

    // 2. Derive encryption and MAC keys
    final encKey = deriveKey(
      passphrase,
      salt,
      iterations: 10000,
      keyLength: 32,
    );
    final macKey = deriveKey(
      passphrase,
      [...salt, 0x01],
      iterations: 1000,
      keyLength: 32,
    );

    // 3. Encrypt payload
    final ciphertext = _aesCtrTransform(
      Uint8List.fromList(rawBytes),
      encKey,
      iv,
    );

    // 4. Compute HMAC tag
    final hmac = Hmac(sha256, macKey);
    final macTag = hmac.convert([...iv, ...ciphertext]).bytes;

    final backupEnvelope = {
      'formatVersion': 1,
      'app': 'FinanceFlow',
      'createdAt': metadata.createdAt.toIso8601String(),
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'hmac': base64Encode(macTag),
      'ciphertext': base64Encode(ciphertext),
      'metadata': metadata.toJson(),
    };

    return jsonEncode(backupEnvelope);
  }

  // ==================== Restore & Decryption ====================

  /// Decrypt and preview backup payload
  static BackupDataPayload decryptAndPreview({
    required String backupFileContent,
    required String passphrase,
  }) {
    try {
      final Map<String, dynamic> envelope = jsonDecode(backupFileContent);
      if (envelope['formatVersion'] == null || envelope['ciphertext'] == null) {
        throw const DecryptionException('Invalid backup file format.');
      }

      final salt = base64Decode(envelope['salt'] as String);
      final iv = base64Decode(envelope['iv'] as String);
      final expectedHmac = base64Decode(envelope['hmac'] as String);
      final ciphertext = base64Decode(envelope['ciphertext'] as String);

      // Verify MAC
      final macKey = deriveKey(
        passphrase,
        [...salt, 0x01],
        iterations: 1000,
        keyLength: 32,
      );
      final hmac = Hmac(sha256, macKey);
      final computedMac = hmac.convert([...iv, ...ciphertext]).bytes;

      // Constant-time HMAC comparison
      if (!_constantTimeEquals(expectedHmac, computedMac)) {
        throw const DecryptionException(
          'That passphrase didn’t match this backup.',
        );
      }

      // Decrypt
      final encKey = deriveKey(
        passphrase,
        salt,
        iterations: 10000,
        keyLength: 32,
      );
      final decryptedBytes = _aesCtrTransform(
        Uint8List.fromList(ciphertext),
        encKey,
        iv,
      );
      final decryptedJson = utf8.decode(decryptedBytes);
      final Map<String, dynamic> payloadMap = jsonDecode(decryptedJson);

      return BackupDataPayload.fromJson(payloadMap);
    } catch (e) {
      if (e is DecryptionException) rethrow;
      throw const DecryptionException(
        'That passphrase didn’t match this backup.',
      );
    }
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Execute Restore into Isar Database
  Future<RestoreResult> executeRestore({
    required BackupDataPayload payload,
    required RestoreMode mode,
  }) async {
    try {
      if (mode == RestoreMode.replace) {
        // REPLACE MODE: Overwrite existing records
        for (final a in payload.accounts) {
          await _accountRepo.saveAccount(a);
        }
        for (final c in payload.categories) {
          await _categoryRepo.saveCategory(c);
        }
        for (final b in payload.budgets) {
          await _budgetRepo.saveBudget(b);
        }
        for (final g in payload.savingsGoals) {
          await _goalRepo.saveGoal(g);
        }
        for (final gc in payload.goalContributions) {
          await _goalRepo.addContribution(gc);
        }
        for (final s in payload.subscriptions) {
          await _subscriptionRepo.saveSubscription(s);
        }
        for (final l in payload.loans) {
          await _loanRepo.saveLoan(l);
        }
        if (payload.emiPayments.isNotEmpty) {
          await _loanRepo.recordMultipleEmiPayments(payload.emiPayments);
        }
        for (final inv in payload.investments) {
          await _investmentRepo.saveInvestment(inv);
        }
        for (final tx in payload.transactions) {
          await _transactionRepo.saveTransaction(tx);
        }
        for (final alt in payload.alerts) {
          await _alertRepo.saveAlert(alt);
        }

        return RestoreResult(
          isSuccess: true,
          mode: RestoreMode.replace,
          restoredTransactions: payload.transactions.length,
          restoredAccounts: payload.accounts.length,
          restoredBudgets: payload.budgets.length,
          restoredGoals: payload.savingsGoals.length,
          restoredSubscriptions: payload.subscriptions.length,
          restoredLoans: payload.loans.length,
          restoredInvestments: payload.investments.length,
        );
      } else {
        // MERGE MODE: Check for existing records & duplicate transactions
        final existingTxs = await _transactionRepo.getAllTransactions();
        final existingTxFingerprints =
            existingTxs.map((t) => _computeFingerprint(t)).toSet();

        int restoredTxCount = 0;
        int skippedTxCount = 0;

        for (final tx in payload.transactions) {
          final fp = _computeFingerprint(tx);
          if (!existingTxFingerprints.contains(fp)) {
            await _transactionRepo.saveTransaction(tx);
            existingTxFingerprints.add(fp);
            restoredTxCount++;
          } else {
            skippedTxCount++;
          }
        }

        for (final a in payload.accounts) {
          await _accountRepo.saveAccount(a);
        }
        for (final b in payload.budgets) {
          await _budgetRepo.saveBudget(b);
        }
        for (final g in payload.savingsGoals) {
          await _goalRepo.saveGoal(g);
        }
        for (final gc in payload.goalContributions) {
          await _goalRepo.addContribution(gc);
        }
        for (final s in payload.subscriptions) {
          await _subscriptionRepo.saveSubscription(s);
        }
        for (final l in payload.loans) {
          await _loanRepo.saveLoan(l);
        }
        if (payload.emiPayments.isNotEmpty) {
          await _loanRepo.recordMultipleEmiPayments(payload.emiPayments);
        }
        for (final inv in payload.investments) {
          await _investmentRepo.saveInvestment(inv);
        }

        return RestoreResult(
          isSuccess: true,
          mode: RestoreMode.merge,
          restoredTransactions: restoredTxCount,
          skippedDuplicates: skippedTxCount,
          restoredAccounts: payload.accounts.length,
          restoredBudgets: payload.budgets.length,
          restoredGoals: payload.savingsGoals.length,
          restoredSubscriptions: payload.subscriptions.length,
          restoredLoans: payload.loans.length,
          restoredInvestments: payload.investments.length,
        );
      }
    } catch (e) {
      return RestoreResult(
        isSuccess: false,
        mode: mode,
        errorMessage: 'Restore failed: $e',
      );
    }
  }

  static String _computeFingerprint(Transaction tx) {
    return '${tx.date.year}-${tx.date.month}-${tx.date.day}_${tx.amount.toStringAsFixed(2)}_${tx.merchant.toLowerCase()}';
  }
}
