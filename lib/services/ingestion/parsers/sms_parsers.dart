import '../../categorization_service.dart';
import '../../merchant_normalization_service.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import 'csv_parser.dart';

abstract class SmsParser {
  String get bankName;
  bool canParse(String sender, String body);
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  });
}

/// HDFC Bank SMS Parser
/// Example: "HDFC Bank: Rs 1500.00 debited from a/c **4321 on 22-AUG-26 to SWIGGY. UPI: 42352345. Bal: Rs 12345"
class HdfcSmsParser implements SmsParser {
  @override
  String get bankName => 'HDFC Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('HDFC') || b.contains('hdfc bank') || b.contains('hdfc');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// ICICI Bank SMS Parser
/// Example: "Dear Customer, Acct XX123 debited with INR 450.00 on 22-Aug-26. Info: UPI/SWIGGY/423524. Avl Bal: INR 5000"
class IciciSmsParser implements SmsParser {
  @override
  String get bankName => 'ICICI Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('ICICI') || b.contains('icici bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// SBI (State Bank of India) SMS Parser
/// Example: "Dear SBI User, your A/C X1234 debited by Rs 2,500.00 on 22Aug26 transfer to Amazon ref no 34567"
class SbiSmsParser implements SmsParser {
  @override
  String get bankName => 'State Bank of India';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('SBI') || b.contains('sbi') || b.contains('state bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Axis Bank SMS Parser
class AxisSmsParser implements SmsParser {
  @override
  String get bankName => 'Axis Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('AXIS') || b.contains('axis bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Federal Bank SMS Parser
class FederalSmsParser implements SmsParser {
  @override
  String get bankName => 'Federal Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('FED') || b.contains('federal bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Canara Bank SMS Parser
class CanaraSmsParser implements SmsParser {
  @override
  String get bankName => 'Canara Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('CAN') || b.contains('canara bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Union Bank SMS Parser
class UnionBankSmsParser implements SmsParser {
  @override
  String get bankName => 'Union Bank';

  @override
  bool canParse(String sender, String body) {
    final s = sender.toUpperCase();
    final b = body.toLowerCase();
    return s.contains('UNION') || s.contains('UBI') || b.contains('union bank');
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Generic UPI & Bank SMS Parser
class GenericUpiSmsParser implements SmsParser {
  @override
  String get bankName => 'Bank SMS';

  @override
  bool canParse(String sender, String body) {
    final lower = body.toLowerCase();
    return (lower.contains('debited') ||
            lower.contains('credited') ||
            lower.contains('spent') ||
            lower.contains('sent') ||
            lower.contains('received')) &&
        (lower.contains('rs') ||
            lower.contains('inr') ||
            lower.contains('₹') ||
            lower.contains('a/c') ||
            lower.contains('acct') ||
            lower.contains('upi'));
  }

  @override
  ParsedTransaction? parse({
    required String sender,
    required String body,
    DateTime? timestamp,
    String defaultAccountId = 'acc_primary_cash',
  }) {
    return _parseIndianBankSms(
      bankName: bankName,
      sender: sender,
      body: body,
      timestamp: timestamp,
      defaultAccountId: defaultAccountId,
    );
  }
}

/// Shared resilient parser for Indian transaction SMS patterns
ParsedTransaction? _parseIndianBankSms({
  required String bankName,
  required String sender,
  required String body,
  DateTime? timestamp,
  required String defaultAccountId,
}) {
  final lower = body.toLowerCase();

  // Filter non-transactional messages (e.g. OTP, login alerts, balance enquiry only without debit/credit)
  if (lower.contains('otp') ||
      lower.contains('one time password') ||
      lower.contains('verification code')) {
    return null;
  }

  final isDebit =
      lower.contains('debited') ||
      lower.contains('spent') ||
      lower.contains('sent') ||
      lower.contains('paid') ||
      lower.contains('withdrawn') ||
      lower.contains('purchase');
  final isCredit =
      lower.contains('credited') ||
      lower.contains('received') ||
      lower.contains('deposited') ||
      lower.contains('refunded');

  if (!isDebit && !isCredit) {
    return null;
  }

  final type = isDebit ? TransactionType.expense : TransactionType.income;

  // Extract Amount: e.g. "Rs. 1,450.00", "INR 500", "₹ 2,000", "Rs 450"
  final amtRegex = RegExp(
    r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  final amtMatch = amtRegex.firstMatch(body);
  if (amtMatch == null) return null;

  final amount = CsvParser.parseAmountString(amtMatch.group(1)!);
  if (amount <= 0) return null;

  // Extract Account Suffix: "A/c **1234", "Acct XX5678", "Card **9999"
  final accMatch = RegExp(
    r'(?:a/c|acct|account|card)[\s\w]*?([xX*]*\d{3,4})\b',
  ).firstMatch(body);
  final accSuffix = accMatch?.group(1);

  // Extract Merchant / Counterparty
  final rawMerchant = _extractSmsMerchant(body, isDebit);
  final normalizedMerchant = MerchantNormalizationService.normalize(
    rawMerchant,
  );

  // Extract Reference / UTR
  final refMatch = RegExp(
    r'(?:upi\s*ref|ref\s*no|rrn|utr|txn\s*id|ref)[\s:]*([A-Za-z0-9]+)',
    caseSensitive: false,
  ).firstMatch(body);
  final refNo = refMatch?.group(1);

  // Date Parsing from SMS or fallback to timestamp
  DateTime date = timestamp ?? DateTime.now();
  final dateMatch = RegExp(
    r'\b(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\d{1,2}[- ]?[A-Za-z]{3}[- ]?\d{2,4})\b',
  ).firstMatch(body);
  if (dateMatch != null) {
    final parsedDate = CsvParser.parseDateString(dateMatch.group(1)!);
    if (parsedDate != null) {
      date = parsedDate;
    }
  }

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
  final catReason = suggestion?.reason ?? 'SMS pattern match';

  final dateKey =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final amtKey = amount.toStringAsFixed(2);
  final merchKey = normalizedMerchant.toLowerCase().replaceAll(
    RegExp(r'\s+'),
    '_',
  );
  final refKey = refNo?.toLowerCase() ?? (accSuffix ?? 'noref');
  final fingerprint = '$dateKey|$amtKey|$merchKey|${type.toDbString()}|$refKey';

  final warnings = <String>[];
  if (rawMerchant == 'Bank Transaction') {
    warnings.add('Could not clearly identify payee from SMS');
  }

  return ParsedTransaction(
    source: TransactionSource.sms,
    sourceName: bankName,
    rawSource: body,
    sourceIdentifier: sender,
    amount: amount,
    type: type,
    rawMerchant: rawMerchant,
    normalizedMerchant: normalizedMerchant,
    date: date,
    time: date,
    accountId: defaultAccountId,
    paymentMethod: 'Bank / SMS',
    categoryId: categoryId,
    categoryName: categoryName,
    categoryIcon: categoryIcon,
    categoryColor: categoryColor,
    categorizationConfidence: catConfidence,
    categorizationReason: catReason,
    referenceNumber: refNo,
    fingerprint: fingerprint,
    warnings: warnings,
    validationErrors: const [],
    isIncluded: true,
    reviewStatus:
        warnings.isEmpty && catConfidence >= 0.7
            ? ReviewStatus.confirmed
            : ReviewStatus.pending,
  );
}

String _extractSmsMerchant(String body, bool isDebit) {
  // Try pattern 1: "to VPA/Swiggy", "to Swiggy", "at Amazon", "towards Electricity"
  final atToMatch = RegExp(
    r'(?:to|at|towards|for|info:?|vpa)\s+([A-Za-z0-9\s&_.-]+?)(?:\s+(?:on|using|via|ref|upi|avl|bal|not you|if not)|[.\n]|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (atToMatch != null) {
    final candidate = atToMatch.group(1)!.trim();
    if (candidate.isNotEmpty &&
        !candidate.toLowerCase().startsWith('a/c') &&
        !candidate.toLowerCase().startsWith('rs')) {
      return candidate;
    }
  }

  // Try pattern 2: "from Rahul", "by Transfer from Ramesh"
  final fromMatch = RegExp(
    r'(?:from|by)\s+([A-Za-z0-9\s&_.-]+?)(?:\s+(?:on|using|via|ref|upi|avl|bal)|[.\n]|$)',
    caseSensitive: false,
  ).firstMatch(body);
  if (fromMatch != null) {
    final candidate = fromMatch.group(1)!.trim();
    if (candidate.isNotEmpty &&
        !candidate.toLowerCase().startsWith('a/c') &&
        !candidate.toLowerCase().startsWith('rs')) {
      return candidate;
    }
  }

  return 'Bank Transaction';
}
