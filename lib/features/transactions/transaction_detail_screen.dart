import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/date_formatter.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/transaction.dart';
import '../../repositories/subscription_repository.dart';
import '../../services/ingestion/transaction_merge_service.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../accounts/accounts_controller.dart';
import '../subscriptions/subscription_detail_screen.dart';
import 'add_edit_transaction_screen.dart';
import 'transactions_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../theme/ff.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];
    final subscriptions = ref.watch(allSubscriptionsStreamProvider).value ?? [];
    final account =
        accounts.where((a) => a.id == transaction.accountId).firstOrNull;
    final toAccount =
        transaction.toAccountId != null
            ? accounts.where((a) => a.id == transaction.toAccountId).firstOrNull
            : null;
    final linkedSubscription =
        transaction.linkedSubscriptionId != null
            ? subscriptions
                .where((s) => s.id == transaction.linkedSubscriptionId)
                .firstOrNull
            : null;

    return Scaffold(
      appBar: FfAppBar(
        title: 'Transaction Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit transaction',
            onPressed: () {
              AddEditTransactionScreen.push<void>(
                context,
                initialTransaction: transaction,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.ff.color.statusError,
            ),
            tooltip: 'Delete transaction',
            onPressed: () async {
              final confirmed = await FfDialog.confirm(
                context,
                title: 'Delete Transaction?',
                message:
                    transaction.linkedLoanId != null
                        ? 'Delete this payment and reopen its linked EMI installment? The loan balance and next due date will be recalculated. This can be undone briefly.'
                        : transaction.linkedMoneyRecordId != null
                        ? 'Delete this linked ledger operation? The personal debt balance and settlement status will be recalculated. This can be undone briefly.'
                        : transaction.linkedSubscriptionId != null
                        ? 'Delete this subscription payment? The payment will no longer appear in the subscription\'s history. This can be undone briefly.'
                        : 'Are you sure you want to delete this transaction for "${transaction.merchant}"? This action can be undone briefly.',
                confirmLabel: 'Delete',
                destructive: true,
              );

              if (confirmed == true && context.mounted) {
                await ref
                    .read(transactionsControllerProvider.notifier)
                    .deleteTransaction(transaction);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  FfToast.show(
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
            padding: EdgeInsets.only(right: FfSpace.md),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.lg,
          FfSpace.md,
          FfSpace.lg,
          FfSpace.x4l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Hero Amount & Merchant ─────────────────────────────
            FfCard(
              variant: FfCardVariant.elevated,
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.lg,
                vertical: FfSpace.xl,
              ),
              child: Center(
                child: Column(
                  children: [
                    FfCategoryTile(
                      iconIdentifier: transaction.categoryIcon,
                      colorTokenIdentifier: transaction.categoryColor,
                      size: 56,
                    ),
                    const SizedBox(height: FfSpace.md),
                    Text(
                      transaction.merchant,
                      style: context.ff.text.titleLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FfSpace.xs),
                    FfAmountText(
                      amount: transaction.amount,
                      type: transaction.type,
                      size: FfAmountSize.hero,
                      showSign: true,
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.sm,
                        vertical: FfSpace.x3s,
                      ),
                      decoration: BoxDecoration(
                        color: context.ff.color.surfaceContainerHighest
                            .withValues(alpha: FfOpacity.half),
                        borderRadius: BorderRadius.circular(FfRadius.full),
                      ),
                      child: Text(
                        transaction.effectivePurpose.displayName,
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: FfSpace.md),

            // ── 2. Provenance Card ────────────────────────────────────
            FfCard(
              variant: FfCardVariant.tinted,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Row(
                children: [
                  Icon(
                    transaction.mergedSources.length > 1
                        ? Icons.call_merge_rounded
                        : Icons.shield_outlined,
                    size: 20,
                    color:
                        transaction.mergedSources.length > 1
                            ? context.ff.color.accent
                            : context.ff.color.statusSuccess,
                  ),
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TransactionMergeService.formatProvenanceSummary(
                            transaction,
                          ),
                          style: context.ff.text.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                transaction.mergedSources.length > 1
                                    ? context.ff.color.accent
                                    : context.ff.color.statusSuccess,
                          ),
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          'Processed 100% locally on this device · 0 bytes sent off-device',
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.lg),

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
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Raw Payee',
                      value: transaction.originalMerchant!,
                    ),
                  ],
                  if (transaction.sourceReference != null &&
                      transaction.sourceReference!.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Reference / UTR',
                      value: transaction.sourceReference!,
                    ),
                  ],
                  if (transaction.mergedSources.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Merged Sources',
                      value: transaction.mergedSources.join(', '),
                    ),
                  ],
                  const FfDivider(),
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
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Destination Account',
                      value:
                          '${toAccount.name} ${toAccount.maskedIdentifier ?? ''}',
                    ),
                  ],
                  if (transaction.externalCounterpartyName != null &&
                      transaction.externalCounterpartyName!.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Counterparty',
                      value: transaction.externalCounterpartyName!,
                    ),
                  ],
                  if (transaction.linkedLoanId != null) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Loan link',
                      value: transaction.linkedLoanId!,
                    ),
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Payment split',
                      value:
                          'Principal ${CurrencyFormatter.formatAmount(transaction.principalAmount)} · Interest ${CurrencyFormatter.formatAmount(transaction.interestAmount)} · Fees ${CurrencyFormatter.formatAmount(transaction.feeAmount)}',
                    ),
                  ],
                  if (transaction.linkedSubscriptionId != null) ...[
                    const FfDivider(),
                    _buildSubscriptionRow(
                      context,
                      linkedSubscription: linkedSubscription,
                      subscriptionId: transaction.linkedSubscriptionId!,
                      onTap:
                          linkedSubscription != null
                              ? () {
                                SubscriptionDetailScreen.push(
                                  context,
                                  subscription: linkedSubscription,
                                );
                              }
                              : null,
                    ),
                  ],
                  const FfDivider(),
                  _buildDetailRow(
                    context,
                    label: 'Date & Time',
                    value: DateFormatter.formatDetailDate(transaction.date),
                  ),
                  if (transaction.paymentMethod != null &&
                      transaction.paymentMethod!.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Payment Method',
                      value: transaction.paymentMethod!,
                    ),
                  ],
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Notes',
                      value: transaction.notes!,
                    ),
                  ],
                  if (transaction.tags.isNotEmpty) ...[
                    const FfDivider(),
                    _buildDetailRow(
                      context,
                      label: 'Tags',
                      value: transaction.tags.join(', '),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 4. Quick Actions ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FfButton(
                    label: 'Edit Transaction',
                    variant: FfButtonVariant.primary,
                    leadingIcon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () {
                      AddEditTransactionScreen.push<void>(
                        context,
                        initialTransaction: transaction,
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.lg,
        vertical: FfSpace.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.ff.text.bodySm.copyWith(
                color: context.ff.color.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (leading != null) ...[leading, const SizedBox(width: FfSpace.xs)],
          Expanded(
            child: Text(
              value,
              style: context.ff.text.body.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRow(
    BuildContext context, {
    required dynamic linkedSubscription,
    required String subscriptionId,
    required VoidCallback? onTap,
  }) {
    final name =
        linkedSubscription?.merchant as String? ??
        'Subscription no longer tracked';
    final isResolved = linkedSubscription != null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Subscription',
                style: context.ff.text.bodySm.copyWith(
                  color: context.ff.color.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.subscriptions_outlined,
              size: 16,
              color:
                  isResolved
                      ? context.ff.color.actionPrimary
                      : context.ff.color.textSecondary,
            ),
            const SizedBox(width: FfSpace.xs),
            Expanded(
              child: Text(
                name,
                style: context.ff.text.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isResolved
                          ? context.ff.color.actionPrimary
                          : context.ff.color.textSecondary,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            if (isResolved) ...[
              const SizedBox(width: FfSpace.x2s),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: context.ff.color.actionPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
