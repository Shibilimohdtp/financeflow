import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_contrast.dart';
import '../../theme/ff_typography.dart';
import 'ff_round_buttons.dart';

// ---------------------------------------------------------------------------
// Aurora
// ---------------------------------------------------------------------------

/// The page background: the canvas colour with a soft wash of the palette's
/// aurora stops (cool top start, warm top end, leaf through the middle) that
/// fades out by about mid-screen, so long lists sit on plain canvas.
///
/// Cheap: three radial gradients painted once into a repaint boundary. It is
/// drawn the same way when effects are reduced.
class FfAurora extends StatelessWidget {
  const FfAurora({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(
          base: c.surfacePage,
          cool: c.auroraCool,
          warm: c.auroraWarm,
          leaf: c.auroraLeaf,
        ),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.base,
    required this.cool,
    required this.warm,
    required this.leaf,
  });

  final Color base, cool, warm, leaf;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    canvas.drawRect(full, Paint()..color = base);
    // The wash lives in the top part of the page.
    final washHeight =
        size.width * 1.7 < size.height ? size.width * 1.7 : size.height;
    final wash = Rect.fromLTWH(0, 0, size.width, washHeight);
    void blob(Color color, Alignment center, double radius) {
      canvas.drawRect(
        wash,
        Paint()
          ..shader = RadialGradient(
            center: center,
            radius: radius,
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(wash),
      );
    }

    blob(cool, const Alignment(-1, -1), 1.0);
    blob(warm, const Alignment(1, -0.85), 0.85);
    blob(leaf, const Alignment(-0.2, 0.05), 0.9);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) =>
      old.base != base ||
      old.cool != cool ||
      old.warm != warm ||
      old.leaf != leaf;
}

// ---------------------------------------------------------------------------
// Grain
// ---------------------------------------------------------------------------

/// The film-grain tile: generated once from a fixed seed, after the first
/// frame, and shared by every hero. No asset and no network.
abstract final class FfGrainTile {
  static ui.Image? _image;
  static Future<ui.Image>? _pending;

  /// The tile, or null until [load] finishes.
  static ui.Image? get image => _image;

  static Future<ui.Image> load() =>
      _pending ??= _generate().then((i) => _image = i);

  static Future<ui.Image> _generate() {
    const size = FfGrain.tileSize;
    final pixels = Uint8List(size * size * 4);
    var s = FfGrain.seed;
    for (var i = 0; i < pixels.length; i += 4) {
      s = (s * 16807) % 2147483647;
      final v = s * 255 ~/ 2147483647;
      pixels[i] = v;
      pixels[i + 1] = v;
      pixels[i + 2] = v;
      pixels[i + 3] = 255;
    }
    final done = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      size,
      size,
      ui.PixelFormat.rgba8888,
      done.complete,
    );
    return done.future;
  }
}

/// Paints grain over its area (soft-light), once the tile is ready and only
/// when effects are full.
class FfGrainLayer extends StatefulWidget {
  const FfGrainLayer({super.key});

  @override
  State<FfGrainLayer> createState() => _FfGrainLayerState();
}

class _FfGrainLayerState extends State<FfGrainLayer> {
  @override
  void initState() {
    super.initState();
    if (FfGrainTile.image == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FfGrainTile.load().then((_) {
          if (mounted) setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = FfGrainTile.image;
    if (image == null || !FfEffects.of(context).allowsGrain) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: CustomPaint(painter: _GrainPainter(image), size: Size.infinite),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        )
        ..color = Color.fromRGBO(0, 0, 0, FfGrain.opacity)
        ..blendMode = BlendMode.softLight,
    );
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.image != image;
}

// ---------------------------------------------------------------------------
// Hero card
// ---------------------------------------------------------------------------

/// Applies a hero's text colours to everything below it: `context.ff.text`
/// and `context.ff.color.textPrimary/Secondary/Tertiary` become the hero's
/// on-colours, so shared widgets (amounts, stat tiles) read correctly on the
/// gradient without extra parameters.
class FfHeroColorScope extends StatelessWidget {
  const FfHeroColorScope({super.key, required this.hero, required this.child});

  final FfHeroColors hero;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.ff.color.copyWith(
      overrides: {
        FfColorRole.textPrimary: hero.onHero,
        FfColorRole.textSecondary: hero.onHeroSecondary,
        FfColorRole.textTertiary: hero.onHeroSecondary,
      },
    );
    final text = FfTypography.forColors(colors);
    return Theme(
      data: theme.copyWith(
        extensions:
            {...theme.extensions, FfColors: colors, FfText: text}.values,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: hero.onHero),
        child: DefaultTextStyle.merge(style: text.body, child: child),
      ),
    );
  }
}

