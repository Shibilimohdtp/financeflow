import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stillwater_colors.dart';
import 'stillwater_tokens.dart';
import 'stillwater_typography.dart';

/// Stillwater Theme Generator (Daylight and Deep Water)
class StillwaterTheme {
  StillwaterTheme._();

  /// Daylight (Light) Theme
  static ThemeData get daylight {
    final textTheme = StillwaterTypography.createTextTheme(
      StillwaterColors.lightTextPrimary,
      StillwaterColors.lightTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: StillwaterColors.lightPrimary,
      onPrimary: StillwaterColors.lightOnPrimary,
      primaryContainer: StillwaterColors.lightPrimaryContainer,
      onPrimaryContainer: StillwaterColors.lightOnPrimaryContainer,
      secondary: StillwaterColors.lightSecondary,
      onSecondary: StillwaterColors.lightSurfaceDefault,
      secondaryContainer: StillwaterColors.lightSecondaryContainer,
      onSecondaryContainer: StillwaterColors.lightOnSecondaryContainer,
      tertiary: StillwaterColors.lightAccent,
      onTertiary: Colors.white,
      tertiaryContainer: StillwaterColors.lightAccentContainer,
      onTertiaryContainer: StillwaterColors.lightOnAccentContainer,
      error: StillwaterColors.lightError,
      onError: Colors.white,
      errorContainer: StillwaterColors.lightErrorContainer,
      onErrorContainer: StillwaterColors.lightError,
      surface: StillwaterColors.lightSurfaceDefault,
      onSurface: StillwaterColors.lightTextPrimary,
      surfaceContainerLowest: StillwaterColors.lightSurfaceElevated,
      surfaceContainerLow: StillwaterColors.lightSurfaceContainerLow,
      surfaceContainer: StillwaterColors.lightSurfaceContainer,
      surfaceContainerHigh: StillwaterColors.lightSurfaceContainerHigh,
      surfaceContainerHighest: StillwaterColors.lightBorderHairline,
      outline: StillwaterColors.lightBorderStrong,
      outlineVariant: StillwaterColors.lightBorderHairline,
      scrim: Color(0x7A10201C),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: StillwaterColors.lightSurfaceApp,
      canvasColor: StillwaterColors.lightSurfaceApp,
      cardColor: StillwaterColors.lightSurfaceDefault,
      dividerColor: StillwaterColors.lightBorderHairline,
      textTheme: textTheme,
      extensions: const [
        FfFinColors.daylight,
        FfAiColors.daylight,
        FfSecColors.daylight,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: StillwaterColors.lightSurfaceApp,
        foregroundColor: StillwaterColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: StillwaterColors.lightSurfaceApp,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardTheme(
        color: StillwaterColors.lightSurfaceDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          side: const BorderSide(
            color: StillwaterColors.lightBorderHairline,
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StillwaterColors.lightPrimary,
          foregroundColor: StillwaterColors.lightOnPrimary,
          minimumSize: const Size.fromHeight(
            StillwaterTokens.buttonHeightPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StillwaterColors.lightPrimary,
          minimumSize: const Size.fromHeight(
            StillwaterTokens.buttonHeightPrimary,
          ),
          side: const BorderSide(
            color: StillwaterColors.lightBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StillwaterColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StillwaterColors.lightSurfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceMd,
          vertical: StillwaterTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.lightBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.lightBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.lightBorderFocus,
            width: StillwaterTokens.borderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.lightError,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.lightError,
            width: StillwaterTokens.borderWidthFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: StillwaterColors.lightTextSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: StillwaterColors.lightTextTertiary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: StillwaterColors.lightSurfaceDefault,
        elevation: 0,
        height: 68,
        indicatorColor: StillwaterColors.lightSurfaceTintPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: StillwaterColors.lightPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: StillwaterColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: StillwaterColors.lightPrimary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: StillwaterColors.lightTextSecondary,
            size: 24,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: StillwaterColors.lightSurfaceDefault,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StillwaterTokens.radius2Xl),
          ),
        ),
        dragHandleColor: StillwaterColors.lightBorderStrong,
        dragHandleSize: Size(32, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: StillwaterColors.lightSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXl),
        ),
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: StillwaterColors.lightPrimary,
        foregroundColor: StillwaterColors.lightOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StillwaterColors.lightSecInk,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: StillwaterColors.lightBorderHairline,
        thickness: StillwaterTokens.borderWidthHairline,
        space: 1,
      ),
    );
  }

