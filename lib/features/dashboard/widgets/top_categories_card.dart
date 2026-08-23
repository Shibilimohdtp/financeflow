import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/category_colors.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../theme/stillwater_tokens.dart';

class TopCategoriesCard extends StatelessWidget {
  final List<
    ({
      String categoryId,
      String name,
      String icon,
      String color,
      double amount,
      double percentage,
    })
  >
  categories;
  final bool isPrivacyBlur;
  final VoidCallback onExploreMore;

  const TopCategoriesCard({
    super.key,
    required this.categories,
    this.isPrivacyBlur = false,
    required this.onExploreMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top Spending',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onExploreMore,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('All analytics'),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              border: Border.all(
                color: theme.dividerColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              children:
                  categories.map((cat) {
                    final catColor = CategoryColors.getColor(
                      cat.color,
                      isDark: theme.brightness == Brightness.dark,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      child: Row(
                        children: [
                          FfCategoryTile(
                            iconIdentifier: cat.icon,
                            colorTokenIdentifier: cat.color,
                            size: 32,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    FfAmountText(
                                      amount: cat.amount,
                                      size: FfAmountSize.sm,
                                      isBlurred: isPrivacyBlur,
                                      showSign: false,
                                      colorOverride:
                                          theme.colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: StillwaterTokens.space3Xs,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          StillwaterTokens.radiusFull,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: cat.percentage.clamp(0.0, 1.0),
                                          backgroundColor:
                                              theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                          color: catColor,
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: StillwaterTokens.spaceSm,
                                    ),
                                    Text(
                                      '${(cat.percentage * 100).toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
