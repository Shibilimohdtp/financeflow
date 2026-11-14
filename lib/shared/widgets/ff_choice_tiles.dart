import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';

/// One option of an [FfChoiceTiles] grid.
class FfChoiceTile<T> {
  const FfChoiceTile({
    required this.value,
    required this.icon,
    required this.label,
    this.semanticLabel,
  });

  final T value;
  final IconData icon;
  final String label;

  /// What a screen reader hears; defaults to [label].
  final String? semanticLabel;
}

/// How an [FfChoiceTiles] tile lays out its icon and label.
enum FfChoiceTileLayout {
  /// Icon beside the label; for short labels ("Bank", "UPI").
  inline,

  /// Icon above the label; for icon-led kinds with longer names.
  stacked,
}

/// A grid of 4–6 icon-led options, [columns] per row. Selected is ink with
/// a check; the rest are outlined cards. Labels wrap to two lines and are
/// never cut off; every tile in a row has the same height and at least a
/// 48 dp target. Use for a required choice of kind (account type, asset
/// class, service kind, lent/borrowed); use `FfChip` for short word options
/// and `FfSegmentedPill` for 2–4 modes.
class FfChoiceTiles<T> extends StatelessWidget {
  const FfChoiceTiles({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.columns = 3,
    this.layout = FfChoiceTileLayout.stacked,
  });

  final List<FfChoiceTile<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final int columns;
  final FfChoiceTileLayout layout;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < options.length; start += columns) {
      final cells = <Widget>[];
      for (var i = 0; i < columns; i++) {
        if (i > 0) cells.add(const SizedBox(width: FfSpace.sm));
        final index = start + i;
        cells.add(
          Expanded(
            child:
                index < options.length
                    ? _Tile<T>(
                      option: options[index],
                      isSelected: options[index].value == selected,
                      layout: layout,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(options[index].value);
                      },
                    )
                    : const SizedBox.shrink(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: FfSpace.sm));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class _Tile<T> extends StatelessWidget {
  const _Tile({
    required this.option,
    required this.isSelected,
    required this.layout,
    required this.onTap,
  });

  final FfChoiceTile<T> option;
  final bool isSelected;
  final FfChoiceTileLayout layout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final fg = isSelected ? c.onActionPrimary : c.textPrimary;
    final iconColor = isSelected ? c.onActionPrimary : c.textSecondary;
    final shape = FfShape.of(
      FfRadius.md,
      side: BorderSide(
        color: isSelected ? c.actionPrimary : c.borderSubtle,
        width: FfBorderWidth.regular,
      ),
    );

    final label = Text(
      option.label,
      style: ff.text.labelLg.copyWith(color: fg),
      textAlign:
          layout == FfChoiceTileLayout.stacked
              ? TextAlign.center
              : TextAlign.start,
      softWrap: true,
      maxLines: 2,
    );
    final icon = Icon(option.icon, size: FfIconSize.lg, color: iconColor);
    final check = Icon(
      Icons.check_rounded,
      size: FfIconSize.sm,
      color: c.onActionPrimary,
    );

    final Widget content = switch (layout) {
      FfChoiceTileLayout.inline => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: FfSpace.xs),
          Flexible(child: label),
          if (isSelected) ...[const SizedBox(width: FfSpace.x2s), check],
        ],
      ),
      FfChoiceTileLayout.stacked => Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [icon, const SizedBox(height: FfSpace.x2s), label],
            ),
          ),
          if (isSelected) PositionedDirectional(top: 0, end: 0, child: check),
        ],
      ),
    };

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: true,
        label: option.semanticLabel ?? option.label,
        child: Material(
          color: isSelected ? c.actionPrimary : c.surfaceCard,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: FfTouch.minTarget),
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.sm),
                child: Center(child: ExcludeSemantics(child: content)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
