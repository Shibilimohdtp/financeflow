import 'package:intl/intl.dart';

/// Exact Indian Rupee (INR) Currency Formatter
///
/// Implements Indian digit grouping:
/// - ₹1,234
/// - ₹1,23,456
/// - ₹12,34,567
/// - ₹1,23,45,678
///
/// Principles:
/// - Never abbreviates primary balances.
/// - Shows decimals only when paise exist (e.g. ₹1,250 vs ₹1,250.50).
/// - Precise tabular-ready outputs.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const String currencySymbol = '₹';

  /// Shortcut helper for INR formatting
  static String formatINR(double amount, {bool showSign = false}) =>
      format(amount, showSign: showSign);

  /// Format an amount into Indian Rupee format with Indian digit grouping
  /// Example: 123456 -> "₹1,23,456"
  /// Example: 123456.75 -> "₹1,23,456.75"
  /// Example: -430 -> "− ₹430"
  static String format(
    double amount, {
    bool showSign = false,
    bool isExpense = false,
    bool isIncome = false,
    bool includeSymbol = true,
  }) {
    final isNegative = amount < 0 || isExpense;
    final absAmount = amount.abs();

    // Check if paise exist (fractional part)
    final hasPaise = (absAmount - absAmount.floorToDouble()) > 0.001;

    final formatPattern = hasPaise ? '##,##,##,##,##0.00' : '##,##,##,##,##0';
    final numberFormat = NumberFormat(formatPattern, 'en_IN');
    final formattedNumber = numberFormat.format(absAmount);

    final prefix = includeSymbol ? currencySymbol : '';

    if (showSign) {
      if (isIncome || amount > 0 && !isExpense) {
        return includeSymbol
            ? '+ $prefix$formattedNumber'
            : '+$formattedNumber';
      } else if (isNegative) {
        // Using true mathematical minus sign '−' for Stillwater precision
        return includeSymbol
            ? '− $prefix$formattedNumber'
            : '−$formattedNumber';
      }
    }

    if (isNegative && !showSign) {
      return includeSymbol ? '− $prefix$formattedNumber' : '−$formattedNumber';
    }

    return includeSymbol ? '$prefix$formattedNumber' : formattedNumber;
  }

  /// Compact representation for chart axes and tight legends
  /// Example: 1200 -> "₹1.2k"
  /// Example: 150000 -> "₹1.5L"
  /// Example: 25000000 -> "₹2.5Cr"
  static String formatCompact(double amount, {bool includeSymbol = true}) {
    final absAmount = amount.abs();
    final prefix = includeSymbol ? currencySymbol : '';

    if (absAmount >= 10000000) {
      final cr = absAmount / 10000000;
      return '$prefix${_formatShort(cr)}Cr';
    } else if (absAmount >= 100000) {
      final l = absAmount / 100000;
      return '$prefix${_formatShort(l)}L';
    } else if (absAmount >= 1000) {
      final k = absAmount / 1000;
      return '$prefix${_formatShort(k)}k';
    } else {
      return format(amount, includeSymbol: includeSymbol);
    }
  }

  static String _formatShort(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Parse user input string to double safely
  /// Handles commas, spaces, currency symbols
  static double? parse(String input) {
    if (input.trim().isEmpty) return null;
    final sanitized =
        input
            .replaceAll('₹', '')
            .replaceAll(',', '')
            .replaceAll(' ', '')
            .replaceAll('+', '')
            .replaceAll('−', '-')
            .trim();

    return double.tryParse(sanitized);
  }
}
