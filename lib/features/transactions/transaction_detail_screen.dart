import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../models/transaction.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../accounts/accounts_controller.dart';
import '../settings/settings_controller.dart';
import 'add_edit_transaction_screen.dart';
import 'detail/widgets/transaction_detail_hero.dart';
import 'detail/widgets/transaction_linked_entity_card.dart';
import 'detail/widgets/transaction_provenance_card.dart';
import 'transactions_controller.dart';

/// The Stillwater Bloom Transaction Detail Screen (Pattern D, Sand/Dusk Hero).
///
/// Features:
/// 1. Type-reactive `TransactionDetailHero` (Sand for expense/income, Dusk for transfer).
/// 2. Interactive `TransactionLinkedEntityCard` bridging to Subscriptions, Loans, or Debts.
/// 3. Semantic `FfGroupedContainer` for payment & categorization facts.
/// 4. On-device `TransactionProvenanceCard` for UTR reference copy and raw evidence disclosure.
/// 5. Ink primary "Edit Transaction" action and separated destructive delete with undo.
class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  static Future<T?> push<T>(
    BuildContext context, {
    required Transaction transaction,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (ctx) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  void _edit(BuildContext context) {
    AddEditTransactionScreen.push<void>(
      context,
      initialTransaction: transaction,
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
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
            ref.read(transactionsControllerProvider.notifier).undoDelete();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(rawAccountsStreamProvider).value ?? [];
    final account =
        accounts.where((a) => a.id == transaction.accountId).firstOrNull;
    final toAccount =
        transaction.toAccountId != null
            ? accounts.where((a) => a.id == transaction.toAccountId).firstOrNull
            : null;

    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final isPrivacyBlur = settings.isPrivacyBlurEnabled;

    final hasNotes = transaction.notes != null && transaction.notes!.isNotEmpty;
    final hasTags = transaction.tags.isNotEmpty;
    final hasPaymentMethod =
        transaction.paymentMethod != null &&
        transaction.paymentMethod!.isNotEmpty;
    final hasCounterparty =
        transaction.externalCounterpartyName != null &&
        transaction.externalCounterpartyName!.isNotEmpty;

    return Scaffold(
      appBar: FfAppBar(
        title: transaction.merchant,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit transaction',
            onPressed: () => _edit(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: FfSpace.md),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.pageMargin,
          FfSpace.sm,
          FfSpace.pageMargin,
          112,
        ),
        children: [
          // ── 1. Type-Reactive Hero Card (Pattern D) ──────────────────
          TransactionDetailHero(
            transaction: transaction,
            account: account,
            toAccount: toAccount,
            isPrivacyBlur: isPrivacyBlur,
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 2. Linked Entity Bridge (Subscription / Loan / Debt) ────
          TransactionLinkedEntityCard(transaction: transaction),

          // ── 3. Plan & Payment Facts ─────────────────────────────────
          const FfSectionHeader(title: 'Payment Details'),
          const SizedBox(height: FfSpace.xs),
          FfGroupedContainer(
            children: [
              FfRow(
                title: 'Category',
                subtitle: transaction.categoryName,
                leading:
                    transaction.categoryIcon.isNotEmpty &&
                            transaction.categoryColor.isNotEmpty
                        ? FfCategoryTile(
                          iconIdentifier: transaction.categoryIcon,
                          colorTokenIdentifier: transaction.categoryColor,
                          size: 32,
                        )
                        : null,
                icon:
                    transaction.categoryIcon.isEmpty
                        ? Icons.category_outlined
                        : null,
                iconTone: FfTone.primary,
                showChevron: false,
              ),
              FfRow(
                icon: Icons.account_balance_outlined,
                iconTone: FfTone.primary,
                title: 'Account',
                subtitle:
                    account != null
                        ? '${account.name} ${account.maskedIdentifier ?? ''}'
                            .trim()
                        : 'Main Account',
                showChevron: false,
              ),
              if (transaction.type == TransactionType.transfer &&
                  toAccount != null)
                FfRow(
                  icon: Icons.login_rounded,
                  iconTone: FfTone.transfer,
                  title: 'Destination Account',
                  subtitle:
                      '${toAccount.name} ${toAccount.maskedIdentifier ?? ''}'
                          .trim(),
                  showChevron: false,
                ),
              if (hasCounterparty)
                FfRow(
                  icon: Icons.person_outline_rounded,
                  iconTone: FfTone.neutral,
                  title: 'Counterparty',
                  subtitle: transaction.externalCounterpartyName!,
                  showChevron: false,
                ),
              if (hasPaymentMethod)
                FfRow(
                  icon: Icons.payment_rounded,
                  iconTone: FfTone.neutral,
                  title: 'Payment Method',
                  subtitle: transaction.paymentMethod!,
                  showChevron: false,
                ),
              if (hasNotes)
                FfRow(
                  icon: Icons.notes_rounded,
                  iconTone: FfTone.neutral,
                  title: 'Notes',
                  subtitle: transaction.notes!,
                  showChevron: false,
                ),
              if (hasTags)
                FfRow(
                  icon: Icons.tag_rounded,
                  iconTone: FfTone.neutral,
                  title: 'Tags',
                  subtitle: transaction.tags.join(', '),
                  showChevron: false,
                ),
            ],
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 4. Provenance & Audit Trail ─────────────────────────────
          TransactionProvenanceCard(transaction: transaction),

          const SizedBox(height: FfSpace.xl),

          // ── 5. Primary Action: Edit Transaction ──────────────────────
          FfButton(
            label: 'Edit Transaction',
            variant: FfButtonVariant.primary,
            leadingIcon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => _edit(context),
          ),

          const SizedBox(height: FfSpace.md),

          // ── 6. Destructive Action: Delete Transaction ────────────────
          Center(
            child: FfButton(
              label: 'Delete Transaction',
              variant: FfButtonVariant.destructive,
              leadingIcon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () => _delete(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
