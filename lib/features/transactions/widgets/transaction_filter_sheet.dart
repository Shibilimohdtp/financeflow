import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_footer.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../transaction_list_utils.dart';

/// Edits every filter except the period (period bar) and search (app bar).
/// Redesigned in Stillwater Bloom: Pattern E sheet with visual entity cards,
/// tactile account/category selectors, amount presets, and high-contrast sort pills.
Future<TransactionQuery?> showTransactionFilterSheet(
  BuildContext context, {
  required TransactionQuery query,
  required List<Category> categories,
  required List<Account> accounts,
  required List<String> tags,
  required List<String> paymentMethods,
}) {
  return showFfSheet<TransactionQuery>(
    context,
    builder:
        (_) => _TransactionFilterSheet(
          initial: query,
          categories: categories,
          accounts: accounts,
          tags: tags,
          paymentMethods: paymentMethods,
        ),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  final TransactionQuery initial;
  final List<Category> categories;
  final List<Account> accounts;
  final List<String> tags;
  final List<String> paymentMethods;

  const _TransactionFilterSheet({
    required this.initial,
    required this.categories,
    required this.accounts,
    required this.tags,
    required this.paymentMethods,
  });

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  late TransactionQuery _query = widget.initial;
  late final _minController = TextEditingController(
    text: _formatBound(widget.initial.minAmount),
  );
  late final _maxController = TextEditingController(
    text: _formatBound(widget.initial.maxAmount),
  );

  static String _formatBound(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  int get _activeCount {
    int count = 0;
    if (_query.kinds.isNotEmpty) count += _query.kinds.length;
    if (_query.accountId != null) count++;
    if (_query.categoryId != null) count++;
    if (_minController.text.isNotEmpty || _maxController.text.isNotEmpty) {
      count++;
    }
    if (_query.paymentMethod != null) count++;
    if (_query.tag != null) count++;
    if (_query.sort != TransactionSort.newest) count++;
    return count;
  }

  void _toggleKind(TransactionKind kind) {
    HapticFeedback.selectionClick();
    final kinds = {..._query.kinds};
    kinds.contains(kind) ? kinds.remove(kind) : kinds.add(kind);
    setState(() => _query = _query.copyWith(kinds: kinds));
  }

  void _applyAmountPreset(double? min, double? max) {
    HapticFeedback.selectionClick();
    setState(() {
      _minController.text = min != null ? _formatBound(min) : '';
      _maxController.text = max != null ? _formatBound(max) : '';
    });
  }

  void _resetAll() {
    HapticFeedback.selectionClick();
    _minController.clear();
    _maxController.clear();
    setState(() {
      _query = TransactionQuery(
        period: _query.period,
        search: _query.search,
        sort: TransactionSort.newest,
      );
    });
  }

  TransactionQuery _withAmounts() {
    final min = CurrencyFormatter.parse(_minController.text);
    final max = CurrencyFormatter.parse(_maxController.text);
    var q = _query.copyWith(clearAmount: true);
    if (min != null || max != null) {
      var lo = min;
      var hi = max;
      if (lo != null && hi != null && lo > hi) (lo, hi) = (hi, lo);
      q = q.copyWith(minAmount: lo, maxAmount: hi);
    }
    return q;
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.creditCard:
        return Icons.credit_card_outlined;
      case AccountType.upi:
        return Icons.qr_code_rounded;
      case AccountType.investment:
        return Icons.trending_up_rounded;
      case AccountType.business:
        return Icons.business_center_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final activeCategories =
        widget.categories.where((c) => !c.isArchived).toList();
    final activeAccounts = widget.accounts.where((a) => !a.isArchived).toList();
    final activeFiltersCount = _activeCount;

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Sheet Header ──────────────────────────────────────────────
        const FfSheetHeader(
          title: 'Filter & sort',
          subtitle: 'Refine transactions by kind, account, category, or amount',
          trailing: FfPrivacyBadge(label: '100% Local', iconOnly: true),
        ),
        const FfDivider(),

        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.sm,
            ),
            children: [
              // ── 2. Active Filters Scope Status Bar ──────────────────────
              if (activeFiltersCount > 0) ...[
                FfCard(
                  variant: FfCardVariant.tinted,
                  tone: FfTone.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ff.color.spark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Text(
                          '$activeFiltersCount ${activeFiltersCount == 1 ? 'filter active' : 'filters active'}',
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _resetAll,
                        child: Text(
                          'Clear all',
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.actionPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              // ── 3. Transaction Type (Kind) ──────────────────────────────
              _SectionHeader(
                icon: Icons.swap_vert_rounded,
                title: 'Show',
                subtitle:
                    _query.kinds.isEmpty
                        ? 'All types'
                        : _query.kinds.map((k) => k.label).join(', '),
              ),
              Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  for (final kind in TransactionKind.values)
                    FfChip(
                      key: ValueKey('kind-${kind.name}'),
                      label: kind.label,
                      isSelected: _query.kinds.contains(kind),
                      onSelected: () => _toggleKind(kind),
                    ),
                ],
              ),
              const SizedBox(height: FfSpace.lg),

              // ── 4. Account Selection (Horizontal Visual Selector) ───────
              _SectionHeader(
                icon: Icons.account_balance_outlined,
                title: 'Account',
                subtitle:
                    _query.accountId == null
                        ? 'All accounts'
                        : activeAccounts
                                .where((a) => a.id == _query.accountId)
                                .firstOrNull
                                ?.name ??
                            'Selected',
              ),
              SingleChildScrollView(
                key: const ValueKey('filter-account'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AccountCard(
                      label: 'All accounts',
                      icon: Icons.all_inclusive_rounded,
                      isSelected: _query.accountId == null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _query = _query.copyWith(clearAccount: true),
                        );
                      },
                    ),
                    for (final a in activeAccounts) ...[
                      const SizedBox(width: FfSpace.xs),
                      _AccountCard(
                        label: a.name,
                        icon: _getAccountIcon(a.type),
                        isSelected: _query.accountId == a.id,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () =>
                                _query = _query.copyWith(
                                  accountId:
                                      _query.accountId == a.id ? null : a.id,
                                  clearAccount: _query.accountId == a.id,
                                ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: FfSpace.lg),

              // ── 5. Category Selection (Horizontal Visual Selector) ───────
              _SectionHeader(
                icon: Icons.category_outlined,
                title: 'Category',
                subtitle:
                    _query.categoryId == null
                        ? 'All categories'
                        : activeCategories
                                .where((c) => c.id == _query.categoryId)
                                .firstOrNull
                                ?.name ??
                            'Selected',
              ),
              SingleChildScrollView(
                key: const ValueKey('filter-category'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryCard(
                      label: 'All categories',
                      isSelected: _query.categoryId == null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _query = _query.copyWith(clearCategory: true),
                        );
                      },
                    ),
                    for (final c in activeCategories) ...[
                      const SizedBox(width: FfSpace.xs),
                      _CategoryCard(
                        label: c.name,
                        iconIdentifier: c.iconIdentifier,
                        colorTokenIdentifier: c.colorTokenIdentifier,
                        isSelected: _query.categoryId == c.id,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () =>
                                _query = _query.copyWith(
                                  categoryId:
                                      _query.categoryId == c.id ? null : c.id,
                                  clearCategory: _query.categoryId == c.id,
                                ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: FfSpace.lg),

              // ── 6. Amount Range & Quick Presets ──────────────────────────
              const _SectionHeader(
                icon: Icons.payments_outlined,
                title: 'Amount',
                subtitle: 'Filter by transaction size',
              ),
              // Preset chips for quick tapping
              Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  _PresetChip(
                    label: '< ₹500',
                    onTap: () => _applyAmountPreset(null, 500),
                  ),
                  _PresetChip(
                    label: '₹500 – ₹2,000',
                    onTap: () => _applyAmountPreset(500, 2000),
                  ),
                  _PresetChip(
                    label: '₹2,000 – ₹10,000',
                    onTap: () => _applyAmountPreset(2000, 10000),
                  ),
                  _PresetChip(
                    label: '> ₹10,000',
                    onTap: () => _applyAmountPreset(10000, null),
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.sm),
              // Custom Dual Input Fields inside a comfortable row
              Row(
                children: [
                  Expanded(
                    child: FfTextField(
                      key: const ValueKey('filter-min-amount'),
                      controller: _minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: 'Min amount',
                      prefixText: '${CurrencyFormatter.currencySymbol} ',
                    ),
                  ),
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: FfTextField(
                      key: const ValueKey('filter-max-amount'),
                      controller: _maxController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: 'Max amount',
                      prefixText: '${CurrencyFormatter.currencySymbol} ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.lg),

              // ── 7. Payment Methods & Tags (if present) ───────────────────
              if (widget.paymentMethods.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment method',
                  subtitle: _query.paymentMethod ?? 'Any method',
                ),
                Wrap(
                  key: const ValueKey('filter-method'),
                  spacing: FfSpace.xs,
                  runSpacing: FfSpace.xs,
                  children: [
                    FfChip(
                      label: 'Any method',
                      isSelected: _query.paymentMethod == null,
                      onSelected: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () =>
                              _query = _query.copyWith(
                                clearPaymentMethod: true,
                              ),
                        );
                      },
                    ),
                    for (final m in widget.paymentMethods)
                      FfChip(
                        label: m,
                        isSelected: _query.paymentMethod == m,
                        onSelected: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () =>
                                _query = _query.copyWith(
                                  paymentMethod:
                                      _query.paymentMethod == m ? null : m,
                                  clearPaymentMethod: _query.paymentMethod == m,
                                ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: FfSpace.lg),
              ],

              if (widget.tags.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.tag_rounded,
                  title: 'Tag',
                  subtitle: _query.tag != null ? '#${_query.tag}' : 'Any tag',
                ),
                Wrap(
                  key: const ValueKey('filter-tag'),
                  spacing: FfSpace.xs,
                  runSpacing: FfSpace.xs,
                  children: [
                    FfChip(
                      label: 'Any tag',
                      isSelected: _query.tag == null,
                      onSelected: () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _query = _query.copyWith(clearTag: true),
                        );
                      },
                    ),
                    for (final t in widget.tags)
                      FfChip(
                        label: '#$t',
                        isSelected: _query.tag == t,
                        onSelected: () {
                          HapticFeedback.selectionClick();
                          setState(
                            () =>
                                _query = _query.copyWith(
                                  tag: _query.tag == t ? null : t,
                                  clearTag: _query.tag == t,
                                ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: FfSpace.lg),
              ],

              // ── 8. Sort Order ────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.sort_rounded,
                title: 'Sort',
                subtitle: _query.sort.label,
              ),
              Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  for (final sort in TransactionSort.values)
                    FfChip(
                      label: sort.label,
                      isSelected: _query.sort == sort,
                      onSelected: () {
                        HapticFeedback.selectionClick();
                        setState(() => _query = _query.copyWith(sort: sort));
                      },
                    ),
                ],
              ),
              const SizedBox(height: FfSpace.lg),

              // ── 9. Date Guidance Card ────────────────────────────────────
              FfCard(
                variant: FfCardVariant.tinted,
                tone: FfTone.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.md,
                  vertical: FfSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: ff.color.textSecondary,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Expanded(
                      child: Text(
                        'Dates are controlled via the period bar on the main screen.',
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FfSpace.md),
            ],
          ),
        ),

        // ── 10. Sheet Footer with Actions ────────────────────────────────
        FfSheetFooter(
          secondaryLabel: 'Reset',
          onSecondaryPressed: _resetAll,
          primaryLabel: 'Show results',
          onPrimaryPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(_withAmounts());
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting Bloom Components for Filter Sheet
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Padding(
      padding: const EdgeInsets.only(bottom: FfSpace.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: ff.color.textSecondary),
              const SizedBox(width: FfSpace.x3s),
              Text(
                title,
                style: ff.text.titleSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ff.color.textPrimary,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: ff.text.labelSm.copyWith(
                color: ff.color.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FfRadius.md),
        child: AnimatedContainer(
          duration: FfMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.md,
            vertical: FfSpace.sm,
          ),
          decoration: ShapeDecoration(
            color:
                isSelected
                    ? ff.color.actionPrimary
                    : ff.color.tint(ff.color.textPrimary, FfTint.faint),
            shape: FfShape.of(
              FfRadius.md,
              side: BorderSide(
                color:
                    isSelected
                        ? ff.color.actionPrimary
                        : ff.color.borderControl,
                width:
                    isSelected ? FfBorderWidth.strong : FfBorderWidth.regular,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    isSelected
                        ? ff.color.onActionPrimary
                        : ff.color.textSecondary,
              ),
              const SizedBox(width: FfSpace.xs),
              Text(
                label,
                style: ff.text.labelSm.copyWith(
                  color:
                      isSelected
                          ? ff.color.onActionPrimary
                          : ff.color.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String? iconIdentifier;
  final String? colorTokenIdentifier;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    this.iconIdentifier,
    this.colorTokenIdentifier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FfRadius.md),
        child: AnimatedContainer(
          duration: FfMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.sm,
            vertical: FfSpace.xs,
          ),
          decoration: ShapeDecoration(
            color:
                isSelected
                    ? ff.color.actionPrimary
                    : ff.color.tint(ff.color.textPrimary, FfTint.faint),
            shape: FfShape.of(
              FfRadius.md,
              side: BorderSide(
                color:
                    isSelected
                        ? ff.color.actionPrimary
                        : ff.color.borderControl,
                width:
                    isSelected ? FfBorderWidth.strong : FfBorderWidth.regular,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconIdentifier != null && colorTokenIdentifier != null)
                FfCategoryTile(
                  iconIdentifier: iconIdentifier!,
                  colorTokenIdentifier: colorTokenIdentifier!,
                  size: 20,
                )
              else
                Icon(
                  Icons.category_outlined,
                  size: 16,
                  color:
                      isSelected
                          ? ff.color.onActionPrimary
                          : ff.color.textSecondary,
                ),
              const SizedBox(width: FfSpace.xs),
              Text(
                label,
                style: ff.text.labelSm.copyWith(
                  color:
                      isSelected
                          ? ff.color.onActionPrimary
                          : ff.color.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.sm,
            vertical: FfSpace.x2s,
          ),
          decoration: ShapeDecoration(
            color: ff.color.tint(ff.color.textPrimary, FfTint.faint),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: ff.text.labelSm.copyWith(
              color: ff.color.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
