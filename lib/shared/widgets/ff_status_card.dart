import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_badge.dart';
import 'ff_button.dart';
import 'ff_card.dart';
import 'ff_icon_tile.dart';

/// A domain status card with a leading icon tile, title, status badge,
/// explanatory subtitle, optional metadata detail line, and primary action.
class FfStatusCard extends StatelessWidget {
  final IconData icon;
  final FfTone tone;
  final String title;
  final String statusLabel;
  final FfTone statusTone;
  final IconData? statusIcon;
  final String subtitle;
  final String? detail;
  final String? actionLabel;
  final VoidCallback? onAction;
  final FfButtonVariant actionVariant;
  final VoidCallback? onTap;

  const FfStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.statusLabel,
    required this.statusTone,
    required this.subtitle,
    this.statusIcon,
    this.detail,
    this.actionLabel,
    this.onAction,
    this.actionVariant = FfButtonVariant.secondary,
    this.tone = FfTone.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Semantics(
      button: onTap != null,
      label: '$title, Status: $statusLabel. $subtitle',
      child: FfCard(
        density: FfDensity.compact,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FfIconTile(icon: icon, tone: tone),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: ff.text.titleSm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FfBadge(
                            label: statusLabel,
                            tone: statusTone,
                            icon: statusIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        subtitle,
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (detail != null) ...[
              const SizedBox(height: FfSpace.sm),
              Padding(
                padding: const EdgeInsets.only(left: 48), // Past icon tile
                child: Text(
                  detail!,
                  style: ff.text.labelSm.copyWith(color: ff.color.textTertiary),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: FfSpace.sm),
              Align(
                alignment: Alignment.centerRight,
                child: FfButton(
                  label: actionLabel!,
                  variant: actionVariant,
                  size: FfButtonSize.sm,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
