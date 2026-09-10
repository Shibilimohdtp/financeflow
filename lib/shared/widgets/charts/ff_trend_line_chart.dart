import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/stillwater_tokens.dart';

class TrendPoint {
  final String label;
  final double value;
  final DateTime? date;

  const TrendPoint({required this.label, required this.value, this.date});
}

/// Stillwater accessible line and gradient area chart for spending trends
class FfTrendLineChart extends StatefulWidget {
  final List<TrendPoint> points;
  final double height;
  final Color? lineColor;
  final String? semanticsSummary;

  const FfTrendLineChart({
    super.key,
    required this.points,
    this.height = 160.0,
    this.lineColor,
    this.semanticsSummary,
  });

  @override
  State<FfTrendLineChart> createState() => _FfTrendLineChartState();
}

class _FfTrendLineChartState extends State<FfTrendLineChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final primaryColor = widget.lineColor ?? theme.colorScheme.primary;

    if (widget.points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No trend data recorded for this period.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxValue = widget.points.fold<double>(
      0.0,
      (maxV, p) => max(maxV, p.value),
    );
    final safeMax = maxValue > 0 ? maxValue : 1.0;

    return Semantics(
      label:
          widget.semanticsSummary ??
          'Spending trend chart with ${widget.points.length} intervals.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final widthPerPoint =
                        constraints.maxWidth / max(1, widget.points.length - 1);
                    final index =
                        (details.localPosition.dx / widthPerPoint).round();
                    if (index >= 0 && index < widget.points.length) {
                      setState(() {
                        _selectedIndex = _selectedIndex == index ? null : index;
                      });
                    }
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, widget.height),
                    painter: _TrendLinePainter(
                      points: widget.points,
                      maxValue: safeMax,
                      selectedIndex: _selectedIndex,
                      lineColor: primaryColor,
                      gridColor: theme.dividerColor.withValues(alpha: 0.25),
                      textColor: theme.colorScheme.onSurface.withValues(
                        alpha: 1,
                      ),
                      pointCenterColor: theme.colorScheme.surface,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedIndex != null &&
              _selectedIndex! < widget.points.length) ...[
            const SizedBox(height: StillwaterTokens.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.space2Xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.points[_selectedIndex!].label}: ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(
                      widget.points[_selectedIndex!].value,
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final List<TrendPoint> points;
  final double maxValue;
  final int? selectedIndex;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color pointCenterColor;

  _TrendLinePainter({
    required this.points,
    required this.maxValue,
    this.selectedIndex,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.pointCenterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomLabelHeight = 22.0;
    const double topPadding = 12.0;
    final chartHeight = size.height - bottomLabelHeight - topPadding;

    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

    // Draw baseline and top boundary
    canvas.drawLine(
      Offset(0, topPadding + chartHeight),
      Offset(size.width, topPadding + chartHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, topPadding + chartHeight / 2),
      Offset(size.width, topPadding + chartHeight / 2),
      gridPaint,
    );

    if (points.length < 2) {
      if (points.isNotEmpty) {
        // Single point center circle
        final p = points.first;
        final y = topPadding + chartHeight - (p.value / maxValue) * chartHeight;
        canvas.drawCircle(
          Offset(size.width / 2, y),
          5,
          Paint()..color = lineColor,
        );
      }
      return;
    }

    final double stepX = size.width / (points.length - 1);
    final path = Path();
    final fillPath = Path();

    final List<Offset> offsets = [];
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y =
          topPadding +
          chartHeight -
          (points[i].value / maxValue).clamp(0.0, 1.0) * chartHeight;
      offsets.add(Offset(x, y));
    }

    path.moveTo(offsets.first.dx, offsets.first.dy);
    fillPath.moveTo(offsets.first.dx, topPadding + chartHeight);
    fillPath.lineTo(offsets.first.dx, offsets.first.dy);

    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
      fillPath.lineTo(offsets[i].dx, offsets[i].dy);
    }

    fillPath.lineTo(offsets.last.dx, topPadding + chartHeight);
    fillPath.close();

    // Draw gradient area fill
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.28),
              lineColor.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight))
          ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final strokePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Draw points and labels
    final stepSkip = max(1, (points.length / 7).floor());
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      final offset = offsets[i];

      if (isSelected) {
        // Draw selected highlight circle
        canvas.drawCircle(offset, 6, Paint()..color = lineColor);
        canvas.drawCircle(offset, 3, Paint()..color = pointCenterColor);
      }

      // Draw intermittent labels
      if (i % stepSkip == 0 || i == points.length - 1) {
        final tp = TextPainter(
          text: TextSpan(
            text: points[i].label,
            style: TextStyle(
              color: isSelected ? lineColor : textColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelX = (offset.dx - tp.width / 2).clamp(
          0.0,
          size.width - tp.width,
        );
        tp.paint(canvas, Offset(labelX, size.height - bottomLabelHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.pointCenterColor != pointCenterColor;
  }
}
