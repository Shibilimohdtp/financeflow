import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
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
import 'widgets/transaction_tile.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isSearchOpen = false;
  int _visibleItemCount = 50;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 300) {
      final totalItems =
          ref.read(filteredTransactionsProvider).value?.length ?? 0;
      if (_visibleItemCount < totalItems) {
        setState(() {
          _visibleItemCount = (_visibleItemCount + 50).clamp(0, totalItems);
        });
      }
    }
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
    final allTransactions =
        ref.watch(allTransactionsStreamProvider).value ?? const <Transaction>[];
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
                    onPressed: () {
                      final items = transactions.value ?? const <Transaction>[];
                      _showFilterSheet(
                        context,
                        filter: filter,
                        categories: categories,
                        accounts: accounts,
                        transactions: items,
                      );
                    },
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
                final visibleItems = items.take(_visibleItemCount).toList();
                final groups = groupTransactionsForList(visibleItems);
                final availableMonths = extractAvailableMonths(
                  allTransactions.isNotEmpty ? allTransactions : items,
                );

                final now = DateTime.now();
                final currentMonth = DateTime(now.year, now.month);
                final targetMonth =
                    filter.selectedMonth ??
                    (filter.startDate == null ? currentMonth : null);

                final String periodLabel;
                final TransactionListSummary summary;

                if (targetMonth != null) {
                  final periodList =
                      allTransactions.isNotEmpty
                          ? allTransactions
                              .where(
                                (t) =>
                                    t.date.year == targetMonth.year &&
                                    t.date.month == targetMonth.month,
                              )
                              .toList()
                          : items
                              .where(
                                (t) =>
                                    t.date.year == targetMonth.year &&
                                    t.date.month == targetMonth.month,
                              )
                              .toList();
                  summary = calculateTransactionListSummary(periodList);
                  periodLabel =
                      (targetMonth.year == currentMonth.year &&
                              targetMonth.month == currentMonth.month)
                          ? 'This Month · ${DateFormatter.formatMonthYear(targetMonth)}'
                          : '${DateFormatter.formatMonthYear(targetMonth)} Cash Flow';
                } else if (filter.startDate != null) {
                  summary = calculateTransactionListSummary(items);
                  periodLabel = 'Custom Period Cash Flow';
                } else {
                  summary = calculateTransactionListSummary(items);
                  periodLabel = 'All-Time Cash Flow';
                }

                return CustomScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    // Interactive Cash Flow Summary Card (Period Aware)
                    SliverToBoxAdapter(
                      child: _CashFlowSummary(
                        summary: summary,
                        periodLabel: periodLabel,
                        isPrivacyBlur: privacyBlur,
                        selectedType: filter.selectedType,
                        onSelectType: (type) {
                          HapticFeedback.selectionClick();
                          if (filter.selectedType == type) {
                            notifier.state = filter.copyWith(
                              clearType: true,
                            );
                          } else {
                            notifier.state = filter.copyWith(
                              selectedType: type,
                            );
                          }
                        },
                      ),
                    ),

                        // Quick Filter & Month Carousel
                        SliverToBoxAdapter(
                          child: _QuickFilterBar(
                            filter: filter,
                            availableMonths: availableMonths,
                            onTypeChanged: (type) {
                              HapticFeedback.selectionClick();
                              notifier.state = filter.copyWith(
                                selectedType: type,
                                clearType: type == null,
                              );
                            },
                            onMonthChanged: (month) {
                              HapticFeedback.selectionClick();
                              notifier.state = filter.copyWith(
                                selectedMonth: month,
                                clearMonth: month == null,
                                clearDates: true,
                              );
                            },
                            onClearFilters: _clearFilters,
                          ),
                        ),

                        if (items.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: FfEmptyState(
                              icon:
                                  filter.searchQuery.trim().isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.receipt_long_outlined,
                              title:
                                  filter.hasActiveFilters
                                      ? 'No matching transactions'
                                      : 'No transactions yet',
                              description:
                                  filter.hasActiveFilters
                                      ? 'Try another search or reset active filters.'
                                      : 'Add your first transaction to start a private, local record.',
                              actionLabel:
                                  filter.hasActiveFilters
                                      ? 'Clear filters'
                                      : 'Add transaction',
                              onAction:
                                  filter.hasActiveFilters
                                      ? _clearFilters
                                      : widget.onAddTransaction,
                            ),
                          )
                        else ...[
                          for (final group in groups) ...[
                            SliverToBoxAdapter(
                              child: _GroupHeader(group: group),
                            ),
                            SliverList.separated(
                              itemCount: group.transactions.length,
                              separatorBuilder:
                                  (_, __) =>
                                      const Divider(indent: 72, height: 1),
                              itemBuilder: (context, index) {
                                final tx = group.transactions[index];
                                return TransactionTile(
                                  transaction: tx,
                                  accounts: accounts,
                                  showDate: group.showDateInRows,
                                  isPrivacyBlur: privacyBlur,
                                  onOpen: () => widget.onOpenDetail(tx),
                                  onEdit: () => _edit(tx),
                                  onDelete: () => _delete(tx),
                                );
                              },
                            ),
                          ],
                          if (items.length > _visibleItemCount)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: StillwaterTokens.spaceMd,
                                ),
                                child: Center(
                                  child: Text(
                                    'Showing $_visibleItemCount of ${items.length} transactions',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: context
                                              .theme
                                              .colorScheme
                                              .secondary,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 104),
                          ),
                        ],
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

class _QuickFilterBar extends StatelessWidget {
  final TransactionFilterState filter;
  final List<DateTime> availableMonths;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<DateTime?> onMonthChanged;
  final VoidCallback onClearFilters;

