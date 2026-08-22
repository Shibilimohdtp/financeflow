import 'package:flutter/material.dart';

/// Stillwater Colors Palette & Theme Extensions
///
/// Daylight (Light) and Deep Water (Dark) colors derived strictly from
/// the Stillwater Design System Specification.
class StillwaterColors {
  StillwaterColors._();

  // ===================== DAYLIGHT (LIGHT) =====================
  // Primary (Deepwater)
  static const Color lightPrimary = Color(0xFF0E5F55); // Deepwater 600
  static const Color lightPrimaryDark = Color(0xFF093F39); // Deepwater 800
  static const Color lightPrimaryContainer = Color(0xFFD3EDE6); // Deepwater 100
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF07423B);

  // Secondary (Shore)
  static const Color lightSecondary = Color(0xFF71624A); // Shore 600
  static const Color lightSecondaryContainer = Color(0xFFF0E6D2); // Shore 150
  static const Color lightOnSecondaryContainer = Color(0xFF4A3E2B);

  // Tertiary / Accent (Marigold / AI)
  static const Color lightAccent = Color(0xFF9C6410); // Marigold 600
  static const Color lightAccentBright = Color(0xFFC98A1F);
  static const Color lightAccentContainer = Color(0xFFFAE3BC);
  static const Color lightOnAccentContainer = Color(0xFF5A3A06);

  // Neutrals & Surfaces (Mist)
  static const Color lightSurfaceApp = Color(
    0xFFF7F5EF,
  ); // Root background (warm paper)
  static const Color lightSurfaceDefault = Color(0xFFFDFDFB); // Cards, sheets
  static const Color lightSurfaceContainerLow = Color(
    0xFFF2F0E8,
  ); // Insets, search resting
  static const Color lightSurfaceContainer = Color(
    0xFFEDEBE2,
  ); // Grouped backgrounds
  static const Color lightSurfaceContainerHigh = Color(
    0xFFE7E5DC,
  ); // Pressed containers
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // Dialogs, FAB
  static const Color lightSurfaceAi = Color(0xFFFBF3E3); // AI insight surfaces
  static const Color lightSurfaceSecurity = Color(
    0xFFE3EFE9,
  ); // Security panels
  static const Color lightSurfaceTintPrimary = Color(
    0xFFE7F3F0,
  ); // Selected tint

  // Text
  static const Color lightTextPrimary = Color(0xFF1B2422);
  static const Color lightTextSecondary = Color(0xFF4E5B57);
  static const Color lightTextTertiary = Color(0xFF77857F);
  static const Color lightTextDisabled = Color(0xFFA9B3AE);

  // Borders
  static const Color lightBorderHairline = Color(0xFFE4E2D8);
  static const Color lightBorderDefault = Color(0xFFD8D6CB);
  static const Color lightBorderStrong = Color(0xFFB9B7AB);
  static const Color lightBorderFocus = Color(0xFF0E5F55);

  // Semantic & Financial
  static const Color lightIncome = Color(
    0xFF177A50,
  ); // Grove Green (Income/Credits)
  static const Color lightIncomeContainer = Color(0xFFD7EFE0);
  static const Color lightExpense = Color(
    0xFFAE4E2E,
  ); // Terracotta Clay (Expense/Debits)
  static const Color lightExpenseContainer = Color(0xFFF7E2D8);
  static const Color lightSavings = Color(0xFF0E7263); // Goals
  static const Color lightDebt = Color(0xFF6D4A78); // Damson Plum (Loans, EMI)
  static const Color lightInvestment = Color(
    0xFF4756A6,
  ); // Neel Indigo (Investments)
  static const Color lightTransfer = Color(0xFF5C7078); // Slate (Transfers)
  static const Color lightWarning = Color(0xFF9A6A00);
  static const Color lightWarningContainer = Color(0xFFF8ECC8);
  static const Color lightInfo = Color(0xFF3E6278);
  static const Color lightInfoContainer = Color(0xFFDCE8EF);
  static const Color lightError = Color(0xFFC23A22);
  static const Color lightErrorContainer = Color(0xFFFBDFD8);

  // Security & Privacy
  static const Color lightSecInk = Color(0xFF142B27);
  static const Color lightSecVerified = Color(0xFF177A50);
  static const Color lightSecBoundary = Color(0xFFC98A1F);

  // ===================== DEEP WATER (DARK) =====================
  // Primary (Deepwater)
  static const Color darkPrimary = Color(0xFF7AD8C6);
  static const Color darkPrimaryDark = Color(0xFF8FE2D2);
  static const Color darkPrimaryContainer = Color(0xFF0E4C43);
  static const Color darkOnPrimary = Color(0xFF063B33);
  static const Color darkOnPrimaryContainer = Color(0xFFC6F0E6);

  // Secondary (Shore)
  static const Color darkSecondary = Color(0xFFD6C4A2);
  static const Color darkSecondaryContainer = Color(0xFF43392A);
  static const Color darkOnSecondaryContainer = Color(0xFFF0E6D2);

  // Tertiary / Accent (Marigold / AI)
  static const Color darkAccent = Color(0xFFE9B366);
  static const Color darkAccentBright = Color(0xFFE9B366);
  static const Color darkAccentContainer = Color(0xFF3B2C10);
  static const Color darkOnAccentContainer = Color(0xFFF8E4C0);

  // Neutrals & Surfaces (Ink Water)
  static const Color darkSurfaceApp = Color(0xFF0B1412); // Root background
  static const Color darkSurfaceDefault = Color(0xFF101B19); // Cards
  static const Color darkSurfaceContainerLow = Color(0xFF14201E); // Insets
  static const Color darkSurfaceContainer = Color(0xFF182624); // Groups
  static const Color darkSurfaceContainerHigh = Color(0xFF1D2D2A); // Pressed
  static const Color darkSurfaceElevated = Color(0xFF21332F); // Dialogs, FAB
  static const Color darkSurfaceAi = Color(0xFF201D12); // AI surfaces
  static const Color darkSurfaceSecurity = Color(0xFF10241F); // Security panels
  static const Color darkSurfaceTintPrimary = Color(
    0xFF12332E,
  ); // Selected tint

  // Text
  static const Color darkTextPrimary = Color(0xFFE6EDE8);
  static const Color darkTextSecondary = Color(0xFFA9B8B0);
  static const Color darkTextTertiary = Color(0xFF7E8D86);
  static const Color darkTextDisabled = Color(0xFF56635E);

  // Borders
  static const Color darkBorderHairline = Color(0xFF22322E);
  static const Color darkBorderDefault = Color(0xFF2E3D39);
  static const Color darkBorderStrong = Color(0xFF45544F);
  static const Color darkBorderFocus = Color(0xFF7AD8C6);

  // Semantic & Financial
  static const Color darkIncome = Color(0xFF6FD39B);
  static const Color darkIncomeContainer = Color(0xFF143324);
  static const Color darkExpense = Color(0xFFE59276);
  static const Color darkExpenseContainer = Color(0xFF3A1F14);
  static const Color darkSavings = Color(0xFF62CBB5);
  static const Color darkDebt = Color(0xFFC79BD4);
  static const Color darkInvestment = Color(0xFFA3B0EE);
  static const Color darkTransfer = Color(0xFF9FB6BF);
  static const Color darkWarning = Color(0xFFE5C069);
  static const Color darkWarningContainer = Color(0xFF362A0C);
  static const Color darkInfo = Color(0xFF9CC0D6);
  static const Color darkInfoContainer = Color(0xFF14252E);
  static const Color darkError = Color(0xFFF2866F);
  static const Color darkErrorContainer = Color(0xFF41160B);

  // Security & Privacy
  static const Color darkSecInk = Color(0xFF081210);
  static const Color darkSecVerified = Color(0xFF6FD39B);
  static const Color darkSecBoundary = Color(0xFFE9B366);
}

