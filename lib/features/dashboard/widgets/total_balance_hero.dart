import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// The total balance, set large and light straight on the aurora. Hiding
/// amounts lives in the Home header; period cash flow belongs in its own card.
class TotalBalanceHero extends StatelessWidget {
  final double totalBalance;
  final int activeAccountsCount;
  final bool isPrivacyBlur;

  /// Shown as a call to action when there are no active accounts.
  final VoidCallback? onAddAccount;

  const TotalBalanceHero({
    super.key,
    required this.totalBalance,
    required this.activeAccountsCount,
    required this.isPrivacyBlur,
    this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final spoken =
        isPrivacyBlur
            ? 'Total balance hidden for privacy'
            : 'Total Balance: ${CurrencyFormatter.format(totalBalance)}';

    return Padding(
      key: const ValueKey('total-balance-card'),
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            key: const ValueKey('balance-amount'),
            liveRegion: true,
            label: spoken,
            excludeSemantics: true,
            child: FfAmountText(
              amount: totalBalance,
              size: FfAmountSize.hero,
              style: FfAmountStyle.split,
              tone:
                  !isPrivacyBlur && totalBalance < 0
                      ? FfTone.expense
                      : FfTone.neutral,
              showSign: totalBalance < 0,
              isBlurred: isPrivacyBlur,
            ),
          ),
          if (activeAccountsCount == 0 && onAddAccount != null)
            Padding(
              padding: const EdgeInsets.only(top: FfSpace.xs),
              child: TextButton.icon(
                key: const ValueKey('balance-add-account'),
                onPressed: onAddAccount,
                icon: const Icon(Icons.add_rounded, size: FfIconSize.md),
                label: const Text('Add your first account'),
              ),
            ),
        ],
      ),
    );
  }
}
