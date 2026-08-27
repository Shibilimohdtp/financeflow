import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../repositories/loan_repository.dart';
import '../../../services/loan_calculator.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_confirm_dialog.dart';
import '../../../shared/widgets/ff_snackbar.dart';
import '../../../theme/stillwater_tokens.dart';
import '../loans_controller.dart';
import '../../accounts/accounts_controller.dart';
import '../payment_account_picker.dart';

class EmiScheduleView extends ConsumerWidget {
  final Loan loan;

  const EmiScheduleView({super.key, required this.loan});

  Future<void> _markInstallmentPaid(
    BuildContext context,
    WidgetRef ref,
    Loan currentLoan,
    AmortizationScheduleItem item,
  ) async {
    final accounts =
        ref.read(accountsWithBalancesProvider).valueOrNull ?? const [];
    final payingAccount =
        accounts.isEmpty
            ? null
            : await showPaymentAccountPicker(
              context: context,
              accounts: accounts,
              selectedAccountId: currentLoan.accountId,
            );
    if (accounts.isNotEmpty && (payingAccount == null || !context.mounted)) {
      return;
    }
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Pay Installment #${item.monthNumber}?',
      message:
          'Record EMI payment of ${CurrencyFormatter.formatINR(item.emiAmount)} (Principal: ${CurrencyFormatter.formatINR(item.principalPaid)}, Interest: ${CurrencyFormatter.formatINR(item.interestPaid)}) due on ${DateFormatter.formatFullDate(item.dueDate)}?',
      confirmLabel: 'Mark Paid',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markInstallmentPaid(
              loan: currentLoan,
              installmentNumber: item.monthNumber,
              accountId: payingAccount?.id,
            );
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'EMI installment #${item.monthNumber} marked as paid.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Failed to record payment: $e');
        }
      }
    }
  }

  Future<void> _markInstallmentUnpaid(
    BuildContext context,
    WidgetRef ref,
    Loan currentLoan,
    AmortizationScheduleItem item,
  ) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Mark Installment #${item.monthNumber} as Unpaid?',
      message:
          'Remove the recorded payment of ${CurrencyFormatter.formatINR(item.emiAmount)} (due ${DateFormatter.formatFullDate(item.dueDate)})? This will update your loan balance and next due date.',
      confirmLabel: 'Mark Unpaid',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markInstallmentUnpaid(
              loan: currentLoan,
              installmentNumber: item.monthNumber,
              paymentId: item.payment?.id,
            );
        if (context.mounted) {
          FfSnackbar.show(
            context,
            message: 'Installment #${item.monthNumber} marked as unpaid.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Failed to unmark payment: $e');
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
    final accounts =
        ref.read(accountsWithBalancesProvider).valueOrNull ?? const [];
    final payingAccount =
        accounts.isEmpty
            ? null
            : await showPaymentAccountPicker(
              context: context,
              accounts: accounts,
              selectedAccountId: currentLoan.accountId,
            );
    if (accounts.isNotEmpty && (payingAccount == null || !context.mounted)) {
      return;
    }
    final totalOverdueAmount = overdueItems.fold<double>(
      0.0,
      (sum, item) => sum + item.emiAmount,
    );

    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Mark All Overdue EMIs Paid?',
      message:
          'Record payments for all ${overdueItems.length} overdue installments totaling ${CurrencyFormatter.formatINR(totalOverdueAmount)}? This will advance your next due date to the next upcoming installment.',
      confirmLabel: 'Mark All (${overdueItems.length}) Paid',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markAllOverduePaid(loan: currentLoan, accountId: payingAccount?.id);
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
    final loans = ref.watch(allLoansStreamProvider).value ?? const [];
    final currentLoan = loans.firstWhere(
      (l) => l.id == loan.id,
      orElse: () => loan,
    );
    final schedule = ref.watch(loanScheduleProvider(currentLoan));

    final paidItems = schedule.where((it) => it.isPaid).toList();
    final overdueItems = schedule.where((it) => it.isOverdue).toList();
    final upcomingItems = schedule.where((it) => it.isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${currentLoan.name} Schedule')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Header Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceMd,
              vertical: StillwaterTokens.spaceSm,
            ),
            color: theme.colorScheme.surface,
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: StillwaterTokens.spaceSm,
              runSpacing: StillwaterTokens.spaceXs,
              children: [
                _buildStatBadge(
                  label: '${paidItems.length} Paid',
                  color: context.secColors.verified,
                  backgroundColor: context.secColors.verified.withValues(
                    alpha: 0.12,
                  ),
                ),
                if (overdueItems.isNotEmpty)
                  _buildStatBadge(
                    label: '${overdueItems.length} Overdue',
                    color: context.secColors.error,
                    backgroundColor: context.secColors.error.withValues(
                      alpha: 0.12,
                    ),
                  ),
                _buildStatBadge(
                  label: '${upcomingItems.length} Upcoming',
                  color: theme.colorScheme.secondary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),

          // Bulk Overdue Action Banner
          if (overdueItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceMd,
                vertical: StillwaterTokens.spaceSm,
              ),
              color: context.secColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.secColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Text(
                      '${overdueItems.length} overdue EMIs detected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.secColors.error,
                      ),
                    ),
                  ),
                  FfButton(
                    label: 'Mark All Paid',
                    size: FfButtonSize.sm,
                    onPressed:
                        () => _markAllOverduePaid(
                          context,
                          ref,
                          currentLoan,
                          overdueItems,
                        ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              itemCount: schedule.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = schedule[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusMd,
                  ),
                  onTap:
                      item.isPaid
                          ? () => _markInstallmentUnpaid(
                            context,
                            ref,
                            currentLoan,
                            item,
                          )
                          : () => _markInstallmentPaid(
                            context,
                            ref,
                            currentLoan,
                            item,
                          ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: StillwaterTokens.space2Xs,
                      horizontal: StillwaterTokens.space2Xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Month Number Icon / Checkmark
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                item.isPaid
                                    ? context.secColors.verified.withValues(
                                      alpha: 0.15,
                                    )
                                    : item.isOverdue
                                    ? context.secColors.error.withValues(
                                      alpha: 0.15,
                                    )
                                    : theme.colorScheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child:
                                item.isPaid
                                    ? Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: context.secColors.verified,
                                    )
                                    : Text(
                                      '#${item.monthNumber}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            item.isOverdue
                                                ? context.secColors.error
                                                : theme.colorScheme.primary,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),

                        // Details Column (Date, Status pill, Principal & Interest breakdown)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: StillwaterTokens.spaceXs,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    DateFormatter.formatFullDate(item.dueDate),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight:
                                          item.isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.isPaid || item.isOverdue)
                                    _buildStatusPill(context, item),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'P: ${CurrencyFormatter.formatINR(item.principalPaid)} · I: ${CurrencyFormatter.formatINR(item.interestPaid)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: StillwaterTokens.spaceXs),

                        // EMI Amount & Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.formatINR(item.emiAmount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Bal: ${CurrencyFormatter.formatINR(item.closingBalance)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: StillwaterTokens.space2Xs),

                        // Action button (Mark Paid / Mark Unpaid)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child:
                              item.isPaid
                                  ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.undo_rounded,
                                      size: 18,
                                    ),
                                    tooltip:
                                        'Mark Installment #${item.monthNumber} Unpaid',
                                    color: theme.colorScheme.secondary,
                                    onPressed:
                                        () => _markInstallmentUnpaid(
                                          context,
                                          ref,
                                          currentLoan,
                                          item,
                                        ),
                                  )
                                  : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 18,
                                    ),
                                    tooltip:
                                        'Mark Installment #${item.monthNumber} Paid',
                                    color:
                                        item.isOverdue
                                            ? context.secColors.error
                                            : theme.colorScheme.primary,
                                    onPressed:
                                        () => _markInstallmentPaid(
                                          context,
                                          ref,
                                          currentLoan,
                                          item,
                                        ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, AmortizationScheduleItem item) {
    if (item.isPaid) {
      final paymentDate = item.payment?.paymentDate;
      final String paidText;
      if (paymentDate != null) {
        paidText = 'Paid ${DateFormatter.formatShortDate(paymentDate)}';
      } else {
        paidText = 'PAID';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: context.secColors.verified.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          paidText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: context.secColors.verified,
          ),
        ),
      );
    }

    if (item.isOverdue) {
      final days = item.daysOverdue();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: context.secColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'OVERDUE ($days d)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: context.secColors.error,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
