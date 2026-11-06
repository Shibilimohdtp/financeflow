import 'package:flutter/material.dart';

import '../../models/subscription.dart';
import '../../theme/ff.dart';
import 'ff_amount_text.dart';
import 'ff_card.dart';
import 'ff_monogram_tile.dart';
import 'ff_renewal_chip.dart';

/// Live preview card for [AddEditSubscriptionSheet] showing how the subscription
/// will render in the list, updating in real time as the user types.
class FfSubscriptionPreviewCard extends StatelessWidget {
  const FfSubscriptionPreviewCard({
    super.key,
    required this.merchant,
    required this.amount,
    required this.frequency,
    this.category = 'Subscriptions',
    this.accountName,
    required this.nextRenewalDate,
    this.status = SubscriptionStatus.active,
  });

  final String merchant;
  final double amount;
  final SubscriptionFrequency frequency;
  final String category;
  final String? accountName;
  final DateTime nextRenewalDate;
  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final displayName =
        merchant.trim().isEmpty ? 'New Subscription' : merchant.trim();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      nextRenewalDate.year,
      nextRenewalDate.month,
      nextRenewalDate.day,
    );
    final days = target.difference(today).inDays;

    final subline =
        accountName != null && accountName!.isNotEmpty
            ? '$category · $accountName'
            : category;

    return Semantics(
      label: 'Live preview of subscription card for $displayName',
      child: FfCard(
        density: FfDensity.compact,
        variant: FfCardVariant.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.md,
          vertical: FfSpace.sm,
        ),
        child: Row(
          children: [
            FfMonogramTile(name: displayName, size: FfRowTokens.iconTile),
            const SizedBox(width: FfSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: ff.text.titleSm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    subline,
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: FfSpace.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FfAmountText(
                      amount: amount,
                      size: FfAmountSize.sm,
                      showSign: false,
                    ),
                    Text(
                      '/${frequency.shortLabel}',
                      style: ff.text.labelSm.copyWith(
                        color: ff.color.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.x3s),
                FfRenewalChip(
                  daysUntilRenewal: days,
                  status: status,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
