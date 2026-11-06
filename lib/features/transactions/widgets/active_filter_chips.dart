import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/account.dart';
import '../../../models/category.dart';
import '../../../theme/ff.dart';
import '../transaction_list_utils.dart';

/// One removable chip per active filter, plus "Clear all". Renders nothing
/// when no filter is active. Styled with Stillwater Bloom tokens.
class ActiveFilterChips extends StatelessWidget {
  final TransactionQuery query;
  final List<Account> accounts;
  final List<Category> categories;
  final ValueChanged<TransactionQuery> onChanged;

  const ActiveFilterChips({
    super.key,
    required this.query,
    required this.accounts,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final chips = <({String label, TransactionQuery without})>[];
    if (query.hasSearch) {
      chips.add((
        label: '“${query.search.trim()}”',
        without: query.copyWith(search: ''),
      ));
    }
    for (final kind in query.kinds) {
      chips.add((
        label: kind.label,
        without: query.copyWith(kinds: {...query.kinds}..remove(kind)),
      ));
    }
    if (query.accountId != null) {
      final name =
          accounts.where((a) => a.id == query.accountId).firstOrNull?.name ??
          'Account';
      chips.add((label: name, without: query.copyWith(clearAccount: true)));
    }
    if (query.budgetScope != null) {
      chips.add((
        label: query.budgetScope!.label,
        without: query.copyWith(clearBudgetScope: true),
      ));
    }
    if (query.categoryId != null) {
      final name =
          categories.where((c) => c.id == query.categoryId).firstOrNull?.name ??
          'Category';
      chips.add((label: name, without: query.copyWith(clearCategory: true)));
    }
    if (query.minAmount != null || query.maxAmount != null) {
      final lo = query.minAmount;
      final hi = query.maxAmount;
      final label =
          lo != null && hi != null
              ? '${CurrencyFormatter.formatAmount(lo)}–${CurrencyFormatter.formatAmount(hi)}'
              : lo != null
              ? '≥ ${CurrencyFormatter.formatAmount(lo)}'
              : '≤ ${CurrencyFormatter.formatAmount(hi!)}';
      chips.add((label: label, without: query.copyWith(clearAmount: true)));
    }
    if (query.paymentMethod != null) {
      chips.add((
        label: query.paymentMethod!,
        without: query.copyWith(clearPaymentMethod: true),
      ));
    }
    if (query.tag != null) {
      chips.add((
        label: '#${query.tag}',
        without: query.copyWith(clearTag: true),
      ));
    }
    if (query.sort != TransactionSort.newest) {
      chips.add((
        label: query.sort.label,
        without: query.copyWith(sort: TransactionSort.newest),
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: FfSpace.xs),
              child: InputChip(
                label: Text(chip.label),
                labelStyle: ff.text.labelSm.copyWith(
                  color: ff.color.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: ff.color.tint(
                  ff.color.textPrimary,
                  FfTint.faint,
                ),
                side: BorderSide(
                  color: ff.color.borderControl,
                  width: FfBorderWidth.regular,
                ),
                shape: const StadiumBorder(),
                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                deleteIconColor: ff.color.textSecondary,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: FfSpace.x2s),
                onDeleted: () => onChanged(chip.without),
                deleteButtonTooltipMessage: 'Remove filter',
              ),
            ),
          Center(
            child: TextButton.icon(
              key: const ValueKey('clear-all-filters'),
              onPressed:
                  () => onChanged(
                    query.cleared().copyWith(sort: TransactionSort.newest),
                  ),
              icon: Icon(
                Icons.clear_all_rounded,
                size: 14,
                color: ff.color.actionPrimary,
              ),
              label: Text(
                'Clear all',
                style: ff.text.labelSm.copyWith(
                  color: ff.color.actionPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: FfSpace.xs),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
