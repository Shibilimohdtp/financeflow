import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_badge.dart';
import 'ff_card.dart';

/// An interactive miniature notification bubble that dynamically renders how
/// FinanceFlow notifications appear on the Android lock screen when sensitive
/// details are hidden versus shown.
class FfNotificationPreviewBubble extends StatelessWidget {
  final bool hideSensitive;
  final String merchant;
  final String amount;
  final String account;

  const FfNotificationPreviewBubble({
    super.key,
    required this.hideSensitive,
    this.merchant = 'Swiggy',
    this.amount = '₹450',
    this.account = 'HDFC Card ending in 4102',
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    final title =
        hideSensitive
            ? '1 imported transaction is waiting for review'
            : '$merchant · $amount';

    final body =
        hideSensitive
            ? 'Sensitive financial details are hidden on lock screen'
            : '$account · Tap to review';

    return Semantics(
      label: 'Notification lock screen preview: $title, $body',
      child: FfCard(
        density: FfDensity.compact,
        variant: FfCardVariant.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header Row
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: ShapeDecoration(
                    color: ff.color.actionPrimary,
                    shape: FfShape.of(FfRadius.xs),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 10,
                      color: ff.color.onSurfaceInk,
                    ),
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                // Flexible so large text shortens the app name line instead
                // of overflowing the bubble.
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'FinanceFlow',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: FfSpace.x3s),
                      Flexible(
                        child: Text(
                          '· Just now',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                FfBadge(
                  label: hideSensitive ? 'Masked' : 'Unmasked',
                  tone: hideSensitive ? FfTone.success : FfTone.warning,
                  icon:
                      hideSensitive
                          ? Icons.lock_outline_rounded
                          : Icons.lock_open_rounded,
                ),
              ],
            ),
            const SizedBox(height: FfSpace.sm),
            // Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                title,
                key: ValueKey('notif-title-$hideSensitive'),
                style: ff.text.titleSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ff.color.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: FfSpace.x3s),
            // Body
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                body,
                key: ValueKey('notif-body-$hideSensitive'),
                style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
