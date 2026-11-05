import 'package:flutter/material.dart';

import '../../theme/ff.dart';

enum FfProgressSize { sm, md, lg }

/// A rounded progress bar. [value] is 0–1; null shows an indeterminate bar.
/// [color] defaults to the primary action colour; pass a palette colour from
/// `context.ff.color` to express meaning (over budget, goal reached).
/// [pace] draws a thin marker where progress "should" be by now.
class FfProgressBar extends StatelessWidget {
  const FfProgressBar({
    super.key,
    required this.value,
    this.color,
    this.size = FfProgressSize.md,
    this.pace,
    this.semanticLabel,
  });

  final double? value;
  final Color? color;
  final FfProgressSize size;
  final double? pace;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final height = switch (size) {
      FfProgressSize.sm => FfProgressTokens.heightSm,
      FfProgressSize.md => FfProgressTokens.heightMd,
      FfProgressSize.lg => FfProgressTokens.heightLg,
    };
    final v = value?.clamp(0.0, 1.0);
    final bar = ClipRRect(
      borderRadius: ffRadius(FfRadius.full),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height,
        color: color ?? c.actionPrimary,
        backgroundColor: c.surfaceContainerHighest,
        semanticsLabel: semanticLabel,
        semanticsValue: v == null ? null : '${(v * 100).round()}%',
      ),
    );
    final p = pace;
    if (p == null) return bar;
    return LayoutBuilder(
      builder:
          (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              bar,
              PositionedDirectional(
                start:
                    (constraints.maxWidth * p.clamp(0.0, 1.0)) -
                    FfProgressTokens.paceMarkerWidth / 2,
                top: -FfSpace.x3s,
                bottom: -FfSpace.x3s,
                child: Container(
                  width: FfProgressTokens.paceMarkerWidth,
                  decoration: BoxDecoration(
                    color: c.textPrimary,
                    borderRadius: ffRadius(FfRadius.full),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

/// A centred loading spinner that announces itself to screen readers.
class FfLoading extends StatelessWidget {
  const FfLoading({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FfSpace.xl),
        child: SizedBox.square(
          dimension: FfProgressTokens.spinnerSize,
          child: CircularProgressIndicator(
            strokeWidth: FfProgressTokens.spinnerStroke,
            color: context.ff.color.actionPrimary,
            semanticsLabel: label,
          ),
        ),
      ),
    );
  }
}
