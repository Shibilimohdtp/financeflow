import 'package:flutter/material.dart';

import 'ff_colors.dart';
import 'palettes/lichen_primitives.dart';

/// Legacy name for the Lichen primitive colours. Static access cannot follow
/// a theme switch, so new code uses `context.ff.color`. Removed in
/// design-system slice DS-9.
typedef StillwaterColors = LichenPrimitives;

// The four extensions below are the legacy grouped views read through
// `context.finColors`, `statusColors`, `accentColors` and `secColors`.
// `FfTheme` fills them from the active palette with `fromColors`.

/// ThemeExtension for Financial Palette
class FfFinColors extends ThemeExtension<FfFinColors> {
  final Color income;
  final Color incomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color savings;
  final Color savingsContainer;
  final Color debt;
  final Color debtContainer;
  final Color investment;
  final Color investmentContainer;
  final Color transfer;
  final Color transferContainer;

  const FfFinColors({
    required this.income,
    required this.incomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.savings,
    required this.savingsContainer,
    required this.debt,
    required this.debtContainer,
    required this.investment,
    required this.investmentContainer,
    required this.transfer,
    required this.transferContainer,
  });

  factory FfFinColors.fromColors(FfColors c) => FfFinColors(
    income: c.moneyIncome,
    incomeContainer: c.moneyIncomeContainer,
    expense: c.moneyExpense,
    expenseContainer: c.moneyExpenseContainer,
    savings: c.moneySavings,
    savingsContainer: c.moneySavingsContainer,
    debt: c.moneyDebt,
    debtContainer: c.moneyDebtContainer,
    investment: c.moneyInvestment,
    investmentContainer: c.moneyInvestmentContainer,
    transfer: c.moneyTransfer,
    transferContainer: c.moneyTransferContainer,
  );

  static const daylight = FfFinColors(
    income: StillwaterColors.lightIncome,
    incomeContainer: StillwaterColors.lightIncomeContainer,
    expense: StillwaterColors.lightExpense,
    expenseContainer: StillwaterColors.lightExpenseContainer,
    savings: StillwaterColors.lightSavings,
    savingsContainer: StillwaterColors.lightSavingsContainer,
    debt: StillwaterColors.lightDebt,
    debtContainer: StillwaterColors.lightDebtContainer,
    investment: StillwaterColors.lightInvestment,
    investmentContainer: StillwaterColors.lightInvestmentContainer,
    transfer: StillwaterColors.lightTransfer,
    transferContainer: StillwaterColors.lightTransferContainer,
  );

  static const deepWater = FfFinColors(
    income: StillwaterColors.darkIncome,
    incomeContainer: StillwaterColors.darkIncomeContainer,
    expense: StillwaterColors.darkExpense,
    expenseContainer: StillwaterColors.darkExpenseContainer,
    savings: StillwaterColors.darkSavings,
    savingsContainer: StillwaterColors.darkSavingsContainer,
    debt: StillwaterColors.darkDebt,
    debtContainer: StillwaterColors.darkDebtContainer,
    investment: StillwaterColors.darkInvestment,
    investmentContainer: StillwaterColors.darkInvestmentContainer,
    transfer: StillwaterColors.darkTransfer,
    transferContainer: StillwaterColors.darkTransferContainer,
  );

  @override
  ThemeExtension<FfFinColors> copyWith({
    Color? income,
    Color? incomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? savings,
    Color? savingsContainer,
    Color? debt,
    Color? debtContainer,
    Color? investment,
    Color? investmentContainer,
    Color? transfer,
    Color? transferContainer,
  }) {
    return FfFinColors(
      income: income ?? this.income,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      expense: expense ?? this.expense,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      savings: savings ?? this.savings,
      savingsContainer: savingsContainer ?? this.savingsContainer,
      debt: debt ?? this.debt,
      debtContainer: debtContainer ?? this.debtContainer,
      investment: investment ?? this.investment,
      investmentContainer: investmentContainer ?? this.investmentContainer,
      transfer: transfer ?? this.transfer,
      transferContainer: transferContainer ?? this.transferContainer,
    );
  }

