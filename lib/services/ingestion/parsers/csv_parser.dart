import 'package:intl/intl.dart';
import '../../categorization_service.dart';
import '../../merchant_normalization_service.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import 'csv_column_mapper.dart';

class CsvParserResult {
  final List<String> headers;
  final List<List<String>> rawRows;
  final CsvColumnMapping detectedMapping;
  final List<ParsedTransaction> parsedTransactions;
  final List<String> globalWarnings;

  const CsvParserResult({
    required this.headers,
    required this.rawRows,
    required this.detectedMapping,
    required this.parsedTransactions,
    this.globalWarnings = const [],
  });
}

class CsvParser {
  CsvParser._();

  /// Parse a CSV raw text string into a list of row tokens (handling quoted commas and escaped quotes)
  static List<List<String>> parseCsvToTable(String content) {
    if (content.trim().isEmpty) return [];

    // Strip UTF-8 BOM if present
    var sanitized = content;
    if (sanitized.startsWith('\uFEFF')) {
      sanitized = sanitized.substring(1);
    }

    final List<List<String>> rows = [];
    List<String> currentRow = [];
    final StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];

      if (char == '"') {
        if (inQuotes && i + 1 < sanitized.length && sanitized[i + 1] == '"') {
          // Escaped quote: "" -> "
          currentCell.write('"');
          i++; // Skip the next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        // Handle \r\n
        if (char == '\r' &&
            i + 1 < sanitized.length &&
            sanitized[i + 1] == '\n') {
          i++;
        }
        currentRow.add(currentCell.toString().trim());
        currentCell.clear();

        // Avoid adding empty blank rows
        if (currentRow.any((c) => c.isNotEmpty)) {
          rows.add(currentRow);
        }
        currentRow = [];
      } else {
        currentCell.write(char);
      }
    }

