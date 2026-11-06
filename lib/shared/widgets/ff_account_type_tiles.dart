import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/account.dart';
import '../../theme/ff.dart';
import 'ff_account_visuals.dart';

/// Compact grid of account type tiles (Bank, Cash, UPI, Credit Card, Investment, Business).
///
/// Designed to Stillwater Bloom standards:
/// - 48 dp minimum touch target
/// - Selection conveyed via solid ink fill + checkmark (never colour alone)
/// - Type-specific hero tone iconography
/// - Accessible screen-reader semantics and tactile feedback
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
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: FfSpace.sm),
              Expanded(
                child: _TypeTile(
                  type: _types[i].$1,
                  label: _types[i].$2,
                  isSelected: selectedType == _types[i].$1,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(_types[i].$1);
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: FfSpace.sm),
        Row(
          children: [
            for (var i = 3; i < 6; i++) ...[
              if (i > 3) const SizedBox(width: FfSpace.sm),
              Expanded(
                child: _TypeTile(
                  type: _types[i].$1,
                  label: _types[i].$2,
                  isSelected: selectedType == _types[i].$1,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(_types[i].$1);
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final AccountType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final icon = FfAccountVisuals.iconFor(type);

    final bg = isSelected ? c.actionPrimary : c.surfaceCard;
    final borderSide =
        isSelected
            ? BorderSide(color: c.actionPrimary, width: 1.5)
            : BorderSide(color: c.borderSubtle, width: 1);
    final fg = isSelected ? c.onActionPrimary : c.textPrimary;
    final iconColor = isSelected ? c.onActionPrimary : c.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${type.displayName}, ${isSelected ? 'selected' : 'not selected'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(FfRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.sm,
              vertical: FfSpace.sm,
            ),
            decoration: ShapeDecoration(
              color: bg,
              shape: FfShape.of(FfRadius.md, side: borderSide),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: ff.text.labelSm.copyWith(
                      color: fg,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_rounded, size: 14, color: c.onActionPrimary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
