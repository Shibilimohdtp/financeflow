import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/stillwater_colors.dart';
import '../../theme/ff.dart';

/// Branding variants for the Stillwater Mark
enum MarkVariant { auto, daylight, deepWater, monochrome, security }

/// The official FinanceFlow Stillwater Mark widget.
///
/// Renders resolution-independent vector geometry with rounded endcaps,
/// fluid current arcs, and a warm marigold core spark.
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
            (isDark
                ? StillwaterColors.darkPrimary
                : StillwaterColors.lightPrimary);
        accentColor =
            customAccentColor ??
            (isDark
                ? StillwaterColors.darkAccent
                : StillwaterColors.lightAccentBright);
        break;
      case MarkVariant.daylight:
        primaryColor = customPrimaryColor ?? StillwaterColors.lightPrimary;
        accentColor = customAccentColor ?? StillwaterColors.lightAccentBright;
        break;
      case MarkVariant.deepWater:
        primaryColor = customPrimaryColor ?? StillwaterColors.darkPrimary;
        accentColor = customAccentColor ?? StillwaterColors.darkAccent;
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

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StillwaterMarkPainter(
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

class _StillwaterMarkPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _StillwaterMarkPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2.0;
    final cy = size.height / 2.0;
    final scale = size.width / 512.0;

    final primaryPaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true;

    final accentPaint =
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    // 1. Outer Protective Arc (Still Water Boundary)
    primaryPaint.strokeWidth = 40 * scale;
    final outerRadius = 188 * scale;
    final outerRect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: outerRadius,
    );
    canvas.drawArc(
      outerRect,
      -250 * (math.pi / 180),
      315 * (math.pi / 180),
      false,
      primaryPaint,
    );

    // 2. Inner Ascending Current (Flow & F-Geometry)
    primaryPaint.strokeWidth = 34 * scale;
    final midRadius = 120 * scale;
    final midRect = Rect.fromCircle(center: Offset(cx, cy), radius: midRadius);
    canvas.drawArc(
      midRect,
      -180 * (math.pi / 180),
      235 * (math.pi / 180),
      false,
      primaryPaint,
    );

    // 3. Horizon Wave Arc
    primaryPaint.strokeWidth = 26 * scale;
    final horizonRadius = 68 * scale;
    final horizonRect = Rect.fromCircle(
      center: Offset(cx, cy + (24 * scale)),
      radius: horizonRadius,
    );
    canvas.drawArc(
      horizonRect,
      -170 * (math.pi / 180),
      160 * (math.pi / 180),
      false,
      primaryPaint,
    );

    // 4. Central Protected Spark / Droplet
    final dotCenter = Offset(cx, cy - (54 * scale));
    final dotRadius = 28 * scale;
    canvas.drawCircle(dotCenter, dotRadius, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _StillwaterMarkPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// The official FinanceFlow Wordmark widget
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainColor =
        color ??
        (isDark ? StillwaterColors.darkPrimary : StillwaterColors.lightPrimary);
    final shoreColor =
        isDark
            ? StillwaterColors.darkSecondary
            : StillwaterColors.lightSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: mainColor,
            ),
            children: [
              const TextSpan(text: 'Finance'),
              TextSpan(
                text: 'Flow',
                style: TextStyle(
                  color: shoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: FfSpace.x3s),
          Text(
            'PRIVATE · LOCAL-FIRST',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: fontSize * 0.38,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color:
                  isDark
                      ? StillwaterColors.darkTextTertiary
                      : StillwaterColors.lightTextTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Full Logo lockup combining Mark and Wordmark
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
