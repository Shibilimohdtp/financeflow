import 'dart:convert';
import 'package:intl/intl.dart';
import '../core/formatting/currency_formatter.dart';
import '../models/account.dart';
import '../models/backup_payload.dart';
import '../models/budget.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../models/savings_goal.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';

enum ExportFormat {
  csv,
  json,
  excel,
  pdf;

  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV (Comma Separated)';
      case ExportFormat.json:
        return 'JSON (Structured Data)';
      case ExportFormat.excel:
        return 'Excel-Compatible Spreadsheet';
      case ExportFormat.pdf:
        return 'PDF Summary Report';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.excel:
        return 'xls';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.excel:
        return 'application/vnd.ms-excel';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

enum ExportScope {
  allTransactions,
  dateRangeTransactions,
  budgets,
  savingsGoals,
  subscriptions,
  loans,
  investments,
  fullDataExport;

  String get displayName {
    switch (this) {
      case ExportScope.allTransactions:
        return 'All Transactions';
      case ExportScope.dateRangeTransactions:
        return 'Transactions in Date Range';
      case ExportScope.budgets:
        return 'Budgets';
      case ExportScope.savingsGoals:
        return 'Savings Goals';
      case ExportScope.subscriptions:
        return 'Subscriptions';
      case ExportScope.loans:
        return 'Loans & EMIs';
      case ExportScope.investments:
        return 'Investments';
      case ExportScope.fullDataExport:
        return 'Full Data Export (All Records)';
    }
  }
}

class ExportRequest {
  final ExportFormat format;
  final ExportScope scope;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedAccountIds;
  final List<String> selectedCategoryIds;
  final bool includeSensitiveFields;

  const ExportRequest({
    required this.format,
    required this.scope,
    this.startDate,
    this.endDate,
    this.selectedAccountIds = const [],
    this.selectedCategoryIds = const [],
    this.includeSensitiveFields = false,
  });
}

class ExportService {
  ExportService._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy');

  /// Generate CSV String (RFC 4180 with UTF-8 BOM)
  static String generateCsv({
    required List<Transaction> transactions,
    required List<Account> accounts,
    bool maskSensitive = true,
  }) {
    final buffer = StringBuffer();
    // UTF-8 BOM
    buffer.write('\uFEFF');

    // Header
    buffer.writeln(
      'Date,Type,Amount (INR),Merchant,Category,Account,Payment Method,Notes,Source',
    );

    final accountMap = {for (var a in accounts) a.id: a};

    for (final tx in transactions) {
      final dateStr = _dateFormat.format(tx.date);
      final typeStr = tx.type.name;
      final amountStr = tx.amount.toStringAsFixed(2);
      final merchantStr = _escapeCsv(tx.merchant);
      final categoryStr = _escapeCsv(tx.categoryName);

      final acc = accountMap[tx.accountId];
      final accName = acc != null ? acc.name : tx.accountId;
      final accDisplay =
          maskSensitive && acc?.maskedIdentifier != null
              ? '$accName (${acc!.maskedIdentifier})'
              : accName;

      final methodStr = _escapeCsv(tx.paymentMethod ?? 'UPI');
      final notesStr = _escapeCsv(tx.notes ?? '');
      final sourceStr = _escapeCsv(tx.source.displayName);

      buffer.writeln(
        '$dateStr,$typeStr,$amountStr,$merchantStr,$categoryStr,${_escapeCsv(accDisplay)},$methodStr,$notesStr,$sourceStr',
      );
    }

    return buffer.toString();
  }

  /// Generate JSON String
  static String generateJson({
    List<Transaction> transactions = const [],
    List<Account> accounts = const [],
    List<Budget> budgets = const [],
    List<SavingsGoal> savingsGoals = const [],
    List<Subscription> subscriptions = const [],
    List<Loan> loans = const [],
    List<Investment> investments = const [],
    bool maskSensitive = true,
  }) {
    final payload = BackupDataPayload(
      metadata: BackupMetadata(
        createdAt: DateTime.now(),
        transactionCount: transactions.length,
        accountCount: accounts.length,
        budgetCount: budgets.length,
        goalCount: savingsGoals.length,
        subscriptionCount: subscriptions.length,
        loanCount: loans.length,
        investmentCount: investments.length,
      ),
      transactions: transactions,
      accounts: accounts,
      budgets: budgets,
      savingsGoals: savingsGoals,
      subscriptions: subscriptions,
      loans: loans,
      investments: investments,
    );

    return const JsonEncoder.withIndent('  ').convert(payload.toJson());
  }

