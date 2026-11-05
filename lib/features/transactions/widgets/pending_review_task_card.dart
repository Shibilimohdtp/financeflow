import 'package:flutter/material.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../theme/ff.dart';

/// An inline task card displayed on the Money/Transactions screen when
/// imported transactions require review before joining the official ledger.
class PendingReviewTaskCard extends StatelessWidget {
  final int count;
  final VoidCallback onReviewNow;
  final VoidCallback onLater;

  const PendingReviewTaskCard({
    super.key,
    required this.count,
    required this.onReviewNow,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final warningColor = context.ff.color.statusWarning;
    final warningBg = context.ff.color.statusWarningContainer;

    final titleText =
        count == 1
            ? '1 imported transaction needs review'
            : '$count imported transactions need review';

    return Semantics(
      container: true,
      label: '$titleText. Verify merchant and category.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.lg,
          FfSpace.xs,
          FfSpace.lg,
          FfSpace.xs,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: warningColor.withValues(alpha: FfTint.strong.alpha),
              width: FfBorderWidth.regular,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FfSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Icon badge + Tag + Snooze/Later button
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: warningBg.withValues(alpha: FfOpacity.muted),
                        borderRadius: BorderRadius.circular(FfRadius.sm),
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 16,
                        color: warningColor,
                      ),
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Text(
                      'NEEDS REVIEW · $count ${count == 1 ? 'ITEM' : 'ITEMS'}',
                      style: context.ff.text.labelSm.copyWith(
                        color: warningColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Remind me later',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: onLater,
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.sm),

                // Headline
                Text(
                  titleText,
                  style: context.ff.text.title.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.ff.color.textPrimary,
                  ),
                ),
                const SizedBox(height: FfSpace.x2s),

                // Explanation of why it matters
                Text(
                  'Verify merchant and category so your ledger balances and spending trends stay accurate.',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.textPrimary.withValues(
                      alpha: FfOpacity.muted,
                    ),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: FfSpace.md),

                // Actions: Review now (primary) + Later (text)
                Row(
                  children: [
                    FfButton(
                      label: 'Review now',
                      size: FfButtonSize.sm,
                      variant: FfButtonVariant.primary,
                      leadingIcon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                      ),
                      onPressed: onReviewNow,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    FfButton(
                      label: 'Later',
                      size: FfButtonSize.sm,
                      variant: FfButtonVariant.text,
                      onPressed: onLater,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
