/// Account and category pickers used by the add/edit transaction screen.
library;

import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../theme/stillwater_colors.dart';
import '../../../theme/stillwater_tokens.dart';

/// A compact, rich tile button for selecting an Account.
class AccountTileButton extends StatelessWidget {
  final String label;
  final Account? account;
  final String? error;
  final IconData icon;
  final VoidCallback onTap;

  const AccountTileButton({
    super.key,
    required this.label,
    required this.account,
    required this.icon,
    required this.onTap,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceMd,
              vertical: StillwaterTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
              border: Border.all(
                color:
                    error != null
                        ? theme.colorScheme.error
                        : (isDark
                            ? StillwaterColors.darkBorderDefault
                            : StillwaterColors.lightBorderDefault),
                width:
                    error != null
                        ? StillwaterTokens.borderWidthFocus
                        : StillwaterTokens.borderWidthDefault,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    account == null ? icon : _accountIcon(account!.type),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child:
                      account == null
                          ? Text(
                            'Select $label',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account!.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${account!.displaySubtitle} • ${CurrencyFormatter.formatAmount(account!.currentBalance)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                ),
                const Icon(Icons.expand_more_rounded, size: 20),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  IconData _accountIcon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.upi => Icons.account_balance_wallet_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    _ => Icons.account_balance_outlined,
  };
}

/// Category selection modal bottom sheet with instant search and multi-column visual grid.
class CategoryPickerSheet extends StatefulWidget {
  final List<Category> categories;
  final Category? selected;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selected,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  String _query = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final filtered =
        widget.categories
            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Material(
      color:
          isDark
              ? StillwaterColors.darkSurfaceDefault
              : StillwaterColors.lightSurfaceDefault,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(StillwaterTokens.radius2Xl),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceSm,
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: 'Choose Category',
                padding: EdgeInsets.zero,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: StillwaterTokens.spaceSm),
              TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (val) => setState(() => _query = val.trim()),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDark
                          ? StillwaterColors.darkSurfaceContainerLow
                          : StillwaterColors.lightSurfaceContainerLow,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon:
                      _query.isEmpty
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  hintText: 'Search categories...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceMd,
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: StillwaterTokens.borderWidthFocus,
                    ),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: StillwaterTokens.spaceMd),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.50,
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: StillwaterTokens.spaceXs),
                              Text(
                                'No matching category found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                        : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount =
                                width < 340 ? 2 : (width < 600 ? 3 : 4);

                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filtered.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: StillwaterTokens.spaceSm,
                                    mainAxisSpacing: StillwaterTokens.spaceSm,
                                    childAspectRatio: 1.3,
                                  ),
                              itemBuilder: (context, index) {
                                final category = filtered[index];
                                final isSelected =
                                    category.id == widget.selected?.id;

                                return _CategoryGridTile(
                                  category: category,
                                  isSelected: isSelected,
                                  onTap: () => Navigator.pop(context, category),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual grid tile for selecting a category in the full picker sheet.
class _CategoryGridTile extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg =
        isDark
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.45);
    final unselectedBg =
        isDark
            ? StillwaterColors.darkSurfaceContainerLow.withValues(alpha: 0.6)
            : StillwaterColors.lightSurfaceContainerLow.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
              width:
                  isSelected
                      ? StillwaterTokens.borderWidthFocus
                      : StillwaterTokens.borderWidthHairline,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceXs,
            vertical: StillwaterTokens.spaceSm,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FfCategoryTile(
                      iconIdentifier: category.iconIdentifier,
                      colorTokenIdentifier: category.colorTokenIdentifier,
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account selection bottom sheet with balance display.
class AccountPickerSheet extends StatelessWidget {
  final String title;
  final List<Account> accounts;
  final Account? selected;

  const AccountPickerSheet({
    super.key,
    required this.title,
    required this.accounts,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color:
          isDark
              ? StillwaterColors.darkSurfaceDefault
              : StillwaterColors.lightSurfaceDefault,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(StillwaterTokens.radius2Xl),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: title,
                padding: EdgeInsets.zero,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: StillwaterTokens.spaceSm),
              if (accounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                  child: Text('No eligible account available.'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final isSelected = account.id == selected?.id;

                      return ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _icon(account.type),
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          account.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${account.displaySubtitle} • ${CurrencyFormatter.formatAmount(account.currentBalance)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                )
                                : null,
                        onTap: () => Navigator.pop(context, account),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.creditCard => Icons.credit_card_outlined,
    AccountType.upi => Icons.account_balance_wallet_outlined,
    AccountType.investment => Icons.trending_up_rounded,
    _ => Icons.account_balance_outlined,
  };
}
