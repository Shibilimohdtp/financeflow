import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/stillwater_tokens.dart';

class BarChartItem {
  final String label;
  final double value;
  final double? secondaryValue; // e.g. income alongside expense
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

/// Stillwater accessible bar chart for financial distributions and comparison
class FfBarChart extends StatefulWidget {
  final List<BarChartItem> items;
  final double height;
  final String? semanticsSummary;
  final String? valuePrefix;

  const FfBarChart({
    super.key,
    required this.items,
    this.height = 180.0,
    this.semanticsSummary,
    this.valuePrefix,
  });

  @override
  State<FfBarChart> createState() => _FfBarChartState();
}

class _FfBarChartState extends State<FfBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No data available for this chart.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    final maxValue = widget.items.fold<double>(
      0.0,
      (maxV, item) => max(maxV, max(item.value, item.secondaryValue ?? 0.0)),
    );
    final safeMax = maxValue > 0 ? maxValue : 1.0;

    return Semantics(
      container: true,
      label:
          widget.semanticsSummary ??
          'Financial bar chart showing ${widget.items.length} bars.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final widthPerItem =
                        constraints.maxWidth / widget.items.length;
                    final index =
                        (details.localPosition.dx / widthPerItem).floor();
                    if (index >= 0 && index < widget.items.length) {
                      setState(() {
                        _selectedIndex = _selectedIndex == index ? null : index;
                      });
                    }
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, widget.height),
                    painter: _BarChartPainter(
                      items: widget.items,
                      maxValue: safeMax,
                      selectedIndex: _selectedIndex,
                      defaultPrimaryColor: finColors.expense,
                      defaultSecondaryColor: finColors.income,
                      gridColor: theme.dividerColor.withValues(alpha: 0.3),
                      textColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                      highlightColor: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedIndex != null &&
              _selectedIndex! < widget.items.length) ...[
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
                    '${widget.items[_selectedIndex!].label}: ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(
                      widget.items[_selectedIndex!].value,
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          widget.items[_selectedIndex!].color ??
                          finColors.expense,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.items[_selectedIndex!].secondaryValue != null) ...[
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'Income: ${CurrencyFormatter.format(widget.items[_selectedIndex!].secondaryValue!)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            widget.items[_selectedIndex!].secondaryColor ??
                            finColors.income,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartItem> items;
  final double maxValue;
  final int? selectedIndex;
  final Color defaultPrimaryColor;
  final Color defaultSecondaryColor;
  final Color gridColor;
  final Color textColor;
  final Color highlightColor;

  _BarChartPainter({
    required this.items,
    required this.maxValue,
    this.selectedIndex,
    required this.defaultPrimaryColor,
    required this.defaultSecondaryColor,
    required this.gridColor,
    required this.textColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomLabelHeight = 24.0;
    const double topPadding = 12.0;
    final chartHeight = size.height - bottomLabelHeight - topPadding;

    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

    // Draw zero baseline
    canvas.drawLine(
      Offset(0, topPadding + chartHeight),
      Offset(size.width, topPadding + chartHeight),
      gridPaint,
    );

    // Draw mid grid line
    canvas.drawLine(
      Offset(0, topPadding + chartHeight / 2),
      Offset(size.width, topPadding + chartHeight / 2),
      gridPaint,
    );

    final numItems = items.length;
    final slotWidth = size.width / numItems;
    final maxBarWidth = min(slotWidth * 0.5, 24.0);

    for (int i = 0; i < numItems; i++) {
      final item = items[i];
      final isSelected = selectedIndex == i;
      final centerX = slotWidth * i + slotWidth / 2;

      final hasSecondary = item.secondaryValue != null;
      final barWidth = hasSecondary ? maxBarWidth * 0.45 : maxBarWidth;

      // Primary Bar (e.g. Expense)
      final primaryRatio = (item.value / maxValue).clamp(0.0, 1.0);
      final primaryHeight = chartHeight * primaryRatio;
      final primaryColor = item.color ?? defaultPrimaryColor;

      final primaryPaint =
          Paint()
            ..color =
                isSelected ? primaryColor : primaryColor.withValues(alpha: 0.85)
            ..style = PaintingStyle.fill;

      final primaryX =
          hasSecondary ? centerX - barWidth - 1.5 : centerX - barWidth / 2;
      final primaryTop = topPadding + chartHeight - primaryHeight;

      final primaryRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(primaryX, primaryTop, barWidth, primaryHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(primaryRect, primaryPaint);

      // Secondary Bar if exists (e.g. Income)
      if (hasSecondary) {
        final secRatio = (item.secondaryValue! / maxValue).clamp(0.0, 1.0);
        final secHeight = chartHeight * secRatio;
        final secColor = item.secondaryColor ?? defaultSecondaryColor;

        final secPaint =
            Paint()
              ..color = isSelected ? secColor : secColor.withValues(alpha: 0.85)
              ..style = PaintingStyle.fill;

        final secX = centerX + 1.5;
        final secTop = topPadding + chartHeight - secHeight;

        final secRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(secX, secTop, barWidth, secHeight),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(secRect, secPaint);
      }

      // Draw bottom label
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(
            color: isSelected ? highlightColor : textColor,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);

      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          size.height - bottomLabelHeight + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
