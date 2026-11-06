import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'tokens/ff_foundation.dart';

/// How rounded shapes are drawn across the app.
enum FfShapeStyle {
  /// Superellipse corners with smoothing (Stillwater Bloom).
  squircle,

  /// Plain circular corners.
  rounded,
}

/// The one place the app's shape language is chosen. Every themed component
/// and shared widget asks [FfShape.of] for its outline, so switching [style]
/// (or [smoothing]) restyles the whole app.
///
/// Flutter 3.29 has no `RoundedSuperellipseBorder` (it arrived in 3.32), so
/// squircles come from [FfSquircleBorder]. After a Flutter upgrade only this
/// file needs to change.
abstract final class FfShape {
  static const FfShapeStyle style = FfShapeStyle.squircle;

  /// Corner smoothing, 0 (circular arc) to 1 (fully smoothed). 0.6 matches
  /// the "iOS-like" smoothing most design tools use.
  static const double smoothing = 0.6;

  /// The outline for a rounded rectangle with [radius] (a [FfRadius] step).
  /// [FfRadius.full] gives a stadium (pill or circle).
  static OutlinedBorder of(double radius, {BorderSide side = BorderSide.none}) {
    if (radius >= FfRadius.full) return StadiumBorder(side: side);
    return switch (style) {
      FfShapeStyle.squircle => FfSquircleBorder(
        radius: radius,
        smoothing: smoothing,
        side: side,
      ),
      FfShapeStyle.rounded => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: side,
      ),
    };
  }

  /// A decoration with the shape at [radius], for containers that paint
  /// their own background (instead of `BoxDecoration` + `BorderRadius`).
  static ShapeDecoration decoration({
    required double radius,
    Color? color,
    Gradient? gradient,
    BorderSide side = BorderSide.none,
    List<BoxShadow>? shadows,
  }) => ShapeDecoration(
    shape: of(radius, side: side),
    color: color,
    gradient: gradient,
    shadows: shadows,
  );
}

/// A rectangle with superellipse ("squircle") corners, using the corner
/// smoothing construction popularised by Figma: each corner is a short
/// circular arc blended into the straight edges by two cubic curves.
///
/// When the shape is too small for the full smoothing, smoothing is reduced
/// first, then the radius, so corners never overlap.
class FfSquircleBorder extends OutlinedBorder {
  const FfSquircleBorder({
    super.side,
    required this.radius,
    this.smoothing = FfShape.smoothing,
  }) : assert(radius >= 0),
       assert(smoothing >= 0 && smoothing <= 1);

  final double radius;
  final double smoothing;

  @override
  FfSquircleBorder copyWith({
    BorderSide? side,
    double? radius,
    double? smoothing,
  }) => FfSquircleBorder(
    side: side ?? this.side,
    radius: radius ?? this.radius,
    smoothing: smoothing ?? this.smoothing,
  );

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.all(math.max(side.strokeInset, 0));

  @override
  ShapeBorder scale(double t) => FfSquircleBorder(
    side: side.scale(t),
    radius: radius * t,
    smoothing: smoothing,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is FfSquircleBorder) {
      return FfSquircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        radius: lerpDouble(a.radius, radius, t)!,
        smoothing: lerpDouble(a.smoothing, smoothing, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is FfSquircleBorder) {
      return FfSquircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        radius: lerpDouble(radius, b.radius, t)!,
        smoothing: lerpDouble(smoothing, b.smoothing, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => squirclePath(
    rect.deflate(side.strokeInset),
    math.max(0, radius - side.strokeInset),
    smoothing,
  );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      squirclePath(rect, radius, smoothing);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    final inset = side.strokeInset - side.width / 2;
    final r = math.max(0.0, radius - inset);
    canvas.drawPath(
      squirclePath(rect.deflate(inset), r, smoothing),
      side.toPaint(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FfSquircleBorder &&
      other.side == side &&
      other.radius == radius &&
      other.smoothing == smoothing;

  @override
  int get hashCode => Object.hash(side, radius, smoothing);

  @override
  String toString() =>
      'FfSquircleBorder($side, radius: $radius, smoothing: $smoothing)';

  /// The squircle outline of [rect].
  static Path squirclePath(Rect rect, double radius, double smoothing) {
    final w = rect.width, h = rect.height;
    if (w <= 0 || h <= 0) return Path();
    final budget = math.min(w, h) / 2;
    final r = math.min(radius, budget);
    if (r <= 0) return Path()..addRect(rect);

    final c = _Corner(r, smoothing, budget);
    final path = Path()..moveTo(rect.left + c.p, rect.top);

    // Top edge → top right.
    path.lineTo(rect.right - c.p, rect.top);
    path.relativeCubicTo(c.a, 0, c.a + c.b, 0, c.a + c.b + c.c, c.d);
    path.relativeArcToPoint(Offset(c.arc, c.arc), radius: Radius.circular(r));
    path.relativeCubicTo(c.d, c.c, c.d, c.b + c.c, c.d, c.a + c.b + c.c);

    // Right edge → bottom right.
    path.lineTo(rect.right, rect.bottom - c.p);
    path.relativeCubicTo(0, c.a, 0, c.a + c.b, -c.d, c.a + c.b + c.c);
    path.relativeArcToPoint(Offset(-c.arc, c.arc), radius: Radius.circular(r));
    path.relativeCubicTo(-c.c, c.d, -(c.b + c.c), c.d, -(c.a + c.b + c.c), c.d);

    // Bottom edge → bottom left.
    path.lineTo(rect.left + c.p, rect.bottom);
    path.relativeCubicTo(-c.a, 0, -(c.a + c.b), 0, -(c.a + c.b + c.c), -c.d);
    path.relativeArcToPoint(Offset(-c.arc, -c.arc), radius: Radius.circular(r));
    path.relativeCubicTo(
      -c.d,
      -c.c,
      -c.d,
      -(c.b + c.c),
      -c.d,
      -(c.a + c.b + c.c),
    );

    // Left edge → top left.
    path.lineTo(rect.left, rect.top + c.p);
    path.relativeCubicTo(0, -c.a, 0, -(c.a + c.b), c.d, -(c.a + c.b + c.c));
    path.relativeArcToPoint(Offset(c.arc, -c.arc), radius: Radius.circular(r));
    path.relativeCubicTo(c.c, -c.d, c.b + c.c, -c.d, c.a + c.b + c.c, -c.d);

    return path..close();
  }
}

/// Geometry of one smoothed corner (all lengths along one edge).
class _Corner {
  factory _Corner(double radius, double smoothing, double budget) {
    // Reduce smoothing first so the corner fits in half the short side.
    final s = math.min(smoothing, math.max(0.0, budget / radius - 1));
    final p = math.min((1 + s) * radius, budget);
    final arcMeasure = 90 * (1 - s);
    final arc = math.sin(_rad(arcMeasure / 2)) * radius * math.sqrt2;
    final alpha = (90 - arcMeasure) / 2;
    final p3ToP4 = radius * math.tan(_rad(alpha / 2));
    final beta = 45 * s;
    final c = p3ToP4 * math.cos(_rad(beta));
    final d = c * math.tan(_rad(beta));
    final b = (p - arc - c - d) / 3;
    return _Corner._(2 * b, b, c, d, p, arc);
  }

  const _Corner._(this.a, this.b, this.c, this.d, this.p, this.arc);

  final double a, b, c, d, p, arc;

  static double _rad(double degrees) => degrees * math.pi / 180;
}
