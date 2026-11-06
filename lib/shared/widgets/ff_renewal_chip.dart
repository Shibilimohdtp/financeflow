import 'package:flutter/material.dart';

import '../../models/subscription.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A status badge showing renewal urgency with both an icon and words.
///
/// Follows Stillwater Bloom rule: status is never conveyed by colour alone.
/// Shows distinct states for overdue, today, tomorrow, due soon (<=3d),
/// normal upcoming, paused, and cancelled.
class FfRenewalChip extends StatelessWidget {
  const FfRenewalChip({
    super.key,
    required this.daysUntilRenewal,
    this.status = SubscriptionStatus.active,
    this.compact = false,
    this.onTap,
  });

  /// Days remaining until renewal (0 = today, negative = overdue).
  final int daysUntilRenewal;

  /// Subscription status.
  final SubscriptionStatus status;

  /// When true, renders shorter labels (e.g. "in 3d" vs "in 3 days").
  final bool compact;

  /// Optional tap callback.
  final VoidCallback? onTap;

  ({IconData icon, String label, FfTone tone}) _resolve() {
    switch (status) {
      case SubscriptionStatus.paused:
        return (
          icon: Icons.pause_circle_outline_rounded,
          label: 'Paused',
          tone: FfTone.neutral,
        );
      case SubscriptionStatus.cancelled:
        return (
          icon: Icons.cancel_outlined,
          label: 'Cancelled',
          tone: FfTone.neutral,
        );
      case SubscriptionStatus.needsReview:
        return (
          icon: Icons.help_outline_rounded,
          label: 'Needs review',
          tone: FfTone.accent,
        );
      case SubscriptionStatus.active:
        if (daysUntilRenewal < 0) {
          final count = daysUntilRenewal.abs();
          return (
            icon: Icons.warning_amber_rounded,
            label:
                compact
                    ? 'Overdue ${count}d'
                    : (count == 1
                        ? 'Overdue by 1 day'
                        : 'Overdue by $count days'),
            tone: FfTone.expense,
          );
        } else if (daysUntilRenewal == 0) {
          return (
            icon: Icons.alarm_rounded,
            label: compact ? 'Today' : 'Renews today',
            tone: FfTone.warning,
          );
        } else if (daysUntilRenewal == 1) {
          return (
            icon: Icons.schedule_rounded,
            label: compact ? 'Tomorrow' : 'Renews tomorrow',
            tone: FfTone.warning,
          );
        } else if (daysUntilRenewal <= 3) {
          return (
            icon: Icons.schedule_rounded,
            label:
                compact
                    ? 'in ${daysUntilRenewal}d'
                    : 'in $daysUntilRenewal days',
            tone: FfTone.warning,
          );
        } else {
          return (
            icon: Icons.repeat_rounded,
            label:
                compact
                    ? 'in ${daysUntilRenewal}d'
                    : 'in $daysUntilRenewal days',
            tone: FfTone.neutral,
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final resolved = _resolve();

    final bg = resolved.tone.container(ff.color);
    final fg = resolved.tone.foreground(ff.color);

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.xs,
        vertical: FfSpace.x3s,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FfRadius.full),
        border: Border.all(
          color: resolved.tone == FfTone.neutral ? ff.color.borderSubtle : bg,
          width: FfBorderWidth.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, size: 13, color: fg),
          const SizedBox(width: FfSpace.x2s),
          Text(
            resolved.label,
            style: ff.text.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        label: resolved.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(FfRadius.full),
          onTap: onTap,
          child: chip,
        ),
      );
    }

    return Semantics(label: resolved.label, child: chip);
  }
}
