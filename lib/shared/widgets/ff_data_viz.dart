import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

// ---------------------------------------------------------------------------
// Progress ring
// ---------------------------------------------------------------------------

/// A thin ring around an icon whose arc shows progress: a loan paid off, a
/// goal saved, a budget used. Colours follow the surrounding icon colour, so
/// it reads on cards and heroes alike.
class FfProgressRing extends StatelessWidget {
  const FfProgressRing({
    super.key,
    required this.value,
    required this.icon,
    required this.semanticsLabel,
    this.size = FfRingTokens.size,
    this.color,
  });

  /// 0–1; clamped.
  final double value;
  final IconData icon;

  /// What the ring means, for example "26% of the loan paid".
  final String semanticsLabel;
  final double size;

  /// Arc colour; defaults to the surrounding icon colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fg = IconTheme.of(context).color ?? context.ff.color.textPrimary;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: value.clamp(0, 1).toDouble(),
            track: fg.withValues(alpha: FfRingTokens.trackAlpha),
            arc: color ?? fg,
          ),
          child: Center(child: Icon(icon, size: FfIconSize.lg, color: fg)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.arc});

  final double value;
  final Color track, arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(FfRingTokens.stroke);
    final p =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = FfRingTokens.stroke * 0.8
          ..color = track;
    canvas.drawOval(rect, p);
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      p
        ..color = arc
        ..strokeWidth = FfRingTokens.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.track != track || old.arc != arc;
}

// ---------------------------------------------------------------------------
// Dot matrix
// ---------------------------------------------------------------------------

/// Progress as a grid of dots that fill in ("31 of 120 EMIs paid"). When
/// [total] is larger than the grid, each dot stands for an equal share. The
/// next step is marked with the spark. Always show the number in text next
/// to it; [semanticsLabel] is what screen readers hear.
class FfDotMatrix extends StatelessWidget {
  const FfDotMatrix({
    super.key,
    required this.total,
    required this.done,
    required this.semanticsLabel,
    this.rows = FfDotMatrixTokens.rows,
    this.maxColumns = FfDotMatrixTokens.maxColumns,
    this.markNext = true,
    this.color,
  });

  final int total;
  final int done;
  final String semanticsLabel;
  final int rows;
  final int maxColumns;

  /// Mark the next step with the spark.
  final bool markNext;

  /// Dot colour; defaults to the surrounding icon colour.
  final Color? color;

  /// How many dots are drawn and how many of them are filled.
  ({int dots, int filled}) get layout {
    final dots = math.max(1, math.min(total, rows * maxColumns));
    final ratio = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return (dots: dots, filled: (ratio * dots).round());
  }

  @override
  Widget build(BuildContext context) {
    final fg =
        color ?? IconTheme.of(context).color ?? context.ff.color.textPrimary;
    final l = layout;
    final columns = (l.dots / rows).ceil();
    const step = FfDotMatrixTokens.dot + FfDotMatrixTokens.gap;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(
          columns * step - FfDotMatrixTokens.gap,
          rows * step - FfDotMatrixTokens.gap,
        ),
        painter: _DotsPainter(
          dots: l.dots,
          filled: l.filled,
          rows: rows,
          color: fg,
          spark: markNext && l.filled < l.dots ? context.ff.color.spark : null,
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.dots,
    required this.filled,
    required this.rows,
    required this.color,
    required this.spark,
  });

  final int dots, filled, rows;
  final Color color;
  final Color? spark;

