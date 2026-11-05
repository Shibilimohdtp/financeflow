import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// How a card sets itself apart from the page.
enum FfCardVariant {
  /// The default: card surface with a hairline border.
  standard,

  /// A soft wash of [FfCard.tone] (defaults to primary) for highlighted
  /// summaries.
  tinted,

  /// A raised surface, for heroes that sit above other cards.
  elevated,

  /// Warning wash and border, for attention items.
  warning,
}

/// A rounded content container. Colours, radius, border and padding come
/// from tokens; pass [onTap] to make the whole card a button.
class FfCard extends StatelessWidget {
  const FfCard({
    super.key,
    required this.child,
    this.variant = FfCardVariant.standard,
    this.tone = FfTone.primary,
    this.padding = const EdgeInsets.all(FfCardTokens.padding),
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final FfCardVariant variant;

  /// Tint colour of the [FfCardVariant.tinted] variant.
  final FfTone tone;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final (Color background, Color border) = switch (variant) {
      FfCardVariant.standard => (c.surfaceCard, c.borderSubtle),
      FfCardVariant.tinted => (
        c.tint(tone.container(c), FfTint.strong),
        c.tint(tone.foreground(c), FfTint.medium),
      ),
      FfCardVariant.elevated => (c.surfaceRaised, c.borderSubtle),
      FfCardVariant.warning => (c.statusWarningContainer, c.statusWarning),
    };
    final radius = ffRadius(FfCardTokens.radius);

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: border, width: FfCardTokens.borderWidth),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      type: MaterialType.transparency,
      borderRadius: radius,
      child: InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}
