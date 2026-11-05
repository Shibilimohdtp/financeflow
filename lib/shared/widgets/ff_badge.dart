import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A small status pill: "Active", "Overdue", "3 pending". Coloured by
/// [tone]; add an [icon] when the status must not rely on colour alone.
class FfBadge extends StatelessWidget {
  const FfBadge({
    super.key,
    required this.label,
    this.tone = FfTone.neutral,
    this.icon,
  });

  final String label;
  final FfTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final fg =
        tone == FfTone.neutral
            ? ff.color.textSecondary
            : tone.foreground(ff.color);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FfBadgeTokens.paddingH,
        vertical: FfBadgeTokens.paddingV,
      ),
      decoration: BoxDecoration(
        color: tone.container(ff.color),
        borderRadius: ffRadius(FfBadgeTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: FfBadgeTokens.iconSize, color: fg),
            const SizedBox(width: FfBadgeTokens.gap),
          ],
          Text(
            label,
            style: ff.text.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
