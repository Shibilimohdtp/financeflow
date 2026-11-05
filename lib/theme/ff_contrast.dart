import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'ff_colors.dart';

/// Accessibility measurements for palettes: WCAG contrast and colour-vision
/// simulation. Used by the guardrail test (every palette, every mode) and by
/// the design-system gallery.
abstract final class FfContrast {
  /// WCAG minimum for body text.
  static const double text = 4.5;

  /// WCAG minimum for UI boundaries, icons and focus indicators.
  static const double ui = 3.0;

  /// Minimum CIE76 colour difference between income and expense, under each
  /// simulated colour-vision deficiency, so the pair never relies on signs
  /// alone. About 10 is where two swatches stop reading as "the same colour".
  static const double moneyPairDeltaE = 10;

  /// WCAG 2.x contrast ratio. A translucent [foreground] is first composited
  /// over [background].
  static double ratio(Color foreground, Color background) {
    final fg = Color.alphaBlend(foreground, background);
    final a = fg.computeLuminance();
    final b = background.computeLuminance();
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
  }

  /// CIE76 ΔE between two colours as seen with [vision].
  static double deltaE(Color a, Color b, [FfVision vision = FfVision.typical]) {
    final la = _lab(vision.simulate(a));
    final lb = _lab(vision.simulate(b));
    var sum = 0.0;
    for (var i = 0; i < 3; i++) {
      sum += (la[i] - lb[i]) * (la[i] - lb[i]);
    }
    return math.sqrt(sum);
  }

  static List<double> _lab(List<double> linearRgb) {
    final r = linearRgb[0], g = linearRgb[1], b = linearRgb[2];
    final x = 0.4124 * r + 0.3576 * g + 0.1805 * b;
    final y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    final z = 0.0193 * r + 0.1192 * g + 0.9505 * b;
    double f(double t) =>
        t > 216 / 24389
            ? math.pow(t, 1 / 3).toDouble()
            : (24389 / 27 * t + 16) / 116;
    final fx = f(x / 0.95047), fy = f(y), fz = f(z / 1.08883);
    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }
}

/// Colour-vision types simulated with the Machado et al. (2009) matrices at
/// full severity, applied in linear RGB.
enum FfVision {
  typical(null),
  deuteranopia([
    [0.367322, 0.860646, -0.227968],
    [0.280085, 0.672501, 0.047413],
    [-0.011820, 0.042940, 0.968881],
  ]),
  protanopia([
    [0.152286, 1.052583, -0.204868],
    [0.114503, 0.786281, 0.099216],
    [-0.003882, -0.048116, 1.051998],
  ]),
  tritanopia([
    [1.255528, -0.076749, -0.178779],
    [-0.078411, 0.930809, 0.147602],
    [0.004733, 0.691367, 0.303900],
  ]);

  const FfVision(this._matrix);
  final List<List<double>>? _matrix;

  /// [color] in linear RGB as this viewer would see it.
  List<double> simulate(Color color) {
    double lin(double c) =>
        c <= 0.04045
            ? c / 12.92
            : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    final rgb = [lin(color.r), lin(color.g), lin(color.b)];
    final m = _matrix;
    if (m == null) return rgb;
    return [
      for (final row in m)
        (row[0] * rgb[0] + row[1] * rgb[1] + row[2] * rgb[2]).clamp(0.0, 1.0),
    ];
  }
}

/// One foreground/background pair the app actually draws, and the minimum
/// contrast it needs.
class FfContrastRule {
  const FfContrastRule(
    this.foreground,
    this.background,
    this.minimum,
    this.use,
  );

  final FfColorRole foreground;
  final FfColorRole background;
  final double minimum;

  /// Where the pair appears, in plain words.
  final String use;

  double measure(FfColors colors) =>
      FfContrast.ratio(colors[foreground], colors[background]);

  String get id => '${foreground.name} on ${background.name}';
}

/// Every pair checked for every palette in both modes. When a component
/// starts drawing a new pair, add it here.
abstract final class FfContrastRules {
  static const _t = FfContrast.text;
  static const _ui = FfContrast.ui;

  /// Backgrounds that general text and money amounts sit on.
  static const textSurfaces = [
    FfColorRole.surfacePage,
    FfColorRole.surfaceCard,
    FfColorRole.surfaceRaised,
    FfColorRole.surfaceSheet,
  ];

  /// Roles drawn as text on those backgrounds.
  static const textOnSurfaces = {
    FfColorRole.textPrimary: 'Body text',
    FfColorRole.textSecondary: 'Supporting text',
    FfColorRole.textTertiary: 'Captions, hints, timestamps',
    FfColorRole.actionPrimary: 'Links, text buttons, selected nav label',
    FfColorRole.accent: 'Accent text',
    FfColorRole.moneyIncome: 'Income amounts',
    FfColorRole.moneyExpense: 'Expense amounts',
    FfColorRole.moneyTransfer: 'Transfer amounts',
    FfColorRole.moneySavings: 'Savings amounts',
    FfColorRole.moneyDebt: 'Debt amounts',
    FfColorRole.moneyInvestment: 'Investment amounts',
    FfColorRole.statusSuccess: 'Success and "verified" text',
    FfColorRole.statusWarning: 'Warning text',
    FfColorRole.statusInfo: 'Info text',
    FfColorRole.statusError: 'Error text and field errors',
  };

