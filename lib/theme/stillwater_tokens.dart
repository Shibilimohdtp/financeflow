import 'package:flutter/material.dart';

/// Stillwater Design System Tokens (Version 1.0)
///
/// Principles: Calm, Precise, Private, Warm, Non-judgmental.
/// Base spacing unit: 4dp.
class StillwaterTokens {
  StillwaterTokens._();

  // Spacing Scale (Base: 4dp)
  static const double space3Xs = 2.0;
  static const double space2Xs = 4.0;
  static const double spaceXs = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 16.0;
  static const double spaceLg =
      20.0; // Horizontal screen margins & comfortable card padding
  static const double spaceXl = 24.0; // Section gaps
  static const double space2Xl = 32.0;
  static const double space3Xl = 40.0;
  static const double space4Xl = 56.0;

  // Corner Radius Scale
  static const double radiusXs = 4.0; // Tags, tiny badges
  static const double radiusSm = 8.0; // Small buttons, icon tiles
  static const double radiusMd = 12.0; // Inputs, buttons, chart cards
  static const double radiusLg = 16.0; // Standard cards, list containers
  static const double radiusXl = 24.0; // Dialogs, hero cards
  static const double radius2Xl = 28.0; // Bottom sheets top corners
  static const double radiusFull = 999.0; // Chips, pills

  // Border Widths
  static const double borderWidthHairline = 0.75;
  static const double borderWidthDefault = 1.0;
  static const double borderWidthStrong = 1.5;
  static const double borderWidthFocus = 2.0;

  // Component Heights
  static const double buttonHeightPrimary = 48.0;
  static const double buttonHeightSecondary = 44.0;
  static const double buttonHeightDense = 36.0;
  static const double inputHeight = 56.0;
  static const double amountFieldHeight = 72.0;
  static const double chipHeight = 36.0;
  static const double transactionRowHeight = 72.0;
  static const double transactionRowHeightDense = 56.0;
  static const double iconTileSize = 36.0;
  static const double touchTargetMin = 48.0;

  // Motion Durations (ms)
  static const Duration durationInstant = Duration(milliseconds: 80);
  static const Duration durationFast = Duration(milliseconds: 160);
  static const Duration durationBase = Duration(milliseconds: 240);
  static const Duration durationSlow = Duration(milliseconds: 360);
  static const Duration durationDeliberate = Duration(milliseconds: 600);

  // Easing Curves
  static const Curve easeEmphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve easeDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  static const Curve easeAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);

  // Opacities
  static const double opacityDisabled = 0.38;
  static const double opacityOverlay = 0.48;
  static const double opacityTint = 0.12; // Category tile background tint
  static const double opacityBlur = 0.92;

  // Breakpoints
  static const double bpCompact = 600.0;
  static const double bpMedium = 840.0;
  static const double bpExpanded = 1200.0;
}
