import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../services/ledger_totals.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_period_bar.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../settings/settings_controller.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_list_utils.dart';
import 'transactions_controller.dart';
import 'widgets/active_filter_chips.dart';
import 'widgets/pending_review_task_card.dart';
import 'widgets/transaction_day_header.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_list_summary.dart';
import 'widgets/transaction_tile.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_corner_badge.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../theme/ff.dart';

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
  static const _pageSize = 200;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  bool _isSearchOpen = false;
  int _visibleCount = _pageSize;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(transactionQueryProvider).search;
    _isSearchOpen = _searchController.text.isNotEmpty;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  TransactionQuery get _query => ref.read(transactionQueryProvider);

  void _setQuery(TransactionQuery query) {
    ref.read(transactionQueryProvider.notifier).state = query;
    if (_searchController.text != query.search) {
      _searchController.text = query.search;
    }
    setState(() {
      _visibleCount = _pageSize;
      _selected.clear();
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 600) return;
    final total = ref.read(filteredTransactionsProvider).value?.length ?? 0;
    if (_visibleCount < total) {
      setState(() => _visibleCount += _pageSize);
    }
  }

  void _openSearch() {
    setState(() => _isSearchOpen = true);
    _searchFocusNode.requestFocus();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    setState(() => _isSearchOpen = false);
    _setQuery(_query.copyWith(search: ''));
  }

  Future<void> _openFilters({
    required List<Category> categories,
    required List<Account> accounts,
  }) async {
    final all =
        ref.read(allTransactionsStreamProvider).value ?? const <Transaction>[];
    final tags = <String>{for (final t in all) ...t.tags}.toList()..sort();
    final methods =
        <String>{
            for (final t in all)
              if (t.paymentMethod?.trim().isNotEmpty ?? false)
                t.paymentMethod!.trim(),
          }.toList()
          ..sort();
    final result = await showTransactionFilterSheet(
      context,
      query: _query,
      categories: categories,
      accounts: accounts,
      tags: tags,
      paymentMethods: methods,
    );
    if (result != null) _setQuery(result);
  }

  Future<void> _edit(Transaction transaction) =>
      AddEditTransactionScreen.push<void>(
        context,
        initialTransaction: transaction,
      );

  Future<void> _deleteOne(Transaction transaction) async {
    await ref
        .read(transactionsControllerProvider.notifier)
        .deleteTransaction(transaction);
    if (!mounted) return;
    FfToast.show(
      context,
      message: 'Transaction deleted.',
      actionLabel: 'Undo',
      onAction:
          () => ref.read(transactionsControllerProvider.notifier).undoDelete(),
    );
  }

  void _toggle(Transaction tx) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.contains(tx.id)
          ? _selected.remove(tx.id)
          : _selected.add(tx.id);
    });
  }

  List<Transaction> _selectedTransactions(List<Transaction> items) =>
      items.where((t) => _selected.contains(t.id)).toList();

  Future<void> _deleteSelected(List<Transaction> items) async {
    final chosen = _selectedTransactions(items);
    if (chosen.isEmpty) return;
    final confirmed = await FfDialog.confirm(
      context,
      title:
          chosen.length == 1
              ? 'Delete 1 transaction?'
              : 'Delete ${chosen.length} transactions?',
      message:
          'Linked loan and debt records are updated too. You can undo right after.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(transactionsControllerProvider.notifier)
        .deleteTransactions(chosen);
    if (!mounted) return;
    setState(_selected.clear);
    FfToast.show(
      context,
      message:
          chosen.length == 1
              ? 'Transaction deleted.'
              : '${chosen.length} transactions deleted.',
      actionLabel: 'Undo',
      onAction:
          () => ref.read(transactionsControllerProvider.notifier).undoDelete(),
    );
  }

  Future<void> _recategorizeSelected(
    List<Transaction> items,
    List<Category> categories,
  ) async {
    final chosen = _selectedTransactions(items);
    if (chosen.isEmpty) return;
    final category = await showFfSheet<Category>(
      context,
      builder:
          (ctx) => FfSheet(
            children: [
              const FfSheetHeader(title: 'Move to category'),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final c in categories.where((c) => !c.isArchived))
                      FfRow(
                        title: c.name,
                        onTap: () => Navigator.of(ctx).pop(c),
                      ),
                  ],
                ),
              ),
            ],
          ),
    );
    if (category == null || !mounted) return;
    final changed = await ref
        .read(transactionsControllerProvider.notifier)
        .recategorize(chosen, category);
    if (!mounted) return;
    setState(_selected.clear);
    final skipped = chosen.length - changed;
    FfToast.show(
      context,
      message:
          skipped == 0
              ? 'Moved $changed to ${category.name}.'
              : 'Moved $changed to ${category.name}. $skipped skipped '
                  '(transfers, lending and loan payments keep their type).',
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(transactionQueryProvider);
    final results = ref.watch(filteredTransactionsProvider);
    final categories =
        ref.watch(categoriesStreamProvider).value ?? const <Category>[];
    final accounts =
        ref.watch(rawAccountsStreamProvider).value ?? const <Account>[];
    final privacyBlur =
        ref.watch(settingsStreamProvider).value?.isPrivacyBlurEnabled ?? false;
    final pendingCount = ref.watch(pendingReviewCountProvider);
    final isReviewSnoozed = ref.watch(reviewPromptSnoozedProvider);
    final items = results.value ?? const <Transaction>[];
    final selecting = _selected.isNotEmpty;

    // Other screens (Insights drill-down) can replace the query.
    ref.listen<TransactionQuery>(transactionQueryProvider, (prev, next) {
      if (_searchController.text != next.search) {
        _searchController.text = next.search;
      }
      if (prev != next &&
          (_selected.isNotEmpty || _visibleCount != _pageSize)) {
        setState(() {
          _selected.clear();
          _visibleCount = _pageSize;
        });
      }
    });

    ref.listen<int>(pendingReviewCountProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        ref.read(reviewPromptSnoozedProvider.notifier).state = false;
      }
    });

    return Scaffold(
      appBar:
          selecting
              ? _selectionAppBar(items, categories)
              : _isSearchOpen
              ? _searchAppBar()
              : _mainAppBar(
                query: query,
                categories: categories,
                accounts: accounts,
                pendingCount: pendingCount,
                showReviewBadge: pendingCount > 0 && isReviewSnoozed,
              ),
      floatingActionButton:
          selecting
              ? null
              : FloatingActionButton.extended(
                heroTag: 'transactions_add_transaction_fab',
                tooltip: 'Add transaction',
                onPressed: widget.onAddTransaction,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
      floatingActionButtonLocation: FfDock.fabLocation,
      body: Column(
        children: [
          if (pendingCount > 0 && !isReviewSnoozed && !selecting)
            PendingReviewTaskCard(
              count: pendingCount,
              onReviewNow: _openReviewQueue,
              onLater:
                  () =>
                      ref.read(reviewPromptSnoozedProvider.notifier).state =
                          true,
            ),
          Expanded(
            child: results.when(
              loading: () => const _TransactionsLoading(),
              error:
                  (err, _) => FfEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Transactions are unavailable',
                    description:
                        'Your data remains on this device. Try loading it again.',
                    actionLabel: 'Try again',
                    onAction:
                        () => ref.invalidate(filteredTransactionsProvider),
                  ),
              data:
                  (items) => _list(
                    query: query,
                    items: items,
                    accounts: accounts,
                    categories: categories,
                    privacyBlur: privacyBlur,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewQueue() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const NeedsReviewScreen()));

  PreferredSizeWidget _mainAppBar({
    required TransactionQuery query,
    required List<Category> categories,
    required List<Account> accounts,
    required int pendingCount,
    required bool showReviewBadge,
  }) {
    return FfAppBar(
      title: 'Transactions',
      actions: [
        if (showReviewBadge)
          IconButton(
            icon: Badge(
              label: Text('$pendingCount'),
              backgroundColor: context.ff.color.statusWarning,
              textColor: context.ff.color.surfaceCard,
              child: const Icon(Icons.pending_actions_rounded),
            ),
            tooltip: 'Review queue ($pendingCount pending)',
            onPressed: _openReviewQueue,
          ),
        FfCircleButton(
          icon: Icons.tune_rounded,
          tooltip: 'Filter & sort',
          soft: true,
          corner:
              query.hasRefinements || query.sort != TransactionSort.newest
                  ? FfCorner.dot
                  : null,
          onPressed:
              () => _openFilters(categories: categories, accounts: accounts),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(
            start: FfSpace.x2s,
            end: FfSpace.md,
          ),
          child: Center(
            child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
          ),
        ),
      ],
    );
  }

  /// Search pill and kind pills above the list. Tapping the pill opens the
  /// search bar; the kind pills set a single kind (or All).
  Widget _filterHeader(TransactionQuery query) {
    final ff = context.ff;
    final single = query.kinds.length == 1 ? query.kinds.first : null;
    void pick(TransactionKind? kind) =>
        _setQuery(query.copyWith(kinds: kind == null ? const {} : {kind}));
    const kinds = [
      TransactionKind.spending,
      TransactionKind.income,
      TransactionKind.transfer,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isSearchOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.xs,
              FfSpace.pageMargin,
              FfSpace.xs,
            ),
            child: Tooltip(
              message: 'Search transactions',
              excludeFromSemantics: true,
              child: Semantics(
                button: true,
                label: 'Search transactions',
                excludeSemantics: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: _openSearch,
                    customBorder: FfShape.of(FfRadius.full),
                    child: Container(
                      height: FfTouch.minTarget,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.md,
                      ),
                      decoration: ShapeDecoration(
                        shape: FfShape.of(
                          FfRadius.full,
                          side: BorderSide(
                            color: ff.color.borderControl,
                            width: FfBorderWidth.regular,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: FfIconSize.lg,
                            color: ff.color.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.sm),
                          Expanded(
                            child: Text(
                              'Search payee, note or amount',
                              style: ff.text.body.copyWith(
                                color: ff.color.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          child: Row(
            children: [
              FfChip(
                label: 'All',
                isSelected: query.kinds.isEmpty,
                onSelected: () => pick(null),
              ),
              for (final kind in kinds) ...[
                const SizedBox(width: FfPillTokens.gap),
                FfChip(
                  label: kind.label,
                  isSelected: single == kind,
                  onSelected: () => pick(single == kind ? null : kind),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// One day's rows (or the flat list) inside a compact Bloom card.
  Widget _card(Widget sliverList) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
    sliver: DecoratedSliver(
      decoration: FfCard.decorationOf(context, density: FfDensity.compact),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: FfSpace.x2s),
        sliver: sliverList,
      ),
    ),
  );

  PreferredSizeWidget _searchAppBar() {
    return FfAppBar.search(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hint: 'Search payee, note, amount, tag…',
      onClose: _closeSearch,
      onChanged: (text) {
        ref.read(transactionQueryProvider.notifier).state = _query.copyWith(
          search: text,
        );
        setState(() => _visibleCount = _pageSize);
      },
      onClear: () => _setQuery(_query.copyWith(search: '')),
    );
  }

  PreferredSizeWidget _selectionAppBar(
    List<Transaction> items,
    List<Category> categories,
  ) {
    final visible = items.take(_visibleCount);
    final allSelected = visible.every((t) => _selected.contains(t.id));
    return FfAppBar.selection(
      count: _selected.length,
      onCancel: () => setState(_selected.clear),
      actions: [
        IconButton(
          icon: Icon(
            allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
          ),
          tooltip: allSelected ? 'Clear selection' : 'Select all',
          onPressed:
              () => setState(() {
                if (allSelected) {
                  _selected.clear();
                } else {
                  _selected.addAll(visible.map((t) => t.id));
                }
              }),
        ),
        IconButton(
          icon: const Icon(Icons.category_outlined),
          tooltip: 'Change category',
          onPressed: () => _recategorizeSelected(items, categories),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete selected',
          onPressed: () => _deleteSelected(items),
        ),
      ],
    );
  }

  Widget _list({
    required TransactionQuery query,
    required List<Transaction> items,
    required List<Account> accounts,
    required List<Category> categories,
    required bool privacyBlur,
  }) {
    final visible = items.take(_visibleCount).toList();
    final selecting = _selected.isNotEmpty;

    Widget tile(Transaction tx, {required bool showDate}) => TransactionTile(
      transaction: tx,
      accounts: accounts,
      showDate: showDate,
      isPrivacyBlur: privacyBlur,
      selectionMode: selecting,
      isSelected: _selected.contains(tx.id),
      onToggleSelected: () => _toggle(tx),
      onOpen: () => widget.onOpenDetail(tx),
      onEdit: () => _edit(tx),
      onDelete: () => _deleteOne(tx),
    );

    return CustomScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (!selecting) SliverToBoxAdapter(child: _filterHeader(query)),
        SliverToBoxAdapter(
          child: FfPeriodBar(
            allowAllTime: true,
            period: query.period,
            onChanged:
                (p) => _setQuery(query.copyWith(period: p, allTime: p == null)),
          ),
        ),
        SliverToBoxAdapter(
          child: TransactionListSummary(
            totals: LedgerTotals.of(items),
            count: items.length,
            isPrivacyBlur: privacyBlur,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: FfSpace.xs),
            child: ActiveFilterChips(
              query: query,
              accounts: accounts,
              categories: categories,
              onChanged: (q) {
                if (!q.hasSearch && _isSearchOpen) {
                  setState(() => _isSearchOpen = false);
                }
                _setQuery(q);
              },
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _emptyState(query))
        else if (query.sort.isByDate)
          for (final group in groupTransactionsByDay(visible))
            SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TransactionDayHeaderDelegate(
                    label: dayLabel(group.day),
                    totals: group.totals,
                    isPrivacyBlur: privacyBlur,
                    background: context.ff.color.surfacePage,
                  ),
                ),
                _card(
                  SliverList.separated(
                    itemCount: group.transactions.length,
                    separatorBuilder: (_, __) => const FfDivider.inset(),
                    itemBuilder:
                        (_, i) => tile(group.transactions[i], showDate: false),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: FfSpace.sm)),
              ],
            )
        else
          _card(
            SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (_, __) => const FfDivider.inset(),
              itemBuilder: (_, i) => tile(visible[i], showDate: true),
            ),
          ),
        if (items.length > visible.length)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FfSpace.md),
              child: Center(
                child: Text(
                  'Showing ${visible.length} of ${items.length}',
                  style: context.ff.text.labelSm,
                ),
              ),
            ),
          ),
        // Room for the Add button so it never covers the last row.
        const SliverToBoxAdapter(child: SizedBox(height: 104)),
      ],
    );
  }

  Widget _emptyState(TransactionQuery query) {
    if (query.hasRefinements || query.hasSearch) {
      return FfEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching transactions',
        description:
            'Nothing in ${periodLabel(query.period)} matches these filters.',
        actionLabel: 'Clear filters',
        onAction: () {
          setState(() => _isSearchOpen = false);
          _setQuery(query.cleared());
        },
      );
    }
    if (query.period != null) {
      return FfEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Nothing in ${periodLabel(query.period)}',
        description: 'Add a transaction, or look at another period.',
        actionLabel: 'Add transaction',
        onAction: widget.onAddTransaction,
      );
    }
    return FfEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      description:
          'Add your first transaction to start a private, local record.',
      actionLabel: 'Add transaction',
      onAction: widget.onAddTransaction,
    );
  }
}

class _TransactionsLoading extends StatelessWidget {
  const _TransactionsLoading();

  @override
  Widget build(BuildContext context) {
    return FfSkeletonLoader(
      child: ListView.separated(
        padding: const EdgeInsets.all(FfSpace.lg),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: FfSpace.md),
        itemBuilder:
            (_, __) => const Row(
              children: [
                FfSkeletonBlock(width: 42, height: 42, borderRadius: 12),
                SizedBox(width: FfSpace.md),
                Expanded(child: FfSkeletonBlock(height: 14)),
                SizedBox(width: FfSpace.lg),
                FfSkeletonBlock(width: 64, height: 14),
              ],
            ),
      ),
    );
  }
}