/// ThemeExtension for Financial Palette
class FfFinColors extends ThemeExtension<FfFinColors> {
  final Color income;
  final Color incomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color savings;
  final Color debt;
  final Color investment;
  final Color transfer;

  const FfFinColors({
    required this.income,
    required this.incomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.savings,
    required this.debt,
    required this.investment,
    required this.transfer,
  });

  static const daylight = FfFinColors(
    income: StillwaterColors.lightIncome,
    incomeContainer: StillwaterColors.lightIncomeContainer,
    expense: StillwaterColors.lightExpense,
    expenseContainer: StillwaterColors.lightExpenseContainer,
    savings: StillwaterColors.lightSavings,
    debt: StillwaterColors.lightDebt,
    investment: StillwaterColors.lightInvestment,
    transfer: StillwaterColors.lightTransfer,
  );

  static const deepWater = FfFinColors(
    income: StillwaterColors.darkIncome,
    incomeContainer: StillwaterColors.darkIncomeContainer,
    expense: StillwaterColors.darkExpense,
    expenseContainer: StillwaterColors.darkExpenseContainer,
    savings: StillwaterColors.darkSavings,
    debt: StillwaterColors.darkDebt,
    investment: StillwaterColors.darkInvestment,
    transfer: StillwaterColors.darkTransfer,
  );

