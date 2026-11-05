import 'package:flutter/material.dart';

import 'ff_theme.dart';

/// Legacy entry points for the default (Lichen) theme, kept so existing code
/// and tests compile during the migration. New code uses [FfTheme]. Removed
/// in design-system slice DS-9.
class StillwaterTheme {
  StillwaterTheme._();

  /// Lichen, light mode.
  static ThemeData get daylight => FfTheme.light();

  /// Lichen, dark mode.
  static ThemeData get deepWater => FfTheme.dark();
}
