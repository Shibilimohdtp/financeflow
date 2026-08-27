import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../repositories/pending_transaction_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_chip.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'needs_review_controller.dart';
import '../transactions/add_edit_transaction_sheet.dart';

class NeedsReviewScreen extends ConsumerStatefulWidget {
  const NeedsReviewScreen({super.key});

  @override
  ConsumerState<NeedsReviewScreen> createState() => _NeedsReviewScreenState();
}

class _NeedsReviewScreenState extends ConsumerState<NeedsReviewScreen> {
  String _selectedFilter = 'all'; // all, duplicates, uncertain, errors

  void _openEditItemSheet(BuildContext context, ParsedTransaction item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => AddEditTransactionSheet(
            initialTransaction: item.toTransaction(targetId: item.tempId),
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
          ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) {
        FfSnackbar.show(
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
      appBar: AppBar(
        title: const Text('Needs Review Queue'),
        actions: [
          if (items.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.playlist_add_check_rounded),
              tooltip: 'Approve All Valid',
              onPressed:
                  busy
                      ? null
                      : () => _runAction(() async {
                        final count = await ref
                            .read(needsReviewControllerProvider.notifier)
                            .approveAllValid(items);
                        if (context.mounted) {
                          FfSnackbar.show(
                            context,
                            message: 'Approved $count valid transactions.',
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
                      }),
            ),
          ],
        ],
      ),
      body:
          pending.isLoading
              ? const Center(child: CircularProgressIndicator())
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
                            'Uncertain (${items.where((i) => i.categorizationConfidence < 0.7 || i.hasWarnings).length})',
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
                    _buildPendingItemCard(context, item, busy),

                  const SizedBox(height: StillwaterTokens.space4Xl),
                ],
              ),
    );
  }

  Widget _buildPendingItemCard(
    BuildContext context,
    ParsedTransaction item,
    bool busy,
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
          Wrap(
            spacing: StillwaterTokens.spaceSm,
            runSpacing: StillwaterTokens.spaceXs,
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
                      item.merchantDisplayName ??
                          (item.normalizedMerchant.isNotEmpty
                              ? item.normalizedMerchant
                              : item.rawMerchant),
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

          if (item.categorizationConfidence < 0.7)
            const Text('Review reason: category needs confirmation'),
          if (item.normalizedMerchant == 'Bank Transaction')
            const Text('Payee not identified — please edit before approving'),
          // Action Buttons
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                onPressed:
                    busy
                        ? null
                        : () => _runAction(
                          () => ref
                              .read(needsReviewControllerProvider.notifier)
                              .dismissItem(item.tempId),
                        ),
                child: const Text('Dismiss'),
              ),
              TextButton(
                onPressed:
                    busy ? null : () => _openEditItemSheet(context, item),
                child: const Text('Edit'),
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              if (item.isDuplicate &&
                  (item.matchedTransaction != null ||
                      item.matchedTransactionId != null)) ...[
                TextButton(
                  onPressed:
                      busy || !item.isValid
                          ? null
                          : () => _runAction(
                            () => ref
                                .read(needsReviewControllerProvider.notifier)
                                .approveItem(
                                  item.copyWith(
                                    duplicateResolution:
                                        DuplicateResolution.keepBoth,
                                  ),
                                ),
                          ),
                  child: const Text('Keep Both'),
                ),
                FfButton(
                  label: 'Merge',
                  variant: FfButtonVariant.secondary,
                  onPressed:
                      busy || !item.isValid
                          ? null
                          : () {
                            final mergeItem = item.copyWith(
                              duplicateResolution: DuplicateResolution.merge,
                            );
                            _runAction(
                              () => ref
                                  .read(needsReviewControllerProvider.notifier)
                                  .approveItem(mergeItem),
                            );
                          },
                ),
              ] else
                FfButton(
                  label: 'Approve',
                  onPressed:
                      busy || !item.isValid
                          ? null
                          : () => _runAction(
                            () => ref
                                .read(needsReviewControllerProvider.notifier)
                                .approveItem(item),
                          ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
