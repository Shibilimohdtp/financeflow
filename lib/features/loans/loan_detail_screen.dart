import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
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

  void _edit(BuildContext context, Loan currentLoan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditLoanSheet(initialLoan: currentLoan),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Loan currentLoan) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Loan?',
      message:
          'Are you sure you want to remove "${currentLoan.name}" and all its EMI payment history from your tracker?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(loansControllerProvider.notifier).deleteLoan(currentLoan.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Loan deleted.');
      }
    }
  }

  Future<void> _markNextPaid(
    BuildContext context,
    WidgetRef ref,
    Loan currentLoan,
    AmortizationScheduleItem? nextInstallment,
  ) async {
    final instNum = nextInstallment?.monthNumber ?? 1;
    final emiAmount = nextInstallment?.emiAmount ?? currentLoan.emiAmount;
    final dueDate = nextInstallment?.dueDate ?? currentLoan.nextDueDate;

    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Pay Installment #$instNum?',
      message:
          'Record an EMI payment of ${CurrencyFormatter.formatINR(emiAmount)} for ${currentLoan.name} due on ${DateFormatter.formatFullDate(dueDate)}?',
      confirmLabel: 'Confirm Payment',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(loansControllerProvider.notifier).markInstallmentPaid(
              loan: currentLoan,
              installmentNumber: instNum,
            );
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'EMI installment #$instNum recorded locally.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'Failed to record payment: $e',
          );
        }
      }
    }
  }

  Future<void> _markAllOverduePaid(
    BuildContext context,
    WidgetRef ref,
    Loan currentLoan,
    List<AmortizationScheduleItem> overdueItems,
  ) async {
    final totalOverdue = overdueItems.fold<double>(
      0.0,
      (sum, item) => sum + item.emiAmount,
    );

    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Mark All Overdue EMIs Paid?',
      message:
          'Record payments for all ${overdueItems.length} overdue installments totaling ${CurrencyFormatter.formatINR(totalOverdue)}? This will advance the next due date to the next upcoming installment.',
      confirmLabel: 'Mark All (${overdueItems.length}) Paid',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markAllOverduePaid(loan: currentLoan);
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'Recorded ${overdueItems.length} overdue EMI payments.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'Failed to record overdue payments: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // Watch live loan updates from repository stream
    final loans = ref.watch(allLoansStreamProvider).value ?? const [];
    final currentLoan = loans.firstWhere(
      (l) => l.id == loan.id,
      orElse: () => loan,
    );

    final schedule = ref.watch(loanScheduleProvider(currentLoan));
    final paidItems = schedule.where((it) => it.isPaid).toList();
    final overdueItems = schedule.where((it) => it.isOverdue).toList();
    final unpaidItems = schedule.where((it) => !it.isPaid).toList();
    final nextInstallment = unpaidItems.isNotEmpty ? unpaidItems.first : null;

    final totalRepayment = LoanCalculator.calculateTotalRepayment(currentLoan);
    final totalInterest = LoanCalculator.calculateTotalEstimatedInterest(currentLoan);
    final daysUntilDue = currentLoan.daysUntilDue();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLoan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Amortization Schedule',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmiScheduleView(loan: currentLoan),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _edit(context, currentLoan),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref, currentLoan),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Overdue Alert Card (if any overdue EMIs)
          if (overdueItems.isNotEmpty && currentLoan.status == LoanStatus.active) ...[
            Container(
              margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceLg),
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: context.secColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: context.secColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: context.secColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceSm),
                      Expanded(
                        child: Text(
                          '${overdueItems.length} Overdue EMI${overdueItems.length > 1 ? "s" : ""}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.secColors.error,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatINR(
                          overdueItems.fold<double>(0.0, (s, it) => s + it.emiAmount),
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.secColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Text(
                    'Installment #${overdueItems.first.monthNumber} (${DateFormatter.formatFullDate(overdueItems.first.dueDate)}) was due ${overdueItems.first.daysOverdue()} days ago.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.secColors.error,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceMd),
                  Row(
                    children: [
                      Expanded(
                        child: FfButton(
                          label: 'Pay #${overdueItems.first.monthNumber}',
                          size: FfButtonSize.sm,
                          onPressed: () => _markNextPaid(
                            context,
                            ref,
                            currentLoan,
                            overdueItems.first,
                          ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceSm),
                      if (overdueItems.length > 1)
                        Expanded(
                          child: FfButton(
                            label: 'Pay All (${overdueItems.length}) Overdue',
                            size: FfButtonSize.sm,
                            variant: FfButtonVariant.outlined,
                            onPressed: () => _markAllOverduePaid(
                              context,
                              ref,
                              currentLoan,
                              overdueItems,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],

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
                        color: currentLoan.status == LoanStatus.active
                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                            : context.secColors.verified.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentLoan.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: currentLoan.status == LoanStatus.active
                              ? theme.colorScheme.primary
                              : context.secColors.verified,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  CurrencyFormatter.formatINR(currentLoan.outstandingPrincipal),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                LinearProgressIndicator(
                  value: currentLoan.progressPercentage,
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
                      'Paid: ${CurrencyFormatter.formatINR(currentLoan.totalPrincipalPaid)} (${(currentLoan.progressPercentage * 100).toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    Text(
                      'Total: ${CurrencyFormatter.formatINR(currentLoan.principalAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Next EMI & Due Date Card
          if (currentLoan.status == LoanStatus.active && nextInstallment != null) ...[
            FfCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: nextInstallment.isOverdue
                          ? context.secColors.error.withValues(alpha: 0.1)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      nextInstallment.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.event_available_rounded,
                      color: nextInstallment.isOverdue
                          ? context.secColors.error
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next EMI #${nextInstallment.monthNumber}: ${CurrencyFormatter.formatINR(nextInstallment.emiAmount)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (nextInstallment.isOverdue)
                          Text(
                            'OVERDUE by ${nextInstallment.daysOverdue()} days (Due ${DateFormatter.formatFullDate(nextInstallment.dueDate)})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.secColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            'Due ${DateFormatter.formatFullDate(nextInstallment.dueDate)} (${daysUntilDue == 0 ? "Today" : (daysUntilDue == 1 ? "Tomorrow" : "in $daysUntilDue days")})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: daysUntilDue <= 3
                                  ? context.secColors.error
                                  : theme.colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  FfButton(
                    label: 'Mark Paid',
                    size: FfButtonSize.sm,
                    onPressed: () => _markNextPaid(
                      context,
                      ref,
                      currentLoan,
                      nextInstallment,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceLg),
          ],

          // Installment Progress Summary Card
          FfCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressColumn(
                  context,
                  label: 'Paid EMIs',
                  count: '${paidItems.length} / ${currentLoan.tenureMonths}',
                  color: context.secColors.verified,
                ),
                _buildProgressColumn(
                  context,
                  label: 'Overdue',
                  count: '${overdueItems.length}',
                  color: overdueItems.isNotEmpty
                      ? context.secColors.error
                      : theme.colorScheme.secondary,
                ),
                _buildProgressColumn(
                  context,
                  label: 'Remaining',
                  count: '${unpaidItems.length}',
                  color: theme.colorScheme.primary,
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
                    currentLoan.lender,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Loan Type'),
                  trailing: Text(
                    currentLoan.loanType.displayName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Interest Rate'),
                  trailing: Text(
                    '${currentLoan.interestRate}% (${currentLoan.interestType.displayName})',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Total Tenure'),
                  trailing: Text(
                    '${currentLoan.tenureMonths} months',
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
                MaterialPageRoute(
                  builder: (_) => EmiScheduleView(loan: currentLoan),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressColumn(
    BuildContext context, {
    required String label,
    required String count,
    required Color color,
  }) {
    final theme = context.theme;
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
