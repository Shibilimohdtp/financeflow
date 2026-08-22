import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

enum FfButtonVariant { primary, filled, secondary, outlined, text, destructive }

enum FfButtonSize { sm, md, lg }

class FfButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final FfButtonVariant variant;
  final FfButtonSize size;
  final Widget? leadingIcon;
  final bool isLoading;
  final double? width;

  const FfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FfButtonVariant.primary,
    this.size = FfButtonSize.md,
    this.leadingIcon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        size == FfButtonSize.sm
            ? StillwaterTokens.radiusSm
            : StillwaterTokens.radiusMd,
      ),
    );

    final double minHeight = switch (size) {
      FfButtonSize.sm => 36.0,
      FfButtonSize.md => StillwaterTokens.buttonHeightSecondary,
      FfButtonSize.lg => StillwaterTokens.buttonHeightPrimary,
    };

    final double fontSize = size == FfButtonSize.sm ? 12.0 : 14.0;

    Widget labelWidget =
        isLoading
            ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: StillwaterTokens.spaceXs),
                ],
                Text(
                  label,
                  style: TextStyle(fontSize: fontSize),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            );

    Widget button;

    switch (variant) {
      case FfButtonVariant.primary:
      case FfButtonVariant.filled:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.primary,
            foregroundColor: context.theme.colorScheme.onPrimary,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
          ),
          child: labelWidget,
        );
        break;

      case FfButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.secondaryContainer,
            foregroundColor: context.theme.colorScheme.onSecondaryContainer,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
            elevation: 0,
          ),
          child: labelWidget,
        );
        break;

      case FfButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: context.theme.colorScheme.primary,
            side: BorderSide(
              color: context.theme.colorScheme.outline,
              width: StillwaterTokens.borderWidthDefault,
            ),
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
          ),
          child: labelWidget,
        );
        break;

      case FfButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: context.theme.colorScheme.primary,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
          ),
          child: labelWidget,
        );
        break;

      case FfButtonVariant.destructive:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.colorScheme.error,
            foregroundColor: context.theme.colorScheme.onError,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
          ),
          child: labelWidget,
        );
        break;
    }

    return button;
  }
}
