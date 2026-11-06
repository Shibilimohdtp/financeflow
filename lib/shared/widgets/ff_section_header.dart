import 'package:flutter/material.dart';
import '../../theme/ff.dart';

/// A section title with an optional count and trailing action.
///
/// On summary screens (Home) every section uses the same shape: title, a quiet
/// count, and an [FfSectionLink] ("See all ↗"), with [sectionPadding] so the
/// title lines up with the page margin of the card below it.
class FfSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool isUppercase;
  final EdgeInsetsGeometry padding;

  /// Quiet number after the title ("Loans · 2"). Hidden when null.
  final int? count;

  /// Header padding for a section whose parent already applies the page
  /// margin: no side inset, a small gap above the card.
  static const EdgeInsetsGeometry sectionPadding = EdgeInsets.only(
    bottom: FfSpace.xs,
  );

  const FfSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.isUppercase = false,
    this.count,
    this.padding = const EdgeInsets.only(
      left: FfSpace.xs,
      right: FfSpace.xs,
      bottom: FfSpace.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final titleText = Text(
      isUppercase ? title.toUpperCase() : title,
      style:
          isUppercase
              ? ff.text.labelSm.copyWith(
                color: ff.color.secondary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              )
              : ff.text.title.copyWith(fontWeight: FontWeight.w600),
    );
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder:
            (context, box) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child:
                      count == null
                          ? titleText
                          : Semantics(
                            header: true,
                            label: '$title, $count',
                            excludeSemantics: true,
                            child: Row(
                              children: [
                                Flexible(child: titleText),
                                const SizedBox(width: FfSpace.xs),
                                Text(
                                  '$count',
                                  style: ff.text.title.copyWith(
                                    color: ff.color.textTertiary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
                if (trailing != null)
                  // Up to 60% of the row, so a long figure or large text wraps or
                  // shrinks inside it instead of overflowing the header.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          box.maxWidth * FfSectionHeaderTokens.trailingShare,
                    ),
                    child: trailing!,
                  ),
              ],
            ),
      ),
    );
  }
}

/// The quiet "See all ↗" link at the end of a section header (and of the
/// balance hero's "3 accounts ↗"): secondary text, an outward arrow, a 48 dp
/// target, aligned to the end so its text sits on the page margin.
class FfSectionLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  /// Spoken instead of [label] when the label alone is vague ("See all").
  final String? semanticLabel;

  const FfSectionLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: ff.color.textSecondary,
          minimumSize: const Size(FfTouch.minTarget, FfTouch.minTarget),
          padding: const EdgeInsetsDirectional.only(
            start: FfSpace.sm,
            end: FfSpace.x2s,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: AlignmentDirectional.centerEnd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: ff.text.label.copyWith(color: ff.color.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: FfSpace.x3s),
            const Icon(Icons.arrow_outward_rounded, size: FfIconSize.xs),
          ],
        ),
      ),
    );
  }
}
