import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A single slice in an allocation band.
class FfAllocationSlice {
  const FfAllocationSlice({
    required this.label,
    required this.value,
    required this.percentage,
    this.tone,
    this.color,
  });

  final String label;
  final double value;
  final double percentage; // 0.0 to 100.0
  final FfTone? tone;
  final Color? color;
}

/// A segmented horizontal proportion band with accessible legend.
///
/// Used for asset allocation in portfolio summaries, category spending
/// distributions, and multi-slice breakdowns.
class FfAllocationBand extends StatelessWidget {
  const FfAllocationBand({
    super.key,
    required this.slices,
    this.height = 12.0,
    this.showLegend = true,
  });

  final List<FfAllocationSlice> slices;
  final double height;
  final bool showLegend;

  Color _resolveColor(
    BuildContext context,
    FfAllocationSlice slice,
    int index,
  ) {
    if (slice.color != null) return slice.color!;
    final c = context.ff.color;
    if (slice.tone != null) return slice.tone!.foreground(c);

    // Default harmonic palette sequence
    const fallbackTones = [
      FfTone.investment,
      FfTone.savings,
      FfTone.income,
      FfTone.primary,
      FfTone.accent,
      FfTone.neutral,
    ];
    final t = fallbackTones[index % fallbackTones.length];
    return t.foreground(c);
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;

    final validSlices = slices.where((s) => s.percentage > 0).toList();
    if (validSlices.isEmpty) {
      return const SizedBox.shrink();
    }

    final semanticsLabel = validSlices
        .map((s) => '${s.label}: ${s.percentage.toStringAsFixed(1)}%')
        .join(', ');

    return Semantics(
      container: true,
      label: 'Allocation: $semanticsLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(FfRadius.full),
            child: Container(
              height: height,
              width: double.infinity,
              color: c.surfaceContainerHighest,
              child: Row(
                children: [
                  for (var i = 0; i < validSlices.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      flex: (validSlices[i].percentage * 10).round().clamp(
                        1,
                        1000,
                      ),
                      child: Container(
                        color: _resolveColor(context, validSlices[i], i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (showLegend) ...[
            const SizedBox(height: FfSpace.md),
            // 2. Legend Wrap
            Wrap(
              spacing: FfSpace.md,
              runSpacing: FfSpace.sm,
              children: [
                for (var i = 0; i < validSlices.length; i++)
                  _LegendItem(
                    slice: validSlices[i],
                    color: _resolveColor(context, validSlices[i], i),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.slice, required this.color});

  final FfAllocationSlice slice;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: FfSpace.xs),
        Text(
          slice.label,
          style: ff.text.labelSm.copyWith(color: ff.color.textSecondary),
        ),
        const SizedBox(width: FfSpace.x2s),
        Text(
          '${slice.percentage.toStringAsFixed(1)}%',
          style: ff.text.labelSm.copyWith(
            fontWeight: FontWeight.w600,
            color: ff.color.textPrimary,
          ),
        ),
      ],
    );
  }
}
