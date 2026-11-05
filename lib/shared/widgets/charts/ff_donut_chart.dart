import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/ff.dart';
import '../../../theme/palettes/ff_palette.dart';
import '../../../models/category_colors.dart';

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

/// Proportional ring with optional numbered segments and linked selection.
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
    this.size = 220,
    this.strokeWidth = 30,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.slices.fold<double>(0, (sum, s) => sum + _value(s));
    if (total <= 0) {
      return SizedBox(
        height: widget.size,
        child: const Center(
          child: Text('No expenses recorded for this period.'),
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
                    if (widget.onSliceSelected != null) {
                      widget.onSliceSelected!(arc.index);
                    } else {
                      setState(() => _localSelection = arc.index);
                    }
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
                        theme: theme,
                        showNumbers: widget.showSegmentNumbers,
                      ),
                    ),
                    ExcludeSemantics(
                      child: SizedBox(
                        width: max(0, size - stroke * 2 - 28),
                        height: max(0, size - stroke * 2 - 28),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: max(0, size - stroke * 2 - 28),
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
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: FfSpace.x2s),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      CurrencyFormatter.format(
                                        selected?.value ?? total,
                                      ),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (selected != null) ...[
                                    const SizedBox(height: FfSpace.x2s),
                                    Text(
                                      '${_share(selected.value / total)} of total',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelMedium,
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
  final ThemeData theme;

  FfColors get _colors =>
      theme.extension<FfColors>() ??
      FfPalettes.lichen.colorsFor(theme.brightness);
  final bool showNumbers;

  _DonutChartPainter({
    required this.slices,
    required this.arcs,
    required this.radius,
    required this.strokeWidth,
    required this.selectedSliceIndex,
    required this.theme,
    required this.showNumbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final arc in arcs) {
      final slice = slices[arc.index];
      final color =
          slice.color ??
          CategoryColors.getColor(
            slice.colorToken,
            isDark: theme.brightness == Brightness.dark,
          );
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
      if (selectedSliceIndex == arc.index) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + strokeWidth / 2 + 3),
          arc.start - pi / 2,
          arc.sweep,
          false,
          Paint()
            ..color = theme.colorScheme.onSurface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      // Small segments keep their actual size, with details in the legend.
      if (showNumbers && arc.sweep * radius >= 26 && strokeWidth >= 24) {
        final angle = arc.start + arc.sweep / 2 - pi / 2;
        final position = center + Offset(cos(angle), sin(angle)) * radius;
        final text = TextPainter(
          text: TextSpan(
            text: '${arc.index + 1}',
            // Ink on light segments, paper on dark ones (WCAG midpoint).
            style: (theme.extension<FfText>()?.label ?? const TextStyle())
                .copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      color.computeLuminance() > .179
                          ? _colors.surfaceInk
                          : _colors.onSurfaceInk,
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
      oldDelegate.theme != theme ||
      oldDelegate.showNumbers != showNumbers ||
      oldDelegate.selectedSliceIndex != selectedSliceIndex;
}