  @override
  ThemeExtension<FfFinColors> lerp(
    ThemeExtension<FfFinColors>? other,
    double t,
  ) {
    if (other is! FfFinColors) return this;
    return FfFinColors(
      income: Color.lerp(income, other.income, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseContainer:
          Color.lerp(expenseContainer, other.expenseContainer, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      savingsContainer:
          Color.lerp(savingsContainer, other.savingsContainer, t)!,
      debt: Color.lerp(debt, other.debt, t)!,
      debtContainer: Color.lerp(debtContainer, other.debtContainer, t)!,
      investment: Color.lerp(investment, other.investment, t)!,
      investmentContainer:
          Color.lerp(investmentContainer, other.investmentContainer, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      transferContainer:
          Color.lerp(transferContainer, other.transferContainer, t)!,
    );
  }
}

/// ThemeExtension for non-financial status colors.
class FfStatusColors extends ThemeExtension<FfStatusColors> {
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;

  const FfStatusColors({
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
  });

  factory FfStatusColors.fromColors(FfColors c) => FfStatusColors(
    warning: c.statusWarning,
    warningContainer: c.statusWarningContainer,
    info: c.statusInfo,
    infoContainer: c.statusInfoContainer,
  );

  static const daylight = FfStatusColors(
    warning: StillwaterColors.lightWarning,
    warningContainer: StillwaterColors.lightWarningContainer,
    info: StillwaterColors.lightInfo,
    infoContainer: StillwaterColors.lightInfoContainer,
  );

  static const deepWater = FfStatusColors(
    warning: StillwaterColors.darkWarning,
    warningContainer: StillwaterColors.darkWarningContainer,
    info: StillwaterColors.darkInfo,
    infoContainer: StillwaterColors.darkInfoContainer,
  );

  @override
  FfStatusColors copyWith({
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
  }) => FfStatusColors(
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    info: info ?? this.info,
    infoContainer: infoContainer ?? this.infoContainer,
  );

  @override
  FfStatusColors lerp(ThemeExtension<FfStatusColors>? other, double t) {
    if (other is! FfStatusColors) return this;
    return FfStatusColors(
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}

/// ThemeExtension for secondary accent moments (insights, highlights)
class FfAccentColors extends ThemeExtension<FfAccentColors> {
  final Color accent;
  final Color container;
  final Color surface;

  const FfAccentColors({
    required this.accent,
    required this.container,
    required this.surface,
  });

  factory FfAccentColors.fromColors(FfColors c) => FfAccentColors(
    accent: c.accent,
    container: c.accentContainer,
    surface: c.surfaceAccent,
  );

  static const daylight = FfAccentColors(
    accent: StillwaterColors.lightAccent,
    container: StillwaterColors.lightAccentContainer,
    surface: StillwaterColors.lightSurfaceAccent,
  );

  static const deepWater = FfAccentColors(
    accent: StillwaterColors.darkAccent,
    container: StillwaterColors.darkAccentContainer,
    surface: StillwaterColors.darkSurfaceAccent,
  );

  @override
  ThemeExtension<FfAccentColors> copyWith({
    Color? accent,
    Color? container,
    Color? surface,
  }) {
    return FfAccentColors(
      accent: accent ?? this.accent,
      container: container ?? this.container,
      surface: surface ?? this.surface,
    );
  }

  @override
  ThemeExtension<FfAccentColors> lerp(
    ThemeExtension<FfAccentColors>? other,
    double t,
  ) {
    if (other is! FfAccentColors) return this;
    return FfAccentColors(
      accent: Color.lerp(accent, other.accent, t)!,
      container: Color.lerp(container, other.container, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

/// ThemeExtension for Privacy & Security Colors
class FfSecColors extends ThemeExtension<FfSecColors> {
  final Color ink;
  final Color onInk;
  final Color verified;
  final Color boundary;
  final Color surface;
  final Color error;

  const FfSecColors({
    required this.ink,
    required this.onInk,
    required this.verified,
    required this.boundary,
    required this.surface,
    required this.error,
  });

  factory FfSecColors.fromColors(FfColors c) => FfSecColors(
    ink: c.surfaceInk,
    onInk: c.onSurfaceInk,
    verified: c.statusSuccess,
    boundary: c.privacyBoundary,
    surface: c.surfaceSecure,
    error: c.statusError,
  );

  static const daylight = FfSecColors(
    ink: StillwaterColors.lightSecInk,
    onInk: StillwaterColors.lightOnSecInk,
    verified: StillwaterColors.lightSecVerified,
    boundary: StillwaterColors.lightSecBoundary,
    surface: StillwaterColors.lightSurfaceSecurity,
    error: StillwaterColors.lightError,
  );

  static const deepWater = FfSecColors(
    ink: StillwaterColors.darkSecInk,
    onInk: StillwaterColors.darkOnSecInk,
    verified: StillwaterColors.darkSecVerified,
    boundary: StillwaterColors.darkSecBoundary,
    surface: StillwaterColors.darkSurfaceSecurity,
    error: StillwaterColors.darkError,
  );

  @override
  ThemeExtension<FfSecColors> copyWith({
    Color? ink,
    Color? onInk,
    Color? verified,
    Color? boundary,
    Color? surface,
    Color? error,
  }) {
    return FfSecColors(
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      verified: verified ?? this.verified,
      boundary: boundary ?? this.boundary,
      surface: surface ?? this.surface,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<FfSecColors> lerp(
    ThemeExtension<FfSecColors>? other,
    double t,
  ) {
    if (other is! FfSecColors) return this;
    return FfSecColors(
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      boundary: Color.lerp(boundary, other.boundary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
