import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/subscription.dart';
import '../../theme/ff.dart';
import 'ff_amount_text.dart';
import 'ff_entity_preview_card.dart';
import 'ff_monogram_tile.dart';
import 'ff_renewal_chip.dart';

/// Live preview at the top of the subscription sheet (sheet archetype B):
/// an [FfEntityPreviewCard] with the service monogram, the kind and account,
/// the renewal chip, and the amount per billing period.
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
        merchant.trim().isEmpty ? 'New subscription' : merchant.trim();
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

    return FfEntityPreviewCard(
      // A sand "renews" disc until a service name is typed.
      leading:
          merchant.trim().isEmpty
              ? FfEntityPreviewCard.disc(
                context,
                FfHeroTone.sand,
                Icons.autorenew_rounded,
              )
              : FfMonogramTile(
                name: merchant.trim(),
                size: FfHeroTokens.leadingSize,
                radius: FfRadius.full,
              ),
      title: displayName,
      subtitle: subline,
      status: FfRenewalChip(
        daysUntilRenewal: days,
        status: status,
        compact: true,
      ),
      figureCaption: 'Each time',
      figure: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          FfAmountText(amount: amount, size: FfAmountSize.lg, showSign: false),
          Text(
            '/${frequency.shortLabel}',
            style: ff.text.label.copyWith(color: ff.color.textSecondary),
          ),
        ],
      ),
      semanticLabel:
          'Preview: $displayName, $subline, '
          '${CurrencyFormatter.formatAmount(amount)} per ${frequency.shortLabel}',
    );
  }
}
