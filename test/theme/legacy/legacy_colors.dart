import 'package:flutter/material.dart';

/// FinanceFlow Lichen Ledger palette and theme extensions.
///
/// Daylight (Light) and Deep Water (Dark) colors derived strictly from
/// the Legacy Design System Specification.
class LegacyColors {
  LegacyColors._();

  // ===================== DAYLIGHT (LIGHT) =====================
  // Primary (Lichen)
  static const Color lightPrimary = Color(0xFF535B36);
  static const Color lightPrimaryDark = Color(0xFF394022);
  static const Color lightPrimaryContainer = Color(0xFFE3E8CB);
  static const Color lightOnPrimary = Color(0xFFFCFCF5);
  static const Color lightOnPrimaryContainer = Color(0xFF282F16);

  // Secondary (Mushroom)
  static const Color lightSecondary = Color(0xFF655C68);
  static const Color lightSecondaryContainer = Color(0xFFECE3EB);
  static const Color lightOnSecondary = Color(0xFFFAF9F3);
  static const Color lightOnSecondaryContainer = Color(0xFF382F3B);

  // Tertiary / Accent (Mineral Rose)
  static const Color lightAccent = Color(0xFF76546A);
  static const Color lightAccentBright = Color(0xFFA77D92);
  static const Color lightAccentContainer = Color(0xFFF1DFEA);
  static const Color lightOnAccent = Color(0xFFFDFCF7);
  static const Color lightOnAccentContainer = Color(0xFF422B3A);

  // Neutrals & Surfaces (Mist)
  static const Color lightSurfaceApp = Color(0xFFF5F4ED);
  static const Color lightSurfaceDefault = Color(0xFFFAF9F3);
  static const Color lightSurfaceContainerLow = Color(0xFFF0EFE7);
  static const Color lightSurfaceContainer = Color(0xFFEAE9DF);
  static const Color lightSurfaceContainerHigh = Color(0xFFE3E3D7);
  static const Color lightSurfaceContainerHighest = Color(0xFFDCDDD1);
  static const Color lightSurfaceElevated = Color(0xFFFDFCF7);
  static const Color lightSurfaceAccent = Color(0xFFF5EDF1);
  static const Color lightSurfaceSecurity = Color(0xFFEDF0E3);
  static const Color lightSurfaceTintPrimary = Color(0xFFE9EDD9);

  // Text
  static const Color lightTextPrimary = Color(0xFF252820);
  static const Color lightTextSecondary = Color(0xFF55594F);
  static const Color lightTextTertiary = Color(0xFF606559);
  static const Color lightTextDisabled = Color(0xFF9DA195);

  // Borders
  static const Color lightBorderHairline = Color(0xFFDCDDD1);
  static const Color lightBorderDefault = Color(0xFF7B806F);
  static const Color lightBorderStrong = Color(0xFF6B715F);
  static const Color lightBorderFocus = Color(0xFF535B36);

  // Semantic & Financial
  static const Color lightIncome = Color(0xFF216843);
  static const Color lightIncomeContainer = Color(0xFFDDEDDD);
  static const Color lightExpense = Color(0xFF9F3D50);
  static const Color lightExpenseContainer = Color(0xFFF5DFE3);
  static const Color lightSavings = Color(0xFF326A70);
  static const Color lightSavingsContainer = Color(0xFFDDEDEE);
  static const Color lightDebt = Color(0xFF80523E);
  static const Color lightDebtContainer = Color(0xFFF0E3D9);
  static const Color lightInvestment = Color(0xFF55569A);
  static const Color lightInvestmentContainer = Color(0xFFE5E4F6);
  static const Color lightTransfer = Color(0xFF536474);
  static const Color lightTransferContainer = Color(0xFFE3E9EF);
  static const Color lightWarning = Color(0xFF795B12);
  static const Color lightWarningContainer = Color(0xFFF3E8C7);
  static const Color lightInfo = Color(0xFF385F82);
  static const Color lightInfoContainer = Color(0xFFDFEAF5);
  static const Color lightError = Color(0xFFAD3529);
  static const Color lightErrorContainer = Color(0xFFF9E0DA);
  static const Color lightOnError = Color(0xFFFDFCF7);

  // Security & Privacy
  static const Color lightSecInk = Color(0xFF24291E);
  static const Color lightOnSecInk = Color(0xFFF4F6EB);
  static const Color lightSecVerified = Color(0xFF216843);
  static const Color lightSecBoundary = Color(0xFF795B12);
  static const Color lightScrim = Color(0x7A171B12);

  // ===================== DEEP WATER (DARK) =====================
  // Primary (Lichen)
  static const Color darkPrimary = Color(0xFFC4CC9B);
  static const Color darkPrimaryDark = Color(0xFFD7DEB5);
  static const Color darkPrimaryContainer = Color(0xFF3E4728);
  static const Color darkOnPrimary = Color(0xFF292F18);
  static const Color darkOnPrimaryContainer = Color(0xFFE6EBCF);

