import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ff_colors.dart';
import 'ff_typography.dart';
import 'palettes/ff_palette.dart';
import 'stillwater_colors.dart';
import 'tokens/ff_component_tokens.dart';
import 'tokens/ff_foundation.dart';

/// Builds the app's `ThemeData` for any palette in either brightness. This is
/// the only place Material component themes are configured: the
/// `ColorScheme`, `TextTheme` and every component theme come from the same
/// semantic colours ([FfColors]) and type scale ([FfText]).
abstract final class FfTheme {
  static ThemeData light([FfPalette palette = FfPalettes.lichen]) =>
      build(palette, Brightness.light);

  static ThemeData dark([FfPalette palette = FfPalettes.lichen]) =>
      build(palette, Brightness.dark);

  static ThemeData build(FfPalette palette, Brightness brightness) {
    final c = palette.colorsFor(brightness);
    final text = FfTypography.forColors(c);
    final textTheme = text.toTextTheme();
    final isDark = brightness == Brightness.dark;
    final overlayIcons = isDark ? Brightness.light : Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.actionPrimary,
      onPrimary: c.onActionPrimary,
      primaryContainer: c.actionPrimaryContainer,
      onPrimaryContainer: c.onActionPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.secondaryContainer,
      onSecondaryContainer: c.onSecondaryContainer,
      tertiary: c.accent,
      onTertiary: c.onAccent,
      tertiaryContainer: c.accentContainer,
      onTertiaryContainer: c.onAccentContainer,
      error: c.statusError,
      onError: c.onStatusError,
      errorContainer: c.statusErrorContainer,
      onErrorContainer: c.statusError,
      surface: c.surfaceCard,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceDim: c.surfaceDim,
      surfaceBright: c.surfaceRaised,
      surfaceContainerLowest: c.surfaceContainerLowest,
      surfaceContainerLow: c.surfaceContainerLow,
      surfaceContainer: c.surfaceContainer,
      surfaceContainerHigh: c.surfaceContainerHigh,
      surfaceContainerHighest: c.surfaceContainerHighest,
      outline: c.borderStrong,
      outlineVariant: c.borderSubtle,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.surfaceInverse,
      onInverseSurface: c.onSurfaceInverse,
      inversePrimary: c.actionInverse,
      surfaceTint: c.actionPrimary,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: ffRadius(FfButtonTokens.radius),
    );
    final buttonLabel = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );

    OutlineInputBorder fieldBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: ffRadius(FfFieldTokens.radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.surfacePage,
      canvasColor: c.surfacePage,
      cardColor: c.surfaceCard,
      dividerColor: c.borderSubtle,
      textTheme: textTheme,
      extensions: [
        c,
        text,
        FfFinColors.fromColors(c),
        FfStatusColors.fromColors(c),
        FfAccentColors.fromColors(c),
        FfSecColors.fromColors(c),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfacePage,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: overlayIcons,
          systemNavigationBarColor: c.surfacePage,
          systemNavigationBarIconBrightness: overlayIcons,
        ),
      ),
      cardTheme: CardTheme(
        color: c.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfCardTokens.radius),
          side: BorderSide(
            color: c.borderSubtle,
            width: FfCardTokens.borderWidth,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.actionPrimary,
          foregroundColor: c.onActionPrimary,
          minimumSize: const Size(0, FfButtonTokens.heightLg),
          shape: buttonShape,
          textStyle: buttonLabel,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.actionPrimary,
          minimumSize: const Size(0, FfButtonTokens.heightLg),
          side: BorderSide(
            color: c.borderControl,
            width: FfBorderWidth.regular,
          ),
          shape: buttonShape,
          textStyle: buttonLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.actionPrimary,
          shape: buttonShape,
          textStyle: buttonLabel,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FfFieldTokens.paddingH,
          vertical: FfFieldTokens.paddingV,
        ),
        border: fieldBorder(c.borderControl, FfBorderWidth.regular),
        enabledBorder: fieldBorder(c.borderControl, FfBorderWidth.regular),
        focusedBorder: fieldBorder(c.focusRing, FfBorderWidth.focus),
        errorBorder: fieldBorder(c.statusError, FfBorderWidth.regular),
        focusedErrorBorder: fieldBorder(c.statusError, FfBorderWidth.focus),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.textTertiary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceCard,
        elevation: 0,
        height: FfNavBarTokens.height,
        indicatorColor: c.surfaceSelected,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: c.actionPrimary,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? c.actionPrimary : c.textSecondary,
            size: FfNavBarTokens.iconSize,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceSheet,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FfSheetTokens.radius),
          ),
        ),
        dragHandleColor: c.borderStrong,
        dragHandleSize: FfSheetTokens.dragHandle,
        showDragHandle: false,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfDialogTokens.radius),
        ),
        elevation: FfDialogTokens.elevation,
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfDialogTokens.radius),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfDialogTokens.radius),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.actionPrimary,
        foregroundColor: c.onActionPrimary,
        elevation: FfFabTokens.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfFabTokens.radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceToast,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.onSurfaceToast,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ffRadius(FfToastTokens.radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: c.borderSubtle,
        thickness: FfDividerTokens.thickness,
        space: FfDividerTokens.space,
      ),
    );
  }
}
