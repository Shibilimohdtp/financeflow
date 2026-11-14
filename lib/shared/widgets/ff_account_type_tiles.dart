import 'package:flutter/material.dart';

import '../../models/account.dart';
import 'ff_account_visuals.dart';
import 'ff_choice_tiles.dart';

/// The account type choice: an [FfChoiceTiles] grid of the six types, three
/// to a row, icon above the label (beside it, a 98 dp tile would break
/// "Business" inside the word). Selected is ink with a check.
class FfAccountTypeTiles extends StatelessWidget {
  const FfAccountTypeTiles({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final AccountType selectedType;
  final ValueChanged<AccountType> onChanged;

  static const List<(AccountType, String)> _types = [
    (AccountType.bank, 'Bank'),
    (AccountType.cash, 'Cash'),
    (AccountType.upi, 'UPI'),
    (AccountType.creditCard, 'Card'),
    (AccountType.investment, 'Invest'),
    (AccountType.business, 'Business'),
  ];

  @override
  Widget build(BuildContext context) {
    return FfChoiceTiles<AccountType>(
      selected: selectedType,
      onChanged: onChanged,
      options: [
        for (final (type, label) in _types)
          FfChoiceTile(
            value: type,
            icon: FfAccountVisuals.iconFor(type),
            label: label,
            semanticLabel: type.displayName,
          ),
      ],
    );
  }
}
