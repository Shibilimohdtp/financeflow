import 'package:flutter/material.dart';

import '../../../models/account.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_navigation.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Home's accounts as a carousel of hero cards, the next one peeking in.
/// The ring around each icon is that account's share of the money you hold.
class HomeAccountsCarousel extends StatelessWidget {
  const HomeAccountsCarousel({
    super.key,
    required this.accounts,
    required this.isPrivacyBlur,
    required this.onOpenAccounts,
  });

  final List<Account> accounts;
  final bool isPrivacyBlur;
  final VoidCallback onOpenAccounts;

  static const double height = 196;

  /// Hero tone by what the account holds, never by bank or brand.
  static FfHeroTone toneFor(AccountType type) => switch (type) {
    AccountType.bank ||
    AccountType.upi ||
    AccountType.business => FfHeroTone.moss,
    AccountType.creditCard || AccountType.investment => FfHeroTone.dusk,
    AccountType.cash => FfHeroTone.sand,
  };

  static IconData iconFor(AccountType type) => switch (type) {
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.upi => Icons.qr_code_2_rounded,
    AccountType.business => Icons.storefront_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    AccountType.cash => Icons.account_balance_wallet_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final active = accounts.where((a) => !a.isArchived).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    final held = active.fold<double>(
      0,
      (sum, a) => sum + (a.currentBalance > 0 ? a.currentBalance : 0),
    );
    return FfCarousel(
      height: height,
      viewportFraction:
          active.length == 1 ? 1 : FfCarouselTokens.viewportFraction,
      children: [
        for (final a in active)
          _AccountHero(
            account: a,
            share:
                held <= 0 || a.currentBalance <= 0
                    ? 0
                    : a.currentBalance / held,
            isPrivacyBlur: isPrivacyBlur,
            onOpen: onOpenAccounts,
          ),
      ],
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({
    required this.account,
    required this.share,
    required this.isPrivacyBlur,
    required this.onOpen,
  });

  final Account account;
  final double share;
  final bool isPrivacyBlur;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final percent = (share * 100).round();
    return FfHeroCard(
      tone: HomeAccountsCarousel.toneFor(account.type),
      height: HomeAccountsCarousel.height,
      leading: FfProgressRing(
        value: share,
        icon: HomeAccountsCarousel.iconFor(account.type),
        semanticsLabel: '$percent% of the money you hold',
      ),
      title: account.name,
      subtitle: account.institutionName ?? account.type.displayName,
      onOpen: onOpen,
      openTooltip: 'Open accounts',
      child: Builder(
        builder: (context) {
          final ff = context.ff;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                account.type == AccountType.creditCard
                    ? 'Balance'
                    : 'Available',
                style: ff.text.label,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FfAmountText(
                      amount: account.currentBalance,
                      size: FfAmountSize.lg,
                      tone: FfTone.neutral,
                      showSign: account.currentBalance < 0,
                      isBlurred: isPrivacyBlur,
                    ),
                  ),
                  if (!isPrivacyBlur && share > 0) ...[
                    const SizedBox(width: FfSpace.sm),
                    ExcludeSemantics(
                      child: Text('$percent%', style: ff.text.label),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
