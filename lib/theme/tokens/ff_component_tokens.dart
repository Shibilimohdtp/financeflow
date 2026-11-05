import 'package:flutter/painting.dart';

import 'ff_foundation.dart';

/// Component tokens: per-component sizing decisions, expressed in foundation
/// tokens. Shared widgets and `FfTheme` read these; feature code should use the
/// shared widgets rather than these values directly.

abstract final class FfButtonTokens {
  static const double heightLg = FfTouch.minTarget; // 48
  static const double heightMd = 44;
  static const double heightSm = 36;
  static const double radius = FfRadius.md;
  static const double radiusSm = FfRadius.sm;
  static const double iconGap = FfSpace.xs;
  static const double spinnerSize = 18;
  static const double spinnerStroke = 2;
}

abstract final class FfCardTokens {
  static const double radius = FfRadius.lg;
  static const double padding = FfSpace.lg;
  static const double borderWidth = FfBorderWidth.hairline;
}

abstract final class FfFieldTokens {
  static const double height = 56;
  static const double amountHeight = 72;
  static const double radius = FfRadius.md;
  static const double paddingH = FfSpace.md;
  static const double paddingV = FfSpace.md;
}

abstract final class FfChipTokens {
  static const double height = 36;
  static const double radius = FfRadius.full;
}

abstract final class FfRowTokens {
  static const double height = 72;
  static const double heightDense = 56;

  /// Every row is at least one touch target tall.
  static const double minHeight = FfTouch.minTarget;
  static const double paddingH = FfSpace.md;

  /// End padding when a switch or checkbox ends the row (they carry their own).
  static const double paddingHControl = FfSpace.xs;
  static const double paddingV = FfSpace.sm;

  /// Space between the leading element and the text.
  static const double gap = FfSpace.md;

  /// Plain leading icon.
  static const double iconSize = 22;

  /// Tinted leading tile (`FfIconTile`).
  static const double iconTile = 36;
  static const double iconTileRadius = FfRadius.sm;
  static const double detailMaxWidth = 160;

  /// Where row text starts, for dividers that skip the leading element.
  static const double textInsetAfterIcon = paddingH + iconSize + gap;
  static const double textInsetAfterTile = paddingH + iconTile + gap;
}

abstract final class FfSheetTokens {
  static const double radius = FfRadius.x2l;
  static const Size dragHandle = Size(32, 4);

  /// Tallest a sheet may grow, as a share of the screen height.
  static const double maxHeightFraction = 0.9;
}

abstract final class FfDialogTokens {
  static const double radius = FfRadius.xl;
  static const double elevation = 4;
}

abstract final class FfNavBarTokens {
  static const double height = 72;
  static const double iconSize = 22;
}

abstract final class FfFabTokens {
  static const double radius = FfRadius.md;
  static const double elevation = 2;
}

abstract final class FfToastTokens {
  static const double radius = FfRadius.md;
  static const double margin = FfSpace.lg;
  static const Duration duration = Duration(seconds: 4);

  /// Longer when the toast offers an action such as Undo.
  static const Duration durationWithAction = Duration(seconds: 6);
}

abstract final class FfDialogActionTokens {
  static const double padding = FfSpace.lg;
  static const double gap = FfSpace.sm;
}

abstract final class FfBannerTokens {
  static const double radius = FfRadius.md;
  static const double padding = FfSpace.md;
  static const double gap = FfSpace.sm;
  static const double iconSize = FfIconSize.lg;
}

abstract final class FfDividerTokens {
  static const double thickness = FfBorderWidth.hairline;
  static const double space = 1;

  /// Total height of a spaced divider (the line sits in the middle).
  static const double spacedHeight = FfSpace.sm;

  /// Where an inset divider starts: past a list row's leading tile.
  static const double rowInset = FfRowTokens.textInsetAfterTile;
}
