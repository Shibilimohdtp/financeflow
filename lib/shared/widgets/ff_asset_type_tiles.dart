import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/investment.dart';
import '../../theme/ff.dart';

/// Compact visual selector for [AssetType] with 48 dp minimum touch targets.
///
/// Follows Stillwater Bloom standards:
/// - 48 dp minimum touch targets
/// - Selection conveyed via solid ink fill + checkmark + high contrast (never colour alone)
/// - Domain-specific iconography
/// - Accessible screen-reader semantics and tactile feedback
class FfAssetTypeTiles extends StatelessWidget {
  const FfAssetTypeTiles({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final AssetType selectedType;
  final ValueChanged<AssetType> onChanged;

  static const List<(AssetType, String, IconData)> types = [
    (AssetType.mutualFunds, 'Mutual Fund', Icons.pie_chart_outline_rounded),
    (AssetType.stocks, 'Stocks', Icons.candlestick_chart_outlined),
    (AssetType.fixedDeposits, 'Fixed Dep.', Icons.lock_clock_outlined),
    (AssetType.gold, 'Gold', Icons.monetization_on_outlined),
    (AssetType.ppf, 'PPF / NPS', Icons.savings_outlined),
    (AssetType.recurringDeposits, 'RD', Icons.timelapse_outlined),
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
    // 2 rows of horizontal scrolling or compact grid
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: FfSpace.xs),
        itemBuilder: (context, index) {
          final item = types[index];
          final isSelected =
              selectedType == item.$1 ||
              (item.$1 == AssetType.ppf && selectedType == AssetType.nps);

          return _AssetTile(
            type: item.$1,
            label: item.$2,
            icon: item.$3,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(item.$1);
            },
          );
        },
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final AssetType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;

    final bg = isSelected ? c.actionPrimary : c.surfaceCard;
    final borderSide =
        isSelected
            ? BorderSide.none
            : BorderSide(color: c.borderControl, width: FfBorderWidth.hairline);

    final fgColor = isSelected ? c.onActionPrimary : c.textPrimary;
    final iconColor = isSelected ? c.spark : c.actionPrimary;

    return Semantics(
      selected: isSelected,
      label: '$label asset type',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FfRadius.md),
          child: Container(
            width: 88,
            height: 96,
            constraints: const BoxConstraints(minHeight: FfTouch.minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.xs,
              vertical: FfSpace.sm,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(FfRadius.md),
              border:
                  borderSide == BorderSide.none
                      ? null
                      : Border.fromBorderSide(borderSide),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, size: 22, color: iconColor),
                    if (isSelected)
                      Positioned(
                        right: -10,
                        top: -6,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: c.spark,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 10, color: c.onSpark),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: FfSpace.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ff.text.labelSm.copyWith(
                    color: fgColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
