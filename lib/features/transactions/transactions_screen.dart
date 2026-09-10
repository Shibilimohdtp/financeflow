import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../settings/settings_controller.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_list_utils.dart';
import 'transactions_controller.dart';
import 'widgets/pending_review_task_card.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final ValueChanged<Transaction> onOpenDetail;
  final VoidCallback onAddTransaction;

  const TransactionsScreen({
    super.key,
    required this.onOpenDetail,
    required this.onAddTransaction,
  });

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearchOpen = true;
    });
    _searchFocusNode.requestFocus();
  }

  void _closeSearch() {
    _searchController.clear();
    ref.read(transactionFilterProvider.notifier).state = ref
        .read(transactionFilterProvider)
        .copyWith(searchQuery: '');
    setState(() {
      _isSearchOpen = false;
    });
    _searchFocusNode.unfocus();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(transactionFilterProvider.notifier).state =
        const TransactionFilterState();
    if (_isSearchOpen) {
      setState(() {
        _isSearchOpen = false;
      });
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _edit(Transaction transaction) =>
      AddEditTransactionScreen.push<void>(
        context,
        initialTransaction: transaction,
      );

  Future<void> _delete(Transaction transaction) async {
    await ref
        .read(transactionsControllerProvider.notifier)
        .deleteTransaction(transaction);
    if (!mounted) return;
    FfSnackbar.show(
      context,
      message: 'Transaction deleted.',
      actionLabel: 'Undo',
      onAction:
          () => ref.read(transactionsControllerProvider.notifier).undoDelete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final transactions = ref.watch(filteredTransactionsProvider);
    final availableTransactions = transactions.value ?? const <Transaction>[];
    final categories =
        ref.watch(categoriesStreamProvider).value ?? const <Category>[];
    final accounts =
        ref.watch(rawAccountsStreamProvider).value ?? const <Account>[];
    final privacyBlur =
        ref.watch(settingsStreamProvider).value?.isPrivacyBlurEnabled ?? false;
    final pendingCount = ref.watch(pendingReviewCountProvider);
    final isReviewSnoozed = ref.watch(reviewPromptSnoozedProvider);

    ref.listen<int>(pendingReviewCountProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        ref.read(reviewPromptSnoozedProvider.notifier).state = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading:
            _isSearchOpen
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Close search',
                  onPressed: _closeSearch,
                )
                : null,
        title:
            _isSearchOpen
                ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (query) {
                    setState(() {});
                    notifier.state = filter.copyWith(searchQuery: query);
                  },
                )
                : const Text('Transactions'),
        actions:
            _isSearchOpen
                ? [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: 'Clear search text',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        notifier.state = filter.copyWith(searchQuery: '');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Dismiss search',
                    onPressed: _closeSearch,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                ]
                : [
                  if (pendingCount > 0 && isReviewSnoozed)
                    IconButton(
                      icon: Badge(
                        label: Text('$pendingCount'),
                        backgroundColor: context.statusColors.warning,
                        textColor: context.theme.colorScheme.surface,
                        child: const Icon(Icons.pending_actions_rounded),
                      ),
                      tooltip: 'Review queue ($pendingCount pending)',
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NeedsReviewScreen(),
                            ),
                          ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Search transactions',
                    onPressed: _openSearch,
                  ),
                  IconButton(
                    icon:
                        filter.hasActiveFilters
                            ? Badge(
                              smallSize: 8,
                              backgroundColor:
                                  context.theme.colorScheme.primary,
                              child: const Icon(Icons.tune_rounded),
                            )
                            : const Icon(Icons.tune_rounded),
                    tooltip: 'Filter & sort',
                    onPressed:
                        () => _showFilterSheet(
                          context,
                          filter: filter,
                          categories: categories,
                          accounts: accounts,
                          transactions: availableTransactions,
                        ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
                    child: Center(
                      child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
                    ),
                  ),
                ],
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add transaction',
        child: FloatingActionButton.extended(
          heroTag: 'transactions_add_transaction_fab',
          tooltip: 'Add transaction',
          onPressed: widget.onAddTransaction,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
        ),
      ),
      body: Column(
        children: [
          if (filter.hasActiveFilters)
            _ActiveFilters(
              filter: filter,
              categories: categories,
              accounts: accounts,
              onClear: _clearFilters,
            ),
          if (pendingCount > 0 && !isReviewSnoozed)
            PendingReviewTaskCard(
              count: pendingCount,
              onReviewNow:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NeedsReviewScreen(),
                    ),
                  ),
              onLater: () {
                ref.read(reviewPromptSnoozedProvider.notifier).state = true;
              },
            ),
          Expanded(
            child: transactions.when(
              loading: () => const _TransactionsLoading(),
              error:
                  (err, _) => FfEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Transactions are unavailable',
                    description:
                        'Your data remains on this device. Try loading it again: $err',
                    actionLabel: 'Try again',
                    onAction:
                        () => ref.invalidate(filteredTransactionsProvider),
                  ),
              data: (items) {
                if (items.isEmpty) {
                  final isSearching = filter.searchQuery.trim().isNotEmpty;
                  return FfEmptyState(
                    icon:
                        isSearching
                            ? Icons.search_off_rounded
                            : Icons.receipt_long_outlined,
                    title:
                        filter.hasActiveFilters
                            ? 'No matching transactions'
                            : 'No transactions yet',
                    description:
                        filter.hasActiveFilters
                            ? 'Try another search or remove a filter.'
                            : 'Add your first transaction to start a private, local record.',
                    actionLabel:
                        filter.hasActiveFilters
                            ? 'Clear filters'
                            : 'Add transaction',
                    onAction:
                        filter.hasActiveFilters
                            ? _clearFilters
                            : widget.onAddTransaction,
                  );
                }
                final summary = calculateTransactionListSummary(items);
                final groups = groupTransactionsForList(items);
                return CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _CashFlowSummary(
                        summary: summary,
                        isPrivacyBlur: privacyBlur,
                      ),
                    ),
                    for (final group in groups) ...[
                      SliverToBoxAdapter(child: _GroupHeader(group: group)),
                      SliverList.separated(
                        itemCount: group.transactions.length,
                        separatorBuilder:
                            (_, __) => const Divider(indent: 72, height: 1),
                        itemBuilder:
                            (context, index) => _TransactionRow(
                              transaction: group.transactions[index],
                              accounts: accounts,
                              showDate: group.showDateInRows,
                              isPrivacyBlur: privacyBlur,
                              onOpen:
                                  () => widget.onOpenDetail(
                                    group.transactions[index],
                                  ),
                              onEdit: () => _edit(group.transactions[index]),
                              onDelete:
                                  () => _delete(group.transactions[index]),
                            ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 104)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context, {
    required TransactionFilterState filter,
    required List<Category> categories,
    required List<Account> accounts,
    required List<Transaction> transactions,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => _TransactionFilterSheet(
            initialFilter: filter,
            categories: categories,
            accounts: accounts,
            transactions: transactions,
            onApply: (applied) {
              ref.read(transactionFilterProvider.notifier).state = applied;
            },
          ),
    );
  }
}

class _TransactionFilterSheet extends StatefulWidget {
  final TransactionFilterState initialFilter;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Transaction> transactions;
  final ValueChanged<TransactionFilterState> onApply;

  const _TransactionFilterSheet({
    required this.initialFilter,
    required this.categories,
    required this.accounts,
    required this.transactions,
    required this.onApply,
  });

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  late TransactionFilterState _draft;
  late final List<String> _methods;
  late final List<String> _tags;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
    _methods =
        widget.transactions
            .map((t) => t.paymentMethod)
            .whereType<String>()
            .where((m) => m.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    _tags = widget.transactions.expand((t) => t.tags).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfSheetHeader(
                title: 'Filter & sort',
                subtitle: 'Refine transactions on device',
              ),
              const Divider(height: 1, thickness: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                    StillwaterTokens.spaceLg,
                    StillwaterTokens.spaceMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Transaction Type',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      Wrap(
                        spacing: StillwaterTokens.spaceXs,
                        runSpacing: StillwaterTokens.spaceXs,
                        children: [
                          FfChip(
                            label: 'All',
                            isSelected: _draft.selectedType == null,
                            onSelected:
                                () => setState(
                                  () =>
                                      _draft = _draft.copyWith(clearType: true),
                                ),
                          ),
                          FfChip(
                            label: 'Expenses',
                            isSelected:
                                _draft.selectedType == TransactionType.expense,
                            onSelected:
                                () => setState(
                                  () =>
                                      _draft = _draft.copyWith(
                                        selectedType: TransactionType.expense,
                                      ),
                                ),
                          ),
                          FfChip(
                            label: 'Income',
                            isSelected:
                                _draft.selectedType == TransactionType.income,
                            onSelected:
                                () => setState(
                                  () =>
                                      _draft = _draft.copyWith(
                                        selectedType: TransactionType.income,
                                      ),
                                ),
                          ),
                          FfChip(
                            label: 'Transfers',
                            isSelected:
                                _draft.selectedType == TransactionType.transfer,
                            onSelected:
                                () => setState(
                                  () =>
                                      _draft = _draft.copyWith(
                                        selectedType: TransactionType.transfer,
                                      ),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                      _FilterDropdown<String>(
                        label: 'Category',
                        value: _draft.selectedCategoryId,
                        noneLabel: 'All categories',
                        entries: {
                          for (final category in widget.categories)
                            category.id: category.name,
                        },
                        onChanged:
                            (value) => setState(
                              () =>
                                  _draft = _draft.copyWith(
                                    selectedCategoryId: value,
                                    clearCategory: value == null,
                                  ),
                            ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      _FilterDropdown<String>(
                        label: 'Account',
                        value: _draft.selectedAccountId,
                        noneLabel: 'All accounts',
                        entries: {
                          for (final account in widget.accounts)
                            account.id: account.name,
                        },
                        onChanged:
                            (value) => setState(
                              () =>
                                  _draft = _draft.copyWith(
                                    selectedAccountId: value,
                                    clearAccount: value == null,
                                  ),
                            ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      _FilterDropdown<String>(
                        label: 'Payment method',
                        value: _draft.paymentMethod,
                        noneLabel: 'Any payment method',
                        entries: {
                          for (final method in _methods) method: method,
                        },
                        onChanged:
                            (value) => setState(
                              () =>
                                  _draft = _draft.copyWith(
                                    paymentMethod: value,
                                    clearPaymentMethod: value == null,
                                  ),
                            ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      _FilterDropdown<String>(
                        label: 'Tag',
                        value: _draft.tag,
                        noneLabel: 'Any tag',
                        entries: {for (final tag in _tags) tag: tag},
                        onChanged:
                            (value) => setState(
                              () =>
                                  _draft = _draft.copyWith(
                                    tag: value,
                                    clearTag: value == null,
                                  ),
                            ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      _FilterDropdown<TransactionSort>(
                        label: 'Sort by',
                        value: _draft.sort,
                        entries: {
                          for (final sort in TransactionSort.values)
                            sort: sort.label,
                        },
                        onChanged:
                            (value) => setState(
                              () => _draft = _draft.copyWith(sort: value),
                            ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                      FfButton(
                        label:
                            _draft.startDate == null
                                ? 'Choose date range'
                                : '${DateFormatter.formatShortDate(_draft.startDate!)} – ${DateFormatter.formatShortDate(_draft.endDate!)}',
                        variant: FfButtonVariant.outlined,
                        leadingIcon: const Icon(
                          Icons.date_range_outlined,
                          size: 18,
                        ),
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            initialDateRange:
                                _draft.startDate == null ||
                                        _draft.endDate == null
                                    ? null
                                    : DateTimeRange(
                                      start: _draft.startDate!,
                                      end: _draft.endDate!,
                                    ),
                          );
                          if (range != null) {
                            setState(
                              () =>
                                  _draft = _draft.copyWith(
                                    startDate: range.start,
                                    endDate: range.end,
                                  ),
                            );
                          }
                        },
                      ),
                      if (_draft.startDate != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed:
                                () => setState(
                                  () =>
                                      _draft = _draft.copyWith(
                                        clearDates: true,
                                      ),
                                ),
                            child: const Text('Clear date range'),
                          ),
                        ),
                      const SizedBox(height: StillwaterTokens.spaceMd),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              FfSheetFooter(
                child: Row(
                  children: [
                    FfButton(
                      label: 'Reset',
                      variant: FfButtonVariant.text,
                      onPressed:
                          () => setState(
                            () => _draft = const TransactionFilterState(),
                          ),
                    ),
                    const Spacer(),
                    FfButton(
                      label: 'Show transactions',
                      variant: FfButtonVariant.primary,
                      onPressed: () {
                        widget.onApply(_draft);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.entries,
    required this.onChanged,
    this.value,
    this.noneLabel,
  });
  final String label;
  final T? value;
  final String? noneLabel;
  final Map<T, String> entries;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    value: entries.containsKey(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    hint: noneLabel != null ? Text(noneLabel!) : null,
    items: [
      if (noneLabel != null)
        DropdownMenuItem<T>(
          value: null,
          child: Text(noneLabel!, overflow: TextOverflow.ellipsis),
        ),
      ...entries.entries.map(
        (entry) => DropdownMenuItem<T>(
          value: entry.key,
          child: Text(entry.value, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
    onChanged: onChanged,
  );
}

class _CashFlowSummary extends StatelessWidget {
  final TransactionListSummary summary;
  final bool isPrivacyBlur;

  const _CashFlowSummary({required this.summary, this.isPrivacyBlur = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceXs,
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceMd,
      ),
      child: FfCard(
        variant: FfCardVariant.elevated,
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        child: Row(
          children: [
            _SummaryValue(
              label: 'Income',
              value: summary.income,
              positive: true,
              isPrivacyBlur: isPrivacyBlur,
            ),
            Container(width: 1, height: 36, color: context.theme.dividerColor),
            _SummaryValue(
              label: 'Expenses',
              value: summary.expenses,
              positive: false,
              isPrivacyBlur: isPrivacyBlur,
            ),
            Container(width: 1, height: 36, color: context.theme.dividerColor),
            _SummaryValue(
              label: 'Net',
              value: summary.net,
              positive: summary.net >= 0,
              isPrivacyBlur: isPrivacyBlur,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final double value;
  final bool positive;
  final bool isPrivacyBlur;

  const _SummaryValue({
    required this.label,
    required this.value,
    required this.positive,
    this.isPrivacyBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceXs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: StillwaterTokens.space2Xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child:
                  isPrivacyBlur
                      ? Text('₹ ••••••', style: StillwaterTypography.numMd())
                      : Text(
                        CurrencyFormatter.format(
                          value,
                          showSign: label == 'Net',
                          isIncome: positive,
                          isExpense: !positive,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StillwaterTypography.numMd(
                          color:
                              positive ? finColors.income : finColors.expense,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final TransactionDateGroup group;

  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final finColors = context.finColors;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceMd,
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceXs,
      ),
      child: Row(
        children: [
          Text(
            group.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.format(
              group.net,
              showSign: true,
              isIncome: group.net >= 0,
              isExpense: group.net < 0,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: group.net >= 0 ? finColors.income : finColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final List<Account> accounts;
  final bool showDate;
  final bool isPrivacyBlur;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _TransactionRow({
    required this.transaction,
    required this.accounts,
    required this.showDate,
    required this.isPrivacyBlur,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final account =
        accounts.where((item) => item.id == transaction.accountId).firstOrNull;
    final metadata = [
      if (showDate) DateFormatter.formatShortDate(transaction.date),
      if (!showDate)
        DateFormatter.formatTransactionDate(transaction.date).split(', ').last,
      if (account != null) account.name,
      if (transaction.paymentMethod?.isNotEmpty ?? false)
        transaction.paymentMethod!,
      if (transaction.tags.isNotEmpty) '#${transaction.tags.first}',
    ].join(' · ');

    return Dismissible(
      key: ValueKey('transaction-${transaction.id}'),
      direction: DismissDirection.horizontal,
      background: _SwipeBackground(
        icon: Icons.edit_outlined,
        label: 'Edit',
        alignment: Alignment.centerLeft,
        color: context.theme.colorScheme.primary,
      ),
      secondaryBackground: _SwipeBackground(
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
        color: context.theme.colorScheme.error,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        await onDelete();
        return true;
      },
      child: Semantics(
        button: true,
        label:
            '${transaction.merchant}, ${transaction.type.displayName}, ${CurrencyFormatter.format(transaction.amount)}',
        child: ListTile(
          minVerticalPadding: StillwaterTokens.spaceXs,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceLg,
          ),
          leading: FfCategoryTile(
            iconIdentifier: transaction.categoryIcon,
            colorTokenIdentifier: transaction.categoryColor,
            size: 40,
          ),
          title: Text(
            transaction.merchant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            metadata,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.secondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfAmountText(
                amount: transaction.amount,
                type: transaction.type,
                size: FfAmountSize.md,
                isBlurred: isPrivacyBlur,
                showSign: true,
              ),
              PopupMenuButton<String>(
                tooltip: 'Transaction actions',
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: context.theme.colorScheme.secondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder:
                    (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: StillwaterTokens.spaceSm),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: context.theme.colorScheme.error,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: context.theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          onTap: onOpen,
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final IconData icon;
  final String label;
  final Alignment alignment;
  final Color color;

  const _SwipeBackground({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: context.theme.colorScheme.onPrimary),
        const SizedBox(width: StillwaterTokens.spaceXs),
        Text(
          label,
          style: TextStyle(color: context.theme.colorScheme.onPrimary),
        ),
      ],
    ),
  );
}

class _ActiveFilters extends StatelessWidget {
  final TransactionFilterState filter;
  final List<Category> categories;
  final List<Account> accounts;
  final VoidCallback onClear;

  const _ActiveFilters({
    required this.filter,
    required this.categories,
    required this.accounts,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (filter.selectedType != null) filter.selectedType!.displayName,
      if (filter.selectedCategoryId != null)
        categories
                .where((category) => category.id == filter.selectedCategoryId)
                .firstOrNull
                ?.name ??
            'Category',
      if (filter.selectedAccountId != null)
        accounts
                .where((account) => account.id == filter.selectedAccountId)
                .firstOrNull
                ?.name ??
            'Account',
      if (filter.paymentMethod != null) filter.paymentMethod!,
      if (filter.tag != null) '#${filter.tag}',
      if (filter.startDate != null) 'Date range',
      if (filter.sort != TransactionSort.newest) filter.sort.label,
    ];
    if (labels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: StillwaterTokens.spaceXs),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: StillwaterTokens.spaceLg),
          children: [
            for (final label in labels)
              Padding(
                padding: const EdgeInsets.only(right: StillwaterTokens.spaceXs),
                child: Chip(
                  label: Text(label),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            TextButton(onPressed: onClear, child: const Text('Clear all')),
          ],
        ),
      ),
    );
  }
}

class _TransactionsLoading extends StatelessWidget {
  const _TransactionsLoading();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
    child: const FfSkeletonLoader(
      child: Column(
        children: [
          FfSkeletonBlock(height: 72, borderRadius: StillwaterTokens.radiusMd),
          SizedBox(height: StillwaterTokens.spaceSm),
          FfSkeletonBlock(height: 72, borderRadius: StillwaterTokens.radiusMd),
          SizedBox(height: StillwaterTokens.spaceSm),
          FfSkeletonBlock(height: 72, borderRadius: StillwaterTokens.radiusMd),
          SizedBox(height: StillwaterTokens.spaceSm),
          FfSkeletonBlock(height: 72, borderRadius: StillwaterTokens.radiusMd),
        ],
      ),
    ),
  );
}
