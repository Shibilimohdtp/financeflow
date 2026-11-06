import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/category_colors.dart';
import '../../models/category_icons.dart';
import '../../theme/ff.dart';

/// A category's icon on a tinted circle, in the category's own colour.
class FfCategoryTile extends StatelessWidget {
  final String iconIdentifier;
  final String colorTokenIdentifier;
  final double size;

  const FfCategoryTile({
    super.key,
    required this.iconIdentifier,
    required this.colorTokenIdentifier,
    this.size = FfRowTokens.iconTile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = CategoryColors.getColor(colorTokenIdentifier, isDark: isDark);
    final iconData = CategoryIcons.getIcon(iconIdentifier);

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: color.withValues(alpha: FfTint.subtle.alpha),
        shape: FfShape.of(FfRowTokens.iconTileRadius),
      ),
      child: Center(child: Icon(iconData, size: size * 0.5, color: color)),
    );
  }
}
