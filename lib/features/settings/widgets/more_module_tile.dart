import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// A tactile squircle tile representing a financial module on the More launcher hub.
class MoreModuleTile extends StatelessWidget {
  final IconData icon;
  final FfTone tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeText;
  final FfTone? badgeTone;

  const MoreModuleTile({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
    this.badgeTone,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Semantics(
      button: true,
      label:
          badgeText != null
              ? '$title, $badgeText, $subtitle'
              : '$title, $subtitle',
      child: FfCard(
        density: FfDensity.compact,
        onTap: onTap,
        child: Row(
          children: [
            FfIconTile(icon: icon, tone: tone),
            const SizedBox(width: FfSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: FfSpace.xs),
                        FfBadge(
                          label: badgeText!,
                          tone: badgeTone ?? FfTone.warning,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    subtitle,
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FfSpace.xs),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: ff.color.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