/// A rich gradient card for the one or two things that matter most on a
/// screen: an account, a loan, a goal. Pick [tone] by what the money is.
///
/// Header: optional [leading] (usually an `FfProgressRing`), [title] and
/// [subtitle], and an ink "open" button when [onOpen] is set. Text below
/// takes the hero's colours automatically. Grain and the inner highlight are
/// drawn only when effects are full. Never put a hero inside a scrolling
/// list item; use `FfCard` there.
class FfHeroCard extends StatelessWidget {
  const FfHeroCard({
    super.key,
    required this.tone,
    required this.child,
    this.leading,
    this.title,
    this.subtitle,
    this.onOpen,
    this.openTooltip = 'Open',
    this.onTap,
    this.padding = const EdgeInsets.all(FfHeroTokens.padding),
    this.width,
    this.height,
  });

  final FfHeroTone tone;
  final Widget child;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final VoidCallback? onOpen;
  final String openTooltip;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final hero = ff.hero(tone);
    final shape = FfShape.of(FfHeroTokens.radius);
    final effects = FfEffects.of(context);
    final brightness = Theme.of(context).brightness;

    final header =
        leading == null && title == null && onOpen == null
            ? null
            : Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: FfSpace.sm),
                ],
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          style: ff.text.title.copyWith(color: hero.onHero),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: ff.text.label.copyWith(
                              color: hero.onHeroSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (onOpen != null) ...[
                  const SizedBox(width: FfSpace.sm),
                  FfInkButton.open(
                    onPressed: onOpen!,
                    tooltip: openTooltip,
                    onHero: true,
                  ),
                ],
              ],
            );

    Widget card = Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        shape: shape,
        gradient: hero.gradient,
        shadows: FfElevation.card(ff.color.shadow, brightness),
      ),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: AlignmentDirectional.bottomEnd.resolve(
                      Directionality.of(context),
                    ),
                    radius: FfHeroTokens.glowRadius,
                    colors: [hero.glow, hero.glow.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
            if (effects.allowsGrain)
              const Positioned.fill(child: FfGrainLayer()),
            Padding(
              padding: padding,
              child: FfHeroColorScope(
                hero: hero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      height == null ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    if (header != null) header,
                    if (header != null) const SizedBox(height: FfSpace.lg),
                    if (height == null) child else Expanded(child: child),
                  ],
                ),
              ),
            ),
            if (effects.allowsGrain)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: FfShape.of(
                        FfHeroTokens.radius,
                        side: BorderSide(
                          color: Colors.white.withValues(
                            alpha: FfHeroTokens.highlightAlpha / 3,
                          ),
                          width: FfBorderWidth.regular,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        type: MaterialType.transparency,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, customBorder: shape, child: card),
      );
    }
    return card;
  }
}

// ---------------------------------------------------------------------------
// Glass
// ---------------------------------------------------------------------------

/// A frosted pill or bar: the dock, "Recent changes" over a hero. Blurs what
/// is behind it when effects are full; otherwise it is a solid raised
/// surface. Never use inside a scrolling list item.
class FfGlass extends StatelessWidget {
  const FfGlass({
    super.key,
    required this.child,
    this.radius = FfRadius.full,
    this.padding = EdgeInsets.zero,
    this.onHero = false,
    this.blur = FfBlur.glass,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// A lighter, more transparent glass for use on top of a hero gradient.
  final bool onHero;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final effects = FfEffects.of(context);
    final fill =
        onHero
            ? FfHeroContrastRules.heroGlass
            : effects.allowsBlur
            ? c.surfaceGlass
            : c.surfaceRaised;
    final shape = FfShape.of(
      radius,
      side: BorderSide(
        color:
            onHero
                ? Colors.white.withValues(alpha: FfTint.medium.alpha)
                : c.borderGlass,
        width: FfBorderWidth.hairline,
      ),
    );
    final body = DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: fill),
      child: Padding(padding: padding, child: child),
    );
    if (!effects.allowsBlur) return body;
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: body,
      ),
    );
  }
}