  @override
  ThemeExtension<FfFinColors> copyWith({
    Color? income,
    Color? incomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? savings,
    Color? debt,
    Color? investment,
    Color? transfer,
  }) {
    return FfFinColors(
      income: income ?? this.income,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      expense: expense ?? this.expense,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      savings: savings ?? this.savings,
      debt: debt ?? this.debt,
      investment: investment ?? this.investment,
      transfer: transfer ?? this.transfer,
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
      debt: Color.lerp(debt, other.debt, t)!,
      investment: Color.lerp(investment, other.investment, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
    );
  }
}

/// ThemeExtension for AI Moments
class FfAiColors extends ThemeExtension<FfAiColors> {
  final Color accent;
  final Color container;
  final Color surface;

  const FfAiColors({
    required this.accent,
    required this.container,
    required this.surface,
  });

  static const daylight = FfAiColors(
    accent: StillwaterColors.lightAccent,
    container: StillwaterColors.lightAccentContainer,
    surface: StillwaterColors.lightSurfaceAi,
  );

  static const deepWater = FfAiColors(
    accent: StillwaterColors.darkAccent,
    container: StillwaterColors.darkAccentContainer,
    surface: StillwaterColors.darkSurfaceAi,
  );

  @override
  ThemeExtension<FfAiColors> copyWith({
    Color? accent,
    Color? container,
    Color? surface,
  }) {
    return FfAiColors(
      accent: accent ?? this.accent,
      container: container ?? this.container,
      surface: surface ?? this.surface,
    );
  }

  @override
  ThemeExtension<FfAiColors> lerp(ThemeExtension<FfAiColors>? other, double t) {
    if (other is! FfAiColors) return this;
    return FfAiColors(
      accent: Color.lerp(accent, other.accent, t)!,
      container: Color.lerp(container, other.container, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

/// ThemeExtension for Privacy & Security Colors
class FfSecColors extends ThemeExtension<FfSecColors> {
  final Color ink;
  final Color verified;
  final Color boundary;
  final Color surface;
  final Color error;

  const FfSecColors({
    required this.ink,
    required this.verified,
    required this.boundary,
    required this.surface,
    required this.error,
  });

  static const daylight = FfSecColors(
    ink: StillwaterColors.lightSecInk,
    verified: StillwaterColors.lightSecVerified,
    boundary: StillwaterColors.lightSecBoundary,
    surface: StillwaterColors.lightSurfaceSecurity,
    error: StillwaterColors.lightError,
  );

  static const deepWater = FfSecColors(
    ink: StillwaterColors.darkSecInk,
    verified: StillwaterColors.darkSecVerified,
    boundary: StillwaterColors.darkSecBoundary,
    surface: StillwaterColors.darkSurfaceSecurity,
    error: StillwaterColors.darkError,
  );

  @override
  ThemeExtension<FfSecColors> copyWith({
    Color? ink,
    Color? verified,
    Color? boundary,
    Color? surface,
    Color? error,
  }) {
    return FfSecColors(
      ink: ink ?? this.ink,
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
      verified: Color.lerp(verified, other.verified, t)!,
      boundary: Color.lerp(boundary, other.boundary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
