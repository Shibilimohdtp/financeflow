import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

enum FfProgressSize { sm, md, lg }

/// A rounded progress bar. [value] is 0–1; null shows an indeterminate bar.
///
/// Colour: [tone] expresses meaning (`FfTone.expense` for over budget,
/// `FfTone.income` for a goal reached); [color] is the older escape hatch and
/// wins when both are given. Status is never colour alone: pair an over or
/// at-risk bar with a badge or words.
///
/// [pace] draws a thin marker where progress "should" be by now (budgets).
/// [onHero] draws the bar for a hero card: fill and marker in the hero's text
/// colour on a translucent track, ignoring [tone] (heroes stay neutral).
/// [semanticValue] replaces the announced percentage, e.g. "62% used, ₹2,400
/// left, ahead of pace by ₹300".
class FfProgressBar extends StatelessWidget {
  const FfProgressBar({
    super.key,
    required this.value,
    this.color,
    this.tone,
    this.size = FfProgressSize.md,
    this.pace,
    this.onHero = false,
    this.semanticLabel,
    this.semanticValue,
  });

  final double? value;
  final Color? color;
  final FfTone? tone;
  final FfProgressSize size;
  final double? pace;
  final bool onHero;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final height = switch (size) {
      FfProgressSize.sm => FfProgressTokens.heightSm,
      FfProgressSize.md => FfProgressTokens.heightMd,
      FfProgressSize.lg => FfProgressTokens.heightLg,
    };
    final v = value?.clamp(0.0, 1.0);
    final Color fill;
    final Color track;
    if (onHero) {
      // Inside FfHeroCard, textPrimary is the hero's own text colour.
      fill = c.textPrimary;
      track = c.tint(c.textPrimary, FfProgressTokens.heroTrack);
    } else {
      fill = color ?? tone?.foreground(c) ?? c.actionPrimary;
      track = c.surfaceContainerHighest;
    }
    final bar = ClipRRect(
      borderRadius: ffRadius(FfRadius.full),
      child: LinearProgressIndicator(
        value: v,
        minHeight: height,
        color: fill,
        backgroundColor: track,
        semanticsLabel: semanticLabel,
        semanticsValue:
            semanticValue ?? (v == null ? null : '${(v * 100).round()}%'),
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
