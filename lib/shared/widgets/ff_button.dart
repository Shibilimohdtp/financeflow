import 'package:flutter/material.dart';
import '../../theme/ff.dart';

enum FfButtonVariant {
  primary,
  filled,
  secondary,
  outlined,
  text,
  destructive,
  spark,
}

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
    final shape = FfShape.of(
      size == FfButtonSize.sm ? FfButtonTokens.radiusSm : FfButtonTokens.radius,
    );

    final double minHeight = switch (size) {
      FfButtonSize.sm => 36.0,
      FfButtonSize.md => FfButtonTokens.heightMd,
      FfButtonSize.lg => FfButtonTokens.heightLg,
    };

    final double fontSize = size == FfButtonSize.sm ? 12.0 : 14.0;

    final loadingColor = switch (variant) {
      FfButtonVariant.primary ||
      FfButtonVariant.filled => context.ff.color.onActionPrimary,
      FfButtonVariant.secondary => context.ff.color.onSecondaryContainer,
      FfButtonVariant.destructive => context.ff.color.onStatusError,
      FfButtonVariant.spark => context.ff.color.onSpark,
      FfButtonVariant.outlined ||
      FfButtonVariant.text => context.ff.color.actionPrimary,
    };

    Widget labelWidget =
        isLoading
            ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: loadingColor,
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: FfSpace.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: fontSize),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
            backgroundColor: context.ff.color.actionPrimary,
            foregroundColor: context.ff.color.onActionPrimary,
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
            backgroundColor: context.ff.color.secondaryContainer,
            foregroundColor: context.ff.color.onSecondaryContainer,
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
            foregroundColor: context.ff.color.actionPrimary,
            side: BorderSide(
              color: context.ff.color.borderStrong,
              width: FfBorderWidth.regular,
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
            foregroundColor: context.ff.color.actionPrimary,
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
            backgroundColor: context.ff.color.statusError,
            foregroundColor: context.ff.color.onStatusError,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
          ),
          child: labelWidget,
        );
        break;

      case FfButtonVariant.spark:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.ff.color.spark,
            foregroundColor: context.ff.color.onSpark,
            minimumSize: Size(width ?? 0, minHeight),
            shape: shape,
            elevation: 0,
          ),
          child: labelWidget,
        );
        break;
    }

    return button;
  }
}
