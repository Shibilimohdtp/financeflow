import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// The status a banner reports. Each tone has its own icon, so the meaning
/// never rests on colour alone.
enum FfBannerTone { info, success, warning, error }

/// An inline message inside a screen or dialog: "Backup is 30 days old",
/// "App lock was turned off during restore". Not for transient feedback;
/// use `FfToast` for that.
class FfBanner extends StatelessWidget {
  const FfBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = FfBannerTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final FfBannerTone tone;

  /// Replaces the tone's default icon when a more specific one helps.
  final IconData? icon;

  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows a close button when set.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final (Color fg, Color bg, IconData defaultIcon) = switch (tone) {
      FfBannerTone.info => (
        c.statusInfo,
        c.statusInfoContainer,
        Icons.info_outline_rounded,
      ),
      FfBannerTone.success => (
        c.statusSuccess,
        c.statusSuccessContainer,
        Icons.check_circle_outline_rounded,
      ),
      FfBannerTone.warning => (
        c.statusWarning,
        c.statusWarningContainer,
        Icons.warning_amber_rounded,
      ),
      FfBannerTone.error => (
        c.statusError,
        c.statusErrorContainer,
        Icons.error_outline_rounded,
      ),
    };

    return Semantics(
      container: true,
      liveRegion: tone == FfBannerTone.error,
      child: Container(
        padding: const EdgeInsetsDirectional.all(FfBannerTokens.padding),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: ffRadius(FfBannerTokens.radius),
          border: Border.all(color: fg, width: FfBorderWidth.hairline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? defaultIcon, size: FfBannerTokens.iconSize, color: fg),
            const SizedBox(width: FfBannerTokens.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: ff.text.titleSm.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: FfSpace.x2s),
                  ],
                  Text(
                    message,
                    style: ff.text.bodySm.copyWith(color: c.textPrimary),
                  ),
                  if (actionLabel != null && onAction != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: fg,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, FfTouch.minTarget),
                        ),
                        child: Text(actionLabel!),
                      ),
                    ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Dismiss',
                icon: Icon(
                  Icons.close_rounded,
                  size: FfIconSize.md,
                  color: c.textSecondary,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
