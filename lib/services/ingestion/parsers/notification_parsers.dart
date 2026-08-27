import '../../categorization_service.dart';
import '../../merchant_normalization_service.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import 'csv_parser.dart';
import 'counterparty_extractor.dart';

abstract class NotificationParser {
  String get sourceName;
  String get packageId;
  bool canParse(String packageName, String title, String text);
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  });
}

/// Google Pay Notification Parser
class GooglePayNotificationParser implements NotificationParser {
  @override
  String get sourceName => 'Google Pay';

  @override
  String get packageId => 'com.google.android.apps.nbu.paisa.user';

  @override
  bool canParse(String packageName, String title, String text) {
    if (packageName == packageId ||
        packageName.toLowerCase().contains('paisa') ||
        packageName.toLowerCase().contains('gpay')) {
      return true;
    }
    final combined = '$title $text'.toLowerCase();
    return combined.contains('google pay') || combined.contains('gpay');
  }

  @override
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    final fullText = '$title $text';
    final date = timestamp ?? DateTime.now();

    // 1. Check Expense / Paid Pattern: "Paid ₹500 to Swiggy", "You paid ₹1,200 to Starbucks", "Payment of ₹450 to Uber successful"
    final paidRegex = RegExp(
      r'(?:paid|payment of|payment to)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:to|for|at)\s+([^.\n]+?)(?:\s+(?:successful|using|via|ref|upi)|$)',
      caseSensitive: false,
    );
    final paidMatch = paidRegex.firstMatch(fullText);

