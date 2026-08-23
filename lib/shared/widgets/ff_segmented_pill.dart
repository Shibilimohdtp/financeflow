import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

class FfSegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const FfSegmentOption({required this.value, required this.label, this.icon});
}

/// A standard Stillwater segmented pill tab bar for switching filters, modes, or time-ranges.
class FfSegmentedPill<T> extends StatelessWidget {
  final List<FfSegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry margin;

  const FfSegmentedPill({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        children:
            options.map((option) {
              final isSelected = option.value == selectedValue;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(option.value),
                  child: AnimatedContainer(
                    duration: StillwaterTokens.durationFast,
                    curve: StillwaterTokens.easeEmphasized,
                    padding: const EdgeInsets.symmetric(
                      vertical: StillwaterTokens.spaceXs,
                      horizontal: StillwaterTokens.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.6,
                              )
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusFull,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option.icon != null) ...[
                            Icon(
                              option.icon,
                              size: 16,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: StillwaterTokens.space2Xs),
                          ],
                          Text(
                            option.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
