import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/category_colors.dart';
import '../../../theme/stillwater_tokens.dart';

class DonutSlice {
  final String label;
  final double value;
  final String colorToken;
  final Color? color;

  const DonutSlice({
    required this.label,
    required this.value,
    this.colorToken = 'slate',
    this.color,
  });
}

/// Stillwater accessible donut chart for category breakdowns
class FfDonutChart extends StatefulWidget {
  final List<DonutSlice> slices;
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? semanticsSummary;

  const FfDonutChart({
    super.key,
    required this.slices,
    this.size = 180.0,
    this.strokeWidth = 24.0,
    this.centerLabel,
    this.semanticsSummary,
  });

  @override
  State<FfDonutChart> createState() => _FfDonutChartState();
}

class _FfDonutChartState extends State<FfDonutChart> {
  int? _selectedSliceIndex;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final total = widget.slices.fold<double>(0.0, (sum, s) => sum + s.value);

    if (widget.slices.isEmpty || total <= 0) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No expenses recorded for this period.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final selectedSlice =
        (_selectedSliceIndex != null &&
                _selectedSliceIndex! < widget.slices.length)
            ? widget.slices[_selectedSliceIndex!]
            : null;

    return Semantics(
      container: true,
      label:
          widget.semanticsSummary ??
          'Donut chart showing category breakdown with ${widget.slices.length} categories.',
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DonutChartPainter(
                  slices: widget.slices,
                  total: total,
                  strokeWidth: widget.strokeWidth,
                  selectedSliceIndex: _selectedSliceIndex,
                  theme: theme,
                ),
              ),
              // Center Label (Total or Selected slice)
              ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsets.all(
                    widget.strokeWidth + StillwaterTokens.spaceSm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedSlice != null
                            ? selectedSlice.label
                            : (widget.centerLabel ?? 'Total'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: StillwaterTokens.space3Xs),
                      Text(
                        CurrencyFormatter.format(
                          selectedSlice != null ? selectedSlice.value : total,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (selectedSlice != null && total > 0) ...[
                        Text(
                          '${((selectedSlice.value / total) * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final double total;
  final double strokeWidth;
  final int? selectedSliceIndex;
  final ThemeData theme;

  _DonutChartPainter({
    required this.slices,
    required this.total,
    required this.strokeWidth,
    this.selectedSliceIndex,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    double startAngle = -pi / 2;
    const double gapAngle =
        0.03; // small gap between slices for Stillwater calm aesthetic

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweepAngle = (slice.value / total) * (2 * pi);
      final isSelected = selectedSliceIndex == i;

      final color =
          slice.color ??
          CategoryColors.getColor(
            slice.colorToken,
            isDark: theme.brightness == Brightness.dark,
          );
      final paint =
          Paint()
            ..color = isSelected ? color : color.withValues(alpha: 0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
            ..strokeCap = StrokeCap.round;

      final actualSweep = max(0.0, sweepAngle - gapAngle);
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: isSelected ? radius + 1 : radius,
        ),
        startAngle + gapAngle / 2,
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.total != total ||
        oldDelegate.selectedSliceIndex != selectedSliceIndex;
  }
}
