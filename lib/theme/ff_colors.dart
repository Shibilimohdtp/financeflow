import 'package:flutter/material.dart';

import 'tokens/ff_foundation.dart';

/// Every semantic colour role in the Stillwater design system. UI code reads
/// colours only through these roles (`context.ff.color.surfaceCard`), never
/// through raw values, so a palette or mode switch restyles the whole app.
///
/// Each palette must give a value for every role in both modes; a test checks
/// this and the contrast of every text/surface pair.
enum FfColorRole {
  // Surfaces
  surfacePage, // screen background
  surfaceCard, // cards, list groups, inputs
  surfaceRaised, // dialogs, popovers
  surfaceSheet, // bottom sheets
  surfaceDim,
  surfaceContainerLowest,
  surfaceContainerLow,
  surfaceContainer,
  surfaceContainerHigh,
  surfaceContainerHighest,
  surfaceSelected, // selected chip, nav indicator, primary-tinted fill
  surfaceAccent, // accent-tinted panel
  surfaceSecure, // privacy and security panels
  surfaceInk, // deepest private surface (lock screen)
  onSurfaceInk,
  surfaceToast, // snackbars
  onSurfaceToast,
  toastAction, // snackbar action such as Undo
  surfaceInverse,
  onSurfaceInverse,

  // Text
  textPrimary,
  textSecondary,
  textTertiary,
  textDisabled,

  // Borders
  borderSubtle, // dividers, card outlines (decorative)
  borderControl, // inputs and chips (must reach 3:1)
  borderStrong,
  focusRing,

  // Actions
  actionPrimary,
  actionPrimaryStrong, // pressed / emphasis
  onActionPrimary,
  actionPrimaryContainer,
  onActionPrimaryContainer,
  actionInverse, // primary on surfaceInverse
  secondary,
  onSecondary,
  secondaryContainer,
  onSecondaryContainer,
  accent,
  accentBright,
  onAccent,
  accentContainer,
  onAccentContainer,

  // Money
  moneyIncome,
  moneyIncomeContainer,
  moneyExpense,
  moneyExpenseContainer,
  moneyTransfer,
  moneyTransferContainer,
  moneySavings,
  moneySavingsContainer,
  moneyDebt,
  moneyDebtContainer,
  moneyInvestment,
  moneyInvestmentContainer,

  // Status
  statusSuccess,
  statusWarning,
  statusWarningContainer,
  statusInfo,
  statusInfoContainer,
  statusError,
  onStatusError,
  statusErrorContainer,
  privacyBoundary, // "may leave this device" markers
  // Utility
  scrim,
  shadow,
}

/// Semantic colours of the active theme, read with `context.ff.color`.
@immutable
class FfColors extends ThemeExtension<FfColors> {
  const FfColors(this._values);

  final Map<FfColorRole, Color> _values;

  Color operator [](FfColorRole role) =>
      _values[role] ?? (throw StateError('Palette is missing $role'));

  /// Roles this set has no value for. Empty for a valid palette.
  List<FfColorRole> get missingRoles =>
      FfColorRole.values.where((r) => !_values.containsKey(r)).toList();

  /// [base] at one of the standard tint levels, for soft fills behind icons,
  /// selected rows and status backgrounds.
  Color tint(Color base, FfTint level) => base.withValues(alpha: level.alpha);

  Color get surfacePage => this[FfColorRole.surfacePage];
  Color get surfaceCard => this[FfColorRole.surfaceCard];
  Color get surfaceRaised => this[FfColorRole.surfaceRaised];
  Color get surfaceSheet => this[FfColorRole.surfaceSheet];
  Color get surfaceDim => this[FfColorRole.surfaceDim];
  Color get surfaceContainerLowest => this[FfColorRole.surfaceContainerLowest];
  Color get surfaceContainerLow => this[FfColorRole.surfaceContainerLow];
  Color get surfaceContainer => this[FfColorRole.surfaceContainer];
  Color get surfaceContainerHigh => this[FfColorRole.surfaceContainerHigh];
  Color get surfaceContainerHighest =>
      this[FfColorRole.surfaceContainerHighest];
  Color get surfaceSelected => this[FfColorRole.surfaceSelected];
  Color get surfaceAccent => this[FfColorRole.surfaceAccent];
  Color get surfaceSecure => this[FfColorRole.surfaceSecure];
  Color get surfaceInk => this[FfColorRole.surfaceInk];
  Color get onSurfaceInk => this[FfColorRole.onSurfaceInk];
  Color get surfaceToast => this[FfColorRole.surfaceToast];
  Color get onSurfaceToast => this[FfColorRole.onSurfaceToast];
  Color get toastAction => this[FfColorRole.toastAction];
  Color get surfaceInverse => this[FfColorRole.surfaceInverse];
  Color get onSurfaceInverse => this[FfColorRole.onSurfaceInverse];

