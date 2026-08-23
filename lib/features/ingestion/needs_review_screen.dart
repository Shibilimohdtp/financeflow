import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import '../categories/categories_controller.dart';
import 'needs_review_controller.dart';

class NeedsReviewScreen extends ConsumerStatefulWidget {
  const NeedsReviewScreen({super.key});

  @override
  ConsumerState<NeedsReviewScreen> createState() => _NeedsReviewScreenState();
}

class _NeedsReviewScreenState extends ConsumerState<NeedsReviewScreen> {
  String _selectedFilter = 'all'; // all, duplicates, uncertain, errors

  void _openEditItemSheet(
    BuildContext context,
    ParsedTransaction item,
    List<Category> categories,
    List<Account> accounts,
  ) {
    final amountController = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );
    final merchantController = TextEditingController(
      text: item.normalizedMerchant,
    );
    String selectedCategoryId = item.categoryId;
    String selectedCategoryName = item.categoryName;
    String selectedCategoryIcon = item.categoryIcon;
    String selectedCategoryColor = item.categoryColor;
    String selectedAccountId = item.accountId;
    TransactionType selectedType = item.type;
    DateTime selectedDate = item.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setModalState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FfSheetHeader(
                      title: 'Edit Pending Transaction',
                      subtitle:
                          'Review and categorize before importing',
                    ),
                    const Divider(height: 1, thickness: 1),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: StillwaterTokens.spaceLg,
                          right: StillwaterTokens.spaceLg,
                          top: StillwaterTokens.spaceMd,
                          bottom:
                              MediaQuery.of(ctx).viewInsets.bottom +
                              StillwaterTokens.spaceMd,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount
                            TextField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Amount (₹)',
                                prefixText: '₹ ',
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceMd),

                      // Payee / Merchant
                      TextField(
                        controller: merchantController,
                        decoration: const InputDecoration(
                          labelText: 'Payee / Merchant',
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),

                      // Type
                      DropdownButtonFormField<TransactionType>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items:
                            [
                                  TransactionType.expense,
                                  TransactionType.income,
                                  TransactionType.transfer,
                                ]
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.displayName),
                                  ),
                                )
                                .toList(),
                        onChanged: (t) {
                          if (t != null) setModalState(() => selectedType = t);
                        },
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),

                      // Category
                      DropdownButtonFormField<String>(
                        value:
                            categories.any((c) => c.id == selectedCategoryId)
                                ? selectedCategoryId
                                : null,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        hint: Text(selectedCategoryName),
                        items:
                            categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final cat = categories.firstWhere(
                              (c) => c.id == id,
                            );
                            setModalState(() {
                              selectedCategoryId = cat.id;
                              selectedCategoryName = cat.name;
                              selectedCategoryIcon = cat.iconIdentifier;
                              selectedCategoryColor = cat.colorTokenIdentifier;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: StillwaterTokens.spaceMd),

                      // Account
                      DropdownButtonFormField<String>(
                        value:
                            accounts.any((a) => a.id == selectedAccountId)
                                ? selectedAccountId
                                : (accounts.isNotEmpty
                                    ? accounts.first.id
                                    : null),
                        decoration: const InputDecoration(labelText: 'Account'),
                        items:
                            accounts
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            setModalState(() => selectedAccountId = id);
                          }
                        },
                      ),
                          ],
                        ),
                      ),
                    ),
                    FfSheetFooter(
                      primaryLabel: 'Save Changes',
                      onPrimaryPressed: () {
                        final parsedAmount =
                            double.tryParse(amountController.text) ??
                            item.amount;
                        final updated = item.copyWith(
                          amount: parsedAmount,
                          normalizedMerchant: merchantController.text.trim(),
                          type: selectedType,
                          categoryId: selectedCategoryId,
                          categoryName: selectedCategoryName,
                          categoryIcon: selectedCategoryIcon,
                          categoryColor: selectedCategoryColor,
                          accountId: selectedAccountId,
                          date: selectedDate,
                        );

                        ref
                            .read(needsReviewControllerProvider.notifier)
                            .updateItem(updated);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(pendingTransactionsStreamProvider).value ?? [];
    final categories = ref.watch(categoriesStreamProvider).value ?? [];
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];

    final filtered =
        items.where((i) {
          switch (_selectedFilter) {
            case 'duplicates':
              return i.isDuplicate;
            case 'uncertain':
              return i.categorizationConfidence < 0.7;
            case 'errors':
              return !i.isValid;
            default:
              return true;
          }
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Needs Review Queue'),
        actions: [
          if (items.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.playlist_add_check_rounded),
              tooltip: 'Approve All Valid',
              onPressed: () async {
                final count = await ref
                    .read(needsReviewControllerProvider.notifier)
                    .approveAllValid(items);
                if (context.mounted) {
                  FfSnackbar.show(
                    context,
                    message: 'Approved $count valid transactions.',
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Queue',
              onPressed: () async {
                final confirmed = await FfConfirmDialog.show(
                  context,
                  title: 'Clear Review Queue?',
                  message:
                      'All unapproved pending transactions will be deleted.',
                  confirmLabel: 'Clear All',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  await ref
                      .read(needsReviewControllerProvider.notifier)
                      .clearAll();
                }
              },
            ),
          ],
        ],
      ),
      body:
          items.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                child: Center(
                  child: FfEmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'All Clear',
                    description:
                        'No transactions are currently pending review.',
                  ),
                ),
              )
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceMd,
                ),
                children: [
                  // Filter Chips Row
                  Wrap(
                    spacing: StillwaterTokens.spaceSm,
                    runSpacing: StillwaterTokens.spaceXs,
                    children: [
                      FfChip(
                        label: 'All (${items.length})',
                        isSelected: _selectedFilter == 'all',
                        onSelected:
                            () => setState(() => _selectedFilter = 'all'),
                      ),
                      FfChip(
                        label:
                            'Duplicates (${items.where((i) => i.isDuplicate).length})',
                        isSelected: _selectedFilter == 'duplicates',
                        onSelected:
                            () =>
                                setState(() => _selectedFilter = 'duplicates'),
                      ),
                      FfChip(
                        label:
                            'Uncertain (${items.where((i) => i.categorizationConfidence < 0.7).length})',
                        isSelected: _selectedFilter == 'uncertain',
                        onSelected:
                            () => setState(() => _selectedFilter = 'uncertain'),
                      ),
                      FfChip(
                        label:
                            'Invalid (${items.where((i) => !i.isValid).length})',
                        isSelected: _selectedFilter == 'errors',
                        onSelected:
                            () => setState(() => _selectedFilter = 'errors'),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),

                  // Pending items list
                  for (final item in filtered)
                    _buildPendingItemCard(context, item, categories, accounts),

                  const SizedBox(height: StillwaterTokens.space4Xl),
                ],
              ),
    );
  }

  Widget _buildPendingItemCard(
    BuildContext context,
    ParsedTransaction item,
    List<Category> categories,
    List<Account> accounts,
  ) {
    final theme = context.theme;
    final isExpense = item.type == TransactionType.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceMd),
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FfSourceBadge(source: item.source, sourceName: item.sourceName),
              Text(
                DateFormatter.formatTransactionDate(item.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.normalizedMerchant.isNotEmpty
                          ? item.normalizedMerchant
                          : item.rawMerchant,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.rawMerchant != item.normalizedMerchant &&
                        item.rawMerchant.isNotEmpty)
                      Text(
                        'Raw: ${item.rawMerchant}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(
                  item.amount,
                  showSign: true,
                  isExpense: isExpense,
                  isIncome: !isExpense,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color:
                      isExpense
                          ? context.finColors.expense
                          : context.finColors.income,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceSm),

          // Review Reasons & Badges
          if (item.isDuplicate) ...[
            Container(
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.duplicateStatus.displayName} with existing transaction',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  if (item.duplicateReasons.isNotEmpty)
                    Text(
                      item.duplicateReasons.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),
          ],

          if (item.warnings.isNotEmpty || item.validationErrors.isNotEmpty) ...[
            Text(
              [...item.validationErrors, ...item.warnings].join('\n'),
              style: TextStyle(color: theme.colorScheme.error, fontSize: 11),
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),
          ],

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(needsReviewControllerProvider.notifier)
                      .dismissItem(item.tempId);
                },
                child: const Text('Dismiss'),
              ),
              TextButton(
                onPressed:
                    () =>
                        _openEditItemSheet(context, item, categories, accounts),
                child: const Text('Edit'),
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              if (item.isDuplicate && item.matchedTransaction != null)
                FfButton(
                  label: 'Merge',
                  variant: FfButtonVariant.secondary,
                  onPressed: () {
                    final mergeItem = item.copyWith(
                      duplicateResolution: DuplicateResolution.merge,
                    );
                    ref
                        .read(needsReviewControllerProvider.notifier)
                        .approveItem(mergeItem);
                  },
                )
              else
                FfButton(
                  label: 'Approve',
                  onPressed: () {
                    ref
                        .read(needsReviewControllerProvider.notifier)
                        .approveItem(item);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