  // Secondary (Shore)
  static const Color darkSecondary = Color(0xFFCEC0D0);
  static const Color darkSecondaryContainer = Color(0xFF493F4C);
  static const Color darkOnSecondary = Color(0xFF1C2019);
  static const Color darkOnSecondaryContainer = Color(0xFFEFE3F0);

  // Tertiary / Accent (Marigold)
  static const Color darkAccent = Color(0xFFDFB6CD);
  static const Color darkAccentBright = Color(0xFFEDCADE);
  static const Color darkAccentContainer = Color(0xFF533849);
  static const Color darkOnAccent = Color(0xFF30212B);
  static const Color darkOnAccentContainer = Color(0xFFF7DEEC);

  // Neutrals & Surfaces (Ink Water)
  static const Color darkSurfaceApp = Color(0xFF151812);
  static const Color darkSurfaceDefault = Color(0xFF1C2019);
  static const Color darkSurfaceContainerLow = Color(0xFF22261E);
  static const Color darkSurfaceContainer = Color(0xFF292D24);
  static const Color darkSurfaceContainerHigh = Color(0xFF30352A);
  static const Color darkSurfaceContainerHighest = Color(0xFF383D31);
  static const Color darkSurfaceElevated = Color(0xFF383D31);
  static const Color darkSurfaceAccent = Color(0xFF2B242B);
  static const Color darkSurfaceSecurity = Color(0xFF242D21);
  static const Color darkSurfaceTintPrimary = Color(0xFF343D26);

  // Text
  static const Color darkTextPrimary = Color(0xFFE8EBDF);
  static const Color darkTextSecondary = Color(0xFFC0C5B6);
  static const Color darkTextTertiary = Color(0xFFABB19F);
  static const Color darkTextDisabled = Color(0xFF717867);

  // Borders
  static const Color darkBorderHairline = Color(0xFF3A4033);
  static const Color darkBorderDefault = Color(0xFF838B77);
  static const Color darkBorderStrong = Color(0xFFA0A98F);
  static const Color darkBorderFocus = Color(0xFFC4CC9B);

  // Semantic & Financial
  static const Color darkIncome = Color(0xFF8CD7A5);
  static const Color darkIncomeContainer = Color(0xFF243D2B);
  static const Color darkExpense = Color(0xFFF0A6B7);
  static const Color darkExpenseContainer = Color(0xFF472832);
  static const Color darkSavings = Color(0xFF91CED1);
  static const Color darkSavingsContainer = Color(0xFF253D40);
  static const Color darkDebt = Color(0xFFDEB39A);
  static const Color darkDebtContainer = Color(0xFF443327);
  static const Color darkInvestment = Color(0xFFBEC0F1);
  static const Color darkInvestmentContainer = Color(0xFF32334F);
  static const Color darkTransfer = Color(0xFFB4C5D7);
  static const Color darkTransferContainer = Color(0xFF303B48);
  static const Color darkWarning = Color(0xFFE8CA7C);
  static const Color darkWarningContainer = Color(0xFF43381B);
  static const Color darkInfo = Color(0xFFA8CDEF);
  static const Color darkInfoContainer = Color(0xFF273B4D);
  static const Color darkError = Color(0xFFFFA99A);
  static const Color darkErrorContainer = Color(0xFF502B24);
  static const Color darkOnError = Color(0xFF3D100B);

  // Security & Privacy
  static const Color darkSecInk = Color(0xFF11160E);
  static const Color darkOnSecInk = Color(0xFFF4F6EB);
  static const Color darkSecVerified = Color(0xFF8CD7A5);
  static const Color darkSecBoundary = Color(0xFFE8CA7C);
  static const Color darkScrim = Color(0x99090C07);
}

/// ThemeExtension for Financial Palette
class LegacyFinColors extends ThemeExtension<LegacyFinColors> {
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

