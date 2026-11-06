import 'package:flutter/material.dart';
import '../../theme/ff.dart';

class FfSegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const FfSegmentOption({required this.value, required this.label, this.icon});
}

/// A segmented pill for switching filters, modes or time ranges. The
/// selected segment is a solid ink pill on a sunken track.
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
      decoration: ShapeDecoration(
        color: context.ff.color.surfaceContainerLow,
        shape: FfShape.of(FfRadius.full),
      ),
      child: Row(
        children:
            options.map((option) {
              final isSelected = option.value == selectedValue;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(option.value),
                    child: AnimatedContainer(
                      duration: FfMotion.fast,
                      curve: FfMotion.emphasized,
                      constraints: const BoxConstraints(
                        minHeight: FfTouch.minTarget - 2 * FfSpace.x2s,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: FfSpace.xs,
                        horizontal: FfSpace.sm,
                      ),
                      decoration: ShapeDecoration(
                        color:
                            isSelected
                                ? context.ff.color.actionPrimary
                                : Colors.transparent,
                        shape: FfShape.of(FfRadius.full),
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
                                  size: FfIconSize.sm,
                                  color:
                                      isSelected
                                          ? context.ff.color.onActionPrimary
                                          : context.ff.color.textSecondary,
                                ),
                                const SizedBox(width: FfSpace.x2s),
                              ],
                              Text(
                                option.label,
                                style: context.ff.text.labelLg.copyWith(
                                  color:
                                      isSelected
                                          ? context.ff.color.onActionPrimary
                                          : context.ff.color.textSecondary,
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
                ),
              );
            }).toList(),
      ),
    );
  }
}
