import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

class FfChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Widget? leading;
  final Widget? trailing;

  const FfChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final backgroundColor =
        isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerLow;

    final borderColor =
        isSelected ? theme.colorScheme.primary : theme.dividerColor;

    final textColor =
        isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
        child: AnimatedContainer(
          duration: StillwaterTokens.durationFast,
          height: StillwaterTokens.chipHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceMd,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
            border: Border.all(
              color: borderColor,
              width: StillwaterTokens.borderWidthDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: StillwaterTokens.spaceXs),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: StillwaterTokens.spaceXs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
