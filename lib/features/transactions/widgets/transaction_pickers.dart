/// Account and category pickers used by the add/edit transaction screen.
library;

import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../theme/ff.dart';

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
          borderRadius: BorderRadius.circular(FfRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.md,
              vertical: FfSpace.sm,
            ),
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.md),
              border: Border.all(
                color:
                    error != null
                        ? context.ff.color.statusError
                        : context.ff.color.borderSubtle,
                width:
                    error != null ? FfBorderWidth.focus : FfBorderWidth.regular,
              ),
            ),
            child: Row(
              children: [
                FfIconTile(
                  icon: account == null ? icon : _accountIcon(account!.type),
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child:
                      account == null
                          ? Text(
                            'Select $label',
                            style: context.ff.text.body.copyWith(
                              color: context.ff.color.textSecondary,
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account!.name,
                                style: context.ff.text.bodyLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${account!.displaySubtitle} • ${CurrencyFormatter.formatAmount(account!.currentBalance)}',
                                style: context.ff.text.bodySm.copyWith(
                                  color: context.ff.color.textSecondary,
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
          const SizedBox(height: FfSpace.x2s),
          Text(
            error!,
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.statusError,
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
    final filtered =
        widget.categories
            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return FfSheet(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.sm,
              FfSpace.lg,
              FfSpace.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FfSheetHeader(
                  title: 'Choose Category',
                  padding: EdgeInsets.zero,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: FfSpace.sm),
                FfTextField.search(
                  controller: _searchController,
                  hint: 'Search categories...',
                  onChanged: (val) => setState(() => _query = val.trim()),
                ),
                const SizedBox(height: FfSpace.md),
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
                                  color: context.ff.color.textSecondary,
                                ),
                                const SizedBox(height: FfSpace.xs),
                                Text(
                                  'No matching category found',
                                  style: context.ff.text.body.copyWith(
                                    color: context.ff.color.textSecondary,
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
                                      crossAxisSpacing: FfSpace.sm,
                                      mainAxisSpacing: FfSpace.sm,
                                      childAspectRatio: 1.3,
                                    ),
                                itemBuilder: (context, index) {
                                  final category = filtered[index];
                                  final isSelected =
                                      category.id == widget.selected?.id;

                                  return _CategoryGridTile(
                                    category: category,
                                    isSelected: isSelected,
                                    onTap:
                                        () => Navigator.pop(context, category),
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
      ],
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
    final selectedBg = context.ff.color.actionPrimaryContainer;
    final unselectedBg = context.ff.color.surfaceCard;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FfRadius.md),
        child: AnimatedContainer(
          duration: FfMotion.fast,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(FfRadius.md),
            border: Border.all(
              color:
                  isSelected
                      ? context.ff.color.actionPrimary
                      : context.ff.color.borderSubtle,
              width: isSelected ? FfBorderWidth.focus : FfBorderWidth.hairline,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.xs,
            vertical: FfSpace.sm,
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
                    const SizedBox(height: FfSpace.x2s),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.ff.text.label.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected
                                ? context.ff.color.actionPrimary
                                : context.ff.color.textPrimary,
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
                      color: context.ff.color.actionPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: context.ff.color.onActionPrimary,
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
    return FfSheet(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(FfSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FfSheetHeader(
                  title: title,
                  padding: EdgeInsets.zero,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: FfSpace.sm),
                if (accounts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(FfSpace.xl),
                    child: Text('No eligible account available.'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const FfDivider(),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        final isSelected = account.id == selected?.id;

                        return FfRow(
                          leading: FfIconTile(icon: _icon(account.type)),
                          title: account.name,
                          subtitle:
                              '${account.displaySubtitle} • ${CurrencyFormatter.formatAmount(account.currentBalance)}',
                          selected: isSelected,
                          onTap: () => Navigator.pop(context, account),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
