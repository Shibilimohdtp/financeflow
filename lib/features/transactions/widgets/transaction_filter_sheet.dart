import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_select.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_footer.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../transaction_list_utils.dart';

/// Edits every filter except the period (period bar) and search (app bar).
/// Redesigned in Stillwater Bloom: Pattern E sheet with tactile cards and chips.
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

  void _toggleKind(TransactionKind kind) {
    final kinds = {..._query.kinds};
    kinds.contains(kind) ? kinds.remove(kind) : kinds.add(kind);
    setState(() => _query = _query.copyWith(kinds: kinds));
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

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final activeCategories =
        widget.categories.where((c) => !c.isArchived).toList();
    final activeAccounts = widget.accounts.where((a) => !a.isArchived).toList();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              // 1. Transaction Type Section
              const _SectionLabel(icon: Icons.swap_vert_rounded, title: 'Show'),
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
              const SizedBox(height: FfSpace.md),

              // 2. Account & Category Section
              const _SectionLabel(
                icon: Icons.account_balance_outlined,
                title: 'Account',
              ),
              _Dropdown<String>(
                keyName: 'filter-account',
                value: _query.accountId,
                allLabel: 'All accounts',
                items: {for (final a in activeAccounts) a.id: a.name},
                onChanged:
                    (v) => setState(
                      () =>
                          _query = _query.copyWith(
                            accountId: v,
                            clearAccount: v == null,
                          ),
                    ),
              ),
              const SizedBox(height: FfSpace.sm),

              const _SectionLabel(
                icon: Icons.category_outlined,
                title: 'Category',
              ),
              _Dropdown<String>(
                keyName: 'filter-category',
                value: _query.categoryId,
                allLabel: 'All categories',
                items: {for (final c in activeCategories) c.id: c.name},
                onChanged:
                    (v) => setState(
                      () =>
                          _query = _query.copyWith(
                            categoryId: v,
                            clearCategory: v == null,
                          ),
                    ),
              ),
              const SizedBox(height: FfSpace.md),

              // 3. Amount Range Section
              const _SectionLabel(
                icon: Icons.payments_outlined,
                title: 'Amount',
              ),
              Row(
                children: [
                  Expanded(
                    child: FfTextField(
                      key: const ValueKey('filter-min-amount'),
                      controller: _minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      label: 'Min',
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
                      label: 'Max',
                      prefixText: '${CurrencyFormatter.currencySymbol} ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FfSpace.md),

              // 4. Payment Method & Tag Filters (if available)
              if (widget.paymentMethods.isNotEmpty) ...[
                const _SectionLabel(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment method',
                ),
                _Dropdown<String>(
                  keyName: 'filter-method',
                  value: _query.paymentMethod,
                  allLabel: 'Any method',
                  items: {for (final m in widget.paymentMethods) m: m},
                  onChanged:
                      (v) => setState(
                        () =>
                            _query = _query.copyWith(
                              paymentMethod: v,
                              clearPaymentMethod: v == null,
                            ),
                      ),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              if (widget.tags.isNotEmpty) ...[
                const _SectionLabel(icon: Icons.tag_rounded, title: 'Tag'),
                _Dropdown<String>(
                  keyName: 'filter-tag',
                  value: _query.tag,
                  allLabel: 'Any tag',
                  items: {for (final t in widget.tags) t: '#$t'},
                  onChanged:
                      (v) => setState(
                        () =>
                            _query = _query.copyWith(
                              tag: v,
                              clearTag: v == null,
                            ),
                      ),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              // 5. Sort Order Section
              const _SectionLabel(icon: Icons.sort_rounded, title: 'Sort'),
              Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  for (final sort in TransactionSort.values)
                    FfChip(
                      label: sort.label,
                      isSelected: _query.sort == sort,
                      onSelected:
                          () => setState(
                            () => _query = _query.copyWith(sort: sort),
                          ),
                    ),
                ],
              ),
              const SizedBox(height: FfSpace.lg),

              // Date change tip card
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
                      Icons.info_outline_rounded,
                      size: 16,
                      color: ff.color.textSecondary,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Expanded(
                      child: Text(
                        'Use the period bar to change dates.',
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
        FfSheetFooter(
          secondaryLabel: 'Reset',
          onSecondaryPressed: () {
            _minController.clear();
            _maxController.clear();
            setState(
              () =>
                  _query = TransactionQuery(
                    period: _query.period,
                    search: _query.search,
                  ),
            );
          },
          primaryLabel: 'Show results',
          onPrimaryPressed: () => Navigator.of(context).pop(_withAmounts()),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Padding(
      padding: const EdgeInsets.only(top: FfSpace.xs, bottom: FfSpace.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: ff.color.textSecondary),
          const SizedBox(width: FfSpace.x3s),
          Text(
            title,
            style: ff.text.labelSm.copyWith(
              fontWeight: FontWeight.w600,
              color: ff.color.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String keyName;
  final T? value;
  final String allLabel;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.keyName,
    required this.value,
    required this.allLabel,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // A filter that points at an archived/deleted entry still shows a value.
    final effective = items.containsKey(value) ? value : null;
    return FfSelect<T?>(
      key: ValueKey(keyName),
      value: effective,
      items: [
        DropdownMenuItem<T?>(value: null, child: Text(allLabel)),
        for (final entry in items.entries)
          DropdownMenuItem<T?>(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
