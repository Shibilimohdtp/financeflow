import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_round_buttons.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// The total balance, set large and light straight on the aurora, with the
/// account count (opens Accounts) and the hide-amounts toggle. Period cash
/// flow belongs in its own card.
class TotalBalanceHero extends StatelessWidget {
  final double totalBalance;
  final int activeAccountsCount;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;
  final VoidCallback? onManageAccounts;

  /// Shown as a call to action when there are no active accounts.
  final VoidCallback? onAddAccount;

  const TotalBalanceHero({
    super.key,
    required this.totalBalance,
    required this.activeAccountsCount,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.onManageAccounts,
    this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final accountLabel =
        activeAccountsCount == 1
            ? '1 account'
            : '$activeAccountsCount accounts';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Balance',
                  style: ff.text.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onManageAccounts == null)
                Flexible(child: Text(accountLabel, style: ff.text.label))
              else
                Flexible(
                  child: TextButton(
                    key: const ValueKey('balance-accounts'),
                    onPressed: onManageAccounts,
                    style: TextButton.styleFrom(
                      foregroundColor: ff.color.textSecondary,
                      minimumSize: const Size(
                        FfTouch.minTarget,
                        FfTouch.minTarget,
                      ),
                      padding: const EdgeInsetsDirectional.only(
                        start: FfSpace.sm,
                      ),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            accountLabel,
                            style: ff.text.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: FfIconSize.sm,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Semantics(
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
              ),
              const SizedBox(width: FfSpace.xs),
              FfCircleButton(
                key: const ValueKey('balance-privacy'),
                icon:
                    isPrivacyBlur
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                tooltip: isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                soft: true,
                onPressed: onToggleBlur,
              ),
            ],
          ),
          if (activeAccountsCount == 0 && onAddAccount != null)
            TextButton.icon(
              key: const ValueKey('balance-add-account'),
              onPressed: onAddAccount,
              icon: const Icon(Icons.add_rounded, size: FfIconSize.md),
              label: const Text('Add your first account'),
            ),
        ],
      ),
    );
  }
}
