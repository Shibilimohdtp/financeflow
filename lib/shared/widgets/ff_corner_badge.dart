import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// What a corner badge says.
enum FfCorner {
  /// Amber triangle with an ink "!".
  warning,

  /// Error circle with "!".
  error,

  /// A small spark dot (something new).
  dot,
}

/// Places a small badge on the top end corner of [child] (an icon tile or a
/// circle button). The badge is decoration: always say the same thing in
/// text nearby or in [semanticLabel], never by the badge alone.
class FfCornerBadge extends StatelessWidget {
  const FfCornerBadge({
    super.key,
    required this.corner,
    required this.child,
    this.semanticLabel,
  });

  final FfCorner corner;
  final Widget child;

  /// Read after the child's own label, for example "needs attention".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          PositionedDirectional(
            top: FfCornerBadgeTokens.offset,
            end: FfCornerBadgeTokens.offset,
            child: ExcludeSemantics(
              child: CustomPaint(
                size: const Size.square(FfCornerBadgeTokens.size),
                painter: _CornerPainter(corner, context.ff.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.corner, this.c);

  final FfCorner corner;
  final FfColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    switch (corner) {
      case FfCorner.dot:
        final r = w * 0.3;
        canvas.drawCircle(
          Offset(w / 2, h / 2),
          r + 2,
          Paint()..color = c.surfacePage,
        );
        canvas.drawCircle(Offset(w / 2, h / 2), r, Paint()..color = c.spark);
      case FfCorner.error:
        canvas.drawCircle(
          Offset(w / 2, h / 2),
          w / 2,
          Paint()..color = c.statusError,
        );
        _bang(canvas, Offset(w / 2, h / 2), h * 0.55, c.onStatusError);
      case FfCorner.warning:
        // Rounded triangle.
        final path =
            Path()
              ..moveTo(w / 2, 0.5)
              ..lineTo(w - 0.5, h - 1)
              ..lineTo(0.5, h - 1)
              ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = c.statusWarningFill
            ..style = PaintingStyle.fill
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = c.statusWarningFill
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..strokeJoin = StrokeJoin.round,
        );
        _bang(canvas, Offset(w / 2, h * 0.62), h * 0.48, c.onStatusWarningFill);
    }
  }

  void _bang(Canvas canvas, Offset center, double height, Color color) {
    final p =
        Paint()
          ..color = color
          ..strokeWidth = math.max(1.4, height * 0.18)
          ..strokeCap = StrokeCap.round;
    final top = center.dy - height / 2;
    canvas.drawLine(
      Offset(center.dx, top),
      Offset(center.dx, top + height * 0.58),
      p,
    );
    canvas.drawCircle(
      Offset(center.dx, top + height * 0.92),
      p.strokeWidth * 0.55,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.corner != corner || old.c != c;
}
