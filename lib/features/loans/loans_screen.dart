import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_loan_sheet.dart';
import 'loan_detail_screen.dart';
import 'loans_controller.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddEditLoanSheet(),
    );
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
      appBar: AppBar(
        title: const Text('Loans & EMIs'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: loansAsync.when(
        data: (loans) {
          final activeLoans =
              loans.where((l) => l.status == LoanStatus.active).toList();
          final closedLoans =
              loans.where((l) => l.status != LoanStatus.active).toList();

          return ListView(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            children: [
              // Total Outstanding Principal Hero Card
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Outstanding Debt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    Text(
                      CurrencyFormatter.formatINR(summary.totalOutstanding),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly EMI: ${CurrencyFormatter.formatINR(summary.totalMonthlyEmi)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '${summary.activeLoansCount} active loans',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              if (loans.isEmpty)
                Center(
                  child: Padding(
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
                  ),
                )
              else ...[
                if (activeLoans.isNotEmpty) ...[
                  Text('Active Loans', style: theme.textTheme.titleMedium),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeLoans.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(height: StillwaterTokens.spaceSm),
                    itemBuilder: (context, index) {
                      final loan = activeLoans[index];
                      final days = loan.daysUntilDue();

                      return FfCard(
                        onTap: () => _openDetail(context, loan),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loan.name,
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${loan.lender} · ${loan.loanType.displayName}',
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
                                      CurrencyFormatter.formatINR(
                                        loan.outstandingPrincipal,
                                      ),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      'EMI: ${CurrencyFormatter.formatINR(loan.emiAmount)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: StillwaterTokens.spaceSm),
                            LinearProgressIndicator(
                              value: loan.progressPercentage,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              color: context.secColors.verified,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: StillwaterTokens.space2Xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Next due: ${DateFormatter.formatTransactionDate(loan.nextDueDate)} (${days == 0 ? "Today" : (days == 1 ? "Tomorrow" : "in $days d")})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color:
                                        days <= 3
                                            ? context.secColors.error
                                            : theme.colorScheme.secondary,
                                  ),
                                ),
                                Text(
                                  '${(loan.progressPercentage * 100).toStringAsFixed(0)}% paid',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
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

                if (closedLoans.isNotEmpty) ...[
                  const SizedBox(height: StillwaterTokens.space2Xl),
                  Text(
                    'Paid Off & Archived',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: closedLoans.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(height: StillwaterTokens.spaceSm),
                    itemBuilder: (context, index) {
                      final loan = closedLoans[index];
                      return FfCard(
                        onTap: () => _openDetail(context, loan),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: context.secColors.verified,
                              size: 24,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loan.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${loan.lender} · Paid Off',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: context.secColors.verified,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatINR(loan.principalAmount),
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Loan'),
      ),
    );
  }
}
