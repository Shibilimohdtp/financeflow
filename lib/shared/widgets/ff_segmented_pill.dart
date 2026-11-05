import 'package:flutter/material.dart';
import '../../theme/ff.dart';

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
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(FfSpace.x2s),
      decoration: BoxDecoration(
        color: context.ff.color.surfaceCard,
        borderRadius: BorderRadius.circular(FfRadius.full),
        border: Border.all(
          color: context.ff.color.borderSubtle,
          width: FfBorderWidth.hairline,
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
                    duration: FfMotion.fast,
                    curve: FfMotion.emphasized,
                    padding: const EdgeInsets.symmetric(
                      vertical: FfSpace.xs,
                      horizontal: FfSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? context.ff.color.actionPrimaryContainer
                                  .withValues(alpha: 0.6)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(FfRadius.full),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option.icon != null) ...[
                              Icon(
                                option.icon,
                                size: 16,
                                color:
                                    isSelected
                                        ? context.ff.color.actionPrimary
                                        : context.ff.color.secondary,
                              ),
                              const SizedBox(width: FfSpace.x2s),
                            ],
                            Text(
                              option.label,
                              style: context.ff.text.labelSm.copyWith(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? context.ff.color.actionPrimary
                                        : context.ff.color.secondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
