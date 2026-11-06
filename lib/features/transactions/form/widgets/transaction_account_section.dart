import 'package:flutter/material.dart';

import '../../../../models/account.dart';
import '../../../../models/transaction.dart';
import '../../../../theme/ff.dart';
import '../../widgets/transaction_pickers.dart';

class TransactionAccountSection extends StatelessWidget {
  final TransactionType selectedType;
  final List<Account> accounts;
  final Account? selectedAccount;
  final Account? selectedToAccount;
  final String? accountError;
  final String? toAccountError;
  final VoidCallback onSwapAccounts;
  final VoidCallback onPickSourceAccount;
  final VoidCallback onPickDestinationAccount;

  const TransactionAccountSection({
    super.key,
    required this.selectedType,
    required this.accounts,
    this.selectedAccount,
    this.selectedToAccount,
    this.accountError,
    this.toAccountError,
    required this.onSwapAccounts,
    required this.onPickSourceAccount,
    required this.onPickDestinationAccount,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedType == TransactionType.transfer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Accounts', style: context.ff.text.labelLg),
              IconButton(
                tooltip: 'Swap accounts',
                icon: const Icon(Icons.swap_vert_rounded, size: 20),
                onPressed: onSwapAccounts,
              ),
            ],
          ),
          const SizedBox(height: FfSpace.x2s),
          Text('From Account', style: context.ff.text.labelSm),
          const SizedBox(height: FfSpace.x2s),
          AccountTileButton(
            label: 'From Account',
            account: selectedAccount,
            error: accountError,
            icon: Icons.upload_rounded,
            onTap: onPickSourceAccount,
          ),
          const SizedBox(height: FfSpace.sm),
          Text('To Account', style: context.ff.text.labelSm),
          const SizedBox(height: FfSpace.x2s),
          AccountTileButton(
            label: 'To Account',
            account: selectedToAccount,
            error: toAccountError,
            icon: Icons.download_rounded,
            onTap: onPickDestinationAccount,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: context.ff.text.labelLg),
        const SizedBox(height: FfSpace.x2s),
        AccountTileButton(
          label: 'Account',
          account: selectedAccount,
          error: accountError,
          icon: Icons.account_balance_wallet_outlined,
          onTap: onPickSourceAccount,
        ),
      ],
    );
  }
}
