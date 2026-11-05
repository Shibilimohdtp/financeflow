import 'package:flutter/material.dart';
import '../../theme/ff.dart';

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
    final backgroundColor =
        isSelected
            ? context.ff.color.actionPrimaryContainer
            : context.ff.color.surfaceContainerLow;

    final borderColor =
        isSelected
            ? context.ff.color.actionPrimary
            : context.ff.color.borderSubtle;

    final textColor =
        isSelected
            ? context.ff.color.onActionPrimaryContainer
            : context.ff.text.body.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(FfRadius.full),
        child: Container(
          height: FfChipTokens.height,
          padding: const EdgeInsets.symmetric(horizontal: FfSpace.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(FfRadius.full),
            border: Border.all(
              color: borderColor,
              width: FfBorderWidth.regular,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: FfSpace.xs),
              ],
              Text(
                label,
                style: context.ff.text.label.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: FfSpace.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
