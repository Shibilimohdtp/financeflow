import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A labelled figure for summaries and heroes: "Spent this month · ₹48,210".
/// [value] is usually an `FfAmountText`; [caption] adds context below.
class FfStatTile extends StatelessWidget {
  const FfStatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.tone = FfTone.neutral,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final Widget value;
  final String? caption;
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
        value,
        if (caption != null) ...[
          const SizedBox(height: FfSpace.x3s),
          Text(caption!, style: ff.text.labelSm),
        ],
      ],
    );
  }
}
