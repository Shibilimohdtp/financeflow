import 'package:flutter/material.dart';

import 'tokens/ff_component_tokens.dart';
import 'tokens/ff_foundation.dart';

/// Legacy token names, kept so existing code compiles during the migration.
/// Every value forwards to `tokens/`. New code uses `FfSpace`, `FfRadius`,
/// `FfMotion` and the component tokens. Removed in design-system slice DS-9.
class StillwaterTokens {
  StillwaterTokens._();

  // Spacing
  static const double space3Xs = FfSpace.x3s;
  static const double space2Xs = FfSpace.x2s;
  static const double spaceXs = FfSpace.xs;
  static const double spaceSm = FfSpace.sm;
  static const double spaceMd = FfSpace.md;
  static const double spaceLg = FfSpace.lg;
  static const double spaceXl = FfSpace.xl;
  static const double space2Xl = FfSpace.x2l;
  static const double space3Xl = FfSpace.x3l;
  static const double space4Xl = FfSpace.x4l;

  // Corner radius
  static const double radiusXs = FfRadius.xs;
  static const double radiusSm = FfRadius.sm;
  static const double radiusMd = FfRadius.md;
  static const double radiusLg = FfRadius.lg;
  static const double radiusXl = FfRadius.xl;
  static const double radius2Xl = FfRadius.x2l;
  static const double radiusFull = FfRadius.full;

  // Border widths
  static const double borderWidthHairline = FfBorderWidth.hairline;
  static const double borderWidthDefault = FfBorderWidth.regular;
  static const double borderWidthStrong = FfBorderWidth.strong;
  static const double borderWidthFocus = FfBorderWidth.focus;

  // Component heights
  static const double buttonHeightPrimary = FfButtonTokens.heightLg;
  static const double buttonHeightSecondary = FfButtonTokens.heightMd;
  static const double buttonHeightDense = FfButtonTokens.heightSm;
  static const double inputHeight = FfFieldTokens.height;
  static const double amountFieldHeight = FfFieldTokens.amountHeight;
  static const double chipHeight = FfChipTokens.height;
  static const double transactionRowHeight = FfRowTokens.height;
  static const double transactionRowHeightDense = FfRowTokens.heightDense;
  static const double iconTileSize = FfRowTokens.iconTile;
  static const double touchTargetMin = FfTouch.minTarget;

  // Motion
  static const Duration durationInstant = FfMotion.instant;
  static const Duration durationFast = FfMotion.fast;
  static const Duration durationBase = FfMotion.base;
  static const Duration durationSlow = FfMotion.slow;
  static const Duration durationDeliberate = FfMotion.deliberate;
  static const Curve easeEmphasized = FfMotion.emphasized;
  static const Curve easeDecelerate = FfMotion.decelerate;
  static const Curve easeAccelerate = FfMotion.accelerate;

  // Opacities
  static const double opacityDisabled = FfOpacity.disabled;
  static const double opacityOverlay = FfOpacity.overlay;
  static const double opacityTint = 0.12; // FfTint.subtle
  static const double opacityBlur = FfOpacity.blur;

  // Breakpoints
  static const double bpCompact = FfBreakpoint.compact;
  static const double bpMedium = FfBreakpoint.medium;
  static const double bpExpanded = FfBreakpoint.expanded;
}
