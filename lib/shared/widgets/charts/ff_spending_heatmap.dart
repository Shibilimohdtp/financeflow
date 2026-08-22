import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../theme/stillwater_tokens.dart';

/// Stillwater spending heatmap visualizing day-of-week intensity
class FfSpendingHeatmap extends StatelessWidget {
  final List<DayOfWeekSpend> days;
  final String? semanticsSummary;

  const FfSpendingHeatmap({
    super.key,
    required this.days,
    this.semanticsSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final maxAmount = days.fold<double>(
      0.0,
      (maxV, d) => max(maxV, d.totalAmount),
    );
    final safeMax = maxAmount > 0 ? maxAmount : 1.0;

    return Semantics(
      label: semanticsSummary ?? 'Day of week spending heatmap.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:
                days.map((day) {
                  final intensity = (day.totalAmount / safeMax).clamp(0.0, 1.0);
                  final Color cellColor;
                  if (day.totalAmount <= 0) {
                    cellColor = theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4);
                  } else {
                    cellColor = context.finColors.expense.withValues(
                      alpha: 0.15 + (intensity * 0.85),
                    );
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Tooltip(
                        message:
                            '${day.dayName}: ${CurrencyFormatter.format(day.totalAmount)} (${day.count} transactions)',
                        child: Column(
                          children: [
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusSm,
                                ),
                                border: Border.all(
                                  color:
                                      intensity > 0.6
                                          ? context.finColors.expense
                                          : theme.dividerColor.withValues(
                                            alpha: 0.2,
                                          ),
                                  width: 0.5,
                                ),
                              ),
                              child: Center(
                                child:
                                    day.totalAmount > 0
                                        ? Text(
                                          '${day.count}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                intensity > 0.5
                                                    ? Colors.white
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                        )
                                        : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.space3Xs),
                            Text(
                              day.dayName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