  /// Generate Excel-compatible Spreadsheet HTML string
  static String generateExcelHtml({
    required List<Transaction> transactions,
    required List<Account> accounts,
    bool maskSensitive = true,
  }) {
    final buffer = StringBuffer();
    final accountMap = {for (var a in accounts) a.id: a};

    buffer.writeln(
      '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">',
    );
    buffer.writeln(
      '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><style>table{border-collapse:collapse;} th,td{border:1px solid #ddd;padding:8px;font-family:sans-serif;} th{background-color:#143D3B;color:#FFFFFF;}</style></head>',
    );
    buffer.writeln('<body>');
    buffer.writeln('<h2>FinanceFlow Transaction Export</h2>');
    buffer.writeln(
      '<p>Generated on ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())} · On-Device Export</p>',
    );
    buffer.writeln('<table>');
    buffer.writeln(
      '<thead><tr><th>Date</th><th>Type</th><th>Amount (INR)</th><th>Merchant</th><th>Category</th><th>Account</th><th>Payment Method</th><th>Notes</th></tr></thead>',
    );
    buffer.writeln('<tbody>');

    for (final tx in transactions) {
      final dateStr = _dateFormat.format(tx.date);
      final typeStr = _escapeHtml(tx.type.name);
      final amountStr = tx.amount.toStringAsFixed(2);
      final merchantStr = _escapeHtml(tx.merchant);
      final categoryStr = _escapeHtml(tx.categoryName);
      final acc = accountMap[tx.accountId];
      final accName = acc != null ? acc.name : tx.accountId;
      final accDisplay = _escapeHtml(
        maskSensitive && acc?.maskedIdentifier != null
            ? '$accName (${acc!.maskedIdentifier})'
            : accName,
      );
      final methodStr = _escapeHtml(tx.paymentMethod ?? 'UPI');
      final notesStr = _escapeHtml(tx.notes ?? '');

      buffer.writeln(
        '<tr><td>$dateStr</td><td>$typeStr</td><td>$amountStr</td><td>$merchantStr</td><td>$categoryStr</td><td>$accDisplay</td><td>$methodStr</td><td>$notesStr</td></tr>',
      );
    }

    buffer.writeln('</tbody></table></body></html>');
    return buffer.toString();
  }

  /// Generate Plain Text Financial Report (Shareable as document/PDF summary)
  static String generateReportText({
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required List<Account> accounts,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();

    double income = 0.0;
    double expense = 0.0;
    final Map<String, double> categorySpending = {};

    for (final tx in transactions) {
      income += tx.earnedIncomeAmount;
      if (tx.consumptionExpenseAmount > 0) {
        expense += tx.consumptionExpenseAmount;
        categorySpending[tx.categoryName] =
            (categorySpending[tx.categoryName] ?? 0.0) +
            tx.consumptionExpenseAmount;
      }
    }

    final netSavings = income - expense;

    buffer.writeln(
      '================================================================',
    );
    buffer.writeln(
      '                 FINANCEFLOW FINANCIAL REPORT                   ',
    );
    buffer.writeln(
      '================================================================',
    );
    buffer.writeln(
      'Generated on: ${DateFormat('dd MMMM yyyy, HH:mm').format(now)}',
    );
    if (startDate != null && endDate != null) {
      buffer.writeln(
        'Report Period: ${_shortDate.format(startDate)} to ${_shortDate.format(endDate)}',
      );
    } else {
      buffer.writeln('Report Period: All Recorded Time');
    }
    buffer.writeln('Total Transactions: ${transactions.length}');
    buffer.writeln(
      '----------------------------------------------------------------',
    );
    buffer.writeln('');
    buffer.writeln('CASH FLOW SUMMARY');
    buffer.writeln('-----------------');
    buffer.writeln('  Total Income:    ${CurrencyFormatter.formatINR(income)}');
    buffer.writeln(
      '  Total Expenses:  ${CurrencyFormatter.formatINR(expense)}',
    );
    buffer.writeln(
      '  Net Savings:     ${CurrencyFormatter.formatINR(netSavings)}',
    );
    if (income > 0) {
      buffer.writeln(
        '  Savings Rate:    ${((netSavings / income) * 100).toStringAsFixed(1)}%',
      );
    }
    buffer.writeln('');
    buffer.writeln('TOP SPENDING CATEGORIES');
    buffer.writeln('-----------------------');
    final sortedCats =
        categorySpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    for (final c in sortedCats) {
      final pct = expense > 0 ? (c.value / expense) * 100 : 0.0;
      buffer.writeln(
        '  • ${c.key.padRight(20)}: ${CurrencyFormatter.formatINR(c.value).padRight(14)} (${pct.toStringAsFixed(1)}%)',
      );
    }
    buffer.writeln('');
    if (budgets.isNotEmpty) {
      buffer.writeln('ACTIVE BUDGETS STATUS');
      buffer.writeln('---------------------');
      for (final b in budgets.where((b) => !b.isArchived)) {
        final catName = b.categoryName ?? b.name;
        final spent = categorySpending[catName] ?? 0.0;
        final rem = b.amountLimit - spent;
        final name = catName.padRight(20);
        buffer.writeln(
          '  • $name: Limit ${CurrencyFormatter.formatINR(b.amountLimit)} | Spent ${CurrencyFormatter.formatINR(spent)} | Rem ${CurrencyFormatter.formatINR(rem)}',
        );
      }
      buffer.writeln('');
    }
    buffer.writeln(
      '================================================================',
    );
    buffer.writeln(
      '      Generated on this device. Privacy First · 100% Offline    ',
    );
    buffer.writeln(
      '================================================================',
    );

    return buffer.toString();
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static String _escapeHtml(String field) {
    return field
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
