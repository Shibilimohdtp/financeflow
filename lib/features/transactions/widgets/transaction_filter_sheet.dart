import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_sheet_footer.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../transaction_list_utils.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../shared/widgets/ff_select.dart';
import '../../../theme/ff.dart';

/// Edits every filter except the period (period bar) and search (app bar).
/// Returns the new query, or null when dismissed.
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
    final activeCategories =
        widget.categories.where((c) => !c.isArchived).toList();
    final activeAccounts = widget.accounts.where((a) => !a.isArchived).toList();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FfSheetHeader(title: 'Filter & sort'),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
            children: [
              const _Label('Show'),
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
              const _Label('Account'),
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
              const _Label('Category'),
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
              const _Label('Amount'),
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
              if (widget.paymentMethods.isNotEmpty) ...[
                const _Label('Payment method'),
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
              ],
              if (widget.tags.isNotEmpty) ...[
                const _Label('Tag'),
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
              ],
              const _Label('Sort'),
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
              Text(
                'Use the period bar to change dates.',
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.textSecondary,
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: FfSpace.md, bottom: FfSpace.xs),
      child: Text(
        text,
        style: context.ff.text.labelLg.copyWith(fontWeight: FontWeight.w600),
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
