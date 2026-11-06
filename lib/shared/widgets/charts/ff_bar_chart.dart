import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/ff.dart';

class BarChartItem {
  final String label;
  final double value;
  final double? secondaryValue;
  final Color? color;
  final Color? secondaryColor;

  const BarChartItem({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.color,
    this.secondaryColor,
  });
}

/// Shared Stillwater Bloom bar chart with rounded bars, spark selection bubble,
/// tabular Geist numerals, and accessible semantics.
class FfBarChart extends StatefulWidget {
  final List<BarChartItem> items;
  final double height;
  final String? semanticsSummary;
  final String? valuePrefix;
  final bool showYAxis;
  final bool showSelectionDetails;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final String primaryLabel;
  final String secondaryLabel;

  const FfBarChart({
    super.key,
    required this.items,
    this.height = FfBarChartTokens.defaultHeight,
    this.semanticsSummary,
    this.valuePrefix,
    this.showYAxis = false,
    this.showSelectionDetails = true,
    this.selectedIndex,
    this.onSelected,
    this.primaryLabel = 'Expenses',
    this.secondaryLabel = 'Income',
  });

  @override
  State<FfBarChart> createState() => _FfBarChartState();
}

class _FfBarChartState extends State<FfBarChart> {
  int? _localIndex;

