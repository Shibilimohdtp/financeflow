import 'package:flutter/material.dart';
import '../theme/stillwater_colors.dart';

/// Stable mapping between string identifiers and Stillwater category colors
class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> _lightColors = {
    'clay': StillwaterColors.lightExpense,
    'grove': StillwaterColors.lightIncome,
    'teal': StillwaterColors.lightPrimary,
    'deepwater': StillwaterColors.lightPrimary,
    'marigold': StillwaterColors.lightAccent,
    'plum': StillwaterColors.lightDebt,
    'indigo': StillwaterColors.lightInvestment,
    'slate': StillwaterColors.lightTransfer,
    'shore': StillwaterColors.lightSecondary,
    'warning': StillwaterColors.lightWarning,
  };

  static const Map<String, Color> _darkColors = {
    'clay': StillwaterColors.darkExpense,
    'grove': StillwaterColors.darkIncome,
    'teal': StillwaterColors.darkPrimary,
    'deepwater': StillwaterColors.darkPrimary,
    'marigold': StillwaterColors.darkAccent,
    'plum': StillwaterColors.darkDebt,
    'indigo': StillwaterColors.darkInvestment,
    'slate': StillwaterColors.darkTransfer,
    'shore': StillwaterColors.darkSecondary,
    'warning': StillwaterColors.darkWarning,
  };

  static Color getColor(String? colorTokenIdentifier, {bool isDark = false}) {
    final map = isDark ? _darkColors : _lightColors;
    if (colorTokenIdentifier == null) return map['teal']!;
    return map[colorTokenIdentifier.toLowerCase()] ?? map['teal']!;
  }

  static List<String> get availableColorKeys => _lightColors.keys.toList();
}
