import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_amount_text.dart';

/// A two-sided proportional balance bar for comparing two competing amounts
/// (e.g. "Owed to you" vs "You owe", or "Assets" vs "Liabilities").
class FfBalanceBand extends StatelessWidget {
  const FfBalanceBand({
    super.key,
    required this.leftLabel,
    required this.leftAmount,
    this.leftTone = FfTone.income,
    required this.rightLabel,
    required this.rightAmount,
    this.rightTone = FfTone.expense,
    this.height = 8.0,
    this.showLegend = true,
    this.onHero = true,
  });

  final String leftLabel;
  final double leftAmount;
  final FfTone leftTone;

  final String rightLabel;
  final double rightAmount;
  final FfTone rightTone;

  final double height;
  final bool showLegend;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final total = leftAmount + rightAmount;

    final leftColor =
        onHero
            ? (leftTone == FfTone.income
                ? const Color(0xFFCBE94C) // Spark accent
                : ff.color.textPrimary)
            : leftTone.foreground(ff.color);

    final rightColor =
        onHero
            ? (rightTone == FfTone.expense
                ? const Color(0xFFFFA89E) // Soft rose brick accent
                : ff.color.textSecondary)
            : rightTone.foreground(ff.color);

    final leftRatio = total > 0 ? (leftAmount / total).clamp(0.0, 1.0) : 0.5;
    final rightRatio = total > 0 ? (rightAmount / total).clamp(0.0, 1.0) : 0.5;

    final leftPct = (leftRatio * 100).round();
    final rightPct = (rightRatio * 100).round();

    final semanticsDesc =
        total > 0
            ? '$leftLabel ${CurrencyFormatter.format(leftAmount)} ($leftPct%), '
                '$rightLabel ${CurrencyFormatter.format(rightAmount)} ($rightPct%)'
            : 'All square, no balance';

    return Semantics(
      label: semanticsDesc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── The Segmented Bar ───────────────────────────────────────────
          Container(
            height: height,
            decoration: BoxDecoration(
              color:
                  onHero
                      ? ff.color.textPrimary.withValues(
                        alpha: FfTint.faint.alpha,
                      )
                      : ff.color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(FfRadius.full),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                total <= 0
                    ? const SizedBox.shrink()
                    : Row(
                      children: [
                        if (leftAmount > 0)
                          Expanded(
                            flex: (leftRatio * 1000).toInt().clamp(1, 999),
                            child: Container(color: leftColor),
                          ),
                        if (leftAmount > 0 && rightAmount > 0)
                          Container(
                            width: 2,
                            color:
                                onHero
                                    ? Colors.transparent
                                    : ff.color.surfaceCard,
                          ),
                        if (rightAmount > 0)
                          Expanded(
                            flex: (rightRatio * 1000).toInt().clamp(1, 999),
                            child: Container(color: rightColor),
                          ),
                      ],
                    ),
          ),

          if (showLegend) ...[
            const SizedBox(height: FfSpace.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Legend
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: leftColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: FfSpace.x2s),
                    Text(
                      '$leftLabel: ',
                      style: ff.text.labelSm.copyWith(
                        color:
                            onHero
                                ? ff.color.textSecondary
                                : ff.color.textSecondary,
                      ),
                    ),
                    FfAmountText(
                      amount: leftAmount,
                      size: FfAmountSize.sm,
                      style: FfAmountStyle.inline,
                      showSign: false,
                    ),
                  ],
                ),

                // Right Legend
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: rightColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: FfSpace.x2s),
                    Text(
                      '$rightLabel: ',
                      style: ff.text.labelSm.copyWith(
                        color:
                            onHero
                                ? ff.color.textSecondary
                                : ff.color.textSecondary,
                      ),
                    ),
                    FfAmountText(
                      amount: rightAmount,
                      size: FfAmountSize.sm,
                      style: FfAmountStyle.inline,
                      showSign: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
