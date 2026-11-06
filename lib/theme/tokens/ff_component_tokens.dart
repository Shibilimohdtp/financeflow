import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

import 'ff_foundation.dart';

/// Component tokens: per-component sizing decisions, expressed in foundation
/// tokens. Shared widgets and `FfTheme` read these; feature code should use the
/// shared widgets rather than these values directly.

abstract final class FfButtonTokens {
  static const double heightLg = FfTouch.minTarget; // 48
  static const double heightMd = 44;
  static const double heightSm = 36;

  /// Buttons are pills (Stillwater Bloom).
  static const double radius = FfRadius.full;
  static const double radiusSm = FfRadius.full;
  static const double iconGap = FfSpace.xs;
  static const double spinnerSize = 18;
  static const double spinnerStroke = 2;
}

abstract final class FfCardTokens {
  /// List groups and everyday cards (compact density).
  static const double radius = FfRadius.lg;

  /// Summary cards (comfortable density).
  static const double radiusSummary = FfRadius.xl;

  /// Hero gradient cards.
  static const double radiusHero = FfRadius.x2l;
  static const double padding = FfSpace.lg;
  static const double borderWidth = FfBorderWidth.hairline;
}

/// Spacing density. Summaries and heroes are comfortable; lists are compact,
/// so the airy look never turns the transaction list sparse. Rows are never
/// shorter than a touch target.
enum FfDensity {
  comfortable(
    rowHeight: 72,
    cardPadding: FfSpace.lg,
    gap: FfSpace.md,
    cardRadius: FfCardTokens.radiusSummary,
  ),
  compact(
    rowHeight: 60,
    cardPadding: FfSpace.md,
    gap: FfSpace.sm,
    cardRadius: FfCardTokens.radius,
  );

  const FfDensity({
    required this.rowHeight,
    required this.cardPadding,
    required this.gap,
    required this.cardRadius,
  });

  final double rowHeight;
  final double cardPadding;
  final double gap;
  final double cardRadius;
}

/// Soft, two-layer shadows tinted with the palette's shadow colour. In dark
/// mode surfaces separate by tone, so [card] and [float] add a faint rim
/// instead of a dark shadow.
abstract final class FfElevation {
  static List<BoxShadow> card(Color shadow, Brightness brightness) =>
      brightness == Brightness.dark
          ? _rim
          : [
            BoxShadow(
              color: shadow.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: shadow.withValues(alpha: 0.10),
              blurRadius: 32,
              spreadRadius: -12,
              offset: const Offset(0, 12),
            ),
          ];

  /// Floating things: the dock, glass bars, raised menus.
  static List<BoxShadow> float(Color shadow, Brightness brightness) => [
    if (brightness == Brightness.dark) ..._rim,
    BoxShadow(
      color: shadow.withValues(
        alpha: brightness == Brightness.dark ? 0.5 : 0.16,
      ),
      blurRadius: 40,
      spreadRadius: -16,
      offset: const Offset(0, 18),
    ),
  ];

  static const List<BoxShadow> _rim = [
    BoxShadow(color: Color(0x0AFFFFFF), spreadRadius: 1),
  ];
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
  static const double radius = FfRadius.xl;
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
  /// Circle (or pill when extended), like every ink action.
  static const double radius = FfRadius.full;
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

abstract final class FfAmountTokens {
  /// Largest system text scale applied to amounts, so big numbers keep
  /// their layout (body text still follows the system setting fully).
  static const double maxTextScale = 1.3;
}

abstract final class FfProgressTokens {
  static const double heightSm = 4;
  static const double heightMd = 6;
  static const double heightLg = 8;
  static const double paceMarkerWidth = 2;
  static const double spinnerSize = 28;
  static const double spinnerStroke = 3;
}

abstract final class FfBadgeTokens {
  static const double paddingH = FfSpace.xs;
  static const double paddingV = FfSpace.x3s;
  static const double radius = FfRadius.full;
  static const double iconSize = FfIconSize.xs;
  static const double gap = FfSpace.x2s;
}

/// Same geometry as list rows, so dividers line up across both.
abstract final class FfKeyValueTokens {
  static const double paddingH = FfRowTokens.paddingH;
  static const double paddingV = FfRowTokens.paddingV;
  static const double iconSize = FfRowTokens.iconSize;
  static const double iconGap = FfRowTokens.gap;
}
