import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';

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
    final theme = context.theme;
    final finColors = context.finColors;

    if (activeLoans.isEmpty) return const SizedBox.shrink();

    // Find next upcoming loan
    final sortedLoans = List<Loan>.from(activeLoans)
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final nextLoan = sortedLoans.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Loans & EMI',
                  style: theme.textTheme.titleSmall?.copyWith(
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
          const SizedBox(height: StillwaterTokens.spaceXs),
          Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              onTap:
                  onOpenLoanDetail != null
                      ? () => onOpenLoanDetail!(nextLoan)
                      : onViewLoans,
              child: Container(
                padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusLg,
                  ),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: StillwaterTokens.borderWidthHairline,
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
                                padding: const EdgeInsets.all(
                                  StillwaterTokens.space2Xs,
                                ),
                                decoration: BoxDecoration(
                                  color: finColors.debt.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.account_balance_outlined,
                                  size: 16,
                                  color: finColors.debt,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceSm),
                              Flexible(
                                child: Text(
                                  nextLoan.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceXs),
                        Text(
                          '${activeLoans.length} active',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next EMI Due',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: StillwaterTokens.space3Xs),
                              FfAmountText(
                                amount: nextLoan.emiAmount,
                                size: FfAmountSize.md,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                colorOverride: finColors.debt,
                              ),
                              const SizedBox(height: StillwaterTokens.space3Xs),
                              Text(
                                DateFormatter.formatTransactionDate(
                                  nextLoan.nextDueDate,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.dividerColor,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Left to pay',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: StillwaterTokens.space3Xs),
                              FfAmountText(
                                amount: totalOutstanding,
                                size: FfAmountSize.md,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                colorOverride: theme.colorScheme.onSurface,
                              ),
                              const SizedBox(height: StillwaterTokens.space3Xs),
                              Text(
                                'Principal + interest',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
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
