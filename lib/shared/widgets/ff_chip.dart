import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// A choice pill. Selected is a solid ink pill; unselected is outlined with
/// the control border (3:1). The tap area is always a full touch target.
class FfChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Widget? leading;
  final Widget? trailing;

  const FfChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final fg = isSelected ? c.onActionPrimary : c.textPrimary;
    final shape = FfShape.of(
      FfChipTokens.radius,
      side:
          isSelected
              ? BorderSide.none
              : BorderSide(
                color: c.borderControl,
                width: FfBorderWidth.regular,
              ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onSelected,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: FfTouch.minTarget),
            child: Center(
              widthFactor: 1,
              child: AnimatedContainer(
                duration: FfMotion.fast,
                curve: FfMotion.emphasized,
                height: FfChipTokens.height,
                padding: const EdgeInsets.symmetric(
                  horizontal: FfChipTokens.paddingH,
                ),
                decoration: ShapeDecoration(
                  color: isSelected ? c.actionPrimary : Colors.transparent,
                  shape: shape,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: fg, size: FfIconSize.sm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        _tinted(leading!, fg),
                        const SizedBox(width: FfChipTokens.gap),
                      ],
                      // Shrinks with an ellipsis instead of overflowing on
                      // narrow screens or at large text.
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.ff.text.labelLg.copyWith(color: fg),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: FfChipTokens.gap),
                        _tinted(trailing!, fg),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Icons always take the chip's foreground, so a caller's colour can never
  /// vanish into the ink fill when the chip is selected.
  static Widget _tinted(Widget w, Color fg) =>
      w is Icon
          ? Icon(
            w.icon,
            size: w.size ?? FfIconSize.sm,
            color: fg,
            semanticLabel: w.semanticLabel,
          )
          : w;
}
