import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_button.dart';
import 'ff_sheet.dart';

/// The sticky footer of a sheet: one full-width primary button, and at most
/// one quiet text-button secondary above it. Dismissal is the header's X,
/// so there is no Cancel button. Destructive actions (Delete) belong at the
/// end of the sheet body, not here.
///
/// Inside an `FfSheet` it draws a hairline on top only while the body has
/// more content underneath it.
class FfSheetFooter extends StatelessWidget {
  final Widget? child;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool isPrimaryLoading;

  /// An optional text-button action shown above the primary button.
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;
  final EdgeInsetsGeometry? padding;

  const FfSheetFooter({
    super.key,
    this.child,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.isPrimaryLoading = false,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final scroll = FfSheetScroll.maybeOf(context);
    // Outside a sheet (or before the body reports) keep the hairline.
    final showHairline = scroll?.moreBelow ?? true;

    final effectivePadding =
        padding ??
        const EdgeInsets.fromLTRB(
          FfSheetTokens.paddingH,
          FfSpace.sm,
          FfSheetTokens.paddingH,
          FfSpace.sm,
        );

    Widget content;
    if (child != null) {
      content = child!;
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (secondaryLabel != null && onSecondaryPressed != null) ...[
            FfButton(
              label: secondaryLabel!,
              variant: FfButtonVariant.text,
              onPressed: onSecondaryPressed,
            ),
            const SizedBox(height: FfSpace.x2s),
          ],
          if (primaryLabel != null)
            FfButton(
              label: primaryLabel!,
              isLoading: isPrimaryLoading,
              onPressed: onPrimaryPressed,
            ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceSheet,
        border: Border(
          top: BorderSide(
            color: showHairline ? c.borderSubtle : Colors.transparent,
            width: FfBorderWidth.hairline,
          ),
        ),
      ),
      child: Padding(padding: effectivePadding, child: content),
    );
  }
}
