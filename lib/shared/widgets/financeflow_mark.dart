import 'package:flutter/material.dart';
import '../../theme/ff.dart';
import '../../theme/palettes/bloom_primitives.dart';

/// Branding variants for the Stillwater Mark.
enum MarkVariant { auto, daylight, deepWater, monochrome, security }

/// The official FinanceFlow Stillwater Mark widget (Stillwater Bloom DS-B19).
///
/// Renders resolution-independent vector geometry with rounded endcaps,
/// concentric squircle currents, and a central radiant lime spark droplet.
class FinanceFlowMark extends StatelessWidget {
  final double size;
  final MarkVariant variant;
  final Color? customPrimaryColor;
  final Color? customAccentColor;

  const FinanceFlowMark({
    super.key,
    this.size = 48,
    this.variant = MarkVariant.auto,
    this.customPrimaryColor,
    this.customAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color primaryColor;
    Color accentColor;

    switch (variant) {
      case MarkVariant.auto:
        primaryColor =
            customPrimaryColor ??
            (isDark ? BloomPrimitives.darkInk : BloomPrimitives.lightInk);
        accentColor =
            customAccentColor ??
            (isDark ? BloomPrimitives.darkSpark : BloomPrimitives.lightSpark);
        break;
      case MarkVariant.daylight:
        primaryColor = customPrimaryColor ?? BloomPrimitives.lightInk;
        accentColor = customAccentColor ?? BloomPrimitives.lightSpark;
        break;
      case MarkVariant.deepWater:
        primaryColor = customPrimaryColor ?? BloomPrimitives.darkInk;
        accentColor = customAccentColor ?? BloomPrimitives.darkSpark;
        break;
      case MarkVariant.monochrome:
        primaryColor = customPrimaryColor ?? Colors.white;
        accentColor = customAccentColor ?? Colors.white;
        break;
      case MarkVariant.security:
        primaryColor = customPrimaryColor ?? context.ff.color.statusSuccess;
        accentColor = customAccentColor ?? context.ff.color.privacyBoundary;
        break;
    }

    return Semantics(
      label: 'FinanceFlow logo mark',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _StillwaterMarkPainter(
            primaryColor: primaryColor,
            accentColor: accentColor,
          ),
        ),
      ),
    );
  }
}

class _StillwaterMarkPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  const _StillwaterMarkPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 512.0;

    final strokePaint1 =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 34 * s
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;

    final strokePaint2 =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28 * s
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;

    // 1. Outer Squircle Current
    final pOuter =
        Path()
          ..moveTo(196 * s, 120 * s)
          ..cubicTo(144 * s, 142 * s, 116 * s, 192 * s, 116 * s, 256 * s)
          ..cubicTo(116 * s, 352 * s, 168 * s, 404 * s, 256 * s, 404 * s)
          ..cubicTo(344 * s, 404 * s, 396 * s, 352 * s, 396 * s, 256 * s)
          ..cubicTo(396 * s, 160 * s, 344 * s, 108 * s, 256 * s, 108 * s);
    canvas.drawPath(pOuter, strokePaint1);

    // 2. Inner Squircle Current
    final pInner =
        Path()
          ..moveTo(292 * s, 180 * s)
          ..cubicTo(316 * s, 196 * s, 328 * s, 220 * s, 328 * s, 256 * s)
          ..cubicTo(328 * s, 316 * s, 300 * s, 344 * s, 256 * s, 344 * s)
          ..cubicTo(212 * s, 344 * s, 184 * s, 316 * s, 184 * s, 256 * s)
          ..cubicTo(184 * s, 196 * s, 212 * s, 168 * s, 256 * s, 168 * s);
    canvas.drawPath(pInner, strokePaint2);

    // 3. Central Focal Lime Spark
    final sparkPaint =
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
    canvas.drawCircle(Offset(256 * s, 256 * s), 24 * s, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _StillwaterMarkPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// The official FinanceFlow Wordmark widget (Stillwater Bloom DS-B19).
class FinanceFlowWordmark extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showTagline;

  const FinanceFlowWordmark({
    super.key,
    this.fontSize = 24,
    this.color,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor =
        color ?? (isDark ? BloomPrimitives.darkInk : BloomPrimitives.lightInk);
    final secondaryColor =
        isDark ? BloomPrimitives.darkText2 : BloomPrimitives.lightText2;

    return Semantics(
      label: 'FinanceFlow',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: mainColor,
              ),
              children: [
                const TextSpan(text: 'Finance'),
                TextSpan(
                  text: 'Flow',
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: FfSpace.x3s),
            Text(
              'STILL WATER FOR YOUR FINANCIAL LIFE',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: fontSize * 0.38,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: secondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full Logo lockup combining Mark and Wordmark.
class FinanceFlowLogo extends StatelessWidget {
  final double markSize;
  final double fontSize;
  final bool showTagline;
  final Axis axis;

  const FinanceFlowLogo({
    super.key,
    this.markSize = 36,
    this.fontSize = 22,
    this.showTagline = false,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FinanceFlowMark(size: markSize),
          const SizedBox(height: FfSpace.sm),
          FinanceFlowWordmark(fontSize: fontSize, showTagline: showTagline),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FinanceFlowMark(size: markSize),
        const SizedBox(width: FfSpace.md),
        FinanceFlowWordmark(fontSize: fontSize, showTagline: showTagline),
      ],
    );
  }
}
