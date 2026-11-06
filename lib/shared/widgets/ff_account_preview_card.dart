import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_account_visuals.dart';
import 'ff_amount_text.dart';
import 'ff_surfaces.dart';

/// Miniature live preview card of an account, matching the Stillwater Bloom
/// squircle hero styling seen on Home and Accounts.
///
/// Updates in real time as the user types account details. Uses static gradients
/// (no blur, no animated grain) keeping bottom-sheet rendering fast and lightweight.
class FfAccountPreviewCard extends StatelessWidget {
  const FfAccountPreviewCard({
    super.key,
    required this.accountType,
    this.name,
    this.institutionName,
    this.maskedIdentifier,
    this.balance = 0.0,
    this.balanceLabel,
    this.isPrivacyBlur = false,
  });

  final AccountType accountType;
  final String? name;
  final String? institutionName;
  final String? maskedIdentifier;
  final double balance;
  final String? balanceLabel;
  final bool isPrivacyBlur;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final tone = FfAccountVisuals.toneFor(accountType);
    final hero = ff.hero(tone);
    final brightness = Theme.of(context).brightness;

    final displayName =
        (name != null && name!.trim().isNotEmpty)
            ? name!.trim()
            : 'Your account name';

    final categoryLabel =
        (institutionName != null && institutionName!.trim().isNotEmpty)
            ? institutionName!.trim()
            : accountType.displayName;

    final effectiveBalanceLabel =
        balanceLabel ??
        (accountType == AccountType.creditCard ? 'Balance' : 'Available');

    return Semantics(
      container: true,
      label:
          'Account preview: $displayName, $categoryLabel, $effectiveBalanceLabel ${balance.toStringAsFixed(2)} rupees',
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          shape: FfShape.of(FfRadius.lg),
          gradient: hero.gradient,
          shadows: FfElevation.card(ff.color.shadow, brightness),
        ),
        clipBehavior: Clip.antiAlias,
        child: FfHeroColorScope(
          hero: hero,
          child: Padding(
            padding: const EdgeInsets.all(FfSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Type icon + Institution / Type name + Masked badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: hero.onHero.withValues(alpha: 0.14),
                        shape: FfShape.of(FfRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        FfAccountVisuals.iconFor(accountType),
                        size: 18,
                        color: hero.onHero,
                      ),
                    ),
                    const SizedBox(width: FfSpace.sm),
                    Expanded(
                      child: Text(
                        categoryLabel,
                        style: ff.text.label.copyWith(
                          color: hero.onHeroSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (maskedIdentifier != null &&
                        maskedIdentifier!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.sm,
                          vertical: 3,
                        ),
                        decoration: ShapeDecoration(
                          color: hero.onHero.withValues(alpha: 0.12),
                          shape: FfShape.of(FfRadius.full),
                        ),
                        child: Text(
                          maskedIdentifier!.trim().length <= 4 &&
                                  int.tryParse(maskedIdentifier!.trim()) != null
                              ? '•••• ${maskedIdentifier!.trim()}'
                              : maskedIdentifier!.trim(),
                          style: ff.text.labelSm.copyWith(
                            color: hero.onHero,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: FfSpace.md),

                // Middle: Account Name
                Text(
                  displayName,
                  style: ff.text.titleLg.copyWith(
                    color:
                        (name != null && name!.trim().isNotEmpty)
                            ? hero.onHero
                            : hero.onHeroSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: FfSpace.sm),

                // Bottom: Amount Label + Split Geist Numeral
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveBalanceLabel,
                            style: ff.text.label.copyWith(
                              color: hero.onHeroSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FfAmountText(
                            amount: balance,
                            size: FfAmountSize.lg,
                            style: FfAmountStyle.split,
                            tone: FfTone.neutral,
                            showSign: balance < 0,
                            isBlurred: isPrivacyBlur,
                          ),
                        ],
                      ),
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
