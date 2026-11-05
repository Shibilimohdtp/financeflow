import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_divider.dart';

/// A rounded card that groups list rows. It draws the dividers between rows
/// and clips their ink to its corners, so rows never need to know whether
/// they are first or last.
class FfGroupedContainer extends StatelessWidget {
  const FfGroupedContainer({
    super.key,
    required this.children,
    this.padding,
    this.margin,
    this.showDividers = true,
    this.dividerInset,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showDividers;

  /// Start dividers where the rows' text starts. Null draws full-width
  /// dividers.
  final FfRowLeading? dividerInset;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final c = context.ff.color;

    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      divided.add(children[i]);
      if (showDividers && i < children.length - 1) {
        divided.add(
          dividerInset == null
              ? const FfDivider()
              : FfDivider.inset(after: dividerInset!),
        );
      }
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: ffRadius(FfCardTokens.radius),
        border: Border.all(
          color: c.borderSubtle,
          width: FfCardTokens.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: ffRadius(FfCardTokens.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: divided,
        ),
      ),
    );
  }
}