    // Add trailing cell/row if any
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString().trim());
      if (currentRow.any((c) => c.isNotEmpty)) {
        rows.add(currentRow);
      }
    }

    return rows;
  }

  /// Locate the header row index (skips bank metadata/disclaimer lines at top)
  static int findHeaderRowIndex(List<List<String>> table) {
    if (table.isEmpty) return -1;

    for (int r = 0; r < table.length; r++) {
      final row = table[r];
      final joined = row.join(' ').toLowerCase();

      // Check if row contains key financial headers
      final hasDate =
          joined.contains('date') ||
          joined.contains('txn date') ||
          joined.contains('value date');
      final hasAmount =
          joined.contains('amount') ||
          joined.contains('debit') ||
          joined.contains('credit') ||
          joined.contains('dr') ||
          joined.contains('cr') ||
          joined.contains('withdrawal');
      final hasDescription =
          joined.contains('particulars') ||
          joined.contains('narration') ||
          joined.contains('description') ||
          joined.contains('details') ||
          joined.contains('payee') ||
          joined.contains('merchant');

      if ((hasDate && hasAmount) ||
          (hasDate && hasDescription) ||
          (hasAmount && hasDescription)) {
        return r;
      }
    }

    return 0; // Fallback to first row
  }

  /// Parse the entire CSV table into domain ParsedTransactions
  static CsvParserResult parse(
    String content, {
    CsvColumnMapping? customMapping,
    String defaultAccountId = 'acc_primary_cash',
    String? sourceFileName,
  }) {
    final table = parseCsvToTable(content);
    if (table.isEmpty) {
      return CsvParserResult(
        headers: [],
        rawRows: [],
        detectedMapping: const CsvColumnMapping(),
        parsedTransactions: [],
        globalWarnings: ['CSV file is empty or could not be read.'],
      );
    }

    final headerIndex = findHeaderRowIndex(table);
    if (headerIndex < 0 || headerIndex >= table.length) {
      return CsvParserResult(
        headers: [],
        rawRows: table,
        detectedMapping: const CsvColumnMapping(),
        parsedTransactions: [],
        globalWarnings: ['No valid header row found in the CSV.'],
      );
    }

    final headers = table[headerIndex];
    final dataRows = table.sublist(headerIndex + 1);

    final mapping =
        customMapping ??
        CsvColumnMapper.autoDetect(
          headers,
          sampleRows: dataRows.take(5).toList(),
        );

    final List<ParsedTransaction> transactions = [];
    final List<String> globalWarnings = [];

    if (!mapping.hasDate) {
      globalWarnings.add('Date column could not be automatically mapped.');
    }
    if (!mapping.hasAmount) {
      globalWarnings.add(
        'Amount, Debit, or Credit column could not be automatically mapped.',
      );
    }

    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      final rowNumber = headerIndex + 2 + i;

      // Skip fully blank rows
      if (row.every((c) => c.isEmpty)) continue;

      final parsed = parseRow(
        row: row,
        rowNumber: rowNumber,
        mapping: mapping,
        headers: headers,
        defaultAccountId: defaultAccountId,
        sourceFileName: sourceFileName,
      );

      if (parsed != null) {
        transactions.add(parsed);
      }
    }

    return CsvParserResult(
      headers: headers,
      rawRows: dataRows,
      detectedMapping: mapping,
      parsedTransactions: transactions,
      globalWarnings: globalWarnings,
    );
  }

  /// Parse a single CSV row into a ParsedTransaction
  static ParsedTransaction? parseRow({
    required List<String> row,
    required int rowNumber,
    required CsvColumnMapping mapping,
    required List<String> headers,
    required String defaultAccountId,
    String? sourceFileName,
  }) {
    final warnings = <String>[];
    final validationErrors = <String>[];

    // Helper to safely get column by index
    String getCol(int? index) {
      if (index == null || index < 0 || index >= row.length) return '';
      return row[index].trim();
    }

    // 1. Date & Time Parsing
    DateTime? parsedDate;
    final dateStr = getCol(mapping.dateIndex);
    final timeStr = getCol(mapping.timeIndex);

    if (dateStr.isNotEmpty) {
      parsedDate = parseDateString(dateStr);
    }

    if (parsedDate == null) {
      parsedDate = DateTime.now();
      validationErrors.add(
        'Row $rowNumber: Invalid or missing date ("$dateStr")',
      );
    }

    // If separate time exists, combine with date
    DateTime? parsedTime;
    if (timeStr.isNotEmpty) {
      parsedTime = parseTimeString(timeStr, baseDate: parsedDate);
      if (parsedTime != null) {
        parsedDate = parsedTime;
      }
    }

    // 2. Amount & Transaction Type Parsing
    double amount = 0.0;
    TransactionType type = TransactionType.expense;

    final debitStr = getCol(mapping.debitIndex);
    final creditStr = getCol(mapping.creditIndex);
    final amountStr = getCol(mapping.amountIndex);
    final typeStr = getCol(mapping.typeIndex);

    if (debitStr.isNotEmpty && creditStr.isNotEmpty) {
      // Both columns exist on this row (rare or invalid, pick non-zero)
      final debitVal = parseAmountString(debitStr);
      final creditVal = parseAmountString(creditStr);

      if (debitVal > 0) {
        amount = debitVal;
        type = TransactionType.expense;
      } else if (creditVal > 0) {
        amount = creditVal;
        type = TransactionType.income;
      }
    } else if (debitStr.isNotEmpty) {
      final val = parseAmountString(debitStr);
      if (val > 0) {
        amount = val;
        type = TransactionType.expense;
      }
    } else if (creditStr.isNotEmpty) {
      final val = parseAmountString(creditStr);
      if (val > 0) {
        amount = val;
        type = TransactionType.income;
      }
    } else if (amountStr.isNotEmpty) {
      final (parsedAmt, isCredit, hasExplicitSign) = parseSingleAmount(
        amountStr,
      );
      amount = parsedAmt;

      if (hasExplicitSign) {
        type = isCredit ? TransactionType.income : TransactionType.expense;
      } else if (typeStr.isNotEmpty) {
        final tLower = typeStr.toLowerCase();
        if (tLower.contains('cr') ||
            tLower.contains('credit') ||
            tLower.contains('deposit') ||
            tLower.contains('income')) {
          type = TransactionType.income;
        } else {
          type = TransactionType.expense;
        }
      } else {
        // Default to expense if ambiguous
        type = TransactionType.expense;
        warnings.add(
          'Direction assumed as expense for amount ${amount.toStringAsFixed(2)}',
        );
      }
    }

    if (amount <= 0) {
      validationErrors.add('Row $rowNumber: Non-positive or unreadable amount');
    }

    // 3. Merchant & Narration Parsing
    final rawMerchantStr = getCol(mapping.merchantIndex);
    if (rawMerchantStr.isEmpty) {
      validationErrors.add('Row $rowNumber: Missing payee or description');
    }
    final rawMerchant =
        rawMerchantStr.isNotEmpty
            ? rawMerchantStr
            : 'Unknown Payee (Row $rowNumber)';
    final normalizedMerchant = MerchantNormalizationService.normalize(
      rawMerchant,
    );

    // 4. Notes, Reference & Payment Method
    final notes = getCol(mapping.notesIndex);
    final refNo = getCol(mapping.referenceIndex);
    final paymentMethod = getCol(mapping.paymentMethodIndex);
    final customAccount = getCol(mapping.accountIndex);
    final accountId =
        customAccount.isNotEmpty ? customAccount : defaultAccountId;

    // 5. Categorization Suggestion
    final customCategory = getCol(mapping.categoryIndex);
    String categoryId = 'cat_miscellaneous';
    String categoryName = 'Miscellaneous';
    String categoryIcon = 'more_horiz';
    String categoryColor = 'clay';
    double catConfidence = 0.3;
    String catReason = 'Default categorization';

    if (customCategory.isNotEmpty) {
      categoryId =
          'cat_${customCategory.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      categoryName = customCategory;
      categoryIcon = 'label';
      categoryColor = 'teal';
      catConfidence = 1.0;
      catReason = 'From CSV category column';
    } else {
      final suggestion = CategorizationService.suggestCategory(rawMerchant);
      if (suggestion != null) {
        categoryId = suggestion.categoryId;
        categoryName = suggestion.categoryName;
        categoryIcon = suggestion.categoryIcon;
        categoryColor = suggestion.categoryColor;
        catConfidence = suggestion.confidence;
        catReason = suggestion.reason;
      } else if (type == TransactionType.income) {
        categoryId = 'cat_salary';
        categoryName = 'Salary';
        categoryIcon = 'payments';
        categoryColor = 'moss';
        catConfidence = 0.7;
        catReason = 'Income default suggestion';
      }
    }

    // 6. Generate stable Fingerprint
    final dateKey =
        '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
    final amtKey = amount.toStringAsFixed(2);
    final merchKey = normalizedMerchant.toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final refKey = refNo.isNotEmpty ? refNo.toLowerCase() : 'noref';
    final fingerprint =
        '$dateKey|$amtKey|$merchKey|${type.toDbString()}|$refKey';

    final rawRowStr = row.join(' , ');

    return ParsedTransaction(
      source: TransactionSource.csv,
      sourceName: sourceFileName ?? 'CSV Statement',
      rawSource: rawRowStr,
      sourceIdentifier: 'Row $rowNumber',
      amount: amount,
      type: type,
      rawMerchant: rawMerchant,
      normalizedMerchant: normalizedMerchant,
      date: parsedDate,
      time: parsedTime,
      notes: notes.isNotEmpty ? notes : null,
      accountId: accountId,
      paymentMethod: paymentMethod.isNotEmpty ? paymentMethod : null,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      categorizationConfidence: catConfidence,
      categorizationReason: catReason,
      referenceNumber: refNo.isNotEmpty ? refNo : null,
      fingerprint: fingerprint,
      warnings: warnings,
      validationErrors: validationErrors,
      isIncluded: validationErrors.isEmpty,
      reviewStatus:
          validationErrors.isNotEmpty || warnings.isNotEmpty
              ? ReviewStatus.pending
              : ReviewStatus.confirmed,
    );
  }

  /// Parse amount string (removes currency symbols ₹, Rs, INR, comma separators, Dr/Cr suffixes)
  static double parseAmountString(String raw) {
    if (raw.trim().isEmpty) return 0.0;

    var cleaned =
        raw
            .replaceAll('₹', '')
            .replaceAll('Rs.', '')
            .replaceAll('Rs', '')
            .replaceAll('INR', '')
            .replaceAll('\$', '')
            .replaceAll('€', '')
            .replaceAll('£', '')
            .replaceAll(',', '')
            .replaceAll('+', '')
            .trim();

    // Check for parentheses format: (500.00) -> 500.00
    if (cleaned.startsWith('(') && cleaned.endsWith(')')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }

    // Strip trailing 'Dr' or 'Cr'
    cleaned =
        cleaned
            .replaceAll(RegExp(r'\s*(dr|cr)\b', caseSensitive: false), '')
            .trim();

    final parsed = double.tryParse(cleaned);
    return parsed != null ? parsed.abs() : 0.0;
  }

  /// Parse a single amount column, returning (amount, isCredit, hasExplicitSign)
  static (double amount, bool isCredit, bool hasExplicitSign) parseSingleAmount(
    String raw,
  ) {
    if (raw.trim().isEmpty) return (0.0, false, false);

    final lower = raw.toLowerCase().trim();
    bool isCredit = false;
    bool hasExplicitSign = false;

    if (lower.contains('cr') || lower.startsWith('+') || lower.endsWith('cr')) {
      isCredit = true;
      hasExplicitSign = true;
    } else if (lower.contains('dr') ||
        lower.startsWith('-') ||
        (lower.startsWith('(') && lower.endsWith(')')) ||
        lower.endsWith('dr')) {
      isCredit = false;
      hasExplicitSign = true;
    }

    final amount = parseAmountString(raw);
    return (amount, isCredit, hasExplicitSign);
  }

  /// Multi-format Date Parser for Indian and ISO dates
  static DateTime? parseDateString(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return null;

    // Supported date format patterns
    final patterns = [
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'dd.MM.yyyy',
      'd/M/yyyy',
      'd-M-yyyy',
      'dd/MM/yy',
      'dd-MM-yy',
      'd/M/yy',
      'd-M-yy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'yyyy.MM.dd',
      'dd MMM yyyy',
      'dd-MMM-yyyy',
      'dd/MMM/yyyy',
      'd MMM yyyy',
      'd-MMM-yyyy',
      'dd MMMM yyyy',
      'MM/dd/yyyy',
      'MM-dd-yyyy',
    ];

    for (final pattern in patterns) {
      try {
        final formatter = DateFormat(pattern);
        final parsed = formatter.parseStrict(cleaned);
        // Sanity check year
        if (parsed.year >= 1990 && parsed.year <= 2100) {
          return parsed;
        }
      } catch (_) {}
    }

    // Try standard ISO 8601
    try {
      final isoParsed = DateTime.tryParse(cleaned);
      if (isoParsed != null) return isoParsed;
    } catch (_) {}

    return null;
  }

  /// Time parser for combined timestamps
  static DateTime? parseTimeString(String raw, {required DateTime baseDate}) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    final timePatterns = [
      'HH:mm:ss',
      'HH:mm',
      'hh:mm:ss a',
      'hh:mm a',
      'h:mm a',
      'h:mm:ss a',
    ];

    for (final pattern in timePatterns) {
      try {
        final formatter = DateFormat(pattern);
        final parsed = formatter.parse(cleaned);
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
        );
      } catch (_) {}
    }

    return null;
  }
}
