import 'package:flutter/material.dart';

import '../../models/investment.dart';
import 'ff_choice_tiles.dart';

/// The asset class choice for an investment: an [FfChoiceTiles] grid, three
/// to a row, so every class is visible at once and no label is cut off.
/// Selected is ink with a check.
class FfAssetTypeTiles extends StatelessWidget {
  const FfAssetTypeTiles({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final AssetType selectedType;
  final ValueChanged<AssetType> onChanged;

  static const List<(AssetType, String, IconData)> types = [
    (AssetType.mutualFunds, 'Mutual fund', Icons.pie_chart_outline_rounded),
    (AssetType.stocks, 'Stocks', Icons.candlestick_chart_outlined),
    (AssetType.fixedDeposits, 'Fixed deposit', Icons.lock_clock_outlined),
    (AssetType.gold, 'Gold', Icons.monetization_on_outlined),
    (AssetType.ppf, 'PPF / NPS', Icons.savings_outlined),
    (
      AssetType.recurringDeposits,
      'Recurring deposit',
      Icons.timelapse_outlined,
    ),
    (AssetType.crypto, 'Crypto', Icons.currency_bitcoin_rounded),
    (AssetType.realEstate, 'Property', Icons.home_work_outlined),
    (AssetType.other, 'Other', Icons.show_chart_rounded),
  ];

  static IconData iconFor(AssetType type) {
    switch (type) {
      case AssetType.stocks:
        return Icons.candlestick_chart_outlined;
      case AssetType.mutualFunds:
        return Icons.pie_chart_outline_rounded;
      case AssetType.fixedDeposits:
        return Icons.lock_clock_outlined;
      case AssetType.recurringDeposits:
        return Icons.timelapse_outlined;
      case AssetType.ppf:
      case AssetType.nps:
        return Icons.savings_outlined;
      case AssetType.gold:
        return Icons.monetization_on_outlined;
      case AssetType.crypto:
        return Icons.currency_bitcoin_rounded;
      case AssetType.realEstate:
        return Icons.home_work_outlined;
      case AssetType.other:
        return Icons.show_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // NPS shares the PPF / NPS tile.
    final selected =
        selectedType == AssetType.nps ? AssetType.ppf : selectedType;
    return FfChoiceTiles<AssetType>(
      selected: selected,
      onChanged: onChanged,
      options: [
        for (final (type, label, icon) in types)
          FfChoiceTile(value: type, icon: icon, label: label),
      ],
    );
  }
}
