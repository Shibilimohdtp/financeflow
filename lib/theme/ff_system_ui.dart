import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ff_context.dart';

/// The Android status bar and navigation bar style for a Stillwater theme.
///
/// Applied once at the app root (see `FinanceFlowApp`), so every route, with or
/// without an app bar, shows light or dark status icons that match the theme
/// the user picked. Icons are dark on the light canvas and light on the dark one.
SystemUiOverlayStyle ffSystemOverlayStyle(
  FfThemeData ff,
  Brightness brightness,
) {
  final dark = brightness == Brightness.dark;
  final iconBrightness = dark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: ff.color.surfacePage,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}

/// `MaterialApp.builder` that puts the theme's system bar style above every
/// route. The brightness is read from the theme that is active right now, so a
/// light/dark switch updates the status bar on the same frame.
Widget ffSystemUiBuilder(BuildContext context, Widget? child) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: ffSystemOverlayStyle(context.ff, Theme.of(context).brightness),
    child: child ?? const SizedBox.shrink(),
  );
}
