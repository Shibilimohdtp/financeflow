import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/account.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';

class AccountSummaryStrip extends StatelessWidget {
  final List<Account> accounts;
  final bool isPrivacyBlur;
  final VoidCallback onManageAccounts;
  final VoidCallback onAddAccount;
  final ValueChanged<Account>? onAccountTap;

  const AccountSummaryStrip({
    super.key,
    required this.accounts,
    required this.isPrivacyBlur,
    required this.onManageAccounts,
    required this.onAddAccount,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final activeAccounts = accounts.where((a) => !a.isArchived).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceLg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Accounts & Wallets',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onManageAccounts,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
        ),
        const SizedBox(height: StillwaterTokens.spaceXs),
        if (activeAccounts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
            ),
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              child: InkWell(
                onTap: onAddAccount,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusLg,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add your first account',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.space3Xs),
                            Text(
                              'Track bank balances, cards, cash & UPI',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.secondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: activeAccounts.length + 1,
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(width: StillwaterTokens.spaceSm),
              itemBuilder: (context, index) {
                if (index == activeAccounts.length) {
                  return _buildAddAccountCard(context, theme);
                }

                final account = activeAccounts[index];
                return _buildAccountCard(context, theme, account);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    ThemeData theme,
    Account account,
  ) {
    return Semantics(
      container: true,
      label:
          isPrivacyBlur
              ? '${account.name} balance hidden'
              : '${account.name}, balance ${account.currentBalance}',
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          onTap:
              onAccountTap != null
                  ? () => onAccountTap!(account)
                  : onManageAccounts,
          child: Container(
            width: 176,
            padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(StillwaterTokens.space3Xs),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusXs,
                        ),
                      ),
                      child: Icon(
                        _getAccountIcon(account.type),
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: StillwaterTokens.spaceXs),
                    Expanded(
                      child: Text(
                        account.name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  account.maskedIdentifier ?? account.type.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FfAmountText(
                  amount: account.currentBalance,
                  size: FfAmountSize.sm,
                  isBlurred: isPrivacyBlur,
                  showSign: false,
                  colorOverride: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountCard(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
      child: InkWell(
        onTap: onAddAccount,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(StillwaterTokens.space3Xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceXs),
              Text(
                'Add Account',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_rounded;
      case AccountType.cash:
        return Icons.wallet_rounded;
      case AccountType.creditCard:
        return Icons.credit_card_rounded;
      case AccountType.upi:
        return Icons.phone_android_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.business:
        return Icons.store_rounded;
    }
  }
}
