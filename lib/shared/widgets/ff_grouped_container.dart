import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

/// A standard Stillwater rounded container that groups list rows or items
/// with subtle backgrounds, hairline borders, and optional dividers.
class FfGroupedContainer extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool showDividers;

  const FfGroupedContainer({
    super.key,
    required this.children,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = StillwaterTokens.radiusLg,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bg = backgroundColor ?? theme.cardColor;
    final border = borderColor ?? theme.dividerColor;

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final dividedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      dividedChildren.add(children[i]);
      if (showDividers && i < children.length - 1) {
        dividedChildren.add(
          Divider(
            height: 1,
            thickness: StillwaterTokens.borderWidthHairline,
            color: theme.dividerColor,
          ),
        );
      }
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: border,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dividedChildren,
        ),
      ),
    );
  }
}