  const LegacyFinColors({
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

  static const daylight = LegacyFinColors(
    income: LegacyColors.lightIncome,
    incomeContainer: LegacyColors.lightIncomeContainer,
    expense: LegacyColors.lightExpense,
    expenseContainer: LegacyColors.lightExpenseContainer,
    savings: LegacyColors.lightSavings,
    savingsContainer: LegacyColors.lightSavingsContainer,
    debt: LegacyColors.lightDebt,
    debtContainer: LegacyColors.lightDebtContainer,
    investment: LegacyColors.lightInvestment,
    investmentContainer: LegacyColors.lightInvestmentContainer,
    transfer: LegacyColors.lightTransfer,
    transferContainer: LegacyColors.lightTransferContainer,
  );

  static const deepWater = LegacyFinColors(
    income: LegacyColors.darkIncome,
    incomeContainer: LegacyColors.darkIncomeContainer,
    expense: LegacyColors.darkExpense,
    expenseContainer: LegacyColors.darkExpenseContainer,
    savings: LegacyColors.darkSavings,
    savingsContainer: LegacyColors.darkSavingsContainer,
    debt: LegacyColors.darkDebt,
    debtContainer: LegacyColors.darkDebtContainer,
    investment: LegacyColors.darkInvestment,
    investmentContainer: LegacyColors.darkInvestmentContainer,
    transfer: LegacyColors.darkTransfer,
    transferContainer: LegacyColors.darkTransferContainer,
  );

  @override
  ThemeExtension<LegacyFinColors> copyWith({
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
    return LegacyFinColors(
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
  ThemeExtension<LegacyFinColors> lerp(
    ThemeExtension<LegacyFinColors>? other,
    double t,
  ) {
    if (other is! LegacyFinColors) return this;
    return LegacyFinColors(
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
class LegacyStatusColors extends ThemeExtension<LegacyStatusColors> {
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;

  const LegacyStatusColors({
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
  });

  static const daylight = LegacyStatusColors(
    warning: LegacyColors.lightWarning,
    warningContainer: LegacyColors.lightWarningContainer,
    info: LegacyColors.lightInfo,
    infoContainer: LegacyColors.lightInfoContainer,
  );

  static const deepWater = LegacyStatusColors(
    warning: LegacyColors.darkWarning,
    warningContainer: LegacyColors.darkWarningContainer,
    info: LegacyColors.darkInfo,
    infoContainer: LegacyColors.darkInfoContainer,
  );

  @override
  LegacyStatusColors copyWith({
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
  }) => LegacyStatusColors(
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    info: info ?? this.info,
    infoContainer: infoContainer ?? this.infoContainer,
  );

  @override
  LegacyStatusColors lerp(ThemeExtension<LegacyStatusColors>? other, double t) {
    if (other is! LegacyStatusColors) return this;
    return LegacyStatusColors(
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}

/// ThemeExtension for secondary accent moments (insights, highlights)
class LegacyAccentColors extends ThemeExtension<LegacyAccentColors> {
  final Color accent;
  final Color container;
  final Color surface;

  const LegacyAccentColors({
    required this.accent,
    required this.container,
    required this.surface,
  });

  static const daylight = LegacyAccentColors(
    accent: LegacyColors.lightAccent,
    container: LegacyColors.lightAccentContainer,
    surface: LegacyColors.lightSurfaceAccent,
  );

  static const deepWater = LegacyAccentColors(
    accent: LegacyColors.darkAccent,
    container: LegacyColors.darkAccentContainer,
    surface: LegacyColors.darkSurfaceAccent,
  );

  @override
  ThemeExtension<LegacyAccentColors> copyWith({
    Color? accent,
    Color? container,
    Color? surface,
  }) {
    return LegacyAccentColors(
      accent: accent ?? this.accent,
      container: container ?? this.container,
      surface: surface ?? this.surface,
    );
  }

  @override
  ThemeExtension<LegacyAccentColors> lerp(
    ThemeExtension<LegacyAccentColors>? other,
    double t,
  ) {
    if (other is! LegacyAccentColors) return this;
    return LegacyAccentColors(
      accent: Color.lerp(accent, other.accent, t)!,
      container: Color.lerp(container, other.container, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

/// ThemeExtension for Privacy & Security Colors
class LegacySecColors extends ThemeExtension<LegacySecColors> {
  final Color ink;
  final Color onInk;
  final Color verified;
  final Color boundary;
  final Color surface;
  final Color error;

  const LegacySecColors({
    required this.ink,
    required this.onInk,
    required this.verified,
    required this.boundary,
    required this.surface,
    required this.error,
  });

  static const daylight = LegacySecColors(
    ink: LegacyColors.lightSecInk,
    onInk: LegacyColors.lightOnSecInk,
    verified: LegacyColors.lightSecVerified,
    boundary: LegacyColors.lightSecBoundary,
    surface: LegacyColors.lightSurfaceSecurity,
    error: LegacyColors.lightError,
  );

  static const deepWater = LegacySecColors(
    ink: LegacyColors.darkSecInk,
    onInk: LegacyColors.darkOnSecInk,
    verified: LegacyColors.darkSecVerified,
    boundary: LegacyColors.darkSecBoundary,
    surface: LegacyColors.darkSurfaceSecurity,
    error: LegacyColors.darkError,
  );

  @override
  ThemeExtension<LegacySecColors> copyWith({
    Color? ink,
    Color? onInk,
    Color? verified,
    Color? boundary,
    Color? surface,
    Color? error,
  }) {
    return LegacySecColors(
      ink: ink ?? this.ink,
      onInk: onInk ?? this.onInk,
      verified: verified ?? this.verified,
      boundary: boundary ?? this.boundary,
      surface: surface ?? this.surface,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<LegacySecColors> lerp(
    ThemeExtension<LegacySecColors>? other,
    double t,
  ) {
    if (other is! LegacySecColors) return this;
    return LegacySecColors(
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      boundary: Color.lerp(boundary, other.boundary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
