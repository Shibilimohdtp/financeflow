import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/category_colors.dart';
import '../../../theme/ff.dart';

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

/// Proportional ring with optional numbered segments and linked selection in Stillwater Bloom.
class FfDonutChart extends StatefulWidget {
  final List<DonutSlice> slices;
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? semanticsSummary;
  final int? selectedSliceIndex;
  final ValueChanged<int>? onSliceSelected;
  final bool showSegmentNumbers;

  const FfDonutChart({
    super.key,
    required this.slices,
    this.size = FfDonutChartTokens.defaultSize,
    this.strokeWidth = FfDonutChartTokens.defaultStrokeWidth,
    this.centerLabel,
    this.semanticsSummary,
    this.selectedSliceIndex,
    this.onSliceSelected,
    this.showSegmentNumbers = false,
  });

  @override
  State<FfDonutChart> createState() => _FfDonutChartState();
}

class _FfDonutChartState extends State<FfDonutChart> {
  int? _localSelection;

  @override
  void didUpdateWidget(covariant FfDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slices != widget.slices) _localSelection = null;
  }

  void _select(int index) {
    final current = widget.selectedSliceIndex ?? _localSelection;
    if (index != current) {
      HapticFeedback.selectionClick();
    }
    if (widget.onSliceSelected != null) {
      widget.onSliceSelected!(index);
    } else {
      setState(() => _localSelection = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final total = widget.slices.fold<double>(0, (sum, s) => sum + _value(s));
    if (total <= 0) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No expenses recorded for this period.',
            style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
          ),
        ),
      );
    }
    final index = widget.selectedSliceIndex ?? _localSelection;
    final selected =
        index != null && index >= 0 && index < widget.slices.length
            ? widget.slices[index]
            : null;

    return Semantics(
      container: true,
      label: widget.semanticsSummary ?? 'Expense category breakdown',
      value: widget.slices
          .where((s) => _value(s) > 0)
          .map(
            (s) =>
                '${s.label}, ${CurrencyFormatter.format(s.value)}, ${_share(s.value / total)}',
          )
          .join('; '),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(widget.size, constraints.maxWidth);
          final stroke = min(widget.strokeWidth, size / 4);
          final radius = (size - stroke) / 2 - 4;
          final arcs = _arcs(widget.slices, total, radius);
          final centerBoxSize = max(0.0, size - stroke * 2 - 24);

          return Center(
            child: GestureDetector(
              key: const ValueKey('donut-ring'),
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final offset =
                    details.localPosition - Offset(size / 2, size / 2);
                if ((offset.distance - radius).abs() > stroke / 2 + 4) return;
                final angle = (atan2(offset.dy, offset.dx) + pi / 2) % (2 * pi);
                for (final arc in arcs) {
                  if (angle >= arc.start && angle <= arc.start + arc.sweep) {
                    _select(arc.index);
                    break;
                  }
                }
              },
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.square(size),
                      painter: _DonutChartPainter(
                        slices: widget.slices,
                        arcs: arcs,
                        radius: radius,
                        strokeWidth: stroke,
                        selectedSliceIndex: index,
                        ff: ff,
                        brightness: Theme.of(context).brightness,
                        showNumbers: widget.showSegmentNumbers,
                      ),
                    ),
                    ExcludeSemantics(
                      child: SizedBox(
                        width: centerBoxSize,
                        height: centerBoxSize,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: centerBoxSize,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selected?.label ??
                                        widget.centerLabel ??
                                        'Total',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ff.text.bodySm.copyWith(
                                      color: ff.color.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: FfSpace.x2s),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      CurrencyFormatter.format(
                                        selected?.value ?? total,
                                      ),
                                      style: ff.text.headlineSm.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (selected != null) ...[
                                    const SizedBox(height: FfSpace.x2s),
                                    Text(
                                      '${_share(selected.value / total)} of total',
                                      textAlign: TextAlign.center,
                                      style: ff.text.label.copyWith(
                                        color: ff.color.textSecondary,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

double _value(DonutSlice slice) =>
    slice.value.isFinite && slice.value > 0 ? slice.value : 0;

String _share(double fraction) =>
    fraction > 0 && fraction < .001
        ? '<0.1%'
        : '${(fraction * 100).toStringAsFixed(1)}%';

typedef _Arc = ({int index, double start, double sweep});

List<_Arc> _arcs(List<DonutSlice> slices, double total, double radius) {
  final result = <_Arc>[];
  final count = slices.where((s) => _value(s) > 0).length;
  var start = 0.0;
  for (var i = 0; i < slices.length; i++) {
    final sweep = _value(slices[i]) / total * 2 * pi;
    if (sweep <= 0) continue;
    // Flat caps stay inside each allocation. Limit gaps for tiny values so
    // they remain visible; a single category gets a continuous ring.
    final gap = count == 1 ? 0.0 : min(4 / max(1, radius), sweep * .2);
    result.add((index: i, start: start + gap / 2, sweep: sweep - gap));
    start += sweep;
  }
  return result;
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final List<_Arc> arcs;
  final double radius;
  final double strokeWidth;
  final int? selectedSliceIndex;
  final FfThemeData ff;
  final Brightness brightness;
  final bool showNumbers;

  _DonutChartPainter({
    required this.slices,
    required this.arcs,
    required this.radius,
    required this.strokeWidth,
    required this.selectedSliceIndex,
    required this.ff,
    required this.brightness,
    required this.showNumbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final isDark = brightness == Brightness.dark;

    for (final arc in arcs) {
      final slice = slices[arc.index];
      final color =
          slice.color ??
          CategoryColors.getColor(slice.colorToken, isDark: isDark);

      // Segment arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        arc.start - pi / 2,
        arc.sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );

      // Selected slice outline ring
      if (selectedSliceIndex == arc.index) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius:
                radius +
                strokeWidth / 2 +
                FfDonutChartTokens.selectionRingGap +
                FfDonutChartTokens.selectionRingWidth / 2,
          ),
          arc.start - pi / 2,
          arc.sweep,
          false,
          Paint()
            ..color = ff.color.textPrimary
            ..style = PaintingStyle.stroke
            ..strokeWidth = FfDonutChartTokens.selectionRingWidth,
        );
      }

      // Small segments keep their actual size, with details in the legend.
      if (showNumbers && arc.sweep * radius >= 26 && strokeWidth >= 24) {
        final angle = arc.start + arc.sweep / 2 - pi / 2;
        final position = center + Offset(cos(angle), sin(angle)) * radius;
        final text = TextPainter(
          text: TextSpan(
            text: '${arc.index + 1}',
            style: ff.text.label.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color:
                  color.computeLuminance() > 0.179
                      ? ff.color.surfaceInk
                      : ff.color.onSurfaceInk,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(canvas, position - Offset(text.width / 2, text.height / 2));
        text.dispose();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.slices != slices ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.ff != ff ||
      oldDelegate.brightness != brightness ||
      oldDelegate.showNumbers != showNumbers ||
      oldDelegate.selectedSliceIndex != selectedSliceIndex;
}
