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
  static const double iconTile = 36;
}

abstract final class FfSheetTokens {
  static const double radius = FfRadius.x2l;
  static const Size dragHandle = Size(32, 4);
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
}

abstract final class FfDividerTokens {
  static const double thickness = FfBorderWidth.hairline;
  static const double space = 1;
}
