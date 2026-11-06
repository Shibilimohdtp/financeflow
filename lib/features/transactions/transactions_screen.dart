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
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
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

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _TransactionsHeader(
          selecting: selecting,
          isSearchOpen: _isSearchOpen,
          query: query,
          categories: categories,
          accounts: accounts,
          items: items,
          selected: _selected,
          visibleCount: _visibleCount,
          pendingCount: pendingCount,
          showReviewBadge: pendingCount > 0 && isReviewSnoozed,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          onOpenSearch: _openSearch,
          onCloseSearch: _closeSearch,
          onSearchChanged: (text) {
            ref.read(transactionQueryProvider.notifier).state = _query.copyWith(
              search: text,
            );
            setState(() => _visibleCount = _pageSize);
          },
          onSearchClear: () => _setQuery(_query.copyWith(search: '')),
          onOpenFilters:
              () => _openFilters(categories: categories, accounts: accounts),
          onOpenReviewQueue: _openReviewQueue,
          onCancelSelection: () => setState(_selected.clear),
          onToggleSelectAll: () {
            final visible = items.take(_visibleCount);
            final allSelected = visible.every((t) => _selected.contains(t.id));
            setState(() {
              if (allSelected) {
                _selected.clear();
              } else {
                _selected.addAll(visible.map((t) => t.id));
              }
            });
          },
          onRecategorizeSelected:
              () => _recategorizeSelected(items, categories),
          onDeleteSelected: () => _deleteSelected(items),
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
      ),
    );
  }

  void _openReviewQueue() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const NeedsReviewScreen()));

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
        SliverToBoxAdapter(child: SizedBox(height: FfDock.insetOf(context))),
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

/// The top bar of Transactions in Stillwater Bloom, seamlessly floating on
/// [FfAurora] without any solid app bar background. Smoothly transitions
/// between the default header, the dynamic search capsule, and selection mode.
class _TransactionsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _TransactionsHeader({
    required this.selecting,
    required this.isSearchOpen,
    required this.query,
    required this.categories,
    required this.accounts,
    required this.items,
    required this.selected,
    required this.visibleCount,
    required this.pendingCount,
    required this.showReviewBadge,
    required this.searchController,
    required this.searchFocusNode,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onOpenFilters,
    required this.onOpenReviewQueue,
    required this.onCancelSelection,
    required this.onToggleSelectAll,
    required this.onRecategorizeSelected,
    required this.onDeleteSelected,
  });

  final bool selecting;
  final bool isSearchOpen;
  final TransactionQuery query;
  final List<Category> categories;
  final List<Account> accounts;
  final List<Transaction> items;
  final Set<String> selected;
  final int visibleCount;
  final int pendingCount;
  final bool showReviewBadge;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenReviewQueue;
  final VoidCallback onCancelSelection;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onRecategorizeSelected;
  final VoidCallback onDeleteSelected;

  @override
  Size get preferredSize =>
      const Size.fromHeight(FfTouch.minTarget + FfSpace.md);

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: FfSpace.pageMargin,
            end:
                FfSpace.pageMargin -
                (FfTouch.minTarget - FfRoundButtonTokens.size) / 2,
            top: FfSpace.xs,
            bottom: FfSpace.x2s,
          ),
          child: SizedBox(
            height: FfTouch.minTarget,
            child: AnimatedSwitcher(
              duration: FfMotion.fast,
              child:
                  selecting
                      ? _buildSelection(context, ff)
                      : isSearchOpen
                      ? _buildSearch(context, ff)
                      : _buildNormal(context, ff),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormal(BuildContext context, FfThemeData ff) {
    return Row(
      key: const ValueKey('transactions_header_normal'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Transactions',
            style: ff.text.headlineSm.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const FfPrivacyBadge(label: 'On-device', iconOnly: true),
        const SizedBox(width: FfSpace.xs),
        if (showReviewBadge) ...[
          IconButton(
            icon: Badge(
              label: Text('$pendingCount'),
              backgroundColor: ff.color.statusWarning,
              textColor: ff.color.surfaceCard,
              child: const Icon(Icons.pending_actions_rounded),
            ),
            tooltip: 'Review queue ($pendingCount pending)',
            onPressed: onOpenReviewQueue,
          ),
          const SizedBox(width: FfSpace.x2s),
        ],
        FfCircleButton(
          icon: Icons.search_rounded,
          tooltip: 'Search transactions',
          soft: true,
          onPressed: onOpenSearch,
        ),
        const SizedBox(width: FfSpace.x2s),
        FfCircleButton(
          icon: Icons.tune_rounded,
          tooltip: 'Filter & sort',
          soft: true,
          corner:
              query.hasRefinements || query.sort != TransactionSort.newest
                  ? FfCorner.dot
                  : null,
          onPressed: onOpenFilters,
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context, FfThemeData ff) {
    return Row(
      key: const ValueKey('transactions_header_search'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FfCircleButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Close search',
          soft: true,
          onPressed: onCloseSearch,
        ),
        const SizedBox(width: FfSpace.xs),
        Expanded(
          child: Container(
            height: FfRoundButtonTokens.size,
            decoration: ShapeDecoration(
              color: ff.color.surfaceCard.withValues(alpha: FfOpacity.high),
              shape: FfShape.of(
                FfRadius.full,
                side: BorderSide(
                  color: ff.color.borderSubtle,
                  width: FfBorderWidth.hairline,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.md),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: FfIconSize.md,
                  color: ff.color.textSecondary,
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    textInputAction: TextInputAction.search,
                    style: ff.text.body,
                    decoration: InputDecoration(
                      hintText: 'Search payee, note, amount, tag…',
                      hintStyle: ff.text.body.copyWith(
                        color: ff.color.textTertiary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                ListenableBuilder(
                  listenable: searchController,
                  builder:
                      (context, _) =>
                          searchController.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: FfIconSize.sm,
                                ),
                                tooltip: 'Clear search text',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 18,
                                onPressed: () {
                                  searchController.clear();
                                  onSearchChanged('');
                                  onSearchClear();
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

  Widget _buildSelection(BuildContext context, FfThemeData ff) {
    final visible = items.take(visibleCount);
    final allSelected =
        visible.isNotEmpty && visible.every((t) => selected.contains(t.id));

    return Row(
      key: const ValueKey('transactions_header_selection'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FfCircleButton(
          icon: Icons.close_rounded,
          tooltip: 'Cancel selection',
          soft: true,
          onPressed: onCancelSelection,
        ),
        const SizedBox(width: FfSpace.sm),
        Expanded(
          child: Text(
            '${selected.length} selected',
            style: ff.text.titleLg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(
            allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
          ),
          tooltip: allSelected ? 'Clear selection' : 'Select all',
          onPressed: onToggleSelectAll,
        ),
        IconButton(
          icon: const Icon(Icons.category_outlined),
          tooltip: 'Change category',
          onPressed: onRecategorizeSelected,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: ff.color.statusError),
          tooltip: 'Delete selected',
          onPressed: onDeleteSelected,
        ),
      ],
    );
  }
}
