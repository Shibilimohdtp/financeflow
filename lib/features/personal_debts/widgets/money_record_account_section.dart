import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_consequence_line.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Account link selector with dynamic consequence line (Pattern E).
class MoneyRecordAccountSection extends StatelessWidget {
  const MoneyRecordAccountSection({
    super.key,
    required this.recordInTransactions,
    required this.onRecordInTransactionsChanged,
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountSelected,
    required this.type,
    required this.amount,
  });

  final bool recordInTransactions;
  final ValueChanged<bool> onRecordInTransactionsChanged;
  final List<Account> accounts;
  final String? selectedAccountId;
  final ValueChanged<String> onAccountSelected;
  final MoneyRecordType type;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isLent = type == MoneyRecordType.lent;

    final selectedAccount =
        accounts.where((a) => a.id == selectedAccountId).firstOrNull ??
        accounts.firstOrNull;

    final accountName = selectedAccount?.name ?? 'Selected account';
    final formattedAmt = CurrencyFormatter.format(amount > 0 ? amount : 0.0);

    final consequenceText =
        isLent
            ? 'Takes $formattedAmt from $accountName now (cash outflow)'
            : 'Adds $formattedAmt to $accountName now (cash inflow)';

    final consequenceTone = isLent ? FfTone.expense : FfTone.income;
    final consequenceIcon =
        isLent ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FfRow.toggle(
          title: 'Record in my accounts',
          subtitle:
              isLent
                  ? 'Posts a transaction and decreases your account balance'
                  : 'Posts a transaction and increases your account balance',
          value: recordInTransactions,
          onChanged: accounts.isEmpty ? null : onRecordInTransactionsChanged,
        ),
        if (recordInTransactions && accounts.isNotEmpty) ...[
          const SizedBox(height: FfSpace.sm),
          Text(
            'Account to use',
            style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: FfSpace.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final acc in accounts) ...[
                  FfChip(
                    label: acc.name,
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                    ),
                    isSelected:
                        acc.id == (selectedAccountId ?? accounts.first.id),
                    onSelected: () => onAccountSelected(acc.id),
                  ),
                  const SizedBox(width: FfSpace.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: FfSpace.md),
          FfConsequenceLine(
            text: consequenceText,
            tone: consequenceTone,
            icon: consequenceIcon,
          ),
        ],
      ],
    );
  }
}
