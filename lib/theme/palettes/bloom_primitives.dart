import 'package:flutter/painting.dart';

/// Primitive colour values of Lichen in the Stillwater Bloom style (DS-B1):
/// an airy aurora canvas, ink actions, one lime spark, and the hero gradients.
/// UI code never reads these; `lichen.dart` maps them to semantic roles.
///
/// The older values in `LichenPrimitives` stay frozen for the legacy
/// `StillwaterColors` shim until DS-9.
///
/// Every text pair here is checked by `test/theme/palette_accessibility_test.dart`
/// (see `FfContrastRules`). The proposal and its contrast numbers:
/// https://claude.ai/artifact/U3rVyisZoEVEw8amj8oamH
abstract final class BloomPrimitives {
  // ===================== LIGHT =====================
  // Canvas and the aurora wash (lilac, blush, moss light).
  static const Color lightCanvas = Color(0xFFF3F2EC);
  static const Color lightAuroraCool = Color(0xFFE9E3F1);
  static const Color lightAuroraWarm = Color(0xFFF7E4DC);
  static const Color lightAuroraLeaf = Color(0xFFE4ECD3);

  // Surfaces
  static const Color lightCard = Color(0xFFFEFEFA);
  static const Color lightRaised = Color(0xFFFFFFFF);
  static const Color lightContainerLow = Color(0xFFF0EFE8);
  static const Color lightContainer = Color(0xFFE9E8E0);
  static const Color lightContainerHigh = Color(0xFFE1E1D7);
  static const Color lightContainerHighest = Color(0xFFDADAD0);
  static const Color lightSelected = Color(0xFFE8EFCB);
  static const Color lightGlass = Color(0x9EFFFFFF); // 62% white
  static const Color lightGlassBorder = Color(0xBFFFFFFF);

  // Text
  static const Color lightText = Color(0xFF1C1E18);
  static const Color lightText2 = Color(0xFF575B50);
  static const Color lightText3 = Color(0xFF62665A);
  static const Color lightTextDisabled = Color(0xFFA3A69A);

  // Borders
  static const Color lightHairline = Color(0xFFE3E3D9);
  static const Color lightControl = Color(0xFF858979);
  static const Color lightBorderStrong = Color(0xFF6B715F);
  static const Color lightFocus = Color(0xFF535B36); // lichen

  // Ink (every action and selection) and the lime spark.
  static const Color lightInk = Color(0xFF1B1D17);
  static const Color lightInkStrong = Color(0xFF000000);
  static const Color lightOnInk = Color(0xFFF6F7EF);
  static const Color lightSpark = Color(0xFFCBE94C);
  static const Color lightSparkSoft = Color(0xFFEEF6CC);

  // Money: the shared set approved for DS-8 (expense is brick, so income and
  // expense stay apart under colour blindness).
  static const Color lightIncome = Color(0xFF17694F);
  static const Color lightIncomeContainer = Color(0xFFD9EEE5);
  static const Color lightExpense = Color(0xFFA8432B);
  static const Color lightExpenseContainer = Color(0xFFF8E2D9);
  static const Color lightTransfer = Color(0xFF5B6570);
  static const Color lightTransferContainer = Color(0xFFE4E7EB);
  static const Color lightSavings = Color(0xFF1F6E7A);
  static const Color lightSavingsContainer = Color(0xFFD9ECEF);
  static const Color lightDebt = Color(0xFF74507A);
  static const Color lightDebtContainer = Color(0xFFEEE3EF);
  static const Color lightInvestment = Color(0xFF4A55A3);
  static const Color lightInvestmentContainer = Color(0xFFE3E5F5);

  // Badge fills (the warning triangle on an icon corner).
  static const Color warningFill = Color(0xFFF2A33A);

  // ===================== DARK =====================
  static const Color darkCanvas = Color(0xFF10120E);
  static const Color darkAuroraCool = Color(0xFF1C1724);
  static const Color darkAuroraWarm = Color(0xFF21181A);
  static const Color darkAuroraLeaf = Color(0xFF151C10);

  static const Color darkCard = Color(0xFF191C16);
  static const Color darkRaised = Color(0xFF22261E);
  static const Color darkSunken = Color(0xFF0C0E0A);
  static const Color darkContainerLow = Color(0xFF1D201A);
  static const Color darkContainer = Color(0xFF24281F);
  static const Color darkContainerHigh = Color(0xFF2B3025);
  static const Color darkContainerHighest = Color(0xFF33382C);
  static const Color darkSelected = Color(0xFF2A3219);
  static const Color darkGlass = Color(0xB32A2E25); // 70%
  static const Color darkGlassBorder = Color(0x1AFFFFFF);

