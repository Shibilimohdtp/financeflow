import 'package:flutter/material.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/ff.dart';

class HomeLoansOverview extends StatelessWidget {
  final List<Loan> activeLoans;
  final double totalOutstanding;
  final double totalMonthlyEmi;
  final bool isPrivacyBlur;
  final VoidCallback onViewLoans;
  final ValueChanged<Loan>? onOpenLoanDetail;

  const HomeLoansOverview({
    super.key,
    required this.activeLoans,
    required this.totalOutstanding,
    required this.totalMonthlyEmi,
    required this.isPrivacyBlur,
    required this.onViewLoans,
    this.onOpenLoanDetail,
  });

  @override
  Widget build(BuildContext context) {
    final finColors = context.ff.color;

    if (activeLoans.isEmpty) return const SizedBox.shrink();

    // Find next upcoming loan
    final sortedLoans = List<Loan>.from(activeLoans)
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final nextLoan = sortedLoans.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Loans & EMI',
                  style: context.ff.text.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onViewLoans,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          Material(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(FfRadius.lg),
              onTap:
                  onOpenLoanDetail != null
                      ? () => onOpenLoanDetail!(nextLoan)
                      : onViewLoans,
              child: Container(
                padding: const EdgeInsets.all(FfSpace.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(FfRadius.lg),
                  border: Border.all(
                    color: context.ff.color.borderSubtle,
                    width: FfBorderWidth.hairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(FfSpace.x2s),
                                decoration: BoxDecoration(
                                  color: finColors.moneyDebt.withValues(
                                    alpha: FfTint.subtle.alpha,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    FfRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_outlined,
                                  size: 16,
                                  color: finColors.moneyDebt,
                                ),
                              ),
                              const SizedBox(width: FfSpace.sm),
                              Flexible(
                                child: Text(
                                  nextLoan.name,
                                  style: context.ff.text.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: FfSpace.xs),
                        Text(
                          '${activeLoans.length} active',
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next EMI Due',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              FfAmountText(
                                amount: nextLoan.emiAmount,
                                size: FfAmountSize.md,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                tone: FfTone.debt,
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Text(
                                DateFormatter.formatTransactionDate(
                                  nextLoan.nextDueDate,
                                ),
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: context.ff.color.borderSubtle,
                        ),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Left to pay',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              FfAmountText(
                                amount: totalOutstanding,
                                size: FfAmountSize.md,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                tone: FfTone.neutral,
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Text(
                                'Principal + interest',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