  Color get textPrimary => this[FfColorRole.textPrimary];
  Color get textSecondary => this[FfColorRole.textSecondary];
  Color get textTertiary => this[FfColorRole.textTertiary];
  Color get textDisabled => this[FfColorRole.textDisabled];

  Color get borderSubtle => this[FfColorRole.borderSubtle];
  Color get borderControl => this[FfColorRole.borderControl];
  Color get borderStrong => this[FfColorRole.borderStrong];
  Color get focusRing => this[FfColorRole.focusRing];

  Color get actionPrimary => this[FfColorRole.actionPrimary];
  Color get actionPrimaryStrong => this[FfColorRole.actionPrimaryStrong];
  Color get onActionPrimary => this[FfColorRole.onActionPrimary];
  Color get actionPrimaryContainer => this[FfColorRole.actionPrimaryContainer];
  Color get onActionPrimaryContainer =>
      this[FfColorRole.onActionPrimaryContainer];
  Color get actionInverse => this[FfColorRole.actionInverse];
  Color get secondary => this[FfColorRole.secondary];
  Color get onSecondary => this[FfColorRole.onSecondary];
  Color get secondaryContainer => this[FfColorRole.secondaryContainer];
  Color get onSecondaryContainer => this[FfColorRole.onSecondaryContainer];
  Color get accent => this[FfColorRole.accent];
  Color get accentBright => this[FfColorRole.accentBright];
  Color get onAccent => this[FfColorRole.onAccent];
  Color get accentContainer => this[FfColorRole.accentContainer];
  Color get onAccentContainer => this[FfColorRole.onAccentContainer];

  Color get moneyIncome => this[FfColorRole.moneyIncome];
  Color get moneyIncomeContainer => this[FfColorRole.moneyIncomeContainer];
  Color get moneyExpense => this[FfColorRole.moneyExpense];
  Color get moneyExpenseContainer => this[FfColorRole.moneyExpenseContainer];
  Color get moneyTransfer => this[FfColorRole.moneyTransfer];
  Color get moneyTransferContainer => this[FfColorRole.moneyTransferContainer];
  Color get moneySavings => this[FfColorRole.moneySavings];
  Color get moneySavingsContainer => this[FfColorRole.moneySavingsContainer];
  Color get moneyDebt => this[FfColorRole.moneyDebt];
  Color get moneyDebtContainer => this[FfColorRole.moneyDebtContainer];
  Color get moneyInvestment => this[FfColorRole.moneyInvestment];
  Color get moneyInvestmentContainer =>
      this[FfColorRole.moneyInvestmentContainer];

  Color get statusSuccess => this[FfColorRole.statusSuccess];
  Color get statusWarning => this[FfColorRole.statusWarning];
  Color get statusWarningContainer => this[FfColorRole.statusWarningContainer];
  Color get statusInfo => this[FfColorRole.statusInfo];
  Color get statusInfoContainer => this[FfColorRole.statusInfoContainer];
  Color get statusError => this[FfColorRole.statusError];
  Color get onStatusError => this[FfColorRole.onStatusError];
  Color get statusErrorContainer => this[FfColorRole.statusErrorContainer];
  Color get privacyBoundary => this[FfColorRole.privacyBoundary];

  Color get scrim => this[FfColorRole.scrim];
  Color get shadow => this[FfColorRole.shadow];

  @override
  FfColors copyWith({Map<FfColorRole, Color>? overrides}) =>
      FfColors({..._values, ...?overrides});

  @override
  FfColors lerp(ThemeExtension<FfColors>? other, double t) {
    if (other is! FfColors) return this;
    return FfColors({
      for (final role in FfColorRole.values)
        role: Color.lerp(this[role], other[role], t)!,
    });
  }
}
