import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
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

/// Shared linear scale with collision-free ticks and selectable date groups.
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
    this.height = 180,
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
    if (widget.onSelected != null) {
      widget.onSelected!(index);
    } else {
      setState(() => _localIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.finColors;
    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No data available for this chart.')),
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
    final textStyle = context.ff.text.labelSm.copyWith(
      color: context.ff.color.textSecondary,
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
                  primaryColor: colors.expense,
                  secondaryColor: colors.income,
                  gridColor: context.ff.color.borderSubtle,
                  highlightColor: context.ff.color.textPrimary,
                  textStyle: textStyle,
                  textScaler: scaler,
                  showYAxis: widget.showYAxis,
                  valuePrefix: widget.valuePrefix,
                );
                final plot = painter.plotRect(
                  Size(constraints.maxWidth, widget.height),
                );
                return GestureDetector(
                  key: const ValueKey('cash-flow-plot'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    final dx = details.localPosition.dx;
                    if (dx < plot.left || dx >= plot.right || plot.width <= 0) {
                      return;
                    }
                    _select(
                      ((dx - plot.left) / plot.width * widget.items.length)
                          .floor(),
                    );
                  },
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
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(selected.label, style: context.ff.text.label),
                  Text('${widget.primaryLabel}: ${amount(selected.value)}'),
                  if (selected.secondaryValue != null)
                    Text(
                      '${widget.secondaryLabel}: ${amount(selected.secondaryValue!)}',
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
  final TextStyle textStyle;
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
    required this.textStyle,
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
                fontWeight: FontWeight.w700,
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
    return Rect.fromLTRB(
      min(left, size.width / 2),
      labelHeight / 2 + 4,
      size.width,
      max(labelHeight / 2 + 5, size.height - labelHeight - 12),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = plotRect(size);
    final slot = plot.width / items.length;
    for (final fraction in [0.0, .5, 1.0]) {
      final y = plot.bottom - plot.height * fraction;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = gridColor
          ..strokeWidth = fraction == 0 ? 1 : .6,
      );
      if (showYAxis) {
        final label = _text(_tick(ceiling * fraction));
        label.paint(
          canvas,
          Offset(max(0, plot.left - label.width - 10), y - label.height / 2),
        );
        label.dispose();
      }
    }
    final hasSecondary = items.any((item) => item.secondaryValue != null);
    final barWidth = min(18.0, slot * (hasSecondary ? .28 : .48));
    for (var i = 0; i < items.length; i++) {
      final centerX = plot.left + slot * (i + .5);
      if (i == selectedIndex) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              plot.left + slot * i + 1,
              plot.top,
              max(0, slot - 2),
              plot.height,
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
            topLeft: Radius.circular(min(3, barWidth / 2)),
            topRight: Radius.circular(min(3, barWidth / 2)),
          ),
          Paint()..color = color,
        );
      }

      bar(
        items[i].value,
        items[i].color ?? primaryColor,
        hasSecondary ? centerX - barWidth - 1 : centerX - barWidth / 2,
      );
      if (hasSecondary) {
        bar(
          items[i].secondaryValue ?? 0,
          items[i].secondaryColor ?? secondaryColor,
          centerX + 1,
        );
      }
    }

    // Lay out ticks unconstrained on a single line, then skip crowded ticks.
    // Never wrap a two-digit day into two rows or force every date to fit.
    var lastRight = double.negativeInfinity;
    for (var i = 0; i < items.length; i++) {
      final label = _text(items[i].label, selected: i == selectedIndex);
      final centerX = plot.left + slot * (i + .5);
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
      old.textStyle != textStyle ||
      old.textScaler != textScaler ||
      old.showYAxis != showYAxis ||
      old.valuePrefix != valuePrefix;
}
