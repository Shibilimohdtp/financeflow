import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import '../ingestion/needs_review_controller.dart';
import '../ingestion/needs_review_screen.dart';
import '../settings/settings_controller.dart';
import 'transactions_controller.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final filter = ref.watch(transactionFilterProvider);
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];
    final settings = ref.watch(settingsStreamProvider).value;
    final isPrivacyBlur = settings?.isPrivacyBlurEnabled ?? false;
    final pendingCount = ref.watch(pendingReviewCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceXs,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search merchant, notes, amount...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            filterNotifier.state = filter.copyWith(
                              searchQuery: '',
                            );
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceMd,
                  vertical: StillwaterTokens.spaceSm,
                ),
              ),
              onChanged: (val) {
                filterNotifier.state = filter.copyWith(searchQuery: val);
              },
            ),
          ),

          // 2. Filter Chips Horizontal Scroll
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
              ),
              children: [
                // Type Filter: All
                FfChip(
                  label: 'All',
                  isSelected: filter.selectedType == null,
                  onSelected: () {
                    filterNotifier.state = filter.copyWith(clearType: true);
                  },
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),

                // Type Filter: Expense
                FfChip(
                  label: 'Expenses',
                  isSelected: filter.selectedType == TransactionType.expense,
                  onSelected: () {
                    filterNotifier.state = filter.copyWith(
                      selectedType: TransactionType.expense,
                    );
                  },
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),

                // Type Filter: Income
                FfChip(
                  label: 'Income',
                  isSelected: filter.selectedType == TransactionType.income,
                  onSelected: () {
                    filterNotifier.state = filter.copyWith(
                      selectedType: TransactionType.income,
                    );
                  },
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),

                // Type Filter: Transfer
                FfChip(
                  label: 'Transfers',
                  isSelected: filter.selectedType == TransactionType.transfer,
                  onSelected: () {
                    filterNotifier.state = filter.copyWith(
                      selectedType: TransactionType.transfer,
                    );
                  },
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),

                // Category Filter Dropdown Chip
                PopupMenuButton<String?>(
                  initialValue: filter.selectedCategoryId,
                  onSelected: (catId) {
                    filterNotifier.state = filter.copyWith(
                      selectedCategoryId: catId,
                      clearCategory: catId == null,
                    );
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categories.map(
                          (cat) => PopupMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        ),
                      ],
                  child: FfChip(
                    label:
                        filter.selectedCategoryId != null
                            ? (categories
                                    .where(
                                      (c) => c.id == filter.selectedCategoryId,
                                    )
                                    .firstOrNull
                                    ?.name ??
                                'Category')
                            : 'Category',
                    isSelected: filter.selectedCategoryId != null,
                    trailing: const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                    ),
                    onSelected: () {},
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),

                // Account Filter Dropdown Chip
                PopupMenuButton<String?>(
                  initialValue: filter.selectedAccountId,
                  onSelected: (accId) {
                    filterNotifier.state = filter.copyWith(
                      selectedAccountId: accId,
                      clearAccount: accId == null,
                    );
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Accounts'),
                        ),
                        ...accounts.map(
                          (acc) => PopupMenuItem(
                            value: acc.id,
                            child: Text(acc.name),
                          ),
                        ),
                      ],
                  child: FfChip(
                    label:
                        filter.selectedAccountId != null
                            ? (accounts
                                    .where(
                                      (a) => a.id == filter.selectedAccountId,
                                    )
                                    .firstOrNull
                                    ?.name ??
                                'Account')
                            : 'Account',
                    isSelected: filter.selectedAccountId != null,
                    trailing: const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                    ),
                    onSelected: () {},
                  ),
                ),

                if (filter.hasActiveFilters) ...[
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      filterNotifier.state = const TransactionFilterState();
                    },
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Pending Review Banner
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
                vertical: StillwaterTokens.spaceXs,
              ),
              child: Material(
                color: context.aiColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NeedsReviewScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                    child: Row(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          color: context.aiColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),
                        Expanded(
                          child: Text(
                            '$pendingCount imported transactions need review',
                            style: TextStyle(
                              color: context.aiColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.aiColors.accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 3. Transactions List grouped by Day
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return FfEmptyState(
                    icon: Icons.search_off_rounded,
                    title:
                        filter.hasActiveFilters
                            ? 'No matching transactions'
                            : 'No transactions found',
                    description:
                        filter.hasActiveFilters
                            ? 'Try clearing some filters or searching for another term.'
                            : 'Add your first transaction to see it listed here.',
                    actionLabel:
                        filter.hasActiveFilters
                            ? 'Clear Filters'
                            : 'Add Transaction',
                    onAction:
                        filter.hasActiveFilters
                            ? () {
                              _searchController.clear();
                              filterNotifier.state =
                                  const TransactionFilterState();
                            }
                            : widget.onAddTransaction,
                  );
                }

                // Group by Day
                final grouped = _groupByDay(transactions);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final group = grouped[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day Header with Day Net Total
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceLg,
                            vertical: StillwaterTokens.spaceSm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormatter.formatDayGroup(group.date),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(
                                  group.dayNetTotal,
                                  showSign: true,
                                  isExpense: group.dayNetTotal < 0,
                                  isIncome: group.dayNetTotal > 0,
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Day Transactions List
                        ...group.transactions.map((tx) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceLg,
                              vertical: StillwaterTokens.space2Xs,
                            ),
                            leading: FfCategoryTile(
                              iconIdentifier: tx.categoryIcon,
                              colorTokenIdentifier: tx.categoryColor,
                            ),
                            title: Text(
                              tx.merchant,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  DateFormatter.formatTransactionDate(tx.date),
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: StillwaterTokens.spaceXs),
                                FfSourceBadge(
                                  source: tx.source,
                                  sourceName: tx.sourceName,
                                  isMerged: tx.mergedSources.length > 1,
                                ),
                              ],
                            ),
                            trailing: FfAmountText(
                              amount: tx.amount,
                              type: tx.type,
                              size: FfAmountSize.md,
                              isBlurred: isPrivacyBlur,
                              showSign: true,
                            ),
                            onTap: () => widget.onOpenDetail(tx),
                          );
                        }),
                        const Divider(height: 16),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<_DayGroup> _groupByDay(List<Transaction> transactions) {
    final Map<String, List<Transaction>> map = {};
    for (final tx in transactions) {
      final key = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      map.putIfAbsent(key, () => []).add(tx);
    }

    return map.entries.map((entry) {
      final txList = entry.value;
      final date = txList.first.date;
      double net = 0.0;
      for (final tx in txList) {
        if (tx.type == TransactionType.income) {
          net += tx.amount;
        } else if (tx.type != TransactionType.transfer) {
          net -= tx.amount;
        }
      }
      return _DayGroup(date: date, transactions: txList, dayNetTotal: net);
    }).toList();
  }
}

class _DayGroup {
  final DateTime date;
  final List<Transaction> transactions;
  final double dayNetTotal;

  _DayGroup({
    required this.date,
    required this.transactions,
    required this.dayNetTotal,
  });
}
