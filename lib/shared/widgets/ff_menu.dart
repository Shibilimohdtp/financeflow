import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// One entry of an [FfMenuButton].
class FfMenuItem<T> {
  const FfMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// Draws the entry in the error colour ("Delete", "Archive").
  final bool destructive;
}

/// An overflow ("more") button that opens a menu of actions.
class FfMenuButton<T> extends StatelessWidget {
  const FfMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.tooltip = 'More options',
    this.icon = Icons.more_vert_rounded,
  });

  final List<FfMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: Icon(icon),
      color: ff.color.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: ffRadius(FfRadius.md)),
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            for (final item in items)
              PopupMenuItem<T>(
                value: item.value,
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: FfIconSize.lg,
                        color:
                            item.destructive
                                ? ff.color.statusError
                                : ff.color.textSecondary,
                      ),
                      const SizedBox(width: FfSpace.sm),
                    ],
                    Text(
                      item.label,
                      style: ff.text.body.copyWith(
                        color:
                            item.destructive
                                ? ff.color.statusError
                                : ff.color.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
    );
  }
}