  static const Color darkText = Color(0xFFECEEE4);
  static const Color darkText2 = Color(0xFFB8BDAE);
  static const Color darkText3 = Color(0xFF9EA394);
  static const Color darkTextDisabled = Color(0xFF62685A);

  static const Color darkHairline = Color(0xFF2D3228);
  static const Color darkControl = Color(0xFF7E8674);
  static const Color darkBorderStrong = Color(0xFFA0A98F);
  static const Color darkFocus = Color(0xFFC4CC9B);

  static const Color darkInk = Color(0xFFECEEE3);
  static const Color darkInkStrong = Color(0xFFFFFFFF);
  static const Color darkOnInk = Color(0xFF151711);
  static const Color darkSpark = Color(0xFFC6E44A);
  static const Color darkSparkSoft = Color(0xFF2C3518);

  static const Color darkIncome = Color(0xFF86D6A9);
  static const Color darkIncomeContainer = Color(0xFF1E3A2C);
  static const Color darkExpense = Color(0xFFF7A285);
  static const Color darkExpenseContainer = Color(0xFF4A2A1F);
  static const Color darkTransfer = Color(0xFFB4C1CE);
  static const Color darkTransferContainer = Color(0xFF2C343D);
  static const Color darkSavings = Color(0xFF7FCFE0);
  static const Color darkSavingsContainer = Color(0xFF1C3940);
  static const Color darkDebt = Color(0xFFD9B0DC);
  static const Color darkDebtContainer = Color(0xFF3B2B3E);
  static const Color darkInvestment = Color(0xFFB6BEF4);
  static const Color darkInvestmentContainer = Color(0xFF2C3152);

  // ===================== HERO GRADIENTS =====================
  // deep: darkest stop · zone: lightest point any text crosses ·
  // glow: decorative corner that never carries text · on: text colour.
  static const Color heroInk = Color(0xFF1C1E18);

  static const Color lightMossDeep = Color(0xFF27310F);
  static const Color lightMossZone = Color(0xFF4A5C1E);
  static const Color lightMossGlow = Color(0xFFB5D24E);
  static const Color lightMossOn = Color(0xFFF8F9EF);
  static const Color lightRoseDeep = Color(0xFFD9AEBE);
  static const Color lightRoseZone = Color(0xFFF1D6CB);
  static const Color lightRoseGlow = Color(0xFFF9EAD9);
  static const Color lightDuskDeep = Color(0xFF2B2233);
  static const Color lightDuskZone = Color(0xFF54445C);
  static const Color lightDuskGlow = Color(0xFFA7889F);
  static const Color lightDuskOn = Color(0xFFF8F6F9);
  static const Color lightTideDeep = Color(0xFF173238);
  static const Color lightTideZone = Color(0xFF2C5A5E);
  static const Color lightTideGlow = Color(0xFF7FBCA9);
  static const Color lightTideOn = Color(0xFFF2F8F6);
  static const Color lightSandDeep = Color(0xFFD8C8A8);
  static const Color lightSandZone = Color(0xFFECE2CC);
  static const Color lightSandGlow = Color(0xFFF7F1E2);

  static const Color darkMossDeep = Color(0xFF1A220A);
  static const Color darkMossZone = Color(0xFF3F4F19);
  static const Color darkMossGlow = Color(0xFF8EA83A);
  static const Color darkMossOn = Color(0xFFF3F5E9);
  static const Color darkRoseDeep = Color(0xFF2E1B23);
  static const Color darkRoseZone = Color(0xFF5B3843);
  static const Color darkRoseGlow = Color(0xFFA57078);
  static const Color darkRoseOn = Color(0xFFF8EEF0);
  static const Color darkDuskDeep = Color(0xFF1E1824);
  static const Color darkDuskZone = Color(0xFF43364A);
  static const Color darkDuskGlow = Color(0xFF8B7086);
  static const Color darkDuskOn = Color(0xFFF6F2F6);
  static const Color darkTideDeep = Color(0xFF0F2226);
  static const Color darkTideZone = Color(0xFF244A4E);
  static const Color darkTideGlow = Color(0xFF5E9C8C);
  static const Color darkTideOn = Color(0xFFEEF6F3);
  static const Color darkSandDeep = Color(0xFF2A2416);
  static const Color darkSandZone = Color(0xFF4F4630);
  static const Color darkSandGlow = Color(0xFF9C8C62);
  static const Color darkSandOn = Color(0xFFF7F3E8);
}
