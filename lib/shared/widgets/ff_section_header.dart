import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

/// A standard Stillwater section header with uppercase label style.
class FfSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool isUppercase;
  final EdgeInsetsGeometry padding;

  const FfSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.isUppercase = false,
    this.padding = const EdgeInsets.only(
      left: StillwaterTokens.spaceXs,
      right: StillwaterTokens.spaceXs,
      bottom: StillwaterTokens.spaceXs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isUppercase ? title.toUpperCase() : title,
              style:
                  isUppercase
                      ? theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      )
                      : theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
