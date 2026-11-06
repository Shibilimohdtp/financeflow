import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_badge.dart';
import 'ff_card.dart';
import 'ff_data_viz.dart';

/// A status card displaying the user's on-device security posture as an
/// [FfProgressRing] with counts and actionable items.
class FfProtectionRingCard extends StatelessWidget {
  final int activeProtections;
  final int totalProtections;
  final VoidCallback? onTap;

  const FfProtectionRingCard({
    super.key,
    required this.activeProtections,
    this.totalProtections = 5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final progress =
        totalProtections > 0
            ? (activeProtections / totalProtections).clamp(0.0, 1.0)
            : 0.0;

    final isAllActive = activeProtections >= totalProtections;
    final isPartiallyActive = activeProtections >= 3;

    final ringColor =
        isAllActive
            ? ff.color.moneyIncome
            : isPartiallyActive
            ? ff.color.actionPrimary
            : ff.color.statusWarning;

    final statusLabel =
        isAllActive
            ? 'Fully protected'
            : isPartiallyActive
            ? 'Strong'
            : 'Needs attention';

    final statusTone =
        isAllActive
            ? FfTone.income
            : isPartiallyActive
            ? FfTone.primary
            : FfTone.warning;

    return Semantics(
      button: onTap != null,
      label:
          '$activeProtections of $totalProtections security protections active. Status: $statusLabel.',
      child: FfCard(
        density: FfDensity.compact,
        onTap: onTap,
        child: Row(
          children: [
            // Progress ring with shield icon
            FfProgressRing(
              value: progress,
              icon:
                  isAllActive
                      ? Icons.verified_user_rounded
                      : Icons.shield_outlined,
              size: 52,
              color: ringColor,
              semanticsLabel:
                  '$activeProtections of $totalProtections protections active',
            ),
            const SizedBox(width: FfSpace.md),
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$activeProtections of $totalProtections active',
                          style: ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FfBadge(
                        label: statusLabel,
                        tone: statusTone,
                        icon:
                            isAllActive
                                ? Icons.check_circle_rounded
                                : isPartiallyActive
                                ? Icons.shield_rounded
                                : Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    isAllActive
                        ? 'Hardware keystore, PIN & screen guards on'
                        : 'Tap to review and strengthen security',
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: FfSpace.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ff.color.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
