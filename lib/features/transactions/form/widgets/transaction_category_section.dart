import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/category.dart';
import '../../../../shared/widgets/ff_category_tile.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/stillwater_colors.dart';

class TransactionCategorySection extends StatelessWidget {
  final List<Category> categoriesForType;
  final Category? selectedCategory;
  final String? categoryError;
  final ValueChanged<Category> onSelectCategory;
  final VoidCallback onOpenCategoryPicker;

  const TransactionCategorySection({
    super.key,
    required this.categoriesForType,
    required this.selectedCategory,
    this.categoryError,
    required this.onSelectCategory,
    required this.onOpenCategoryPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    // Show top 3 prioritized categories.
    // If active selection is outside top 3, display it in place of 3rd slot.
    final top3 = categoriesForType.take(3).toList();
    final List<Category> displayedQuickCategories;
    if (selectedCategory != null &&
        !top3.any((c) => c.id == selectedCategory!.id)) {
      if (top3.length >= 3) {
        displayedQuickCategories = [top3[0], top3[1], selectedCategory!];
      } else {
        displayedQuickCategories = [...top3, selectedCategory!];
      }
    } else {
      displayedQuickCategories = top3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: context.ff.text.labelLg),
        const SizedBox(height: FfSpace.x2s),

        // 4-Column Balanced Grid/Row: 3 Top Categories + 1 "All Categories" Tile
        Row(
          children: [
            ...displayedQuickCategories.map((cat) {
              final isSelected = cat.id == selectedCategory?.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: FfSpace.x2s),
                  child: InkWell(
                    onTap: () => onSelectCategory(cat),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.x3s,
                        vertical: FfSpace.x2s,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? (isDark
                                    ? context.ff.color.actionPrimaryContainer
                                        .withValues(alpha: FfTint.strong.alpha)
                                    : context.ff.color.actionPrimaryContainer
                                        .withValues(alpha: FfTint.strong.alpha))
                                : (isDark
                                    ? StillwaterColors.darkSurfaceContainerLow
                                    : StillwaterColors
                                        .lightSurfaceContainerLow),
                        borderRadius: BorderRadius.circular(FfRadius.md),
                        border: Border.all(
                          color:
                              isSelected
                                  ? context.ff.color.actionPrimary
                                  : context.ff.color.borderSubtle.withValues(
                                    alpha: 0.5,
                                  ),
                          width:
                              isSelected
                                  ? FfBorderWidth.focus
                                  : FfBorderWidth.regular,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FfCategoryTile(
                            iconIdentifier: cat.iconIdentifier,
                            colorTokenIdentifier: cat.colorTokenIdentifier,
                            size: 26,
                          ),
                          const SizedBox(height: FfSpace.x2s),
                          Text(
                            cat.name,
                            style: context.ff.text.labelSm.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? context.ff.color.actionPrimary
                                      : context.ff.color.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // 4th Tile: All Categories Launcher
            Expanded(
              child: InkWell(
                onTap: onOpenCategoryPicker,
                borderRadius: BorderRadius.circular(FfRadius.md),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.x3s,
                    vertical: FfSpace.x2s,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? StillwaterColors.darkSurfaceContainerLow
                            : StillwaterColors.lightSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    border: Border.all(
                      color: context.ff.color.borderSubtle.withValues(
                        alpha: 0.5,
                      ),
                      width: FfBorderWidth.regular,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: context.ff.color.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: context.ff.color.actionPrimary,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x2s),
                      Text(
                        'All Categories',
                        style: context.ff.text.labelSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.ff.color.actionPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        if (categoryError != null) ...[
          const SizedBox(height: FfSpace.x2s),
          Text(
            categoryError!,
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.statusError,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
