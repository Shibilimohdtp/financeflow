import 'package:flutter/material.dart';
import 'ff_button.dart';
import '../../theme/ff.dart';

/// A standard sticky bottom sheet footer with top divider hairline, safe-area insets,
/// and support for a single full-width primary CTA or dual (secondary + primary) actions.
class FfSheetFooter extends StatelessWidget {
  final Widget? child;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool isPrimaryLoading;
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final effectivePadding =
        padding ??
        EdgeInsets.fromLTRB(
          FfSpace.lg,
          FfSpace.sm,
          FfSpace.lg,
          FfSpace.sm + bottomInset,
        );

    Widget content;
    if (child != null) {
      content = child!;
    } else if (secondaryLabel != null && primaryLabel != null) {
      content = Row(
        children: [
          Expanded(
            child: FfButton(
              label: secondaryLabel!,
              variant: FfButtonVariant.outlined,
              onPressed:
                  onSecondaryPressed ?? () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: FfButton(
              label: primaryLabel!,
              isLoading: isPrimaryLoading,
              onPressed: onPrimaryPressed,
            ),
          ),
        ],
      );
    } else if (primaryLabel != null) {
      content = SizedBox(
        width: double.infinity,
        child: FfButton(
          label: primaryLabel!,
          isLoading: isPrimaryLoading,
          onPressed: onPrimaryPressed,
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: context.ff.color.surfacePage,
        border: Border(
          top: BorderSide(
            color: context.ff.color.borderSubtle.withValues(
              alpha: FfOpacity.half,
            ),
            width: FfBorderWidth.hairline,
          ),
        ),
      ),
      padding: effectivePadding,
      child: content,
    );
  }
}
