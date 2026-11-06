import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// How a card sets itself apart from the page.
enum FfCardVariant {
  /// The default: card surface on a soft shadow (a faint rim in dark mode).
  standard,

  /// A soft wash of [FfCard.tone] (defaults to primary) for highlighted
  /// summaries. No shadow.
  tinted,

  /// A raised surface with a stronger shadow, for things that float.
  elevated,

  /// Warning wash and border, for attention items.
  warning,
}

/// A squircle content container. Colour, shape, shadow and padding come from
/// tokens; [density] picks the comfortable (summary) or compact (list) size.
/// Pass [onTap] to make the whole card a button.
class FfCard extends StatelessWidget {
  const FfCard({
    super.key,
    required this.child,
    this.variant = FfCardVariant.standard,
    this.tone = FfTone.primary,
    this.density = FfDensity.comfortable,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final FfCardVariant variant;

  /// Tint colour of the [FfCardVariant.tinted] variant.
  final FfTone tone;
  final FfDensity density;

  /// Overrides the density's padding.
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  /// The standard card look as a decoration, for containers that need their
  /// own `Material`/`InkWell` (use `Ink` so the ripple shows on top).
  static ShapeDecoration decorationOf(
    BuildContext context, {
    FfDensity density = FfDensity.comfortable,
  }) {
    final c = context.ff.color;
    return ShapeDecoration(
      shape: FfShape.of(density.cardRadius),
      color: c.surfaceCard,
      shadows: FfElevation.card(c.shadow, Theme.of(context).brightness),
    );
  }

  /// The card outline for [density], for `InkWell.customBorder`.
  static ShapeBorder shapeOf(FfDensity density) =>
      FfShape.of(density.cardRadius);

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final brightness = Theme.of(context).brightness;
    final (
      Color background,
      BorderSide side,
      List<BoxShadow> shadows,
    ) = switch (variant) {
      FfCardVariant.standard => (
        c.surfaceCard,
        BorderSide.none,
        FfElevation.card(c.shadow, brightness),
      ),
      FfCardVariant.tinted => (
        c.tint(tone.container(c), FfTint.strong),
        BorderSide(
          color: c.tint(tone.foreground(c), FfTint.medium),
          width: FfCardTokens.borderWidth,
        ),
        const <BoxShadow>[],
      ),
      FfCardVariant.elevated => (
        c.surfaceRaised,
        BorderSide.none,
        FfElevation.float(c.shadow, brightness),
      ),
      FfCardVariant.warning => (
        c.statusWarningContainer,
        BorderSide(color: c.statusWarning, width: FfCardTokens.borderWidth),
        const <BoxShadow>[],
      ),
    };
    final shape = FfShape.of(density.cardRadius, side: side);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(density.cardPadding),
      decoration: ShapeDecoration(
        shape: shape,
        color: background,
        shadows: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, customBorder: shape, child: content),
      );
    }
    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}
