import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// What a toast is telling the user. Non-neutral tones add an icon, so the
/// meaning never rests on colour alone.
enum FfToastTone {
  neutral(null, null),
  success(Icons.check_circle_outline_rounded, 'Done'),
  warning(Icons.info_outline_rounded, 'Check this'),
  error(Icons.error_outline_rounded, 'Error');

  const FfToastTone(this.icon, this.semanticsPrefix);
  final IconData? icon;
  final String? semanticsPrefix;
}

/// Short, temporary feedback at the bottom of the screen ("Transaction
/// deleted", with Undo). The one way to show a snackbar in FinanceFlow.
///
/// Showing a new toast replaces the current one. A toast with an action stays
/// longer ([FfToastTokens.durationWithAction]) so there is time to use it.
abstract final class FfToast {
  static void show(
    BuildContext context, {
    required String message,
    FfToastTone tone = FfToastTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      build(
        context,
        message: message,
        tone: tone,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
  }

  /// The snackbar [show] displays. Exposed for tests and the gallery.
  static SnackBar build(
    BuildContext context, {
    required String message,
    FfToastTone tone = FfToastTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final ff = context.ff;
    final hasAction = actionLabel != null && onAction != null;
    final icon = tone.icon;

    return SnackBar(
      content: Semantics(
        label:
            tone.semanticsPrefix == null
                ? null
                : '${tone.semanticsPrefix}: $message',
        excludeSemantics: tone.semanticsPrefix != null,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: FfIconSize.lg, color: ff.color.onSurfaceToast),
              const SizedBox(width: FfSpace.sm),
            ],
            Expanded(
              child: Text(
                message,
                style: ff.text.body.copyWith(color: ff.color.onSurfaceToast),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: ff.color.surfaceToast,
      duration:
          duration ??
          (hasAction
              ? FfToastTokens.durationWithAction
              : FfToastTokens.duration),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(FfToastTokens.margin),
      shape: RoundedRectangleBorder(
        borderRadius: ffRadius(FfToastTokens.radius),
      ),
      action:
          hasAction
              ? SnackBarAction(
                label: actionLabel,
                textColor: ff.color.toastAction,
                onPressed: onAction,
              )
              : null,
    );
  }
}
