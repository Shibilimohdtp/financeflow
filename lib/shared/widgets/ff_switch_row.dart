import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

/// A standard Stillwater settings switch row.
class FfSwitchRow extends StatelessWidget {
  final Widget? leading;
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  const FfSwitchRow({
    super.key,
    this.leading,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: StillwaterTokens.spaceMd,
      vertical: StillwaterTokens.spaceSm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && icon != null) {
      final iColor = iconColor ?? theme.colorScheme.primary;
      leadingWidget = Container(
        width: StillwaterTokens.iconTileSize,
        height: StillwaterTokens.iconTileSize,
        decoration: BoxDecoration(
          color: iColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
        ),
        child: Icon(icon, size: 20, color: iColor),
      );
    }

    return Padding(
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
          const SizedBox(width: StillwaterTokens.spaceSm),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
