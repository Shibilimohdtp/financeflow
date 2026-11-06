import 'package:flutter/material.dart';

import 'ff_colors.dart';

/// Every text role in the Stillwater type scale. UI code reads styles through
/// these roles (`context.ff.text.title`), never with raw font sizes.
enum FfTextRole {
  // Display: light Geist for onboarding titles and hero moments.
  displayLg,
  display,
  displaySm,
  headlineLg,
  headline,
  headlineSm,
  titleLg,
  title,
  titleSm,
  bodyLg,
  body,
  bodySm,
  labelLg,
  label,
  labelSm,
  // Amounts: tabular figures so digits line up in columns.
  moneyHero,
  moneyLg,
  moneyMd,
  moneySm,
}

/// The app's fonts. They are bundled in `assets/fonts/` and declared in
/// `pubspec.yaml`, so text never needs the network and release builds match
/// debug builds. Font families are named here and nowhere else.
abstract final class FfFonts {
  /// UI, amounts and display (Stillwater Bloom, DS-B2). Bundled weights:
  /// 300, 400, 500, 600.
  static const String geistFamily = 'Geist';

  /// Fallback for glyphs Geist lacks. Bundled weights: 400–800.
  static const String manropeFamily = 'Manrope';

  /// Used for scripts the bundled fonts don't cover (for example Devanagari).
  static const List<String> fallbackFamilies = [
    manropeFamily,
    'NotoSansDevanagari',
    'Roboto',
    'sans-serif',
  ];

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// The one UI face.
  static TextStyle ui({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) => TextStyle(
    fontFamily: geistFamily,
    fontFamilyFallback: fallbackFamilies,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: fontFeatures,
  );
}

/// The type scale. Sizes, line heights, weights and tracking are defined
/// once here; [FfText] and Material's `TextTheme` are both built from it.
///
/// Stillwater Bloom: hierarchy comes from size, not weight. Large text and
/// amounts are light (300); weight 300 is only used at 28 dp and above.
abstract final class FfTypography {
  static TextStyle moneyHero({Color? color}) => FfFonts.ui(
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneyLg({Color? color}) => FfFonts.ui(
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.0,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneyMd({Color? color}) => FfFonts.ui(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneySm({Color? color}) => FfFonts.ui(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  /// All roles in the given text colours. Small supporting roles (bodySm,
  /// label, labelSm) use the secondary colour.
  static FfText build({required Color primary, required Color secondary}) {
    return FfText({
      FfTextRole.displayLg: FfFonts.ui(
        fontSize: 40,
        height: 44 / 40,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.4,
        color: primary,
      ),
      FfTextRole.display: FfFonts.ui(
        fontSize: 32,
        height: 38 / 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.0,
        color: primary,
      ),
      FfTextRole.displaySm: FfFonts.ui(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.7,
        color: primary,
      ),
      FfTextRole.headlineLg: FfFonts.ui(
        fontSize: 26,
        height: 32 / 26,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.6,
        color: primary,
      ),
      FfTextRole.headline: FfFonts.ui(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.4,
        color: primary,
      ),
      FfTextRole.headlineSm: FfFonts.ui(
        fontSize: 19,
        height: 24 / 19,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
        color: primary,
      ),
      FfTextRole.titleLg: FfFonts.ui(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
        color: primary,
      ),
      FfTextRole.title: FfFonts.ui(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: primary,
      ),
      FfTextRole.titleSm: FfFonts.ui(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      FfTextRole.bodyLg: FfFonts.ui(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      FfTextRole.body: FfFonts.ui(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      FfTextRole.bodySm: FfFonts.ui(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      FfTextRole.labelLg: FfFonts.ui(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      FfTextRole.label: FfFonts.ui(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: secondary,
      ),
      FfTextRole.labelSm: FfFonts.ui(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: secondary,
      ),
      FfTextRole.moneyHero: moneyHero(color: primary),
      FfTextRole.moneyLg: moneyLg(color: primary),
      FfTextRole.moneyMd: moneyMd(color: primary),
      FfTextRole.moneySm: moneySm(color: primary),
    });
  }

  static FfText forColors(FfColors colors) =>
      build(primary: colors.textPrimary, secondary: colors.textSecondary);
}

/// Text styles of the active theme, read with `context.ff.text`.
@immutable
class FfText extends ThemeExtension<FfText> {
  const FfText(this._styles);

  final Map<FfTextRole, TextStyle> _styles;

  TextStyle operator [](FfTextRole role) =>
      _styles[role] ?? (throw StateError('Type scale is missing $role'));

  TextStyle get displayLg => this[FfTextRole.displayLg];
  TextStyle get display => this[FfTextRole.display];
  TextStyle get displaySm => this[FfTextRole.displaySm];
  TextStyle get headlineLg => this[FfTextRole.headlineLg];
  TextStyle get headline => this[FfTextRole.headline];
  TextStyle get headlineSm => this[FfTextRole.headlineSm];
  TextStyle get titleLg => this[FfTextRole.titleLg];
  TextStyle get title => this[FfTextRole.title];
  TextStyle get titleSm => this[FfTextRole.titleSm];
  TextStyle get bodyLg => this[FfTextRole.bodyLg];
  TextStyle get body => this[FfTextRole.body];
  TextStyle get bodySm => this[FfTextRole.bodySm];
  TextStyle get labelLg => this[FfTextRole.labelLg];
  TextStyle get label => this[FfTextRole.label];
  TextStyle get labelSm => this[FfTextRole.labelSm];
  TextStyle get moneyHero => this[FfTextRole.moneyHero];
  TextStyle get moneyLg => this[FfTextRole.moneyLg];
  TextStyle get moneyMd => this[FfTextRole.moneyMd];
  TextStyle get moneySm => this[FfTextRole.moneySm];

  /// The Material text theme, so stock widgets use the same scale.
  TextTheme toTextTheme() => TextTheme(
    displayLarge: displayLg,
    displayMedium: display,
    displaySmall: displaySm,
    headlineLarge: headlineLg,
    headlineMedium: headline,
    headlineSmall: headlineSm,
    titleLarge: titleLg,
    titleMedium: title,
    titleSmall: titleSm,
    bodyLarge: bodyLg,
    bodyMedium: body,
    bodySmall: bodySm,
    labelLarge: labelLg,
    labelMedium: label,
    labelSmall: labelSm,
  );

  @override
  FfText copyWith({Map<FfTextRole, TextStyle>? overrides}) =>
      FfText({..._styles, ...?overrides});

  @override
  FfText lerp(ThemeExtension<FfText>? other, double t) {
    if (other is! FfText) return this;
    return FfText({
      for (final role in FfTextRole.values)
        role: TextStyle.lerp(this[role], other[role], t)!,
    });
  }
}
