import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_sheet.dart';

/// The header of every bottom sheet: drag handle, sentence-case title, one
/// short subtitle saying what the sheet is for, and the close (X).
///
/// Inside an `FfSheet` it draws a hairline under itself only while the body
/// is scrolled away from the top.
class FfSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Kept for older callers. New sheets put nothing here: privacy cues
  /// belong on top-level screens, and the X is the only header action.
  final Widget? trailing;
  final bool showCloseButton;
  final bool showDragHandle;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  const FfSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showCloseButton = true,
    this.showDragHandle = true,
    this.onClose,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      FfSheetTokens.paddingH,
      FfSpace.sm,
      FfSpace.xs,
      FfSpace.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final scroll = FfSheetScroll.maybeOf(context);
    final showHairline = scroll?.scrolled ?? false;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showHairline ? c.borderSubtle : Colors.transparent,
            width: FfBorderWidth.hairline,
          ),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle)
              Center(
                child: Container(
                  width: FfSheetTokens.dragHandle.width,
                  height: FfSheetTokens.dragHandle.height,
                  margin: const EdgeInsets.only(bottom: FfSpace.xs),
                  decoration: ShapeDecoration(
                    color: c.borderSubtle,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: ff.text.titleLg),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          subtitle!,
                          style: ff.text.bodySm.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: FfSpace.sm),
                  trailing!,
                ],
                if (showCloseButton) ...[
                  const SizedBox(width: FfSpace.x2s),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: FfIconSize.xl),
                    color: c.textPrimary,
                    tooltip: 'Close',
                    constraints: const BoxConstraints.tightFor(
                      width: FfTouch.minTarget,
                      height: FfTouch.minTarget,
                    ),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
