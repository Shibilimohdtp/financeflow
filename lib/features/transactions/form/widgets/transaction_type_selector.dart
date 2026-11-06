import 'package:flutter/material.dart';

import '../../../../models/account.dart';
import '../../../../models/category.dart';
import '../../../../models/transaction.dart';
import '../../../../shared/widgets/ff_segmented_pill.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final TransactionPurpose selectedPurpose;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Transaction> history;
  final void Function(
    TransactionPurpose purpose,
    List<Category> categories,
    List<Account> accounts,
    List<Transaction> history,
  )
  onPurposeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.selectedPurpose,
    required this.categories,
    required this.accounts,
    required this.history,
    required this.onPurposeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Transaction type',
      child: FfSegmentedPill<TransactionType>(
        options: const [
          FfSegmentOption(
            value: TransactionType.expense,
            label: 'Expense',
            icon: Icons.arrow_outward_rounded,
          ),
          FfSegmentOption(
            value: TransactionType.income,
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
          ),
          FfSegmentOption(
            value: TransactionType.transfer,
            label: 'Transfer',
            icon: Icons.swap_horiz_rounded,
          ),
        ],
        selectedValue: selectedType,
        onSelected: (type) {
          final purpose = switch (type) {
            TransactionType.income => TransactionPurpose.income,
            TransactionType.transfer => TransactionPurpose.internalTransfer,
            _ => TransactionPurpose.expense,
          };
          onPurposeChanged(purpose, categories, accounts, history);
        },
      ),
    );
  }
}
