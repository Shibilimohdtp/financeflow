import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../models/category.dart';
import '../../../../models/transaction.dart';
import '../../../../services/categorization_service.dart';
import '../../../../services/payee_suggestion_service.dart';
import '../../../../shared/widgets/ff_divider.dart';
import '../../../../shared/widgets/ff_text_field.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/stillwater_colors.dart';

class TransactionMerchantSection extends ConsumerWidget {
  final Key? merchantFieldKey;
  final TextEditingController merchantController;
  final FocusNode merchantFocusNode;
  final TransactionType selectedType;
  final Category? selectedCategory;
  final bool needsCategory;
  final String? merchantError;
  final bool showMerchantSuggestions;
  final List<PayeeSuggestion> suggestions;
  final CategorySuggestion? suggestedCategory;
  final List<Category> categories;
  final List<Transaction> history;
  final void Function(PayeeSuggestion suggestion) onSelectSuggestion;
  final VoidCallback onApplySuggestedCategory;
  final VoidCallback onCloseSuggestions;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClearPayee;

  const TransactionMerchantSection({
    super.key,
    this.merchantFieldKey,
    required this.merchantController,
    required this.merchantFocusNode,
    required this.selectedType,
    required this.selectedCategory,
    required this.needsCategory,
    this.merchantError,
    required this.showMerchantSuggestions,
    required this.suggestions,
    this.suggestedCategory,
    required this.categories,
    required this.history,
    required this.onSelectSuggestion,
    required this.onApplySuggestedCategory,
    required this.onCloseSuggestions,
    this.onChanged,
    required this.onClearPayee,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final label = switch (selectedType) {
      TransactionType.income => 'Payer / Source (optional)',
      TransactionType.transfer => 'Note (optional)',
      TransactionType.investment => 'Asset / Platform (optional)',
      TransactionType.loanEmi => 'Lender / Loan Name (optional)',
      _ => 'Payee (optional)',
    };

    final hint = switch (selectedType) {
      TransactionType.income => 'e.g. Employer, Client, Refund',
      TransactionType.transfer => 'e.g. Move to savings, Shared bill',
      TransactionType.investment => 'e.g. Zerodha, Parag Parikh Flexi Cap',
      TransactionType.loanEmi => 'e.g. HDFC Home Loan, Car EMI',
      _ => 'e.g. Swiggy, Amazon, Groceries',
    };

    final prefixIcon = switch (selectedType) {
      TransactionType.income => Icons.account_circle_outlined,
      TransactionType.transfer => Icons.swap_horiz_rounded,
      TransactionType.investment => Icons.trending_up_rounded,
      TransactionType.loanEmi => Icons.receipt_long_rounded,
      _ => Icons.storefront_outlined,
    };

    final isFocused = merchantFocusNode.hasFocus || showMerchantSuggestions;
    final typedText = merchantController.text.trim();
    final typedTextLower = typedText.toLowerCase();

    final visibleSuggestions =
        typedText.isEmpty
            ? suggestions
            : suggestions
                .where((s) => s.displayName.toLowerCase() != typedTextLower)
                .toList();

    return Column(
      key: merchantFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FfTextField(
          controller: merchantController,
          focusNode: merchantFocusNode,
          textCapitalization: TextCapitalization.words,
          label: label,
          hint: hint,
          errorText: merchantError,
          icon: prefixIcon,
          suffix:
              merchantController.text.isEmpty
                  ? null
                  : IconButton(
                    tooltip: 'Clear payee',
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: onClearPayee,
                  ),
          onChanged: onChanged,
        ),

        // Context-aware dynamic Payee suggestions surface
        if (isFocused &&
            (visibleSuggestions.isNotEmpty || typedText.isNotEmpty)) ...[
          const SizedBox(height: FfSpace.xs),
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? StillwaterColors.darkSurfaceContainerLow
                      : StillwaterColors.lightSurfaceContainerLow,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle.withValues(
                  alpha: FfOpacity.muted,
                ),
                width: FfBorderWidth.regular,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.ff.color.shadow.withValues(
                    alpha: isDark ? 0.35 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.sm,
              vertical: FfSpace.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory != null &&
                              visibleSuggestions.any((s) => s.isCategoryMatch)
                          ? 'Suggested for ${selectedCategory!.name}'
                          : (typedText.isEmpty
                              ? 'Recent payees'
                              : 'Matching payees'),
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.actionPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Close suggestions',
                      onPressed: onCloseSuggestions,
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.x2s),
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return true;
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Rank best matching payees at the top of the dropdown
                        ...visibleSuggestions.map((suggestion) {
                          return InkWell(
                            onTap: () => onSelectSuggestion(suggestion),
                            borderRadius: BorderRadius.circular(FfRadius.md),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FfSpace.xs,
                                vertical: FfSpace.sm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    suggestion.isCategoryMatch
                                        ? Icons.auto_awesome_rounded
                                        : Icons.history_rounded,
                                    size: 18,
                                    color:
                                        suggestion.isCategoryMatch
                                            ? context.ff.color.actionPrimary
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: FfSpace.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          suggestion.displayName,
                                          style: context.ff.text.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (suggestion.reasonLabel != null)
                                          Text(
                                            suggestion.reasonLabel!,
                                            style: context.ff.text.bodySm
                                                .copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                  fontSize: 11,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (suggestion.primaryCategoryName != null &&
                                      needsCategory &&
                                      selectedCategory?.id !=
                                          suggestion.primaryCategoryId)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: FfSpace.xs,
                                        vertical: FfSpace.x3s,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          FfRadius.sm,
                                        ),
                                      ),
                                      child: Text(
                                        suggestion.primaryCategoryName!,
                                        style: context.ff.text.labelSm.copyWith(
                                          color:
                                              theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (typedText.isNotEmpty &&
                            !visibleSuggestions.any(
                              (s) =>
                                  s.displayName.toLowerCase() == typedTextLower,
                            )) ...[
                          if (visibleSuggestions.isNotEmpty)
                            const FfDivider.spaced(),
                          InkWell(
                            onTap: onCloseSuggestions,
                            borderRadius: BorderRadius.circular(FfRadius.md),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FfSpace.xs,
                                vertical: FfSpace.sm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 18,
                                    color: context.ff.color.actionPrimary,
                                  ),
                                  const SizedBox(width: FfSpace.sm),
                                  Expanded(
                                    child: Text(
                                      'Use "$typedText"',
                                      style: context.ff.text.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.ff.color.actionPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Enter',
                                    style: context.ff.text.labelSm.copyWith(
                                      color: context.ff.color.actionPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Offline Categorization Suggestion Banner / Pill
        if (suggestedCategory != null && needsCategory) ...[
          const SizedBox(height: FfSpace.xs),
          InkWell(
            onTap: onApplySuggestedCategory,
            borderRadius: BorderRadius.circular(FfRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.sm,
                vertical: FfSpace.xs,
              ),
              decoration: BoxDecoration(
                color: context.ff.color.actionPrimaryContainer.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(FfRadius.md),
                border: Border.all(
                  color: context.ff.color.actionPrimary.withValues(
                    alpha: FfTint.strong.alpha,
                  ),
                  width: FfBorderWidth.regular,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: context.ff.color.actionPrimary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      'Suggested: ${suggestedCategory!.categoryName} • ${suggestedCategory!.reason}',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.onActionPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  Text(
                    'Apply',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.actionPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
