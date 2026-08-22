import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/category_colors.dart';
import '../../models/category_icons.dart';
import '../../theme/stillwater_tokens.dart';

class FfCategoryTile extends StatelessWidget {
  final String iconIdentifier;
  final String colorTokenIdentifier;
  final double size;

  const FfCategoryTile({
    super.key,
    required this.iconIdentifier,
    required this.colorTokenIdentifier,
    this.size = StillwaterTokens.iconTileSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = CategoryColors.getColor(colorTokenIdentifier, isDark: isDark);
    final iconData = CategoryIcons.getIcon(iconIdentifier);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: StillwaterTokens.opacityTint),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      ),
      child: Center(child: Icon(iconData, size: size * 0.55, color: color)),
    );
  }
}
