import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';
import 'ff_button.dart';

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
    final theme = context.theme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final effectivePadding =
        padding ??
        EdgeInsets.fromLTRB(
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceSm,
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceSm + bottomInset,
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
              onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
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
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
      ),
      padding: effectivePadding,
      child: content,
    );
  }
}
