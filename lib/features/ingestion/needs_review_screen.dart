import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts/accounts_controller.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../services/categorization_service.dart';
import '../../services/default_account_service.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../transactions/add_edit_transaction_screen.dart';
import 'needs_review_controller.dart';
import 'widgets/pending_transaction_card.dart';
import 'widgets/review_empty_states.dart';
import 'widgets/review_filter_chips.dart';

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
          const SizedBox(height: FfSpace.xs),
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
                  padding: const EdgeInsets.all(FfSpace.sm),
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
                  padding: const EdgeInsets.all(FfSpace.lg),
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
                  horizontal: FfSpace.lg,
                  vertical: FfSpace.md,
                ),
                children: [
                  // 1. Privacy Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: FfSpace.md),
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: context.ff.color.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      border: Border.all(
                        color: context.ff.color.borderSubtle,
                        width: FfBorderWidth.hairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: context.ff.color.actionPrimary,
                        ),
                        const SizedBox(width: FfSpace.sm),
                        Expanded(
                          child: Text(
                            'Private on-device review. Unapproved items are kept separate from your ledger reports and balances.',
                            style: context.ff.text.label.copyWith(
                              color: context.ff.color.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Filter Chips
                  ReviewFilterChips(
                    selectedFilter: _selectedFilter,
                    totalCount: items.length,
                    duplicatesCount: duplicatesCount,
                    uncertainCount: uncertainCount,
                    errorsCount: errorsCount,
                    onFilterSelected:
                        (f) => setState(() => _selectedFilter = f),
                  ),
                  const SizedBox(height: FfSpace.lg),

                  // 3. Pending items or filter empty state
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: FfSpace.x3l,
                      ),
                      child: ReviewFilterEmptyState(
                        filter: _selectedFilter,
                        onResetFilter:
                            () => setState(() => _selectedFilter = 'all'),
                      ),
                    )
                  else
                    for (final item in filtered)
                      PendingTransactionCard(
                        item: item,
                        accounts: accounts,
                        busy: busy,
                        onApprove:
                            () => _runAction(() async {
                              final merchant =
                                  item.merchantDisplayName ??
                                  (item.normalizedMerchant.isNotEmpty
                                      ? item.normalizedMerchant
                                      : item.rawMerchant);
                              await ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(item);
                              if (context.mounted) {
                                FfToast.show(
                                  context,
                                  message: '$merchant approved.',
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
                        onDismiss:
                            () => _runAction(() async {
                              final merchant =
                                  item.merchantDisplayName ??
                                  (item.normalizedMerchant.isNotEmpty
                                      ? item.normalizedMerchant
                                      : item.rawMerchant);
                              await ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .dismissItem(item.tempId, item: item);
                              if (context.mounted) {
                                FfToast.show(
                                  context,
                                  message: '$merchant dismissed.',
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
                            }),
                        onEdit: () => _openEditItemSheet(context, item),
                        onMerge:
                            () => _runAction(() async {
                              final merchant =
                                  item.merchantDisplayName ??
                                  (item.normalizedMerchant.isNotEmpty
                                      ? item.normalizedMerchant
                                      : item.rawMerchant);
                              final mergeItem = item.copyWith(
                                duplicateResolution: DuplicateResolution.merge,
                              );
                              await ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(mergeItem);
                              if (context.mounted) {
                                FfToast.show(
                                  context,
                                  message: '$merchant merged with existing.',
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
                        onKeepBoth:
                            () => _runAction(() async {
                              final merchant =
                                  item.merchantDisplayName ??
                                  (item.normalizedMerchant.isNotEmpty
                                      ? item.normalizedMerchant
                                      : item.rawMerchant);
                              await ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(
                                    item.copyWith(
                                      duplicateResolution:
                                          DuplicateResolution.keepBoth,
                                    ),
                                  );
                              if (context.mounted) {
                                FfToast.show(
                                  context,
                                  message:
                                      '$merchant approved (kept separate).',
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

                  const SizedBox(height: FfSpace.x4l),
                ],
              ),
    );
  }
}
