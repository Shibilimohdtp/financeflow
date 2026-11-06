import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/app_settings.dart';
import '../../theme/ff.dart';

/// A live visual miniature card representing an [AppThemePreference] option
/// (Daylight Light, Deep Water Dark, or System Default). Renders a miniature
/// preview of the Home canvas, hero card, and list rows.
class FfThemePreviewCard extends StatelessWidget {
  final AppThemePreference preference;
  final bool isSelected;
  final VoidCallback onTap;

  const FfThemePreviewCard({
    super.key,
    required this.preference,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    // Palette primitives for static preview rendering
    final isDark = preference == AppThemePreference.deepWater;
    final isSystem = preference == AppThemePreference.system;

    final bgColor =
        isDark
            ? const Color(0xFF10120E)
            : isSystem
            ? const Color(0xFFE8E7E0)
            : const Color(0xFFF3F2EC);

    final heroColor =
        isDark ? const Color(0xFF1E281C) : const Color(0xFFD6DEC9);

    final rowColor = isDark ? const Color(0xFF1C1E19) : const Color(0xFFFFFFFF);

    final miniTextColor =
        isDark ? const Color(0xFF9EABA2) : const Color(0xFF5A665A);

    final shape = FfShape.of(
      FfThemePreviewTokens.radius,
      side: BorderSide(
        color: isSelected ? ff.color.actionPrimary : ff.color.borderSubtle,
        width: isSelected ? FfBorderWidth.regular : FfBorderWidth.hairline,
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${preference.displayName}, ${isSelected ? 'selected' : 'not selected'}',
      excludeSemantics: true,
      child: SizedBox(
        width: FfThemePreviewTokens.width,
        height: FfThemePreviewTokens.height,
        child: Material(
          type: MaterialType.transparency,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: ShapeDecoration(
              color: ff.color.surfaceCard,
              shape: shape,
              shadows: FfElevation.card(
                ff.color.shadow,
                Theme.of(context).brightness,
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Miniature Canvas Container
                    Container(
                      width: double.infinity,
                      height: 84,
                      decoration: ShapeDecoration(
                        color: bgColor,
                        shape: FfShape.of(FfRadius.sm),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mini header dots
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: miniTextColor,
                                  borderRadius: BorderRadius.circular(
                                    FfRadius.full,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: miniTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Mini hero card
                          Container(
                            width: double.infinity,
                            height: 22,
                            decoration: ShapeDecoration(
                              color: heroColor,
                              shape: FfShape.of(FfRadius.xs),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.x2s,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: miniTextColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: FfSpace.x2s),
                                Container(
                                  width: 24,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: miniTextColor,
                                    borderRadius: BorderRadius.circular(
                                      FfRadius.full,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Mini row 1
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: ShapeDecoration(
                              color: rowColor,
                              shape: FfShape.of(FfRadius.xs),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Mini row 2
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: ShapeDecoration(
                              color: rowColor,
                              shape: FfShape.of(FfRadius.xs),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Theme Label + Selection indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _shortName(preference),
                            style: ff.text.labelSm.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? ff.color.actionPrimary
                                      : ff.color.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: FfSpace.x3s),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: ff.color.actionPrimary,
                          ),
                        ],
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

  static String _shortName(AppThemePreference pref) {
    switch (pref) {
      case AppThemePreference.system:
        return 'System';
      case AppThemePreference.daylight:
        return 'Light';
      case AppThemePreference.deepWater:
        return 'Dark';
    }
  }
}
