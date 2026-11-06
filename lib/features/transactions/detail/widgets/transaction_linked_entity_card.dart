import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/currency_formatter.dart';
import '../../../../models/money_record.dart';
import '../../../../models/transaction.dart';
import '../../../../repositories/loan_repository.dart';
import '../../../../repositories/subscription_repository.dart';
import '../../../../shared/widgets/ff_allocation_band.dart';
import '../../../../shared/widgets/ff_card.dart';
import '../../../../shared/widgets/ff_icon_tile.dart';
import '../../../../shared/widgets/ff_monogram_tile.dart';
import '../../../../shared/widgets/ff_renewal_chip.dart';
import '../../../../shared/widgets/ff_section_header.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/ff_tone.dart';
import '../../../loans/loan_detail_screen.dart';
import '../../../personal_debts/money_record_detail_screen.dart';
import '../../../personal_debts/money_records_controller.dart';
import '../../../subscriptions/subscription_detail_screen.dart';

/// Contextual bridge card displaying connections to Subscriptions,
/// Loans, or Personal Debt ledgers for [TransactionDetailScreen].
class TransactionLinkedEntityCard extends ConsumerWidget {
  final Transaction transaction;

  const TransactionLinkedEntityCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ff = context.ff;

    // ── 1. Linked Subscription Bridge ──────────────────────────────
    if (transaction.linkedSubscriptionId != null) {
      final subsAsync = ref.watch(allSubscriptionsStreamProvider);
      final sub =
          subsAsync.value
              ?.where((s) => s.id == transaction.linkedSubscriptionId)
              .firstOrNull;

      final merchantName =
          sub?.merchant ?? transaction.merchant.ifEmpty('Subscription');
      final isFound = sub != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FfSectionHeader(title: 'Linked Plan'),
          const SizedBox(height: FfSpace.xs),
          FfCard(
            onTap:
                isFound
                    ? () => SubscriptionDetailScreen.push(
                      context,
                      subscription: sub,
                    )
                    : null,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                FfMonogramTile(
                  name: merchantName,
                  size: 40,
                  radius: FfRadius.md,
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchantName,
                        style: ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        isFound
                            ? 'Billed ${sub.billingFrequency.displayName.toLowerCase()} · ${CurrencyFormatter.formatAmount(sub.amount)}'
                            : 'Plan archived or no longer tracked',
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFound) ...[
                  const SizedBox(width: FfSpace.xs),
                  FfRenewalChip(
                    daysUntilRenewal: sub.daysUntilRenewal(),
                    compact: true,
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: ff.color.textTertiary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FfSpace.lg),
        ],
      );
    }

    // ── 2. Linked Loan / EMI Bridge ────────────────────────────────
    if (transaction.linkedLoanId != null) {
      final loansAsync = ref.watch(allLoansStreamProvider);
      final loan =
          loansAsync.value
              ?.where((l) => l.id == transaction.linkedLoanId)
              .firstOrNull;

      final loanName = loan?.name ?? 'Loan EMI';
      final lender = loan?.lender ?? 'Bank';

      final principal = transaction.principalAmount;
      final interest = transaction.interestAmount;
      final fee = transaction.feeAmount;
      final totalSplit = principal + interest + fee;

      final hasSplit = totalSplit > 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FfSectionHeader(title: 'Linked Loan'),
          const SizedBox(height: FfSpace.xs),
          FfCard(
            onTap:
                loan != null
                    ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoanDetailScreen(loan: loan),
                      ),
                    )
                    : null,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const FfIconTile(
                      icon: Icons.account_balance_outlined,
                      tone: FfTone.primary,
                    ),
                    const SizedBox(width: FfSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loanName,
                            style: ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: FfSpace.x3s),
                          Text(
                            '$lender · ${loan != null ? 'Remaining ${CurrencyFormatter.formatAmount(loan.outstandingPrincipal)}' : 'Archived loan'}',
                            style: ff.text.bodySm.copyWith(
                              color: ff.color.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (loan != null) ...[
                      const SizedBox(width: FfSpace.xs),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: ff.color.textTertiary,
                      ),
                    ],
                  ],
                ),
                if (hasSplit) ...[
                  const SizedBox(height: FfSpace.md),
                  FfAllocationBand(
                    slices: [
                      if (principal > 0)
                        FfAllocationSlice(
                          label: 'Principal',
                          value: principal,
                          percentage: (principal / totalSplit) * 100,
                          tone: FfTone.primary,
                        ),
                      if (interest > 0)
                        FfAllocationSlice(
                          label: 'Interest',
                          value: interest,
                          percentage: (interest / totalSplit) * 100,
                          tone: FfTone.expense,
                        ),
                      if (fee > 0)
                        FfAllocationSlice(
                          label: 'Fees',
                          value: fee,
                          percentage: (fee / totalSplit) * 100,
                          tone: FfTone.neutral,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FfSpace.lg),
        ],
      );
    }

    // ── 3. Linked Personal Debt Bridge ─────────────────────────────
    if (transaction.linkedMoneyRecordId != null) {
      final recordsAsync = ref.watch(allMoneyRecordsStreamProvider);
      final record =
          recordsAsync.value
              ?.where((r) => r.id == transaction.linkedMoneyRecordId)
              .firstOrNull;

      final contactName =
          record?.personName ??
          transaction.externalCounterpartyName ??
          'Contact';
      final isFound = record != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FfSectionHeader(title: 'Linked Debt Ledger'),
          const SizedBox(height: FfSpace.xs),
          FfCard(
            onTap:
                isFound
                    ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MoneyRecordDetailScreen(record: record),
                      ),
                    )
                    : null,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                FfMonogramTile(
                  name: contactName,
                  size: 40,
                  radius: FfRadius.md,
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contactName,
                        style: ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        isFound
                            ? (record.type == MoneyRecordType.lent
                                ? 'Money you lent'
                                : 'Money you borrowed')
                            : 'Personal debt entry',
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isFound) ...[
                  const SizedBox(width: FfSpace.xs),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 16,
                    color: ff.color.textTertiary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: FfSpace.lg),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

extension on String? {
  String ifEmpty(String fallback) =>
      (this == null || this!.isEmpty) ? fallback : this!;
}
