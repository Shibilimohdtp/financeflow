import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/account.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';

class AccountSummaryStrip extends StatelessWidget {
  final List<Account> accounts;
  final bool isPrivacyBlur;
  final VoidCallback onManageAccounts;
  final VoidCallback onAddAccount;

  const AccountSummaryStrip({
    super.key,
    required this.accounts,
    required this.isPrivacyBlur,
    required this.onManageAccounts,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

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
              Text('Accounts', style: theme.textTheme.titleMedium),
              TextButton(
                onPressed: onManageAccounts,
                child: const Text('Manage'),
              ),
            ],
          ),
        ),
        const SizedBox(height: StillwaterTokens.spaceXs),
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: accounts.length + 1,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(width: StillwaterTokens.spaceSm),
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return FfCard(
                  width: 140,
                  onTap: onAddAccount,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Text(
                        'Add Account',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final account = accounts[index];
              return FfCard(
                width: 180,
                padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getAccountIcon(account.type),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        Expanded(
                          child: Text(
                            account.name,
                            style: theme.textTheme.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      account.maskedIdentifier ?? account.type.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    FfAmountText(
                      amount: account.currentBalance,
                      size: FfAmountSize.sm,
                      isBlurred: isPrivacyBlur,
                      showSign: false,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
