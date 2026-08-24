import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/date_formatter.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/transaction.dart';
import '../../services/ingestion/transaction_merge_service.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../accounts/accounts_controller.dart';
import 'add_edit_transaction_sheet.dart';
import 'transactions_controller.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];
    final account =
        accounts.where((a) => a.id == transaction.accountId).firstOrNull;
    final toAccount =
        transaction.toAccountId != null
            ? accounts.where((a) => a.id == transaction.toAccountId).firstOrNull
            : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit transaction',
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (ctx) => AddEditTransactionSheet(
                      initialTransaction: transaction,
                    ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.error,
            ),
            tooltip: 'Delete transaction',
            onPressed: () async {
              final confirmed = await FfConfirmDialog.show(
                context,
                title: 'Delete Transaction?',
                message:
                    transaction.linkedLoanId != null
                        ? 'Delete this payment and reopen its linked EMI installment? The loan balance and next due date will be recalculated. This can be undone briefly.'
                        : transaction.linkedMoneyRecordId != null
                        ? 'Delete this linked ledger operation? The personal debt balance and settlement status will be recalculated. This can be undone briefly.'
                        : 'Are you sure you want to delete this transaction for "${transaction.merchant}"? This action can be undone briefly.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );

              if (confirmed == true && context.mounted) {
                await ref
                    .read(transactionsControllerProvider.notifier)
                    .deleteTransaction(transaction);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  FfSnackbar.show(
                    context,
                    message: 'Transaction deleted.',
                    actionLabel: 'Undo',
                    onAction: () {
                      ref
                          .read(transactionsControllerProvider.notifier)
                          .undoDelete();
                    },
                  );
                }
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceMd,
          StillwaterTokens.spaceLg,
          StillwaterTokens.space4Xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Amount & Merchant ─────────────────────────────
            FfCard(
              variant: FfCardVariant.elevated,
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
                vertical: StillwaterTokens.spaceXl,
              ),
              child: Center(
                child: Column(
                  children: [
                    FfCategoryTile(
                      iconIdentifier: transaction.categoryIcon,
                      colorTokenIdentifier: transaction.categoryColor,
                      size: 56,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    Text(
                      transaction.merchant,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    FfAmountText(
                      amount: transaction.amount,
                      type: transaction.type,
                      size: FfAmountSize.hero,
                      showSign: true,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceSm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                      ),
                      child: Text(
                        transaction.effectivePurpose.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // ── 2. Provenance Card ────────────────────────────────────
            FfCard(
              variant: FfCardVariant.tinted,
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              child: Row(
                children: [
                  Icon(
                    transaction.mergedSources.length > 1
                        ? Icons.call_merge_rounded
                        : Icons.shield_outlined,
                    size: 20,
                    color:
                        transaction.mergedSources.length > 1
                            ? context.aiColors.accent
                            : context.secColors.verified,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TransactionMergeService.formatProvenanceSummary(
                            transaction,
                          ),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                transaction.mergedSources.length > 1
                                    ? context.aiColors.accent
                                    : context.secColors.verified,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Processed 100% locally on this device · 0 bytes sent off-device',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            // ── 3. Detail Fields Table ────────────────────────────────
            FfCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Category',
                    value: transaction.categoryName,
                    leading: FfCategoryTile(
                      iconIdentifier: transaction.categoryIcon,
                      colorTokenIdentifier: transaction.categoryColor,
                      size: 24,
                    ),
                  ),
                  if (transaction.originalMerchant != null &&
                      transaction.originalMerchant!.isNotEmpty &&
                      transaction.originalMerchant != transaction.merchant) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Raw Payee',
                      value: transaction.originalMerchant!,
                    ),
                  ],
                  if (transaction.sourceReference != null &&
                      transaction.sourceReference!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Reference / UTR',
                      value: transaction.sourceReference!,
                    ),
                  ],
                  if (transaction.mergedSources.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Merged Sources',
                      value: transaction.mergedSources.join(', '),
                    ),
                  ],
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    label: 'Account',
                    value:
                        account != null
                            ? '${account.name} ${account.maskedIdentifier ?? ''}'
                            : 'Main Account',
                  ),
                  if (transaction.type == TransactionType.transfer &&
                      toAccount != null) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Destination Account',
                      value:
                          '${toAccount.name} ${toAccount.maskedIdentifier ?? ''}',
                    ),
                  ],
                  if (transaction.externalCounterpartyName != null &&
                      transaction.externalCounterpartyName!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Counterparty',
                      value: transaction.externalCounterpartyName!,
                    ),
                  ],
                  if (transaction.linkedLoanId != null) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Loan link',
                      value: transaction.linkedLoanId!,
                    ),
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Payment split',
                      value:
                          'Principal ${CurrencyFormatter.formatINR(transaction.principalAmount)} · Interest ${CurrencyFormatter.formatINR(transaction.interestAmount)} · Fees ${CurrencyFormatter.formatINR(transaction.feeAmount)}',
                    ),
                  ],
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    label: 'Date & Time',
                    value: DateFormatter.formatDetailDate(transaction.date),
                  ),
                  if (transaction.paymentMethod != null &&
                      transaction.paymentMethod!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Payment Method',
                      value: transaction.paymentMethod!,
                    ),
                  ],
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Notes',
                      value: transaction.notes!,
                    ),
                  ],
                  if (transaction.tags.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      label: 'Tags',
                      value: transaction.tags.join(', '),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceXl),

            // ── 4. Quick Actions ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FfButton(
                    label: 'Edit Transaction',
                    variant: FfButtonVariant.primary,
                    leadingIcon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (ctx) => AddEditTransactionSheet(
                              initialTransaction: transaction,
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Widget? leading,
  }) {
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceLg,
        vertical: StillwaterTokens.spaceMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (leading != null) ...[
            leading,
            const SizedBox(width: StillwaterTokens.spaceXs),
          ],
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
