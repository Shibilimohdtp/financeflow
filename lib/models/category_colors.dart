import 'package:flutter/material.dart';

/// Stable mapping between persisted category identifiers and category colors.
///
/// These values intentionally do not reference brand or status tokens: changing
/// the app theme must not silently change a user's category identity.
class CategoryColors {
  CategoryColors._();

  static const Map<String, Color> _lightColors = {
    'clay': Color(0xFFAE4E2E),
    'grove': Color(0xFF177A50),
    'teal': Color(0xFF0E5F55),
    'deepwater': Color(0xFF0E5F55),
    'marigold': Color(0xFF9C6410),
    'plum': Color(0xFF6D4A78),
    'indigo': Color(0xFF4756A6),
    'slate': Color(0xFF5C7078),
    'shore': Color(0xFF71624A),
    'warning': Color(0xFF9A6A00),
  };

  static const Map<String, Color> _darkColors = {
    'clay': Color(0xFFE59276),
    'grove': Color(0xFF6FD39B),
    'teal': Color(0xFF7AD8C6),
    'deepwater': Color(0xFF7AD8C6),
    'marigold': Color(0xFFE9B366),
    'plum': Color(0xFFC79BD4),
    'indigo': Color(0xFFA3B0EE),
    'slate': Color(0xFF9FB6BF),
    'shore': Color(0xFFD6C4A2),
    'warning': Color(0xFFE5C069),
  };

  static Color getColor(String? colorTokenIdentifier, {bool isDark = false}) {
    final map = isDark ? _darkColors : _lightColors;
    if (colorTokenIdentifier == null) return map['teal']!;
    return map[colorTokenIdentifier.toLowerCase()] ?? map['teal']!;
  }

  static List<String> get availableColorKeys => _lightColors.keys.toList();
}
