import 'package:flutter/material.dart';

import 'ff_dialog.dart';

/// Legacy name for [FfDialog.confirm], kept for files another chat owns
/// (budgets). New code calls `FfDialog.confirm`. Removed in design-system
/// slice DS-9.
class FfConfirmDialog {
  FfConfirmDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) => FfDialog.confirm(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    destructive: isDestructive,
  );
}
