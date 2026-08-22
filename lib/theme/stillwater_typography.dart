import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stillwater Typography System (Manrope + Fraunces + Ledger Tabular Numerals)
class StillwaterTypography {
  StillwaterTypography._();

  static const List<String> fallbackFamilies = [
    'NotoSansDevanagari',
    'Roboto',
    'sans-serif',
  ];

  // Base font getter with fallback safety
  static TextStyle manrope({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) {
    try {
      return GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFeatures: fontFeatures,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Manrope',
        fontFamilyFallback: fallbackFamilies,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFeatures: fontFeatures,
      );
    }
  }

  static TextStyle fraunces({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    try {
      return GoogleFonts.fraunces(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Fraunces',
        fontFamilyFallback: fallbackFamilies,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  // Tabular Numerals Font Features
  static const List<FontFeature> tabularFeatures = [
    FontFeature.tabularFigures(),
  ];

  // Ledger Tabular Amounts
  static TextStyle numHero({Color? color}) => manrope(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: color,
    fontFeatures: tabularFeatures,
  );

  static TextStyle numLg({Color? color}) => manrope(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
    fontFeatures: tabularFeatures,
  );

  static TextStyle numMd({Color? color}) => manrope(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: color,
    fontFeatures: tabularFeatures,
  );

  static TextStyle numSm({Color? color}) => manrope(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: color,
    fontFeatures: tabularFeatures,
  );

  static TextTheme createTextTheme(
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return TextTheme(
      displayLarge: fraunces(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
        color: primaryTextColor,
      ),
      displayMedium: fraunces(
        fontSize: 30,
        height: 36 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.50,
        color: primaryTextColor,
      ),
      displaySmall: fraunces(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      headlineLarge: manrope(
        fontSize: 26,
        height: 32 / 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.40,
        color: primaryTextColor,
      ),
      headlineMedium: manrope(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.30,
        color: primaryTextColor,
      ),
      headlineSmall: manrope(
        fontSize: 19,
        height: 24 / 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.20,
        color: primaryTextColor,
      ),
      titleLarge: manrope(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleMedium: manrope(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleSmall: manrope(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      bodyLarge: manrope(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      bodyMedium: manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      ),
      bodySmall: manrope(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
      labelLarge: manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      labelMedium: manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: manrope(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }
}