  /// Deep Water (Dark) Theme
  static ThemeData get deepWater {
    final textTheme = StillwaterTypography.createTextTheme(
      StillwaterColors.darkTextPrimary,
      StillwaterColors.darkTextSecondary,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: StillwaterColors.darkPrimary,
      onPrimary: StillwaterColors.darkOnPrimary,
      primaryContainer: StillwaterColors.darkPrimaryContainer,
      onPrimaryContainer: StillwaterColors.darkOnPrimaryContainer,
      secondary: StillwaterColors.darkSecondary,
      onSecondary: StillwaterColors.darkSurfaceDefault,
      secondaryContainer: StillwaterColors.darkSecondaryContainer,
      onSecondaryContainer: StillwaterColors.darkOnSecondaryContainer,
      tertiary: StillwaterColors.darkAccent,
      onTertiary: Colors.black,
      tertiaryContainer: StillwaterColors.darkAccentContainer,
      onTertiaryContainer: StillwaterColors.darkOnAccentContainer,
      error: StillwaterColors.darkError,
      onError: Colors.black,
      errorContainer: StillwaterColors.darkErrorContainer,
      onErrorContainer: StillwaterColors.darkError,
      surface: StillwaterColors.darkSurfaceDefault,
      onSurface: StillwaterColors.darkTextPrimary,
      surfaceContainerLowest: StillwaterColors.darkSurfaceApp,
      surfaceContainerLow: StillwaterColors.darkSurfaceContainerLow,
      surfaceContainer: StillwaterColors.darkSurfaceContainer,
      surfaceContainerHigh: StillwaterColors.darkSurfaceContainerHigh,
      surfaceContainerHighest: StillwaterColors.darkSurfaceElevated,
      outline: StillwaterColors.darkBorderStrong,
      outlineVariant: StillwaterColors.darkBorderHairline,
      scrim: Color(0x99050B0A),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: StillwaterColors.darkSurfaceApp,
      canvasColor: StillwaterColors.darkSurfaceApp,
      cardColor: StillwaterColors.darkSurfaceDefault,
      dividerColor: StillwaterColors.darkBorderHairline,
      textTheme: textTheme,
      extensions: const [
        FfFinColors.deepWater,
        FfAiColors.deepWater,
        FfSecColors.deepWater,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: StillwaterColors.darkSurfaceApp,
        foregroundColor: StillwaterColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: StillwaterColors.darkSurfaceApp,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardTheme(
        color: StillwaterColors.darkSurfaceDefault,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          side: const BorderSide(
            color: StillwaterColors.darkBorderHairline,
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StillwaterColors.darkPrimary,
          foregroundColor: StillwaterColors.darkOnPrimary,
          minimumSize: const Size.fromHeight(
            StillwaterTokens.buttonHeightPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StillwaterColors.darkPrimary,
          minimumSize: const Size.fromHeight(
            StillwaterTokens.buttonHeightPrimary,
          ),
          side: const BorderSide(
            color: StillwaterColors.darkBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StillwaterColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StillwaterColors.darkSurfaceDefault,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceMd,
          vertical: StillwaterTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.darkBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.darkBorderDefault,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.darkBorderFocus,
            width: StillwaterTokens.borderWidthFocus,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.darkError,
            width: StillwaterTokens.borderWidthDefault,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          borderSide: const BorderSide(
            color: StillwaterColors.darkError,
            width: StillwaterTokens.borderWidthFocus,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: StillwaterColors.darkTextSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: StillwaterColors.darkTextTertiary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: StillwaterColors.darkSurfaceDefault,
        elevation: 0,
        height: 68,
        indicatorColor: StillwaterColors.darkSurfaceTintPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: StillwaterColors.darkPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: StillwaterColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: StillwaterColors.darkPrimary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: StillwaterColors.darkTextSecondary,
            size: 24,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: StillwaterColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StillwaterTokens.radius2Xl),
          ),
        ),
        dragHandleColor: StillwaterColors.darkBorderStrong,
        dragHandleSize: Size(32, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: StillwaterColors.darkSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXl),
        ),
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: StillwaterColors.darkPrimary,
        foregroundColor: StillwaterColors.darkOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StillwaterColors.darkSurfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: StillwaterColors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: StillwaterColors.darkBorderHairline,
        thickness: StillwaterTokens.borderWidthHairline,
        space: 1,
      ),
    );
  }
}