  const _QuickFilterBar({
    required this.filter,
    required this.availableMonths,
    required this.onTypeChanged,
    required this.onMonthChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceLg,
        vertical: StillwaterTokens.spaceXs,
      ),
      child: Row(
        children: [
          if (filter.hasActiveFilters) ...[
            ActionChip(
              avatar: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear'),
              onPressed: onClearFilters,
            ),
            const SizedBox(width: StillwaterTokens.spaceXs),
          ],
          // Type Pills
          FfChip(
            label: 'All Types',
            isSelected: filter.selectedType == null,
            onSelected: () => onTypeChanged(null),
          ),
          const SizedBox(width: StillwaterTokens.spaceXs),
          FfChip(
            label: 'Expenses',
            isSelected: filter.selectedType == TransactionType.expense,
            onSelected: () => onTypeChanged(TransactionType.expense),
          ),
          const SizedBox(width: StillwaterTokens.spaceXs),
          FfChip(
            label: 'Income',
            isSelected: filter.selectedType == TransactionType.income,
            onSelected: () => onTypeChanged(TransactionType.income),
          ),
          const SizedBox(width: StillwaterTokens.spaceXs),
          FfChip(
            label: 'Transfers',
            isSelected: filter.selectedType == TransactionType.transfer,
            onSelected: () => onTypeChanged(TransactionType.transfer),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),

          Container(
            height: 20,
            width: 1,
            color: context.theme.dividerColor.withValues(alpha: 0.5),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),

          // Month Selection Pills
          FfChip(
            label: 'All Time',
            isSelected:
                filter.selectedMonth == null && filter.startDate == null,
            onSelected: () => onMonthChanged(null),
          ),
          const SizedBox(width: StillwaterTokens.spaceXs),
          FfChip(
            label: 'This Month',
            isSelected:
                filter.selectedMonth != null &&
                filter.selectedMonth!.year == currentMonth.year &&
                filter.selectedMonth!.month == currentMonth.month,
            onSelected: () => onMonthChanged(currentMonth),
          ),
          for (final month in availableMonths)
            if (month.year != currentMonth.year ||
                month.month != currentMonth.month) ...[
              const SizedBox(width: StillwaterTokens.spaceXs),
              FfChip(
                label: DateFormatter.formatMonthYear(month),
                isSelected:
                    filter.selectedMonth != null &&
                    filter.selectedMonth!.year == month.year &&
                    filter.selectedMonth!.month == month.month,
                onSelected: () => onMonthChanged(month),
              ),
            ],
        ],
      ),
    );
  }
}

class _CashFlowSummary extends StatelessWidget {
  final TransactionListSummary summary;
  final String periodLabel;
  final bool isPrivacyBlur;
  final TransactionType? selectedType;
  final ValueChanged<TransactionType> onSelectType;

  const _CashFlowSummary({
    required this.summary,
    required this.periodLabel,
    required this.isPrivacyBlur,
    required this.selectedType,
    required this.onSelectType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final totalFlow = summary.income + summary.expenses;
    final expenseRatio = totalFlow > 0 ? (summary.expenses / totalFlow) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceXs,
        StillwaterTokens.spaceLg,
        StillwaterTokens.spaceXs,
      ),
      child: FfCard(
        variant: FfCardVariant.elevated,
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Heading
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Text(
                  periodLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),
            const Divider(height: 1),
            const SizedBox(height: StillwaterTokens.spaceSm),

            Row(
              children: [
                _SummaryValue(
                  label: 'Income',
                  value: summary.income,
                  positive: true,
                  isPrivacyBlur: isPrivacyBlur,
                  isActive: selectedType == TransactionType.income,
                  onTap: () => onSelectType(TransactionType.income),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.theme.dividerColor,
                ),
                _SummaryValue(
                  label: 'Expenses',
                  value: summary.expenses,
                  positive: false,
                  isPrivacyBlur: isPrivacyBlur,
                  isActive: selectedType == TransactionType.expense,
                  onTap: () => onSelectType(TransactionType.expense),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.theme.dividerColor,
                ),
                _SummaryValue(
                  label: 'Net',
                  value: summary.net,
                  positive: summary.net >= 0,
                  isPrivacyBlur: isPrivacyBlur,
                  isActive: false,
                ),
              ],
            ),
            if (totalFlow > 0) ...[
              const SizedBox(height: StillwaterTokens.spaceSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
                child: SizedBox(
                  height: 4,
                  child: Row(
                    children: [
                      Flexible(
                        flex: (expenseRatio * 100).round().clamp(1, 99),
                        child: Container(color: context.finColors.expense),
                      ),
                      Flexible(
                        flex: ((1 - expenseRatio) * 100).round().clamp(1, 99),
                        child: Container(color: context.finColors.income),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  final bool isActive;
  final VoidCallback? onTap;

  const _SummaryValue({
    required this.label,
    required this.value,
    required this.positive,
    this.isPrivacyBlur = false,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle_rounded,
                size: 10,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: StillwaterTokens.space2Xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child:
              isPrivacyBlur
                  ? Text('${CurrencyFormatter.currencySymbol} ••••••', style: StillwaterTypography.numMd())
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
                      color: positive ? finColors.income : finColors.expense,
                    ),
                  ),
        ),
      ],
    );

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceXs,
            vertical: StillwaterTokens.space2Xs,
          ),
          child: content,
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
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (group.net >= 0 ? finColors.income : finColors.expense)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
            ),
            child: Text(
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
          ),
        ],
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
                                    clearMonth: true,
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
