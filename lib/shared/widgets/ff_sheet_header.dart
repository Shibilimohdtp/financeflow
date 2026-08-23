import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

/// A standard Stillwater bottom sheet header with drag handle, title, optional subtitle, and actions.
class FfSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
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
    this.padding = const EdgeInsets.fromLTRB(
      StillwaterTokens.spaceLg,
      StillwaterTokens.spaceSm,
      StillwaterTokens.spaceSm,
      StillwaterTokens.spaceMd,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered drag handle
          if (showDragHandle) ...[
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusFull,
                  ),
                ),
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: StillwaterTokens.spaceSm),
                trailing!,
              ],
              if (showCloseButton && trailing == null) ...[
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ] else if (showCloseButton && trailing != null) ...[
                const SizedBox(width: StillwaterTokens.spaceXs),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
