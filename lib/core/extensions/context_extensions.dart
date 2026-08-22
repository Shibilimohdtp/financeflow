import 'package:flutter/material.dart';
import '../../theme/stillwater_colors.dart';

/// BuildContext convenience extensions
extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Custom Stillwater Theme Extensions
  FfFinColors get finColors =>
      Theme.of(this).extension<FfFinColors>() ?? FfFinColors.daylight;

  FfAiColors get aiColors =>
      Theme.of(this).extension<FfAiColors>() ?? FfAiColors.daylight;

  FfSecColors get secColors =>
      Theme.of(this).extension<FfSecColors>() ?? FfSecColors.daylight;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
