import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'legacy_colors.dart';
import 'legacy_tokens.dart';
import 'legacy_typography.dart';

/// FinanceFlow theme generator. Public names remain stable for compatibility.
class LegacyTheme {
  LegacyTheme._();

  /// Daylight (Light) Theme
  static ThemeData get daylight {
    final textTheme = LegacyTypography.createTextTheme(
      LegacyColors.lightTextPrimary,
      LegacyColors.lightTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: LegacyColors.lightPrimary,
      onPrimary: LegacyColors.lightOnPrimary,
      primaryContainer: LegacyColors.lightPrimaryContainer,
      onPrimaryContainer: LegacyColors.lightOnPrimaryContainer,
      secondary: LegacyColors.lightSecondary,
      onSecondary: LegacyColors.lightOnSecondary,
      secondaryContainer: LegacyColors.lightSecondaryContainer,
      onSecondaryContainer: LegacyColors.lightOnSecondaryContainer,
      tertiary: LegacyColors.lightAccent,
      onTertiary: LegacyColors.lightOnAccent,
      tertiaryContainer: LegacyColors.lightAccentContainer,
      onTertiaryContainer: LegacyColors.lightOnAccentContainer,
      error: LegacyColors.lightError,
      onError: LegacyColors.lightOnError,
      errorContainer: LegacyColors.lightErrorContainer,
      onErrorContainer: LegacyColors.lightError,
      surface: LegacyColors.lightSurfaceDefault,
      onSurface: LegacyColors.lightTextPrimary,
      onSurfaceVariant: LegacyColors.lightTextSecondary,
      surfaceDim: LegacyColors.lightSurfaceContainerHighest,
      surfaceBright: LegacyColors.lightSurfaceElevated,
      surfaceContainerLowest: LegacyColors.lightSurfaceElevated,
      surfaceContainerLow: LegacyColors.lightSurfaceContainerLow,
      surfaceContainer: LegacyColors.lightSurfaceContainer,
      surfaceContainerHigh: LegacyColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: LegacyColors.lightSurfaceContainerHighest,
      outline: LegacyColors.lightBorderStrong,
      outlineVariant: LegacyColors.lightBorderHairline,
      shadow: LegacyColors.darkSecInk,
      scrim: LegacyColors.lightScrim,
      inverseSurface: LegacyColors.darkSurfaceDefault,
      onInverseSurface: LegacyColors.darkTextPrimary,
      inversePrimary: LegacyColors.darkPrimary,
      surfaceTint: LegacyColors.lightPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LegacyColors.lightSurfaceApp,
      canvasColor: LegacyColors.lightSurfaceApp,
      cardColor: LegacyColors.lightSurfaceDefault,
      dividerColor: LegacyColors.lightBorderHairline,
      textTheme: textTheme,
      extensions: const [
        LegacyFinColors.daylight,
        LegacyStatusColors.daylight,
        LegacyAccentColors.daylight,
        LegacySecColors.daylight,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: LegacyColors.lightSurfaceApp,
        foregroundColor: LegacyColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: LegacyColors.lightSurfaceApp,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardTheme(
        color: LegacyColors.lightSurfaceDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusLg),
          side: const BorderSide(
            color: LegacyColors.lightBorderHairline,
            width: LegacyTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LegacyColors.lightPrimary,
          foregroundColor: LegacyColors.lightOnPrimary,
          minimumSize: const Size(0, LegacyTokens.buttonHeightPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LegacyColors.lightPrimary,
          minimumSize: const Size(0, LegacyTokens.buttonHeightPrimary),
          side: const BorderSide(
            color: LegacyColors.lightBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LegacyColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LegacyColors.lightSurfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LegacyTokens.spaceMd,
          vertical: LegacyTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.lightBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.lightBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.lightBorderFocus,
            width: LegacyTokens.borderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.lightError,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.lightError,
            width: LegacyTokens.borderWidthFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.lightTextSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.lightTextTertiary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LegacyColors.lightSurfaceDefault,
        elevation: 0,
        height: 72,
        indicatorColor: LegacyColors.lightSurfaceTintPrimary,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: LegacyColors.lightPrimary,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: LegacyColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: LegacyColors.lightPrimary,
              size: 22,
            );
          }
          return const IconThemeData(
            color: LegacyColors.lightTextSecondary,
            size: 22,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LegacyColors.lightSurfaceDefault,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LegacyTokens.radius2Xl),
          ),
        ),
        dragHandleColor: LegacyColors.lightBorderStrong,
        dragHandleSize: Size(32, 4),
        showDragHandle: false,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: LegacyColors.lightSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusXl),
        ),
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: LegacyColors.lightPrimary,
        foregroundColor: LegacyColors.lightOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LegacyColors.lightSecInk,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.lightOnSecInk,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: LegacyColors.lightBorderHairline,
        thickness: LegacyTokens.borderWidthHairline,
        space: 1,
      ),
    );
  }

  /// Deep Water (Dark) Theme
  static ThemeData get deepWater {
    final textTheme = LegacyTypography.createTextTheme(
      LegacyColors.darkTextPrimary,
      LegacyColors.darkTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: LegacyColors.darkPrimary,
      onPrimary: LegacyColors.darkOnPrimary,
      primaryContainer: LegacyColors.darkPrimaryContainer,
      onPrimaryContainer: LegacyColors.darkOnPrimaryContainer,
      secondary: LegacyColors.darkSecondary,
      onSecondary: LegacyColors.darkOnSecondary,
      secondaryContainer: LegacyColors.darkSecondaryContainer,
      onSecondaryContainer: LegacyColors.darkOnSecondaryContainer,
      tertiary: LegacyColors.darkAccent,
      onTertiary: LegacyColors.darkOnAccent,
      tertiaryContainer: LegacyColors.darkAccentContainer,
      onTertiaryContainer: LegacyColors.darkOnAccentContainer,
      error: LegacyColors.darkError,
      onError: LegacyColors.darkOnError,
      errorContainer: LegacyColors.darkErrorContainer,
      onErrorContainer: LegacyColors.darkError,
      surface: LegacyColors.darkSurfaceDefault,
      onSurface: LegacyColors.darkTextPrimary,
      onSurfaceVariant: LegacyColors.darkTextSecondary,
      surfaceDim: LegacyColors.darkSurfaceApp,
      surfaceBright: LegacyColors.darkSurfaceElevated,
      surfaceContainerLowest: LegacyColors.darkSurfaceApp,
      surfaceContainerLow: LegacyColors.darkSurfaceContainerLow,
      surfaceContainer: LegacyColors.darkSurfaceContainer,
      surfaceContainerHigh: LegacyColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: LegacyColors.darkSurfaceContainerHighest,
      outline: LegacyColors.darkBorderStrong,
      outlineVariant: LegacyColors.darkBorderHairline,
      shadow: LegacyColors.darkSecInk,
      scrim: LegacyColors.darkScrim,
      inverseSurface: LegacyColors.lightSurfaceDefault,
      onInverseSurface: LegacyColors.lightTextPrimary,
      inversePrimary: LegacyColors.lightPrimary,
      surfaceTint: LegacyColors.darkPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LegacyColors.darkSurfaceApp,
      canvasColor: LegacyColors.darkSurfaceApp,
      cardColor: LegacyColors.darkSurfaceDefault,
      dividerColor: LegacyColors.darkBorderHairline,
      textTheme: textTheme,
      extensions: const [
        LegacyFinColors.deepWater,
        LegacyStatusColors.deepWater,
        LegacyAccentColors.deepWater,
        LegacySecColors.deepWater,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: LegacyColors.darkSurfaceApp,
        foregroundColor: LegacyColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: LegacyColors.darkSurfaceApp,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        color: LegacyColors.darkSurfaceDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusLg),
          side: const BorderSide(
            color: LegacyColors.darkBorderHairline,
            width: LegacyTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LegacyColors.darkPrimary,
          foregroundColor: LegacyColors.darkOnPrimary,
          minimumSize: const Size(0, LegacyTokens.buttonHeightPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LegacyColors.darkPrimary,
          minimumSize: const Size(0, LegacyTokens.buttonHeightPrimary),
          side: const BorderSide(
            color: LegacyColors.darkBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LegacyColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LegacyColors.darkSurfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LegacyTokens.spaceMd,
          vertical: LegacyTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.darkBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.darkBorderDefault,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.darkBorderFocus,
            width: LegacyTokens.borderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.darkError,
            width: LegacyTokens.borderWidthDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
          borderSide: const BorderSide(
            color: LegacyColors.darkError,
            width: LegacyTokens.borderWidthFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.darkTextSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.darkTextTertiary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LegacyColors.darkSurfaceDefault,
        elevation: 0,
        height: 72,
        indicatorColor: LegacyColors.darkSurfaceTintPrimary,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: LegacyColors.darkPrimary,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: LegacyColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: LegacyColors.darkPrimary,
              size: 22,
            );
          }
          return const IconThemeData(
            color: LegacyColors.darkTextSecondary,
            size: 22,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LegacyColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LegacyTokens.radius2Xl),
          ),
        ),
        dragHandleColor: LegacyColors.darkBorderStrong,
        dragHandleSize: Size(32, 4),
        showDragHandle: false,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: LegacyColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusXl),
        ),
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: LegacyColors.darkPrimary,
        foregroundColor: LegacyColors.darkOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LegacyColors.darkSurfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: LegacyColors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LegacyTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: LegacyColors.darkBorderHairline,
        thickness: LegacyTokens.borderWidthHairline,
        space: 1,
      ),
    );
  }
}
