import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_card.dart';

/// A compact, tactile squircle toggle tile designed for the quick settings strip
/// on the More hub. Displays an icon, a short label, and a status chip
/// (word + icon, never colour alone).
class FfQuickToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String statusText;
  final IconData statusIcon;
  final bool isActive;
  final FfTone tone;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FfQuickToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.statusText,
    required this.statusIcon,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
    this.tone = FfTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    final baseDecoration = FfCard.decorationOf(
      context,
      density: FfDensity.compact,
    );

    // Active state subtly accents the squircle border and icon background
    final shape = FfShape.of(
      FfQuickToggleTokens.radius,
      side: BorderSide(
        color:
            isActive
                ? ff.color.actionPrimary.withValues(alpha: FfTint.strong.alpha)
                : ff.color.borderSubtle,
        width: isActive ? FfBorderWidth.regular : FfBorderWidth.hairline,
      ),
    );

    return Semantics(
      button: true,
      selected: isActive,
      label: '$title: $statusText',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: FfQuickToggleTokens.minHeight,
          minWidth: FfTouch.minTarget,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: ShapeDecoration(
              color: baseDecoration.color,
              shadows: baseDecoration.shadows,
              shape: shape,
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.xs,
                  vertical: FfSpace.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon in circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: ShapeDecoration(
                        shape: FfShape.of(FfRadius.full),
                        color:
                            isActive
                                ? ff.color.actionPrimary.withValues(
                                  alpha: FfTint.subtle.alpha,
                                )
                                : ff.color.surfaceGlass,
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: FfQuickToggleTokens.iconSize,
                          color:
                              isActive
                                  ? ff.color.actionPrimary
                                  : ff.color.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: FfSpace.xs),
                    // Title
                    Text(
                      title,
                      style: ff.text.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ff.color.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    // Status row (icon + word)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          statusIcon,
                          size: 11,
                          color:
                              isActive
                                  ? ff.color.actionPrimary
                                  : ff.color.textTertiary,
                        ),
                        const SizedBox(width: FfSpace.x3s),
                        Flexible(
                          child: Text(
                            statusText,
                            style: ff.text.labelSm.copyWith(
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isActive
                                      ? ff.color.actionPrimary
                                      : ff.color.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal container for a strip of [FfQuickToggleTile]s.
class FfQuickToggleStrip extends StatelessWidget {
  final List<FfQuickToggleTile> tiles;

  const FfQuickToggleStrip({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          Expanded(child: tiles[i]),
          if (i < tiles.length - 1) const SizedBox(width: FfSpace.xs),
        ],
      ],
    );
  }
}