  @override
  void didUpdateWidget(covariant FfBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) _localIndex = null;
  }

  void _select(int index) {
    final current = widget.selectedIndex ?? _localIndex;
    if (index != current) {
      HapticFeedback.selectionClick();
    }
    if (widget.onSelected != null) {
      widget.onSelected!(index);
    } else {
      setState(() => _localIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No data available for this chart.',
            style: ff.text.bodySm.copyWith(color: c.textSecondary),
          ),
        ),
      );
    }
    final rawIndex = widget.selectedIndex ?? _localIndex;
    final index =
        rawIndex != null && rawIndex >= 0 && rawIndex < widget.items.length
            ? rawIndex
            : null;
    final selected = index == null ? null : widget.items[index];
    final maxValue = widget.items.fold<double>(
      0,
      (v, item) => max(
        v,
        max(_positive(item.value), _positive(item.secondaryValue ?? 0)),
      ),
    );
    final ceiling = _axisCeiling(maxValue);
    final textStyle = ff.text.labelSm.copyWith(
      color: c.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final bubbleStyle = ff.text.labelSm.copyWith(
      color: c.onSpark,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final scaler = MediaQuery.textScalerOf(context);
    String amount(double value) =>
        widget.valuePrefix == null
            ? CurrencyFormatter.format(value)
            : '${widget.valuePrefix}${CurrencyFormatter.format(value, includeSymbol: false)}';

    String describe(BarChartItem item) =>
        '${item.label}, ${widget.primaryLabel} ${amount(item.value)}'
        '${item.secondaryValue == null ? '' : ', ${widget.secondaryLabel} ${amount(item.secondaryValue!)}'}';

    return Semantics(
      container: true,
      label: widget.semanticsSummary ?? 'Financial bar chart',
      value:
          selected == null
              ? '${widget.items.length} periods'
              : describe(selected),
      increasedValue:
          (index ?? -1) < widget.items.length - 1
              ? describe(widget.items[(index ?? -1) + 1])
              : null,
      decreasedValue:
          index != null && index > 0 ? describe(widget.items[index - 1]) : null,
      onIncrease:
          (index ?? -1) < widget.items.length - 1
              ? () => _select((index ?? -1) + 1)
              : null,
      onDecrease: index != null && index > 0 ? () => _select(index - 1) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final painter = _BarChartPainter(
                  items: widget.items,
                  ceiling: ceiling,
                  selectedIndex: index,
                  primaryColor: c.moneyExpense,
                  secondaryColor: c.moneyIncome,
                  gridColor: c.borderSubtle,
                  highlightColor: c.textPrimary,
                  sparkColor: c.spark,
                  onSparkColor: c.onSpark,
                  textStyle: textStyle,
                  bubbleStyle: bubbleStyle,
                  textScaler: scaler,
                  showYAxis: widget.showYAxis,
                  valuePrefix: widget.valuePrefix,
                );
                final plot = painter.plotRect(
                  Size(constraints.maxWidth, widget.height),
                );

                void handleTouch(Offset localPosition) {
                  final dx = localPosition.dx;
                  if (dx < plot.left || dx >= plot.right || plot.width <= 0) {
                    return;
                  }
                  final target = ((dx - plot.left) /
                          plot.width *
                          widget.items.length)
                      .floor()
                      .clamp(0, widget.items.length - 1);
                  _select(target);
                }

                return GestureDetector(
                  key: const ValueKey('cash-flow-plot'),
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => handleTouch(details.localPosition),
                  onHorizontalDragUpdate:
                      (details) => handleTouch(details.localPosition),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, widget.height),
                    painter: painter,
                  ),
                );
              },
            ),
          ),
          if (widget.showSelectionDetails && selected != null)
            Padding(
              padding: const EdgeInsets.only(top: FfSpace.sm),
              child: Wrap(
                spacing: FfSpace.sm,
                runSpacing: FfSpace.x2s,
                children: [
                  Text(selected.label, style: ff.text.label),
                  Text(
                    '${widget.primaryLabel}: ${amount(selected.value)}',
                    style: ff.text.label.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (selected.secondaryValue != null)
                    Text(
                      '${widget.secondaryLabel}: ${amount(selected.secondaryValue!)}',
                      style: ff.text.label.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

double _positive(double value) => value.isFinite && value > 0 ? value : 0;

double _axisCeiling(double value) {
  if (value <= 0) return 1;
  final magnitude = pow(10, (log(value) / ln10).floor()).toDouble();
  return (value * 1.05 / magnitude).ceil() * magnitude;
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartItem> items;
  final double ceiling;
  final int? selectedIndex;
  final Color primaryColor, secondaryColor, gridColor, highlightColor;
  final Color sparkColor, onSparkColor;
  final TextStyle textStyle, bubbleStyle;
  final TextScaler textScaler;
  final bool showYAxis;
  final String? valuePrefix;

  _BarChartPainter({
    required this.items,
    required this.ceiling,
    required this.selectedIndex,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gridColor,
    required this.highlightColor,
    required this.sparkColor,
    required this.onSparkColor,
    required this.textStyle,
    required this.bubbleStyle,
    required this.textScaler,
    required this.showYAxis,
    required this.valuePrefix,
  });

  TextPainter _text(String value, {bool selected = false}) => TextPainter(
    text: TextSpan(
      text: value,
      style:
          selected
              ? textStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: highlightColor,
              )
              : textStyle,
    ),
    maxLines: 1,
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  String _tick(double value) =>
      valuePrefix == null
          ? CurrencyFormatter.formatCompact(value)
          : '$valuePrefix${CurrencyFormatter.formatCompact(value, includeSymbol: false)}';

  Rect plotRect(Size size) {
    final labels = [
      _text(_tick(ceiling)),
      _text(_tick(ceiling / 2)),
      _text(_tick(0)),
    ];
    final left = showYAxis ? labels.map((t) => t.width).reduce(max) + 10 : 0.0;
    final labelHeight = labels.map((t) => t.height).reduce(max);
    for (final label in labels) {
      label.dispose();
    }
    // Reserve top headroom for the spark bubble when selected.
    final top = FfBarChartTokens.bubbleHeight + 6.0;
    return Rect.fromLTRB(
      min(left, size.width / 2),
      top,
      size.width,
      max(top + 5, size.height - labelHeight - 12),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = plotRect(size);
    final slot = plot.width / items.length;

    // Grid lines (3 levels: 0%, 50%, 100%)
    for (final fraction in [0.0, .5, 1.0]) {
      final y = plot.bottom - plot.height * fraction;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = fraction == 0 ? 1 : 0.6,
      );
      if (showYAxis) {
        final label = _text(_tick(ceiling * fraction));
        label.paint(
          canvas,
          Offset(max(0, plot.left - label.width - 8), y - label.height / 2),
        );
        label.dispose();
      }
    }

    final hasSecondary = items.any((item) => item.secondaryValue != null);
    final barWidth = min(18.0, slot * (hasSecondary ? 0.28 : 0.46));
    final barRadius = min(FfBarChartTokens.barRadius, barWidth / 2);

    for (var i = 0; i < items.length; i++) {
      final centerX = plot.left + slot * (i + 0.5);

      // Selected column background wash
      if (i == selectedIndex) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              plot.left + slot * i + 1,
              plot.top - 4,
              max(0, slot - 2),
              plot.height + 4,
            ),
            const Radius.circular(FfRadius.xs),
          ),
          Paint()..color = highlightColor.withValues(alpha: FfTint.faint.alpha),
        );
      }

      void bar(double value, Color color, double x) {
        final height =
            plot.height * (_positive(value) / ceiling).clamp(0.0, 1.0);
        if (height <= 0) return;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, plot.bottom - height, barWidth, height),
            topLeft: Radius.circular(barRadius),
            topRight: Radius.circular(barRadius),
          ),
          Paint()..color = color,
        );
      }

      bar(
        items[i].value,
        items[i].color ?? primaryColor,
        hasSecondary
            ? centerX - barWidth - FfBarChartTokens.secondaryGap / 2
            : centerX - barWidth / 2,
      );
      if (hasSecondary) {
        bar(
          items[i].secondaryValue ?? 0,
          items[i].secondaryColor ?? secondaryColor,
          centerX + FfBarChartTokens.secondaryGap / 2,
        );
      }
    }

    // Spark value bubble over selected item
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < items.length) {
      final sel = items[selectedIndex!];
      final centerX = plot.left + slot * (selectedIndex! + 0.5);
      final String bubbleText;
      if (sel.secondaryValue != null) {
        final p = CurrencyFormatter.formatCompact(sel.value);
        final s = CurrencyFormatter.formatCompact(sel.secondaryValue!);
        bubbleText = '$p · $s';
      } else {
        bubbleText = CurrencyFormatter.formatCompact(sel.value);
      }

      final bp = TextPainter(
        text: TextSpan(text: bubbleText, style: bubbleStyle),
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: size.width / 2);

      final bw = max(
        FfBarChartTokens.bubbleMinWidth,
        bp.width + FfBarChartTokens.bubblePaddingH * 2,
      );
      final bh = max(FfBarChartTokens.bubbleHeight, bp.height + 6);
      final minX = bw / 2;
      final maxX = max(minX, size.width - bw / 2);
      final bx = centerX.clamp(minX, maxX);

      final minY = bh / 2;
      final maxY = max(minY, plot.bottom - bh);
      final by = (plot.top - bh / 2 - 2).clamp(minY, maxY);

      // Bubble pill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
          Radius.circular(bh / 2),
        ),
        Paint()..color = sparkColor,
      );

      // Indicator triangle pointing to the column
      const triH = 3.0;
      const triW = 6.0;
      final triY = by + bh / 2;
      canvas.drawPath(
        Path()
          ..moveTo(centerX - triW / 2, triY)
          ..lineTo(centerX, triY + triH)
          ..lineTo(centerX + triW / 2, triY)
          ..close(),
        Paint()..color = sparkColor,
      );

      bp.paint(canvas, Offset(bx - bp.width / 2, by - bp.height / 2));
      bp.dispose();
    }

    // X-axis ticks (skip overlapping labels)
    var lastRight = double.negativeInfinity;
    for (var i = 0; i < items.length; i++) {
      final label = _text(items[i].label, selected: i == selectedIndex);
      final centerX = plot.left + slot * (i + 0.5);
      final x =
          (centerX - label.width / 2)
              .clamp(plot.left, max(plot.left, plot.right - label.width))
              .toDouble();
      if (label.width <= plot.width && x >= lastRight + 12) {
        label.paint(canvas, Offset(x, plot.bottom + 8));
        lastRight = x + label.width;
      }
      label.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.items != items ||
      old.ceiling != ceiling ||
      old.selectedIndex != selectedIndex ||
      old.primaryColor != primaryColor ||
      old.secondaryColor != secondaryColor ||
      old.gridColor != gridColor ||
      old.highlightColor != highlightColor ||
      old.sparkColor != sparkColor ||
      old.onSparkColor != onSparkColor ||
      old.textStyle != textStyle ||
      old.bubbleStyle != bubbleStyle ||
      old.textScaler != textScaler ||
      old.showYAxis != showYAxis ||
      old.valuePrefix != valuePrefix;
}
