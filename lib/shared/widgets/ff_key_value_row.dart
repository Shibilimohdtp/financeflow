import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A label on the left, a value on the right: "Interest rate · 8.5%".
/// Put several in an `FfGroupedContainer` for a details card.
class FfKeyValueRow extends StatelessWidget {
  const FfKeyValueRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
    this.valueTone,
    this.emphasize = false,
  }) : assert(value != null || valueWidget != null);

  final String label;
  final String? value;

  /// Replaces [value], for amounts (`FfAmountText`) or badges.
  final Widget? valueWidget;
  final IconData? icon;

  /// Colours the value (for example overdue in error).
  final FfTone? valueTone;

  /// Bolder value, for totals.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfKeyValueTokens.paddingH,
          vertical: FfKeyValueTokens.paddingV,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: FfKeyValueTokens.iconSize,
                color: c.textSecondary,
              ),
              const SizedBox(width: FfKeyValueTokens.iconGap),
            ],
            Expanded(
              child: Text(
                label,
                style: ff.text.body.copyWith(color: c.textSecondary),
              ),
            ),
            const SizedBox(width: FfSpace.sm),
            Flexible(
              child:
                  valueWidget ??
                  Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: (emphasize ? ff.text.title : ff.text.titleSm)
                        .copyWith(
                          color:
                              valueTone == null || valueTone == FfTone.neutral
                                  ? c.textPrimary
                                  : valueTone!.foreground(c),
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
