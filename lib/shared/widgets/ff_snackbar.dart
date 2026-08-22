import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

class FfSnackbar {
  FfSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(StillwaterTokens.spaceLg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      ),
      action:
          actionLabel != null && onAction != null
              ? SnackBarAction(
                label: actionLabel,
                textColor: context.theme.colorScheme.primary,
                onPressed: onAction,
              )
              : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