  @override
  void paint(Canvas canvas, Size size) {
    const r = FfDotMatrixTokens.dot / 2;
    const step = FfDotMatrixTokens.dot + FfDotMatrixTokens.gap;
    final empty =
        Paint()..color = color.withValues(alpha: FfDotMatrixTokens.emptyAlpha);
    final full = Paint()..color = color;
    for (var i = 0; i < dots; i++) {
      // Fill column by column, top to bottom, so progress reads left to right.
      final col = i ~/ rows, row = i % rows;
      final center = Offset(col * step + r, row * step + r);
      if (spark != null && i == filled) {
        canvas.drawCircle(center, r + 1, Paint()..color = spark!);
      } else {
        canvas.drawCircle(center, r, i < filled ? full : empty);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.dots != dots ||
      old.filled != filled ||
      old.color != color ||
      old.spark != spark;
}

// ---------------------------------------------------------------------------
// Range band
// ---------------------------------------------------------------------------

/// One segment of an [FfRangeBand].
class FfBand {
  const FfBand({
    required this.start,
    required this.end,
    required this.tone,
    required this.label,
  });

  /// Positions on a 0–1 scale.
  final double start, end;
  final FfTone tone;

  /// Read by screen readers: "Good, under 30%".
  final String label;
}

/// Soft rounded bands (good, watch, high) with a marker at [value]: budget
/// pace, credit utilisation. [valueLabel] is shown under the marker side and
/// read with the band the value falls in.
class FfRangeBand extends StatelessWidget {
  const FfRangeBand({
    super.key,
    required this.bands,
    required this.value,
    required this.valueLabel,
  });

  final List<FfBand> bands;
  final double value;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final v = value.clamp(0.0, 1.0);
    final current = bands.firstWhere(
      (b) => v >= b.start && v <= b.end,
      orElse: () => bands.last,
    );
    return Semantics(
      label: '$valueLabel, ${current.label}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final x =
                  Directionality.of(context) == TextDirection.rtl
                      ? w * (1 - v)
                      : w * v;
              return SizedBox(
                height: FfRangeBandTokens.height + FfRangeBandTokens.marker + 4,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: FfRangeBandTokens.height,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, b) in bands.indexed) ...[
                            if (i > 0)
                              const SizedBox(width: FfRangeBandTokens.gap),
                            Expanded(
                              flex: math.max(
                                1,
                                ((b.end - b.start) * 100).round(),
                              ),
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: b.tone.container(c),
                                  shape: FfShape.of(FfRangeBandTokens.radius),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      left: x - FfRangeBandTokens.marker / 2,
                      top: 0,
                      bottom: -4,
                      width: FfRangeBandTokens.marker,
                      child: CustomPaint(
                        painter: _MarkerPainter(c.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: FfSpace.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  current.label,
                  style: ff.text.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(valueLabel, style: ff.text.labelLg),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final m = FfRangeBandTokens.marker;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(m, 0)
        ..lineTo(m / 2, m * 0.85)
        ..close(),
      p,
    );
    canvas.drawLine(
      Offset(size.width / 2, m * 0.6),
      Offset(size.width / 2, size.height),
      p..strokeWidth = FfBorderWidth.strong,
    );
  }

  @override
  bool shouldRepaint(_MarkerPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Line chart with the spark bubble
// ---------------------------------------------------------------------------

/// One point on an [FfLineChart].
class FfChartPoint {
  const FfChartPoint(this.label, this.value);

  /// The axis label, for example "Aug".
  final String label;
  final double value;
}

/// A thin line chart. The selected point gets a spark bubble with its value,
/// a dashed guide to the axis and a small triangle; drag or tap to move it
/// (with a haptic tick). Screen readers hear the selected point and can
/// step through points with increase/decrease.
///
/// An optional [reference] series (a budget's ideal pace, a target) is drawn
/// as a quiet dashed line without dots. With [domainLength] the x axis has
/// that many slots, so [points] can stop at today while the reference spans
/// the whole period. [referenceLabel] adds the reference value at the
/// selected slot to what screen readers hear ("Day 6: ₹6,800, pace ₹1,200").
class FfLineChart extends StatefulWidget {
  const FfLineChart({
    super.key,
    required this.points,
    required this.valueLabel,
    this.initialIndex,
    this.onSelected,
    this.height = FfLineChartTokens.height,
    this.reference,
    this.domainLength,
    this.referenceLabel,
    this.hint = 'Swipe up or down to change the month',
  }) : assert(points.length > 0),
       assert(domainLength == null || domainLength >= points.length);

  final List<FfChartPoint> points;

  /// Short text for the bubble and screen readers, e.g. "₹18.2L".
  final String Function(FfChartPoint point) valueLabel;

  /// Defaults to the last point.
  final int? initialIndex;
  final ValueChanged<int>? onSelected;
  final double height;

  /// Values of a dashed reference line, one per x slot from the left.
  final List<double>? reference;

  /// Number of x slots; defaults to the longer of [points] and [reference].
  final int? domainLength;

  /// The reference value at slot `index`, for screen readers.
  final String Function(int index)? referenceLabel;

  /// Screen-reader hint for stepping through the points.
  final String hint;

  int get slotCount => math.max(
    domainLength ?? points.length,
    math.max(points.length, reference?.length ?? 0),
  );

  @override
  State<FfLineChart> createState() => _FfLineChartState();
}

class _FfLineChartState extends State<FfLineChart> {
  late int _index = (widget.initialIndex ?? widget.points.length - 1).clamp(
    0,
    widget.points.length - 1,
  );

  void _select(int i) {
    i = i.clamp(0, widget.points.length - 1);
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    widget.onSelected?.call(i);
  }

  int _indexAt(double dx, double width) {
    final slots = widget.slotCount;
    if (slots == 1) return 0;
    final i = ((dx / width) * (slots - 1)).round();
    return i.clamp(0, widget.points.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final p = widget.points[_index];
    final label = widget.valueLabel(p);
    final refText = widget.referenceLabel?.call(_index);
    return Semantics(
      label: '${p.label}: $label${refText == null ? '' : ', $refText'}',
      hint: widget.hint,
      onIncrease: () => _select(_index + 1),
      onDecrease: () => _select(_index - 1),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder:
            (context, box) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  (d) => _select(_indexAt(d.localPosition.dx, box.maxWidth)),
              onHorizontalDragUpdate:
                  (d) => _select(_indexAt(d.localPosition.dx, box.maxWidth)),
              child: CustomPaint(
                size: Size(box.maxWidth, widget.height),
                painter: _LinePainter(
                  points: widget.points,
                  reference: widget.reference,
                  slots: widget.slotCount,
                  referenceColor: c.textSecondary,
                  selected: _index,
                  bubbleText: label,
                  line: c.textPrimary,
                  grid: c.textTertiary.withValues(alpha: FfOpacity.half),
                  axisText: ff.text.label,
                  spark: c.spark,
                  onSpark: c.onSpark,
                  bubbleStyle: ff.text.label.copyWith(
                    color: c.onSpark,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.points,
    required this.reference,
    required this.slots,
    required this.referenceColor,
    required this.selected,
    required this.bubbleText,
    required this.line,
    required this.grid,
    required this.axisText,
    required this.spark,
    required this.onSpark,
    required this.bubbleStyle,
  });

  final List<FfChartPoint> points;
  final List<double>? reference;
  final int slots;
  final Color referenceColor;
  final int selected;
  final String bubbleText;
  final Color line, grid, spark, onSpark;
  final TextStyle axisText, bubbleStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const bubble = FfLineChartTokens.bubble;
    const axisH = 22.0;
    final top = bubble * 0.4 + 4;
    final plotH = size.height - top - axisH;
    final ref = reference ?? const <double>[];
    final values = [...points.map((p) => p.value), ...ref];
    final lo = values.reduce(math.min), hi = values.reduce(math.max);
    final span = hi - lo == 0 ? 1 : hi - lo;
    final n = points.length;
    double xOf(int i) =>
        slots == 1 ? size.width / 2 : size.width * i / (slots - 1);
    double yOf(double v) => top + plotH * (1 - (v - lo) / span);
    Offset at(int i) => Offset(xOf(i), yOf(points[i].value));

    // Dashed grid.
    final gridPaint =
        Paint()
          ..color = grid
          ..strokeWidth = 1;
    for (var g = 0; g <= FfLineChartTokens.gridLines; g++) {
      final y = top + plotH * g / FfLineChartTokens.gridLines;
      _dash(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Reference: a quiet dashed line, no dots.
    if (ref.length > 1) {
      final refPaint =
          Paint()
            ..color = referenceColor
            ..strokeWidth = FfLineChartTokens.referenceStroke;
      for (var i = 1; i < ref.length; i++) {
        _dash(
          canvas,
          Offset(xOf(i - 1), yOf(ref[i - 1])),
          Offset(xOf(i), yOf(ref[i])),
          refPaint,
          pattern: FfLineChartTokens.referenceDash,
        );
      }
    }

    // Line and dots.
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < n; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = FfLineChartTokens.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = line;
    for (var i = 0; i < n; i++) {
      if (i != selected) canvas.drawCircle(at(i), FfLineChartTokens.dot, dot);
    }

    // Selected: guide, axis marker, bubble, axis label.
    final s = at(selected);
    final axisY = top + plotH + 4;
    _dash(
      canvas,
      s,
      Offset(s.dx, axisY),
      Paint()
        ..color = line
        ..strokeWidth = 1,
    );
    const m = FfLineChartTokens.axisMarker;
    canvas.drawPath(
      Path()
        ..moveTo(s.dx - m / 2, axisY + m)
        ..lineTo(s.dx, axisY)
        ..lineTo(s.dx + m / 2, axisY + m)
        ..close(),
      Paint()..color = line,
    );
    final tp = TextPainter(
      text: TextSpan(text: bubbleText, style: bubbleStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width / 2);
    // The bubble grows to fit its value, up to a pill.
    final bw = math.max(bubble, tp.width + 16);
    final bh = math.max(bubble * 0.8, tp.height + 12);
    final bx = s.dx.clamp(bw / 2, size.width - bw / 2);
    final by = math.max(bh / 2, s.dy - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
        Radius.circular(bh / 2),
      ),
      Paint()..color = spark,
    );
    tp.paint(canvas, Offset(bx - tp.width / 2, by - tp.height / 2));

    final lp = TextPainter(
      text: TextSpan(text: points[selected].label, style: axisText),
      textDirection: TextDirection.ltr,
    )..layout();
    final lx = (s.dx - lp.width / 2).clamp(0.0, size.width - lp.width);
    lp.paint(canvas, Offset(lx, axisY + m + 2));
  }

  void _dash(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    List<double> pattern = FfLineChartTokens.dash,
  }) {
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    final on = pattern[0], off = pattern[1];
    for (var d = 0.0; d < total; d += on + off) {
      canvas.drawLine(a + dir * d, a + dir * math.min(d + on, total), paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.points != points ||
      old.reference != reference ||
      old.slots != slots ||
      old.selected != selected ||
      old.bubbleText != bubbleText ||
      old.line != line ||
      old.spark != spark;
}

// ---------------------------------------------------------------------------
// Month grid
// ---------------------------------------------------------------------------

/// The state of one month in an [FfMonthGrid].
///
/// Payments use [paid], [missed], [due] and [upcoming]. Budget history uses
/// [under] ("within plan", spark check) and [over] ("over plan", amber "!").
/// [none] is a month with nothing to show. Each status is announced in words.
enum FfMonthStatus { paid, missed, due, upcoming, none, under, over }

/// One month tile.
class FfMonthCell {
  const FfMonthCell({required this.label, required this.status, this.note});

  /// Short month name, "Sep".
  final String label;
  final FfMonthStatus status;

  /// Small text instead of a marker for [FfMonthStatus.due], e.g. "6th";
  /// for [FfMonthStatus.under] and [FfMonthStatus.over] it is shown under
  /// the marker, e.g. "₹6.8k". Always read out after the status.
  final String? note;
}

/// A grid of rounded month tiles for EMIs and subscription payments (paid
/// months carry a spark check, missed months an outlined cross, upcoming
/// months are faded) and for budget history (within plan: spark check; over
/// plan: amber "!"; the amount underneath). Each tile is announced as
/// "September, missed" or "September, over plan, ₹6,800".
class FfMonthGrid extends StatelessWidget {
  const FfMonthGrid({
    super.key,
    required this.months,
    this.columns = FfMonthGridTokens.columns,
  });

  final List<FfMonthCell> months;
  final int columns;

  static String _statusWord(FfMonthStatus s) => switch (s) {
    FfMonthStatus.paid => 'paid',
    FfMonthStatus.missed => 'missed',
    FfMonthStatus.due => 'due',
    FfMonthStatus.upcoming => 'upcoming',
    FfMonthStatus.none => 'no payment',
    FfMonthStatus.under => 'within plan',
    FfMonthStatus.over => 'over plan',
  };

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final fg = IconTheme.of(context).color ?? c.textPrimary;
    // When any tile shows an amount under its marker, every tile keeps that
    // line so the row stays even.
    final noteLine = months.any(_showsNote);
    return LayoutBuilder(
      builder: (context, box) {
        const gap = FfMonthGridTokens.gap;
        final w = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final m in months)
              Semantics(
                label:
                    '${m.label}, ${_statusWord(m.status)}${m.note == null ? '' : ', ${m.note}'}',
                excludeSemantics: true,
                child: Opacity(
                  opacity:
                      m.status == FfMonthStatus.upcoming ? FfOpacity.half : 1,
                  child: Container(
                    width: w,
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        FfMonthGridTokens.minTileHeight,
                        w * 1.08,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: FfSpace.x2s + 2,
                    ),
                    decoration: ShapeDecoration(
                      color: fg.withValues(alpha: FfTint.faint.alpha),
                      shape: FfShape.of(FfMonthGridTokens.radius),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m.label,
                          style: ff.text.labelSm.copyWith(color: fg),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: FfSpace.x2s),
                        _marker(context, m, fg),
                        if (noteLine) ...[
                          const SizedBox(height: FfSpace.x2s),
                          Text(
                            _showsNote(m) ? m.note! : ' ',
                            style: ff.text.labelSm.copyWith(
                              color: fg,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static bool _showsNote(FfMonthCell m) =>
      m.note != null &&
      (m.status == FfMonthStatus.under || m.status == FfMonthStatus.over);

  Widget _marker(BuildContext context, FfMonthCell m, Color fg) {
    final c = context.ff.color;
    const size = FfMonthGridTokens.marker;
    switch (m.status) {
      case FfMonthStatus.over:
        return Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: c.statusWarningFill,
          ),
          child: Icon(
            Icons.priority_high_rounded,
            size: FfIconSize.xs,
            color: c.onStatusWarningFill,
          ),
        );
      case FfMonthStatus.under:
      case FfMonthStatus.paid:
        return Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: c.spark,
          ),
          child: Icon(
            Icons.check_rounded,
            size: FfIconSize.xs,
            color: c.onSpark,
          ),
        );
      case FfMonthStatus.missed:
        return Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(color: fg, width: FfBorderWidth.strong),
            ),
          ),
          child: Icon(Icons.close_rounded, size: FfIconSize.xs, color: fg),
        );
      case FfMonthStatus.due:
        return SizedBox(
          height: size,
          child: Center(
            child: Text(
              m.note ?? 'Due',
              style: context.ff.text.labelSm.copyWith(color: fg),
            ),
          ),
        );
      case FfMonthStatus.upcoming:
      case FfMonthStatus.none:
        return const SizedBox(height: size);
    }
  }
}
