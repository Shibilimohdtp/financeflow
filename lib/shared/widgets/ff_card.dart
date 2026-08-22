import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

enum FfCardVariant { standard, tinted, elevated, warning }

class FfCard extends StatelessWidget {
  final Widget child;
  final FfCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const FfCard({
    super.key,
    required this.child,
    this.variant = FfCardVariant.standard,
    this.padding = const EdgeInsets.all(StillwaterTokens.spaceLg),
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;

    switch (variant) {
      case FfCardVariant.standard:
        backgroundColor = context.theme.cardColor;
        borderColor = context.theme.dividerColor;
        break;
      case FfCardVariant.tinted:
        backgroundColor = context.theme.colorScheme.primaryContainer.withValues(
          alpha: 0.3,
        );
        borderColor = context.theme.colorScheme.primary.withValues(alpha: 0.2);
        break;
      case FfCardVariant.elevated:
        backgroundColor = context.theme.colorScheme.surfaceContainerLowest;
        borderColor = context.theme.dividerColor;
        break;
      case FfCardVariant.warning:
        backgroundColor = context.theme.colorScheme.tertiaryContainer
            .withValues(alpha: 0.3);
        borderColor = context.theme.colorScheme.tertiary.withValues(alpha: 0.3);
        break;
    }

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          child: content,
        ),
      );
    }

    return content;
  }
}
