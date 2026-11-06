import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Loans on Home: the next EMI on a rose hero card. The ring around the
/// icon shows how much of that loan's principal is paid off.
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
    if (activeLoans.isEmpty) return const SizedBox.shrink();

    final sortedLoans = List<Loan>.from(activeLoans)
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    final nextLoan = sortedLoans.first;
    final paid = nextLoan.progressPercentage;
    final open =
        onOpenLoanDetail != null
            ? () => onOpenLoanDetail!(nextLoan)
            : onViewLoans;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Loans & EMI',
            padding: EdgeInsets.zero,
            trailing: TextButton(
              onPressed: onViewLoans,
              child: const Text('Manage'),
            ),
          ),
          FfHeroCard(
            tone: FfHeroTone.rose,
            leading: FfProgressRing(
              value: paid,
              icon: Icons.account_balance_outlined,
              semanticsLabel: '${(paid * 100).round()}% of the principal paid',
            ),
            title: nextLoan.name,
            subtitle:
                activeLoans.length == 1
                    ? '1 active loan'
                    : '${activeLoans.length} active loans',
            onOpen: open,
            openTooltip: 'Open ${nextLoan.name}',
            child: Builder(
              builder: (context) {
                final ff = context.ff;
                Widget stat(String label, double amount, String caption) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: ff.text.label),
                        const SizedBox(height: FfSpace.x3s),
                        FfAmountText(
                          amount: amount,
                          size: FfAmountSize.md,
                          isBlurred: isPrivacyBlur,
                          showSign: false,
                          tone: FfTone.neutral,
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        Text(caption, style: ff.text.label),
                      ],
                    );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: stat(
                        'Next EMI Due',
                        nextLoan.emiAmount,
                        DateFormatter.formatTransactionDate(
                          nextLoan.nextDueDate,
                        ),
                      ),
                    ),
                    const SizedBox(width: FfSpace.md),
                    Expanded(
                      child: stat(
                        'Left to pay',
                        totalOutstanding,
                        'Principal + interest',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
