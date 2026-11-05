import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Stillwater foundation tokens: the values that are the same in every colour
/// theme. They are `const` so widgets can stay `const`; changing a value here
/// changes it everywhere.
///
/// Colour and typography follow the active theme and are read with
/// `context.ff.color` and `context.ff.text` instead.

/// Spacing scale, built on one 4dp unit. Names match the legacy
/// `StillwaterTokens.space*` names so migrated code keeps the same values.
abstract final class FfSpace {
  static const double unit = 4;

  static const double x3s = unit * 0.5; // 2
  static const double x2s = unit; // 4
  static const double xs = unit * 2; // 8
  static const double sm = unit * 3; // 12
  static const double md = unit * 4; // 16
  static const double lg = unit * 5; // 20: screen margins, card padding
  static const double xl = unit * 6; // 24: section gaps
  static const double x2l = unit * 8; // 32
  static const double x3l = unit * 10; // 40
  static const double x4l = unit * 14; // 56

  /// Horizontal margin of every screen.
  static const double pageMargin = lg;
}

/// Corner radius scale.
abstract final class FfRadius {
  static const double xs = 4; // tags, tiny badges
  static const double sm = 8; // small buttons, icon tiles
  static const double md = 12; // inputs, buttons, chart cards
  static const double lg = 16; // cards, list containers
  static const double xl = 24; // dialogs, hero cards
  static const double x2l = 28; // bottom sheet top corners
  static const double full = 999; // chips, pills
}

/// Stroke widths.
abstract final class FfBorderWidth {
  static const double hairline = 0.75;
  static const double regular = 1;
  static const double strong = 1.5;
  static const double focus = 2;
}

/// Icon sizes. Pick the nearest role instead of a number.
abstract final class FfIconSize {
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 18;
  static const double lg = 20;
  static const double xl = 24;
  static const double x2l = 32;
}

/// Motion durations and curves. Respect `MediaQuery.disableAnimations`.
abstract final class FfMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration deliberate = Duration(milliseconds: 600);

  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve decelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  static const Curve accelerate = Cubic(0.3, 0.0, 1.0, 1.0);
}

/// Opacity levels. Tinted fills use [FfTint] through `context.ff.color.tint`.
abstract final class FfOpacity {
  static const double disabled = 0.38;
  static const double overlay = 0.48;

  /// De-emphasised foregrounds (secondary marks on coloured surfaces).
  static const double half = 0.5;
  static const double muted = 0.7;
  static const double high = 0.85;
  static const double blur = 0.92;
}

/// The only alpha levels for tinted backgrounds (icon tiles, selected rows,
/// soft status fills).
enum FfTint {
  whisper(0.04),
  faint(0.08),
  subtle(0.12),
  medium(0.2),
  strong(0.35);

  const FfTint(this.alpha);
  final double alpha;
}

/// Layout breakpoints (window width in dp).
abstract final class FfBreakpoint {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
}

/// Minimum interactive size (Material and WCAG target size).
abstract final class FfTouch {
  static const double minTarget = 48;
}

/// Shorthand for the radius of a rounded rectangle at a scale step.
BorderRadius ffRadius(double radius) =>
    BorderRadius.all(Radius.circular(radius));
