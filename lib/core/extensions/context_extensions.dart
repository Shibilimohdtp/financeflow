import 'package:flutter/material.dart';
import '../../theme/stillwater_colors.dart';

export '../../theme/ff_context.dart';

/// BuildContext convenience extensions
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom Stillwater Theme Extensions
  FfFinColors get finColors =>
      Theme.of(this).extension<FfFinColors>() ??
      (isDarkMode ? FfFinColors.deepWater : FfFinColors.daylight);

  FfStatusColors get statusColors =>
      Theme.of(this).extension<FfStatusColors>() ??
      (isDarkMode ? FfStatusColors.deepWater : FfStatusColors.daylight);

  FfAccentColors get accentColors =>
      Theme.of(this).extension<FfAccentColors>() ??
      (isDarkMode ? FfAccentColors.deepWater : FfAccentColors.daylight);

  FfSecColors get secColors =>
      Theme.of(this).extension<FfSecColors>() ??
      (isDarkMode ? FfSecColors.deepWater : FfSecColors.daylight);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
