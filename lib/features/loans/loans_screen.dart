import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_loan_sheet.dart';
import 'loan_detail_screen.dart';
import 'loans_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  void _openAddSheet(BuildContext context) {
    showFfSheet(context, builder: (_) => const AddEditLoanSheet());
  }

  void _openDetail(BuildContext context, Loan loan) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: loan)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(loansSummaryProvider);
    final loansAsync = ref.watch(allLoansStreamProvider);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Loans & EMIs',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.lg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'loans_add_fab',
        tooltip: 'Add loan',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Loan'),
      ),
      body: loansAsync.when(
        data: (loans) {
          final activeLoans =
              loans.where((l) => l.status == LoanStatus.active).toList();
          final closedLoans =
              loans.where((l) => l.status != LoanStatus.active).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.md,
              FfSpace.lg,
              104,
            ),
            children: [
              // ── 1. Summary Hero ─────────────────────────────────────────
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL OUTSTANDING DEBT',
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.secondary,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (summary.activeLoansCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.sm,
                              vertical: FfSpace.x3s,
                            ),
                            decoration: BoxDecoration(
                              color: context.ff.color.actionPrimary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                FfRadius.full,
                              ),
                            ),
                            child: Text(
                              '${summary.activeLoansCount} active',
                              style: context.ff.text.labelSm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.ff.color.actionPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.totalOutstanding),
                      style: StillwaterTypography.numHero(
                        color: context.ff.color.textPrimary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly EMI: ${CurrencyFormatter.formatAmount(summary.totalMonthlyEmi)}',
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${loans.length} total ${loans.length == 1 ? 'record' : 'records'}',
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.lg),

              if (loans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.x2l),
                  child: FfEmptyState(
                    icon: Icons.account_balance_outlined,
                    title: 'No loans or EMIs recorded',
                    description:
                        'Track home loans, personal loans, vehicle loans, and credit card EMIs completely on-device.',
                    actionLabel: 'Add Loan',
                    onAction: () => _openAddSheet(context),
                  ),
                )
              else ...[
                // ── 2. Active Loans ─────────────────────────────────────────
                if (activeLoans.isNotEmpty) ...[
                  const FfSectionHeader(title: 'Active Loans'),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeLoans.length,
                    separatorBuilder:
                        (_, __) => const SizedBox(height: FfSpace.sm),
                    itemBuilder: (context, index) {
                      final loan = activeLoans[index];
                      final isOverdue = loan.nextDueDate.isBefore(
                        DateTime.now(),
                      );
                      final paidProgress =
                          loan.principalAmount > 0
                              ? (loan.totalPrincipalPaid / loan.principalAmount)
                                  .clamp(0.0, 1.0)
                              : 0.0;

                      return FfCard(
                        onTap: () => _openDetail(context, loan),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: FfRowTokens.iconTile,
                                  height: FfRowTokens.iconTile,
                                  decoration: BoxDecoration(
                                    color: context
                                        .ff
                                        .color
                                        .actionPrimaryContainer
                                        .withValues(alpha: FfTint.strong.alpha),
                                    borderRadius: BorderRadius.circular(
                                      FfRadius.sm,
                                    ),
                                  ),
                                  child: Icon(
                                    _getLoanTypeIcon(loan.loanType),
                                    size: 20,
                                    color: context.ff.color.actionPrimary,
                                  ),
                                ),
                                const SizedBox(width: FfSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loan.name,
                                        style: context.ff.text.titleSm.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: FfSpace.x3s),
                                      Text(
                                        '${loan.lender} · ${loan.interestRate}% ${loan.interestType.displayName.toLowerCase()}',
                                        style: context.ff.text.bodySm.copyWith(
                                          color: context.ff.color.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatAmount(
                                        ref
                                            .watch(
                                              loanRemainingBalanceProvider(
                                                loan,
                                              ),
                                            )
                                            .total,
                                      ),
                                      style: StillwaterTypography.numMd(
                                        color: context.ff.color.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'EMI: ${CurrencyFormatter.formatAmount(loan.emiAmount)}',
                                      style: context.ff.text.labelSm.copyWith(
                                        color: context.ff.color.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: FfSpace.md),
                            FfProgressBar(
                              value: paidProgress,
                              color: context.ff.color.actionPrimary,
                              size: FfProgressSize.md,
                            ),
                            const SizedBox(height: FfSpace.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(paidProgress * 100).toStringAsFixed(0)}% paid off',
                                  style: context.ff.text.bodySm.copyWith(
                                    color: context.ff.color.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: FfSpace.x2s,
                                      vertical: FfSpace.x3s,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          context
                                              .ff
                                              .color
                                              .moneyExpenseContainer,
                                      borderRadius: BorderRadius.circular(
                                        FfRadius.xs,
                                      ),
                                    ),
                                    child: Text(
                                      'Overdue',
                                      style: context.ff.text.labelSm.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.ff.color.moneyExpense,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    'Due on ${loan.paymentDay}th',
                                    style: context.ff.text.bodySm.copyWith(
                                      color: context.ff.color.secondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                // ── 3. Closed / Archived Loans ──────────────────────────────
                if (closedLoans.isNotEmpty) ...[
                  const SizedBox(height: FfSpace.x2l),
                  const FfSectionHeader(title: 'Paid Off & Archived'),
                  FfGroupedContainer(
                    children:
                        closedLoans.map((loan) {
                          return FfRow(
                            leading: Container(
                              width: FfRowTokens.iconTile,
                              height: FfRowTokens.iconTile,
                              decoration: BoxDecoration(
                                color: context.ff.color.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  FfRadius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.check_circle_outline_rounded,
                                size: 20,
                                color: context.ff.color.moneyIncome,
                              ),
                            ),
                            title: loan.name,
                            subtitle:
                                '${loan.lender} · Closed ${DateFormatter.formatShortDate(loan.updatedAt)}',
                            detail: CurrencyFormatter.formatAmount(
                              loan.principalAmount,
                            ),
                            onTap: () => _openDetail(context, loan),
                          );
                        }).toList(),
                  ),
                ],
              ],

              const SizedBox(height: FfSpace.x4l),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(FfSpace.x4l),
                child: FfLoading(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static IconData _getLoanTypeIcon(LoanType type) {
    switch (type) {
      case LoanType.homeLoan:
        return Icons.home_outlined;
      case LoanType.personalLoan:
        return Icons.person_outline_rounded;
      case LoanType.vehicleLoan:
        return Icons.directions_car_outlined;
      case LoanType.educationLoan:
        return Icons.school_outlined;
      case LoanType.creditCardEmi:
        return Icons.credit_card_outlined;
      case LoanType.bnpl:
        return Icons.shopping_bag_outlined;
      case LoanType.other:
        return Icons.handshake_outlined;
    }
  }
}
