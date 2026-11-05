import 'package:flutter/material.dart';

import 'ff_toast.dart';

/// Legacy name for [FfToast], kept for files another chat owns (budgets).
/// New code calls `FfToast.show`. Removed in design-system slice DS-9.
class FfSnackbar {
  FfSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) => FfToast.show(
    context,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );
}
