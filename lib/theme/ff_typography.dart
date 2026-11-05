import 'package:flutter/material.dart';

import 'ff_colors.dart';

/// Every text role in the Stillwater type scale. UI code reads styles through
/// these roles (`context.ff.text.title`), never with raw font sizes.
enum FfTextRole {
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
  /// UI and amounts. Bundled weights: 400, 500, 600, 700, 800.
  static const String manropeFamily = 'Manrope';

  /// Display roles only. Bundled weights: 600, 700.
  static const String frauncesFamily = 'Fraunces';

  /// Used for scripts the bundled fonts don't cover (for example Devanagari).
  static const List<String> fallbackFamilies = [
    'NotoSansDevanagari',
    'Roboto',
    'sans-serif',
  ];

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// Body and UI face.
  static TextStyle manrope({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    List<FontFeature>? fontFeatures,
  }) => TextStyle(
    fontFamily: manropeFamily,
    fontFamilyFallback: fallbackFamilies,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontFeatures: fontFeatures,
  );

  /// Display face, used only by the display roles.
  static TextStyle fraunces({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) => TextStyle(
    fontFamily: frauncesFamily,
    fontFamilyFallback: fallbackFamilies,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );
}

/// The type scale. Sizes, line heights, weights and tracking are defined
/// once here; [FfText] and Material's `TextTheme` are both built from it.
abstract final class FfTypography {
  static TextStyle moneyHero({Color? color}) => FfFonts.manrope(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneyLg({Color? color}) => FfFonts.manrope(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneyMd({Color? color}) => FfFonts.manrope(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  static TextStyle moneySm({Color? color}) => FfFonts.manrope(
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: color,
    fontFeatures: FfFonts.tabularFigures,
  );

  /// All roles in the given text colours. Small supporting roles (bodySm,
  /// label, labelSm) use the secondary colour.
  static FfText build({required Color primary, required Color secondary}) {
    return FfText({
      FfTextRole.displayLg: FfFonts.fraunces(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
        color: primary,
      ),
      FfTextRole.display: FfFonts.fraunces(
        fontSize: 30,
        height: 36 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.50,
        color: primary,
      ),
      FfTextRole.displaySm: FfFonts.fraunces(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      FfTextRole.headlineLg: FfFonts.manrope(
        fontSize: 26,
        height: 32 / 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.40,
        color: primary,
      ),
      FfTextRole.headline: FfFonts.manrope(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.30,
        color: primary,
      ),
      FfTextRole.headlineSm: FfFonts.manrope(
        fontSize: 19,
        height: 24 / 19,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.20,
        color: primary,
      ),
      FfTextRole.titleLg: FfFonts.manrope(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      FfTextRole.title: FfFonts.manrope(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      FfTextRole.titleSm: FfFonts.manrope(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      FfTextRole.bodyLg: FfFonts.manrope(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      FfTextRole.body: FfFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      FfTextRole.bodySm: FfFonts.manrope(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      FfTextRole.labelLg: FfFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      FfTextRole.label: FfFonts.manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      FfTextRole.labelSm: FfFonts.manrope(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
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
