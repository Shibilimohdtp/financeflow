import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A labelled figure for summaries and heroes: "Spent this month · ₹48,210".
/// [value] is usually an `FfAmountText`; [unit] sets a small, quiet suffix
/// after it ("/120", "%", "EMIs"); [caption] adds context below.
class FfStatTile extends StatelessWidget {
  const FfStatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.unit,
    this.icon,
    this.tone = FfTone.neutral,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final Widget value;
  final String? caption;
  final String? unit;
  final IconData? icon;

  /// Colours the label's icon.
  final FfTone tone;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: FfIconSize.sm,
                color:
                    tone == FfTone.neutral
                        ? c.textSecondary
                        : tone.foreground(c),
              ),
              const SizedBox(width: FfSpace.x2s),
            ],
            Flexible(
              child: Text(
                label,
                style: ff.text.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: FfSpace.x2s),
        if (unit == null)
          value
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: value),
              const SizedBox(width: FfSpace.x3s),
              Text(
                unit!,
                style: ff.text.bodySm.copyWith(color: c.textTertiary),
              ),
            ],
          ),
        if (caption != null) ...[
          const SizedBox(height: FfSpace.x3s),
          Text(caption!, style: ff.text.labelSm),
        ],
      ],
    );
  }
}

/// One small figure in an [FfHeroFigures] row.
class FfHeroFigure {
  const FfHeroFigure(this.label, this.value, {this.semanticsValue});

  /// Quiet label above, "Paid".
  final String label;

  /// Already formatted, "₹6,51,200" or "18.3%".
  final String value;

  /// What screen readers hear instead of [value] (for example when amounts
  /// are hidden).
  final String? semanticsValue;
}

/// The row of two or three small figures at the bottom of a hero card
/// ("Paid · Complete · Total payable", "Per day · Forecast · Days left").
/// The first figure starts the row, the last ends it, any middle ones are
/// centred; values use tabular `labelLg` and shrink rather than overflow at
/// large text. Each figure is read as one phrase, "Paid, ₹6,51,200".
class FfHeroFigures extends StatelessWidget {
  const FfHeroFigures(this.figures, {super.key});

  final List<FfHeroFigure> figures;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final n = figures.length;
    if (n == 0) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(width: FfSpace.xs),
          Expanded(
            child: () {
              final f = figures[i];
              final (cross, align, text) =
                  n == 1 || i == 0
                      ? (
                        CrossAxisAlignment.start,
                        AlignmentDirectional.centerStart,
                        TextAlign.start,
                      )
                      : i == n - 1
                      ? (
                        CrossAxisAlignment.end,
                        AlignmentDirectional.centerEnd,
                        TextAlign.end,
                      )
                      : (
                        CrossAxisAlignment.center,
                        AlignmentDirectional.center,
                        TextAlign.center,
                      );
              return Semantics(
                container: true,
                label: '${f.label}, ${f.semanticsValue ?? f.value}',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: cross,
                  children: [
                    Text(
                      f.label,
                      style: ff.text.label,
                      textAlign: text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: align,
                      child: Text(
                        f.value,
                        maxLines: 1,
                        style: ff.text.labelLg.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }(),
          ),
        ],
      ],
    );
  }
}
