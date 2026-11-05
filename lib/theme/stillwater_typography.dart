import 'package:flutter/material.dart';

import 'ff_typography.dart';

/// Legacy typography entry points, kept so existing code compiles during the
/// migration. Everything forwards to `ff_typography.dart`. New code uses
/// `context.ff.text`. Removed in design-system slice DS-9.
class StillwaterTypography {
  StillwaterTypography._();

  static const List<String> fallbackFamilies = FfFonts.fallbackFamilies;
  static const List<FontFeature> tabularFeatures = FfFonts.tabularFigures;

  static TextStyle manrope({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) => FfFonts.manrope(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: fontFeatures,
  );

  static TextStyle fraunces({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) => FfFonts.fraunces(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );

  static TextStyle numHero({Color? color}) =>
      FfTypography.moneyHero(color: color);
  static TextStyle numLg({Color? color}) => FfTypography.moneyLg(color: color);
  static TextStyle numMd({Color? color}) => FfTypography.moneyMd(color: color);
  static TextStyle numSm({Color? color}) => FfTypography.moneySm(color: color);

  static TextTheme createTextTheme(
    Color primaryTextColor,
    Color secondaryTextColor,
  ) =>
      FfTypography.build(
        primary: primaryTextColor,
        secondary: secondaryTextColor,
      ).toTextTheme();
}
