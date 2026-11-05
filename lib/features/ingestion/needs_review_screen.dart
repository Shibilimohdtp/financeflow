import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../accounts/accounts_controller.dart';
import '../../models/account.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../services/categorization_service.dart';
import '../../services/default_account_service.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'needs_review_controller.dart';
import '../transactions/add_edit_transaction_screen.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_progress.dart';

class NeedsReviewScreen extends ConsumerStatefulWidget {
  const NeedsReviewScreen({super.key});

  @override
  ConsumerState<NeedsReviewScreen> createState() => _NeedsReviewScreenState();
}

class _NeedsReviewScreenState extends ConsumerState<NeedsReviewScreen> {
  String _selectedFilter = 'all'; // all, duplicates, uncertain, errors

  void _openEditItemSheet(BuildContext context, ParsedTransaction item) {
    final accounts = ref.read(rawAccountsStreamProvider).value ?? const [];
    final importedDefault = defaultTransactionAccount(
      accounts,
      preferNonCash: true,
    );
    final parsedTransaction = item.toTransaction(targetId: item.tempId);
    final isImportedFinancialEvent =
        item.source == TransactionSource.sms ||
        item.source == TransactionSource.notification;
    final wasAlreadyReviewed =
        item.categorizationConfidence >= 1 &&
        item.categorizationReason == 'User reviewed category';
    // Older queued SMS/notification items may still carry the historical
    // Cash Wallet fallback. Repair that default when the user opens review;
    // explicitly chosen accounts remain untouched.
    var initialTransaction =
        isImportedFinancialEvent &&
                item.accountId == 'acc_primary_cash' &&
                importedDefault != null &&
                !wasAlreadyReviewed
            ? parsedTransaction.copyWith(accountId: importedDefault.id)
            : parsedTransaction;

    final history = ref.read(allTransactionsStreamProvider).value ?? const [];
    final isMisc =
        initialTransaction.categoryId == 'cat_miscellaneous' ||
        initialTransaction.categoryName.toLowerCase() == 'miscellaneous';
    if ((isMisc ||
            (initialTransaction.categorizationConfidence ?? 0.0) < 0.7) &&
        initialTransaction.merchant.isNotEmpty) {
      final histSuggestion = CategorizationService.suggestCategory(
        initialTransaction.merchant,
        history: history,
      );
      if (histSuggestion != null &&
          histSuggestion.categoryId != 'cat_miscellaneous') {
        initialTransaction = initialTransaction.copyWith(
          categoryId: histSuggestion.categoryId,
          categoryName: histSuggestion.categoryName,
          categoryIcon: histSuggestion.categoryIcon,
          categoryColor: histSuggestion.categoryColor,
          categorizationConfidence: histSuggestion.confidence,
        );
      }
    }

    AddEditTransactionScreen.push<void>(
      context,
      initialTransaction: initialTransaction,
      headerTitle: 'Edit Pending Transaction',
      saveLabel: 'Save Changes',
      sourceContext: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FfSourceBadge(source: item.source, sourceName: item.sourceName),
          const SizedBox(height: StillwaterTokens.spaceXs),
          const Text(
            'Review before importing. Saving keeps this item pending.',
          ),
          if (item.isDuplicate)
            const Text(
              'Merging retains the existing transaction’s accounts and purpose. Choose Keep Both to save a separate transaction.',
            ),
          if (item.categorizationConfidence < 0.7)
            const Text('Category needs confirmation.'),
          ...[...item.validationErrors, ...item.warnings].map(Text.new),
          if (item.rawSource != null)
            ExpansionTile(
              title: const Text('Source details'),
              subtitle: const Text(
                'Private source evidence · stored on this device',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                  child: SelectableText(item.rawSource!),
                ),
              ],
            ),
        ],
      ),
      onSave:
          (draft) => ref
              .read(needsReviewControllerProvider.notifier)
              .updateItem(item.withReviewEdit(draft)),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        FfToast.show(
          context,
          message:
              error is StateError
                  ? error.message.toString()
                  : 'Could not update the review queue. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingTransactionsStreamProvider);
    final items = pending.value ?? [];
    final busy = ref.watch(needsReviewControllerProvider).isLoading;
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? const [];

    final duplicatesCount = items.where((i) => i.isDuplicate).length;
    final uncertainCount =
        items
            .where((i) => i.categorizationConfidence < 0.7 || i.hasWarnings)
            .length;
    final errorsCount = items.where((i) => !i.isValid).length;
    final validCount = items.where((i) => i.isValid && !i.isDuplicate).length;

    final filtered =
        items.where((i) {
          switch (_selectedFilter) {
            case 'duplicates':
              return i.isDuplicate;
            case 'uncertain':
              return i.categorizationConfidence < 0.7 || i.hasWarnings;
            case 'errors':
              return !i.isValid;
            default:
              return true;
          }
        }).toList();

    return Scaffold(
      appBar: FfAppBar(
        title: 'Needs Review Queue',
        actions: [
          if (items.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.playlist_add_check_rounded),
              tooltip:
                  validCount > 0
                      ? 'Approve All Valid ($validCount)'
                      : 'Approve All Valid',
              onPressed:
                  busy || validCount == 0
                      ? null
                      : () => _runAction(() async {
                        final count = await ref
                            .read(needsReviewControllerProvider.notifier)
                            .approveAllValid(items);
                        if (context.mounted) {
                          FfToast.show(
                            context,
                            message: 'Approved $count valid transactions.',
                            actionLabel: 'Undo',
                            onAction:
                                () =>
                                    ref
                                        .read(
                                          needsReviewControllerProvider
                                              .notifier,
                                        )
                                        .undoLastApprove(),
                          );
                        }
                      }),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Queue',
              onPressed:
                  busy
                      ? null
                      : () => _runAction(() async {
                        final confirmed = await FfDialog.confirm(
                          context,
                          title: 'Clear Review Queue?',
                          message:
                              'All unapproved pending transactions will be deleted.',
                          confirmLabel: 'Clear All',
                          destructive: true,
                        );
                        if (confirmed == true) {
                          await ref
                              .read(needsReviewControllerProvider.notifier)
                              .clearAll();
                        }
                      }),
            ),
          ],
        ],
      ),
      body:
          pending.isLoading
              ? const FfLoading()
              : pending.hasError
              ? Center(
                child: TextButton(
                  onPressed:
                      () => ref.invalidate(pendingTransactionsStreamProvider),
                  child: const Text(
                    'Could not load review queue. Tap to retry.',
                  ),
                ),
              )
              : items.isEmpty
              ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                  child: FfEmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'All Clear',
                    description:
                        'No transactions are currently pending review.',
                    actionLabel: 'Back to Transactions',
                    onAction: () => Navigator.of(context).maybePop(),
                  ),
                ),
              )
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceLg,
                  vertical: StillwaterTokens.spaceMd,
                ),
                children: [
                  // 1. Privacy & Context Banner
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: StillwaterTokens.spaceMd,
                    ),
                    padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusMd,
                      ),
                      border: Border.all(
                        color: context.theme.dividerColor,
                        width: StillwaterTokens.borderWidthHairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: context.theme.colorScheme.primary,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),
                        Expanded(
                          child: Text(
                            'Private on-device review. Unapproved items are kept separate from your ledger reports and balances.',
                            style: context.theme.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Horizontal Scrollable Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FfChip(
                          label: 'All (${items.length})',
                          isSelected: _selectedFilter == 'all',
                          onSelected:
                              () => setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceXs),
                        FfChip(
                          label: 'Duplicates ($duplicatesCount)',
                          isSelected: _selectedFilter == 'duplicates',
                          onSelected:
                              () => setState(
                                () => _selectedFilter = 'duplicates',
                              ),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceXs),
                        FfChip(
                          label: 'Uncertain ($uncertainCount)',
                          isSelected: _selectedFilter == 'uncertain',
                          onSelected:
                              () =>
                                  setState(() => _selectedFilter = 'uncertain'),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceXs),
                        FfChip(
                          label: 'Invalid ($errorsCount)',
                          isSelected: _selectedFilter == 'errors',
                          onSelected:
                              () => setState(() => _selectedFilter = 'errors'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),

                  // 3. Pending items or filter-specific empty state
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: StillwaterTokens.space3Xl,
                      ),
                      child: _buildFilterEmptyState(context),
                    )
                  else
                    for (final item in filtered)
                      _buildPendingItemCard(context, item, busy, accounts),

                  const SizedBox(height: StillwaterTokens.space4Xl),
                ],
              ),
    );
  }

  Widget _buildFilterEmptyState(BuildContext context) {
    switch (_selectedFilter) {
      case 'duplicates':
        return FfEmptyState(
          icon: Icons.copy_rounded,
          title: 'No duplicate transactions',
          description:
              'None of your pending imports match existing ledger entries.',
          actionLabel: 'View all items',
          onAction: () => setState(() => _selectedFilter = 'all'),
        );
      case 'uncertain':
        return FfEmptyState(
          icon: Icons.category_outlined,
          title: 'All categories confirmed',
          description:
              'All pending transactions have confident categories assigned.',
          actionLabel: 'View all items',
          onAction: () => setState(() => _selectedFilter = 'all'),
        );
      case 'errors':
        return FfEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'No invalid transactions',
          description:
              'All pending transactions have valid amounts, dates, and accounts.',
          actionLabel: 'View all items',
          onAction: () => setState(() => _selectedFilter = 'all'),
        );
      default:
        return const FfEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'All Clear',
          description: 'No transactions are currently pending review.',
        );
    }
  }

  Widget _buildPendingItemCard(
    BuildContext context,
    ParsedTransaction item,
    bool busy,
    List<Account> accounts,
  ) {
    final theme = context.theme;
    final isExpense = item.type == TransactionType.expense;

    final account = accounts.where((a) => a.id == item.accountId).firstOrNull;
    final accountName = account?.name ?? (item.sourceName ?? 'Account');

    final merchantName =
        item.merchantDisplayName ??
        (item.normalizedMerchant.isNotEmpty
            ? item.normalizedMerchant
            : item.rawMerchant);

    Widget? statusBadge;
    if (item.isDuplicate) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.statusColors.warningContainer,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXs),
        ),
        child: Text(
          item.duplicateStatus.displayName,
          style: TextStyle(
            color: context.statusColors.warning,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (!item.isValid) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXs),
        ),
        child: Text(
          'Needs details',
          style: TextStyle(
            color: theme.colorScheme.error,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (item.categorizationConfidence < 0.7) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.statusColors.warningContainer,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXs),
        ),
        child: Text(
          'Confirm category',
          style: TextStyle(
            color: context.statusColors.warning,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

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
          // Row 1: Source badge, date, and status tag
          Wrap(
            spacing: StillwaterTokens.spaceSm,
            runSpacing: StillwaterTokens.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FfSourceBadge(source: item.source, sourceName: item.sourceName),
              Text(
                DateFormatter.formatTransactionDate(item.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 11,
                ),
              ),
              if (statusBadge != null) statusBadge,
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),

          // Row 2: Category Icon Tile + Merchant Name/Category & Account Subtitle + Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FfCategoryTile(
                iconIdentifier: item.categoryIcon,
                colorTokenIdentifier: item.categoryColor,
                size: 40,
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.categoryName.isNotEmpty ? item.categoryName : 'Uncategorized'} • $accountName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
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

          // Row 3: Review Reason Callout Boxes
          if (item.isDuplicate) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: StillwaterTokens.spaceSm),
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.25),
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.copy_all_outlined,
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceXs),
                      Text(
                        '${item.duplicateStatus.displayName} with existing transaction',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (item.duplicateReasons.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.duplicateReasons.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    'Merge to update the existing ledger entry, or Keep Both to record as separate.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.warnings.isNotEmpty || item.validationErrors.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: StillwaterTokens.spaceSm),
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.25),
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Expanded(
                    child: Text(
                      [...item.validationErrors, ...item.warnings].join('\n'),
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.categorizationConfidence < 0.7 && !item.isDuplicate) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: StillwaterTokens.spaceSm),
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: context.statusColors.warningContainer.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                border: Border.all(
                  color: context.statusColors.warning.withValues(alpha: 0.3),
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: context.statusColors.warning,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Expanded(
                    child: Text(
                      'Suggested category: ${item.categoryName.isNotEmpty ? item.categoryName : 'Uncategorized'}. Confirm or tap Edit to change.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.statusColors.warning,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.normalizedMerchant == 'Bank Transaction') ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: StillwaterTokens.spaceSm),
              padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
              decoration: BoxDecoration(
                color: context.statusColors.warningContainer.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
                border: Border.all(
                  color: context.statusColors.warning.withValues(alpha: 0.3),
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 14,
                    color: context.statusColors.warning,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Expanded(
                    child: Text(
                      'Payee not identified — please edit before approving.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.statusColors.warning,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Collapsible original SMS snippet
          if (item.rawSource != null) ...[
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'Original imported text',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: StillwaterTokens.spaceXs,
                    ),
                    padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                    ),
                    child: SelectableText(
                      item.rawSource!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: StillwaterTokens.spaceSm),

          // Action Buttons: Dismiss, Edit, Approve / Merge / Keep Both / Fix
          Wrap(
            alignment: WrapAlignment.end,
            spacing: StillwaterTokens.spaceXs,
            runSpacing: StillwaterTokens.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed:
                    busy
                        ? null
                        : () async {
                          await _runAction(
                            () => ref
                                .read(needsReviewControllerProvider.notifier)
                                .dismissItem(item.tempId, item: item),
                          );
                          if (context.mounted) {
                            FfToast.show(
                              context,
                              message: '$merchantName dismissed.',
                              actionLabel: 'Undo',
                              onAction:
                                  () =>
                                      ref
                                          .read(
                                            needsReviewControllerProvider
                                                .notifier,
                                          )
                                          .undoLastDismiss(),
                            );
                          }
                        },
                child: const Text('Dismiss'),
              ),
              TextButton(
                onPressed:
                    busy ? null : () => _openEditItemSheet(context, item),
                child: const Text('Edit'),
              ),
              if (item.isDuplicate &&
                  (item.matchedTransaction != null ||
                      item.matchedTransactionId != null)) ...[
                TextButton(
                  onPressed:
                      busy || !item.isValid
                          ? null
                          : () async {
                            await _runAction(
                              () => ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(
                                    item.copyWith(
                                      duplicateResolution:
                                          DuplicateResolution.keepBoth,
                                    ),
                                  ),
                            );
                            if (context.mounted) {
                              FfToast.show(
                                context,
                                message:
                                    '$merchantName approved (kept separate).',
                                actionLabel: 'Undo',
                                onAction:
                                    () =>
                                        ref
                                            .read(
                                              needsReviewControllerProvider
                                                  .notifier,
                                            )
                                            .undoLastApprove(),
                              );
                            }
                          },
                  child: const Text('Keep Both'),
                ),
                FfButton(
                  label: 'Merge',
                  variant: FfButtonVariant.secondary,
                  size: FfButtonSize.sm,
                  onPressed:
                      busy || !item.isValid
                          ? null
                          : () async {
                            final mergeItem = item.copyWith(
                              duplicateResolution: DuplicateResolution.merge,
                            );
                            await _runAction(
                              () => ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(mergeItem),
                            );
                            if (context.mounted) {
                              FfToast.show(
                                context,
                                message: '$merchantName merged with existing.',
                                actionLabel: 'Undo',
                                onAction:
                                    () =>
                                        ref
                                            .read(
                                              needsReviewControllerProvider
                                                  .notifier,
                                            )
                                            .undoLastApprove(),
                              );
                            }
                          },
                ),
              ] else if (!item.isValid)
                FfButton(
                  label: 'Fix Details',
                  size: FfButtonSize.sm,
                  onPressed:
                      busy ? null : () => _openEditItemSheet(context, item),
                )
              else
                FfButton(
                  label: 'Approve',
                  size: FfButtonSize.sm,
                  onPressed:
                      busy
                          ? null
                          : () async {
                            await _runAction(
                              () => ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(item),
                            );
                            if (context.mounted) {
                              FfToast.show(
                                context,
                                message: '$merchantName approved.',
                                actionLabel: 'Undo',
                                onAction:
                                    () =>
                                        ref
                                            .read(
                                              needsReviewControllerProvider
                                                  .notifier,
                                            )
                                            .undoLastApprove(),
                              );
                            }
                          },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
