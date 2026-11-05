import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

/// Legacy list row, kept only for the budgets screens another chat owns.
/// New code uses `FfRow`. Removed in design-system slice DS-9.
class FfListRow extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showChevron;
  final bool enabled;

  const FfListRow({
    super.key,
    this.leading,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: StillwaterTokens.spaceMd,
      vertical: StillwaterTokens.spaceSm,
    ),
    this.showChevron = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && icon != null) {
      final iColor = iconColor ?? theme.colorScheme.primary;
      final bgColor = iconBackgroundColor ?? iColor.withValues(alpha: 0.12);
      leadingWidget = Container(
        width: StillwaterTokens.iconTileSize,
        height: StillwaterTokens.iconTileSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
        ),
        child: Icon(icon, size: 20, color: iColor),
      );
    }

    Widget? trailingWidget = trailing;
    if (trailingWidget == null) {
      if (trailingText != null) {
        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailingText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            if (showChevron && onTap != null) ...[
              const SizedBox(width: StillwaterTokens.spaceXs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.outline,
              ),
            ],
          ],
        );
      } else if (showChevron && onTap != null) {
        trailingWidget = Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: theme.colorScheme.outline,
        );
      }
    }

    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: StillwaterTokens.spaceMd),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        enabled
                            ? theme.textTheme.titleSmall?.color
                            : theme.colorScheme.outline,
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
          if (trailingWidget != null) ...[
            const SizedBox(width: StillwaterTokens.spaceSm),
            trailingWidget,
          ],
        ],
      ),
    );

    if (onTap == null || !enabled) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