  static final List<FfContrastRule> all = [
    for (final bg in textSurfaces)
      for (final fg in textOnSurfaces.entries)
        FfContrastRule(fg.key, bg, _t, fg.value),

    // Boundaries and focus.
    const FfContrastRule(
      FfColorRole.borderControl,
      FfColorRole.surfacePage,
      _ui,
      'Input and outlined-button border on the page',
    ),
    const FfContrastRule(
      FfColorRole.borderControl,
      FfColorRole.surfaceCard,
      _ui,
      'Input and chip border inside a card',
    ),
    const FfContrastRule(
      FfColorRole.focusRing,
      FfColorRole.surfacePage,
      _ui,
      'Focus ring on the page',
    ),
    const FfContrastRule(
      FfColorRole.focusRing,
      FfColorRole.surfaceCard,
      _ui,
      'Focus ring inside a card',
    ),
    const FfContrastRule(
      FfColorRole.statusError,
      FfColorRole.surfaceCard,
      _ui,
      'Error border on a field',
    ),

    // Filled controls.
    const FfContrastRule(
      FfColorRole.onActionPrimary,
      FfColorRole.actionPrimary,
      _t,
      'Primary button label, FAB icon',
    ),
    const FfContrastRule(
      FfColorRole.onActionPrimaryContainer,
      FfColorRole.actionPrimaryContainer,
      _t,
      'Text on primary container',
    ),
    const FfContrastRule(
      FfColorRole.onSecondary,
      FfColorRole.secondary,
      _t,
      'Text on secondary fill',
    ),
    const FfContrastRule(
      FfColorRole.onSecondaryContainer,
      FfColorRole.secondaryContainer,
      _t,
      'Secondary button label',
    ),
    const FfContrastRule(
      FfColorRole.onAccent,
      FfColorRole.accent,
      _t,
      'Text on accent fill',
    ),
    const FfContrastRule(
      FfColorRole.onAccentContainer,
      FfColorRole.accentContainer,
      _t,
      'Text on accent container',
    ),
    const FfContrastRule(
      FfColorRole.onStatusError,
      FfColorRole.statusError,
      _t,
      'Destructive button label',
    ),

    // Selected states.
    const FfContrastRule(
      FfColorRole.textPrimary,
      FfColorRole.surfaceSelected,
      _t,
      'Text on a selected chip or row',
    ),
    const FfContrastRule(
      FfColorRole.actionPrimary,
      FfColorRole.surfaceSelected,
      _ui,
      'Selected nav icon on its indicator',
    ),

    // Special surfaces.
    const FfContrastRule(
      FfColorRole.onSurfaceToast,
      FfColorRole.surfaceToast,
      _t,
      'Snackbar message',
    ),
    const FfContrastRule(
      FfColorRole.toastAction,
      FfColorRole.surfaceToast,
      _t,
      'Snackbar action (Undo)',
    ),
    const FfContrastRule(
      FfColorRole.actionInverse,
      FfColorRole.surfaceInverse,
      _t,
      'Primary action on inverse surface',
    ),
    const FfContrastRule(
      FfColorRole.onSurfaceInk,
      FfColorRole.surfaceInk,
      _t,
      'Lock screen text',
    ),
    const FfContrastRule(
      FfColorRole.onSurfaceInverse,
      FfColorRole.surfaceInverse,
      _t,
      'Text on inverse surface',
    ),
    const FfContrastRule(
      FfColorRole.textPrimary,
      FfColorRole.surfaceSecure,
      _t,
      'Text on privacy panels',
    ),
    const FfContrastRule(
      FfColorRole.textPrimary,
      FfColorRole.surfaceAccent,
      _t,
      'Text on accent panels',
    ),

    // Money and status on their own soft containers (badges, banners).
    for (final (fg, bg, use) in const [
      (
        FfColorRole.moneyIncome,
        FfColorRole.moneyIncomeContainer,
        'Income badge',
      ),
      (
        FfColorRole.moneyExpense,
        FfColorRole.moneyExpenseContainer,
        'Expense badge',
      ),
      (
        FfColorRole.moneyTransfer,
        FfColorRole.moneyTransferContainer,
        'Transfer badge',
      ),
      (
        FfColorRole.moneySavings,
        FfColorRole.moneySavingsContainer,
        'Savings badge',
      ),
      (FfColorRole.moneyDebt, FfColorRole.moneyDebtContainer, 'Debt badge'),
      (
        FfColorRole.moneyInvestment,
        FfColorRole.moneyInvestmentContainer,
        'Investment badge',
      ),
      (
        FfColorRole.statusWarning,
        FfColorRole.statusWarningContainer,
        'Warning banner',
      ),
      (FfColorRole.statusInfo, FfColorRole.statusInfoContainer, 'Info banner'),
      (
        FfColorRole.statusError,
        FfColorRole.statusErrorContainer,
        'Error banner',
      ),
    ])
      FfContrastRule(fg, bg, _t, use),
  ];
}
