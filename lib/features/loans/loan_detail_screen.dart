import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../services/loan_calculator.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_loan_sheet.dart';
import 'loans_controller.dart';
import 'widgets/emi_schedule_view.dart';

class LoanDetailScreen extends ConsumerWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  void _edit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditLoanSheet(initialLoan: loan),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Loan?',
      message:
          'Are you sure you want to remove "${loan.name}" from your tracker?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(loansControllerProvider.notifier).deleteLoan(loan.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Loan deleted.');
      }
    }
  }

  Future<void> _markPaid(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Record EMI Payment?',
      message:
          'Record an EMI payment of ${CurrencyFormatter.formatINR(loan.emiAmount)} for ${loan.name}? This will update the outstanding balance and advance the next due date.',
      confirmLabel: 'Confirm Payment',
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(loansControllerProvider.notifier)
          .markEmiPaid(loan: loan, emiAmount: loan.emiAmount);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'EMI payment recorded locally.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final totalRepayment = LoanCalculator.calculateTotalRepayment(loan);
    final totalInterest = LoanCalculator.calculateTotalEstimatedInterest(loan);
    final daysUntilDue = loan.daysUntilDue();

    return Scaffold(
      appBar: AppBar(
        title: Text(loan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Amortization Schedule',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EmiScheduleView(loan: loan)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Outstanding Balance Hero Card
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outstanding Principal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            loan.status == LoanStatus.active
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                )
                                : context.secColors.verified.withValues(
                                  alpha: 0.15,
                                ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        loan.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              loan.status == LoanStatus.active
                                  ? theme.colorScheme.primary
                                  : context.secColors.verified,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  CurrencyFormatter.formatINR(loan.outstandingPrincipal),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                LinearProgressIndicator(
                  value: loan.progressPercentage,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: context.secColors.verified,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid: ${CurrencyFormatter.formatINR(loan.totalPrincipalPaid)} (${(loan.progressPercentage * 100).toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    Text(
                      'Total: ${CurrencyFormatter.formatINR(loan.principalAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Next EMI & Due Date Card
          FfCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next EMI: ${CurrencyFormatter.formatINR(loan.emiAmount)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Due ${DateFormatter.formatFullDate(loan.nextDueDate)} (${daysUntilDue == 0 ? "Today" : (daysUntilDue == 1 ? "Tomorrow" : "in $daysUntilDue days")})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              daysUntilDue <= 3
                                  ? context.secColors.error
                                  : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (loan.status == LoanStatus.active)
                  FfButton(
                    label: 'Mark Paid',
                    size: FfButtonSize.sm,
                    onPressed: () => _markPaid(context, ref),
                  ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Loan Parameters Grid
          FfCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lender'),
                  trailing: Text(
                    loan.lender,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Loan Type'),
                  trailing: Text(
                    loan.loanType.displayName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Interest Rate'),
                  trailing: Text(
                    '${loan.interestRate}% (${loan.interestType.displayName})',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Total Tenure'),
                  trailing: Text(
                    '${loan.tenureMonths} months',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Total Estimated Repayment'),
                  trailing: Text(
                    CurrencyFormatter.formatINR(totalRepayment),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Total Estimated Interest'),
                  trailing: Text(
                    CurrencyFormatter.formatINR(totalInterest),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Trust statement
          FfCard(
            variant: FfCardVariant.tinted,
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 18,
                  color: context.secColors.verified,
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: Text(
                    'Values entered by you. Amortization and repayment calculated locally on this device.',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          FfButton(
            label: 'View Complete Amortization Schedule',
            variant: FfButtonVariant.outlined,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EmiScheduleView(loan: loan)),
              );
            },
          ),
        ],
      ),
    );
  }
}
