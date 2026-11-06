import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_section_header.dart';
import 'add_edit_loan_sheet.dart';
import 'loan_detail_screen.dart';
import 'loans_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_corner_badge.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../theme/ff_tone.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../shared/widgets/ff_surfaces.dart';
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

    return FfPageScaffold(
      title: 'Loans & EMIs',
      subtitle: 'Loans on this device',
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
              FfSpace.pageMargin,
              FfSpace.md,
              FfSpace.pageMargin,
              104,
            ),
            children: [
              // ── 1. Summary Hero ─────────────────────────────────────────
              FfHeroCard(
                tone: FfHeroTone.rose,
                title: 'Total outstanding',
                subtitle:
                    summary.activeLoansCount == 1
                        ? '1 active loan'
                        : '${summary.activeLoansCount} active loans',
                child: Builder(
                  builder:
                      (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FfAmountText(
                            amount: summary.totalOutstanding,
                            size: FfAmountSize.hero,
                            tone: FfTone.neutral,
                            showSign: false,
                          ),
                          const SizedBox(height: FfSpace.xs),
                          Text(
                            'Monthly EMI ${CurrencyFormatter.formatAmount(summary.totalMonthlyEmi)} · '
                            '${loans.length} total ${loans.length == 1 ? 'record' : 'records'}',
                            style: context.ff.text.label,
                          ),
                        ],
                      ),
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

                      final remaining =
                          ref.watch(loanRemainingBalanceProvider(loan)).total;
                      final percent = (paidProgress * 100).toStringAsFixed(0);
                      Widget ring = FfProgressRing(
                        value: paidProgress,
                        icon: _getLoanTypeIcon(loan.loanType),
                        semanticsLabel: '$percent% paid off',
                      );
                      if (isOverdue) {
                        ring = FfCornerBadge(
                          corner: FfCorner.warning,
                          child: ring,
                        );
                      }
                      return FfCard(
                        onTap: () => _openDetail(context, loan),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconTheme.merge(
                                  data: IconThemeData(
                                    color: context.ff.color.textPrimary,
                                  ),
                                  child: ring,
                                ),
                                const SizedBox(width: FfSpace.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loan.name,
                                        style: context.ff.text.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${loan.lender} · ${loan.interestRate}% ${loan.interestType.displayName.toLowerCase()}',
                                        style: context.ff.text.bodySm,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: FfSpace.sm),
                                FfInkButton.open(
                                  onPressed: () => _openDetail(context, loan),
                                  tooltip: 'Open ${loan.name}',
                                  small: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: FfSpace.md),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: FfStatTile(
                                    label: 'Left to pay',
                                    value: FfAmountText(
                                      amount: remaining,
                                      size: FfAmountSize.lg,
                                      tone: FfTone.neutral,
                                      showSign: false,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: FfSpace.sm),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'EMI ${CurrencyFormatter.formatAmount(loan.emiAmount)}',
                                      style: context.ff.text.label,
                                    ),
                                    const SizedBox(height: FfSpace.x2s),
                                    if (isOverdue)
                                      const FfBadge(
                                        label: 'Overdue',
                                        tone: FfTone.error,
                                        icon: Icons.error_outline_rounded,
                                      )
                                    else
                                      Text(
                                        'Due on ${loan.paymentDay}th',
                                        style: context.ff.text.label,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: FfSpace.x2s),
                            Text(
                              '$percent% paid off',
                              style: context.ff.text.label,
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
                            leading: const FfIconTile(
                              icon: Icons.check_circle_outline_rounded,
                              tone: FfTone.income,
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
