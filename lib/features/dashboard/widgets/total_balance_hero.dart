import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/stillwater_typography.dart';

/// A compact account-balance summary. Period cash flow belongs in its own card.
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
    final theme = context.theme;
    final accountLabel =
        activeAccountsCount == 1
            ? '1 account'
            : '$activeAccountsCount accounts';
    final amount =
        isPrivacyBlur ? '${CurrencyFormatter.currencySymbol} ••••••' : CurrencyFormatter.format(totalBalance);

    return Container(
      key: const ValueKey('total-balance-card'),
      margin: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              Flexible(
                child:
                    onManageAccounts == null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            accountLabel,
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                        : TextButton(
                          key: const ValueKey('balance-accounts'),
                          onPressed: onManageAccounts,
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.only(left: 8),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  accountLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded, size: 16),
                            ],
                          ),
                        ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  key: const ValueKey('balance-amount'),
                  liveRegion: true,
                  label:
                      isPrivacyBlur
                          ? 'Total balance hidden for privacy'
                          : 'Total Balance: $amount',
                  excludeSemantics: true,
                  // Fit unusually large balances without abbreviating or truncating
                  // the amount. Assistive technology always receives the full value.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      amount,
                      style: StillwaterTypography.numHero(
                        color:
                            !isPrivacyBlur && totalBalance < 0
                                ? context.finColors.expense
                                : theme.colorScheme.onSurface,
                      ).copyWith(
                        fontSize: 34,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              IconButton(
                key: const ValueKey('balance-privacy'),
                tooltip: isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                onPressed: onToggleBlur,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                icon: Icon(
                  isPrivacyBlur
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (activeAccountsCount == 0 && onAddAccount != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('balance-add-account'),
                onPressed: onAddAccount,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add your first account'),
              ),
            ),
        ],
      ),
    );
  }
}
