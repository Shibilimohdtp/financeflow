import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_chip.dart';

/// Item model for [FfSuggestionChips].
class FfSuggestionChipItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final String? subtitle;

  const FfSuggestionChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
  });
}

/// A horizontal scrolling row of tactile suggestion chips in Stillwater Bloom.
class FfSuggestionChips<T> extends StatelessWidget {
  final List<FfSuggestionChipItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const FfSuggestionChips({
    super.key,
    required this.items,
    this.selectedValue,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: FfSpace.xs),
            FfChip(
              label: items[i].label,
              isSelected: selectedValue == items[i].value,
              leading:
                  items[i].icon != null ? Icon(items[i].icon, size: 16) : null,
              onSelected: () => onSelected(items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}
