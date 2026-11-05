import 'package:flutter/material.dart';

import 'ff_colors.dart';
import 'ff_typography.dart';
import 'palettes/ff_palette.dart';

/// The design system as seen from a widget: semantic colours and text roles
/// of the active theme.
@immutable
class FfThemeData {
  const FfThemeData({required this.color, required this.text});

  final FfColors color;
  final FfText text;
}

extension FfContext on BuildContext {
  /// Stillwater tokens for the active theme: `context.ff.color.surfaceCard`,
  /// `context.ff.text.title`.
  ///
  /// Falls back to the default palette when the surrounding theme was not
  /// built by `FfTheme` (for example a bare `MaterialApp` in a test).
  FfThemeData get ff {
    final theme = Theme.of(this);
    final color =
        theme.extension<FfColors>() ??
        FfPalettes.lichen.colorsFor(theme.brightness);
    return FfThemeData(
      color: color,
      text: theme.extension<FfText>() ?? FfTypography.forColors(color),
    );
  }
}
