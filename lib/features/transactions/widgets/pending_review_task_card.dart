import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../theme/stillwater_tokens.dart';

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

    final theme = context.theme;
    final warningColor = context.statusColors.warning;
    final warningBg = context.statusColors.warningContainer;

    final titleText =
        count == 1
            ? '1 imported transaction needs review'
            : '$count imported transactions need review';

    return Semantics(
      container: true,
      label: '$titleText. Verify merchant and category.',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceXs,
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceXs,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: warningColor.withValues(alpha: 0.4),
              width: StillwaterTokens.borderWidthDefault,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
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
                        color: warningBg.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 16,
                        color: warningColor,
                      ),
                    ),
                    const SizedBox(width: StillwaterTokens.spaceXs),
                    Text(
                      'NEEDS REVIEW · $count ${count == 1 ? 'ITEM' : 'ITEMS'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: warningColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        fontSize: 10,
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
                const SizedBox(height: StillwaterTokens.spaceSm),

                // Headline
                Text(
                  titleText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space2Xs),

                // Explanation of why it matters
                Text(
                  'Verify merchant and category so your ledger balances and spending trends stay accurate.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),

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
                    const SizedBox(width: StillwaterTokens.spaceXs),
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
