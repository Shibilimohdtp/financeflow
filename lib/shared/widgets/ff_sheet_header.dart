import 'package:flutter/material.dart';
import '../../theme/ff.dart';

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
      FfSpace.lg,
      FfSpace.sm,
      FfSpace.sm,
      FfSpace.md,
    ),
  });

  @override
  Widget build(BuildContext context) {
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
                margin: const EdgeInsets.only(bottom: FfSpace.sm),
                decoration: BoxDecoration(
                  color: context.ff.color.borderSubtle,
                  borderRadius: BorderRadius.circular(FfRadius.full),
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
                      style: context.ff.text.titleLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        subtitle!,
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
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
              if (showCloseButton && trailing == null) ...[
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ] else if (showCloseButton && trailing != null) ...[
                const SizedBox(width: FfSpace.xs),
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
