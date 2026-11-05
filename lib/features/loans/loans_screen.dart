import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_loan_sheet.dart';
import 'loan_detail_screen.dart';
import 'loans_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';

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
    final theme = context.theme;
    final summary = ref.watch(loansSummaryProvider);
    final loansAsync = ref.watch(allLoansStreamProvider);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Loans & EMIs',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
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
              StillwaterTokens.spaceLg,
              StillwaterTokens.spaceMd,
              StillwaterTokens.spaceLg,
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
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (summary.activeLoansCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusFull,
                              ),
                            ),
                            child: Text(
                              '${summary.activeLoansCount} active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.totalOutstanding),
                      style: StillwaterTypography.numHero(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly EMI: ${CurrencyFormatter.formatAmount(summary.totalMonthlyEmi)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${loans.length} total ${loans.length == 1 ? 'record' : 'records'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              if (loans.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.space2Xl,
                  ),
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
                        (_, __) =>
                            const SizedBox(height: StillwaterTokens.spaceSm),
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
                                  width: StillwaterTokens.iconTileSize,
                                  height: StillwaterTokens.iconTileSize,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusSm,
                                    ),
                                  ),
                                  child: Icon(
                                    _getLoanTypeIcon(loan.loanType),
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: StillwaterTokens.spaceMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loan.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${loan.lender} · ${loan.interestRate}% ${loan.interestType.displayName.toLowerCase()}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
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
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'EMI: ${CurrencyFormatter.formatAmount(loan.emiAmount)}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: StillwaterTokens.spaceMd),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusFull,
                              ),
                              child: LinearProgressIndicator(
                                value: paidProgress,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: theme.colorScheme.primary,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceSm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(paidProgress * 100).toStringAsFixed(0)}% paid off',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isOverdue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.finColors.expenseContainer,
                                      borderRadius: BorderRadius.circular(
                                        StillwaterTokens.radiusXs,
                                      ),
                                    ),
                                    child: Text(
                                      'Overdue',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: context.finColors.expense,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    'Due on ${loan.paymentDay}th',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.secondary,
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
                  const SizedBox(height: StillwaterTokens.space2Xl),
                  const FfSectionHeader(title: 'Paid Off & Archived'),
                  FfGroupedContainer(
                    children:
                        closedLoans.map((loan) {
                          return FfListRow(
                            leading: Container(
                              width: StillwaterTokens.iconTileSize,
                              height: StillwaterTokens.iconTileSize,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusSm,
                                ),
                              ),
                              child: Icon(
                                Icons.check_circle_outline_rounded,
                                size: 20,
                                color: context.finColors.income,
                              ),
                            ),
                            title: loan.name,
                            subtitle:
                                '${loan.lender} · Closed ${DateFormatter.formatShortDate(loan.updatedAt)}',
                            trailingText: CurrencyFormatter.formatAmount(
                              loan.principalAmount,
                            ),
                            onTap: () => _openDetail(context, loan),
                          );
                        }).toList(),
                  ),
                ],
              ],

              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: CircularProgressIndicator(),
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