    if (paidMatch != null) {
      final amount = CsvParser.parseAmountString(paidMatch.group(1)!);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.expense,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    // 2. Check Income / Received Pattern: "Received ₹2,000 from Rahul", "Rahul sent you ₹1,200", "₹500 received from Priya"
    final receivedRegex = RegExp(
      r'(?:received|credited with)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:from)?\s*([^.\n]+?)(?:\s+(?:using|via|ref|upi)|$)|(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+received from\s+([^.\n]+)|^([^.\n]+?)\s+sent you\s+(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );
    final recMatch = receivedRegex.firstMatch(fullText);

    if (recMatch != null) {
      final amtStr =
          recMatch.group(1) ?? recMatch.group(3) ?? recMatch.group(6) ?? '0';
      var payeeStr =
          (recMatch.group(2) ??
                  recMatch.group(4) ??
                  recMatch.group(5) ??
                  'Payer')
              .trim();
      if (payeeStr.toLowerCase().startsWith('google pay')) {
        payeeStr = payeeStr.substring('google pay'.length).trim();
      }
      final amount = CsvParser.parseAmountString(amtStr);
      final rawMerchant =
          CounterpartyExtractor.validate(payeeStr) ??
          CounterpartyExtractor.unknown;
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.income,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    return null;
  }
}

/// PhonePe Notification Parser
class PhonePeNotificationParser implements NotificationParser {
  @override
  String get sourceName => 'PhonePe';

  @override
  String get packageId => 'com.phonepe.app';

  @override
  bool canParse(String packageName, String title, String text) {
    if (packageName == packageId ||
        packageName.toLowerCase().contains('phonepe')) {
      return true;
    }
    final combined = '$title $text'.toLowerCase();
    return combined.contains('phonepe');
  }

  @override
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    final fullText = '$title $text';
    final date = timestamp ?? DateTime.now();

    // Pattern: "Paid ₹350 to Dominos Pizza", "Paid ₹890 to Zomato", "Payment of ₹420 to Swiggy successful"
    final paidRegex = RegExp(
      r'(?:paid|payment of|payment to)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:to|at|for)\s+([^.\n]+?)(?:\s+(?:successfully|successful|done|via|using)|$)',
      caseSensitive: false,
    );
    final paidMatch = paidRegex.firstMatch(fullText);

    if (paidMatch != null) {
      final amount = CsvParser.parseAmountString(paidMatch.group(1)!);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.expense,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    // Income pattern: "Received ₹1,500 from John"
    final recRegex = RegExp(
      r'(?:received|credited)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+from\s+([^.\n]+)',
      caseSensitive: false,
    );
    final recMatch = recRegex.firstMatch(fullText);
    if (recMatch != null) {
      final amount = CsvParser.parseAmountString(recMatch.group(1)!);
      final rawMerchant = recMatch.group(2)!.trim();
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.income,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    return null;
  }
}

/// Paytm Notification Parser
class PaytmNotificationParser implements NotificationParser {
  @override
  String get sourceName => 'Paytm';

  @override
  String get packageId => 'net.one97.paytm';

  @override
  bool canParse(String packageName, String title, String text) {
    if (packageName == packageId ||
        packageName.toLowerCase().contains('paytm')) {
      return true;
    }
    final combined = '$title $text'.toLowerCase();
    return combined.contains('paytm');
  }

  @override
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    final fullText = '$title $text';
    final date = timestamp ?? DateTime.now();

    // Pattern: "Paid ₹120 to Chai Point", "Paid ₹550 at Apollo Pharmacy successfully", "Money sent ₹500 to Amit"
    final paidRegex = RegExp(
      r'(?:paid|money sent|sent|payment of)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:to|at|for)\s+([^.\n]+?)(?:\s+(?:successfully|successful|via|using)|$)',
      caseSensitive: false,
    );
    final paidMatch = paidRegex.firstMatch(fullText);

    if (paidMatch != null) {
      final amount = CsvParser.parseAmountString(paidMatch.group(1)!);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.expense,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    // Pattern: "Money received ₹2,000 from Ravi", "Received ₹500 from Rohit"
    final recRegex = RegExp(
      r'(?:received|money received)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+from\s+([^.\n]+)',
      caseSensitive: false,
    );
    final recMatch = recRegex.firstMatch(fullText);

    if (recMatch != null) {
      final amount = CsvParser.parseAmountString(recMatch.group(1)!);
      final rawMerchant = recMatch.group(2)!.trim();
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.income,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    return null;
  }
}

/// CRED Notification Parser
class CredNotificationParser implements NotificationParser {
  @override
  String get sourceName => 'CRED';

  @override
  String get packageId => 'com.dreamplug.androidapp';

  @override
  bool canParse(String packageName, String title, String text) {
    if (packageName == packageId ||
        packageName.toLowerCase().contains('dreamplug') ||
        packageName.toLowerCase().contains('cred')) {
      return true;
    }
    final combined = '$title $text'.toLowerCase();
    return combined.contains('cred');
  }

  @override
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    final fullText = '$title $text';
    final date = timestamp ?? DateTime.now();

    // Pattern: "₹1,450 paid to Swiggy using CRED pay", "Paid ₹8,500 towards HDFC Credit Card"
    final paidRegex = RegExp(
      r'(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+paid (?:to|towards)\s+([^.\n]+)',
      caseSensitive: false,
    );
    final paidMatch = paidRegex.firstMatch(fullText);

    if (paidMatch != null) {
      final amount = CsvParser.parseAmountString(paidMatch.group(1)!);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.expense,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    return null;
  }
}

/// Generic Banking & Financial Notification Parser
class GenericBankNotificationParser implements NotificationParser {
  @override
  String get sourceName => 'Bank Notification';

  @override
  String get packageId => 'generic.banking';

  @override
  bool canParse(String packageName, String title, String text) {
    final combined = '$title $text'.toLowerCase();
    return combined.contains('debited') ||
        combined.contains('credited') ||
        combined.contains('spent') ||
        combined.contains('txn') ||
        combined.contains('transaction') ||
        combined.contains('withdrawn') ||
        combined.contains('upi');
  }

  @override
  ParsedTransaction? parse({
    required String packageName,
    required String title,
    required String text,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    final fullText = '$title $text';
    final date = timestamp ?? DateTime.now();

    // 1. Debit pattern: "debited with ₹1,200", "spent ₹450 at Swiggy", "₹500 debited from A/c"
    final debitRegex = RegExp(
      r'(?:debited (?:with|by|for)?|spent|withdrawn)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)|(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+(?:debited|spent|withdrawn)',
      caseSensitive: false,
    );
    final debitMatch = debitRegex.firstMatch(fullText);

    if (debitMatch != null) {
      final amtStr = debitMatch.group(1) ?? debitMatch.group(2) ?? '0';
      final amount = CsvParser.parseAmountString(amtStr);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: _detectBankName(fullText) ?? sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.expense,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    // 2. Credit pattern: "credited with ₹5,000", "₹10,000 credited to A/c"
    final creditRegex = RegExp(
      r'(?:credited (?:with|by|for)?|received|deposited)\s*(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)|(?:₹|rs\.?|inr)?\s*([\d,]+(?:\.\d{1,2})?)\s+(?:credited|received|deposited)',
      caseSensitive: false,
    );
    final creditMatch = creditRegex.firstMatch(fullText);

    if (creditMatch != null) {
      final amtStr = creditMatch.group(1) ?? creditMatch.group(2) ?? '0';
      final amount = CsvParser.parseAmountString(amtStr);
      final rawMerchant = CounterpartyExtractor.extract(fullText);
      final normalizedMerchant = MerchantNormalizationService.normalize(
        rawMerchant,
      );
      final refNo = _extractUpiRef(fullText);

      return _createParsedTx(
        sourceName: _detectBankName(fullText) ?? sourceName,
        rawSource: fullText,
        amount: amount,
        type: TransactionType.income,
        rawMerchant: rawMerchant,
        normalizedMerchant: normalizedMerchant,
        date: date,
        defaultAccountId: defaultAccountId,
        referenceNumber: refNo,
      );
    }

    return null;
  }

  String? _detectBankName(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('hdfc')) return 'HDFC Bank';
    if (lower.contains('icici')) return 'ICICI Bank';
    if (lower.contains('sbi') || lower.contains('state bank')) return 'SBI';
    if (lower.contains('axis')) return 'Axis Bank';
    if (lower.contains('federal')) return 'Federal Bank';
    if (lower.contains('kotak')) return 'Kotak Bank';
    if (lower.contains('canara')) return 'Canara Bank';
    if (lower.contains('union bank') || lower.contains('ubi')) {
      return 'Union Bank';
    }
    return null;
  }
}

// Helpers
String? _extractUpiRef(String text) {
  final match = RegExp(
    r'(?:upi ref|ref no|rrn|utr|txn id|ref)[\s:]*([A-Za-z0-9]+)',
    caseSensitive: false,
  ).firstMatch(text);
  return CounterpartyExtractor.structuredReference(text) ?? match?.group(1);
}

ParsedTransaction _createParsedTx({
  required String sourceName,
  required String rawSource,
  required double amount,
  required TransactionType type,
  required String rawMerchant,
  required String normalizedMerchant,
  required DateTime date,
  required String defaultAccountId,
  String? referenceNumber,
}) {
  final suggestion = CategorizationService.suggestCategory(rawMerchant);
  final categoryId =
      suggestion?.categoryId ??
      (type == TransactionType.income ? 'cat_salary' : 'cat_miscellaneous');
  final categoryName =
      suggestion?.categoryName ??
      (type == TransactionType.income ? 'Salary' : 'Miscellaneous');
  final categoryIcon =
      suggestion?.categoryIcon ??
      (type == TransactionType.income ? 'payments' : 'more_horiz');
  final categoryColor = suggestion?.categoryColor ?? 'clay';
  final catConfidence =
      suggestion?.confidence ?? (type == TransactionType.income ? 0.7 : 0.4);
  final catReason = suggestion?.reason ?? 'Notification heuristic';

  final dateKey =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final amtKey = amount.toStringAsFixed(2);
  final merchKey = normalizedMerchant.toLowerCase().replaceAll(
    RegExp(r'\s+'),
    '_',
  );
  final refKey = referenceNumber?.toLowerCase() ?? 'noref';
  final fingerprint = '$dateKey|$amtKey|$merchKey|${type.toDbString()}|$refKey';

  final validationErrors = <String>[];
  if (amount <= 0) {
    validationErrors.add('Could not extract positive transaction amount');
  }

  return ParsedTransaction(
    source: TransactionSource.notification,
    sourceName: sourceName,
    rawSource: rawSource,
    amount: amount,
    type: type,
    rawMerchant: rawMerchant,
    normalizedMerchant: normalizedMerchant,
    date: date,
    time: date,
    accountId: defaultAccountId,
    paymentMethod: 'UPI / Notification',
    categoryId: categoryId,
    categoryName: categoryName,
    categoryIcon: categoryIcon,
    categoryColor: categoryColor,
    categorizationConfidence: catConfidence,
    categorizationReason: catReason,
    referenceNumber: referenceNumber,
    fingerprint: fingerprint,
    warnings:
        rawMerchant == CounterpartyExtractor.unknown
            ? const ['Could not clearly identify payee from notification']
            : const [],
    validationErrors: validationErrors,
    isIncluded: validationErrors.isEmpty,
    reviewStatus:
        validationErrors.isEmpty &&
                rawMerchant != CounterpartyExtractor.unknown &&
                catConfidence >= 0.7
            ? ReviewStatus.confirmed
            : ReviewStatus.pending,
  );
}
