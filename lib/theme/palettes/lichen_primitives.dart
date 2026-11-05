import 'package:flutter/painting.dart';

/// Primitive colour values of the Lichen palette (the default FinanceFlow
/// look). These are raw values; UI code never reads them. `lichen.dart` maps
/// them to semantic roles, and `StillwaterColors` is a legacy alias of this
/// class until design-system slice DS-9.
///
/// Light mode is "Mist" surfaces with lichen-green primary, mushroom
/// secondary and mineral-rose accent; dark mode is the ink-water variant.
abstract final class LichenPrimitives {
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

  // Tertiary / Accent (Mineral Rose)
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
