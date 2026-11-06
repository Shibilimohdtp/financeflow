import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/category.dart';
import '../../../../shared/widgets/ff_category_tile.dart';
import '../../../../theme/ff.dart';

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
        Text(
          'Category',
          style: context.ff.text.label.copyWith(
            color: context.ff.color.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: FfSpace.xs),

        Row(
          children: [
            ...displayedQuickCategories.map((cat) {
              final isSelected = cat.id == selectedCategory?.id;
              final tileBg =
                  isSelected
                      ? (isDark
                          ? context.ff.color.actionPrimaryContainer.withValues(
                            alpha: FfTint.strong.alpha,
                          )
                          : context.ff.color.actionPrimaryContainer.withValues(
                            alpha: FfTint.strong.alpha,
                          ))
                      : context.ff.color.surfaceCard;

              final borderColor =
                  isSelected
                      ? context.ff.color.actionPrimary
                      : context.ff.color.borderSubtle.withValues(alpha: 0.5);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: FfSpace.xs),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: cat.name,
                    child: InkWell(
                      onTap: () => onSelectCategory(cat),
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      child: Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.x2s,
                          vertical: FfSpace.xs,
                        ),
                        decoration: BoxDecoration(
                          color: tileBg,
                          borderRadius: BorderRadius.circular(FfRadius.md),
                          border: Border.all(
                            color: borderColor,
                            width:
                                isSelected
                                    ? FfBorderWidth.focus
                                    : FfBorderWidth.hairline,
                          ),
                          boxShadow:
                              isDark
                                  ? const []
                                  : FfElevation.card(
                                    context.ff.color.shadow,
                                    Brightness.light,
                                  ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FfCategoryTile(
                              iconIdentifier: cat.iconIdentifier,
                              colorTokenIdentifier: cat.colorTokenIdentifier,
                              size: 28,
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
                ),
              );
            }),

            // 4th Tile: All Categories Launcher
            Expanded(
              child: Semantics(
                button: true,
                label: 'All categories',
                child: InkWell(
                  onTap: onOpenCategoryPicker,
                  borderRadius: BorderRadius.circular(FfRadius.md),
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.x2s,
                      vertical: FfSpace.xs,
                    ),
                    decoration: BoxDecoration(
                      color: context.ff.color.surfaceCard,
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color: context.ff.color.borderSubtle.withValues(
                          alpha: 0.5,
                        ),
                        width: FfBorderWidth.hairline,
                      ),
                      boxShadow:
                          isDark
                              ? const []
                              : FfElevation.card(
                                context.ff.color.shadow,
                                Brightness.light,
                              ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
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
            ),
          ],
        ),

        if (categoryError != null) ...[
          const SizedBox(height: FfSpace.x2s),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: context.ff.color.statusError,
              ),
              const SizedBox(width: FfSpace.x2s),
              Text(
                categoryError!,
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.statusError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
