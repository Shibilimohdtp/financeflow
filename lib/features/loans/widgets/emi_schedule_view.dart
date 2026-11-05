import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../repositories/loan_repository.dart';
import '../../../services/loan_calculator.dart';
import '../../../shared/widgets/ff_button.dart';
import '../loans_controller.dart';
import '../../accounts/accounts_controller.dart';
import '../payment_account_picker.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../shared/widgets/ff_dialog.dart';
import '../../../shared/widgets/ff_app_bar.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff.dart';

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
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Pay Installment #${item.monthNumber}?',
      message:
          'Record EMI payment of ${CurrencyFormatter.formatAmount(item.emiAmount)} (Principal: ${CurrencyFormatter.formatAmount(item.principalPaid)}, Interest: ${CurrencyFormatter.formatAmount(item.interestPaid)}) due on ${DateFormatter.formatFullDate(item.dueDate)}?',
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
          FfToast.show(
            context,
            message: 'EMI installment #${item.monthNumber} marked as paid.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to record payment: $e',
          );
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
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Mark Installment #${item.monthNumber} as Unpaid?',
      message:
          'Remove the recorded payment of ${CurrencyFormatter.formatAmount(item.emiAmount)} (due ${DateFormatter.formatFullDate(item.dueDate)})? This will update your loan balance and next due date.',
      confirmLabel: 'Mark Unpaid',
      cancelLabel: 'Cancel',
      destructive: true,
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
          FfToast.show(
            context,
            message: 'Installment #${item.monthNumber} marked as unpaid.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to unmark payment: $e',
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

    final confirmed = await FfDialog.confirm(
      context,
      title: 'Mark All Overdue EMIs Paid?',
      message:
          'Record payments for all ${overdueItems.length} overdue installments totaling ${CurrencyFormatter.formatAmount(totalOverdueAmount)}? This will advance your next due date to the next upcoming installment.',
      confirmLabel: 'Mark All (${overdueItems.length}) Paid',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markAllOverduePaid(
              loan: currentLoan,
              accountId: payingAccount?.id,
            );
        if (context.mounted) {
          FfToast.show(
            context,
            message: 'Recorded ${overdueItems.length} overdue EMI payments.',
          );
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to record overdue payments: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: FfAppBar(title: '${currentLoan.name} Schedule'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Header Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.md,
              vertical: FfSpace.sm,
            ),
            color: context.ff.color.surfaceCard,
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: FfSpace.sm,
              runSpacing: FfSpace.xs,
              children: [
                _buildStatBadge(
                  context,
                  label: '${paidItems.length} Paid',
                  color: context.ff.color.statusSuccess,
                  backgroundColor: context.ff.color.statusSuccess.withValues(
                    alpha: 0.12,
                  ),
                ),
                if (overdueItems.isNotEmpty)
                  _buildStatBadge(
                    context,
                    label: '${overdueItems.length} Overdue',
                    color: context.ff.color.statusError,
                    backgroundColor: context.ff.color.statusError.withValues(
                      alpha: 0.12,
                    ),
                  ),
                _buildStatBadge(
                  context,
                  label: '${upcomingItems.length} Upcoming',
                  color: context.ff.color.secondary,
                  backgroundColor: context.ff.color.surfaceContainerHighest,
                ),
              ],
            ),
          ),

          // Bulk Overdue Action Banner
          if (overdueItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.md,
                vertical: FfSpace.sm,
              ),
              color: context.ff.color.statusError.withValues(
                alpha: FfTint.subtle.alpha,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.ff.color.statusError,
                    size: 20,
                  ),
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: Text(
                      '${overdueItems.length} overdue EMIs detected',
                      style: context.ff.text.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.ff.color.statusError,
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

          const FfDivider(),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(FfSpace.md),
              itemCount: schedule.length,
              separatorBuilder: (_, __) => const FfDivider(),
              itemBuilder: (context, index) {
                final item = schedule[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(FfRadius.md),
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
                      vertical: FfSpace.x2s,
                      horizontal: FfSpace.x2s,
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
                                    ? context.ff.color.statusSuccess.withValues(
                                      alpha: 0.15,
                                    )
                                    : item.isOverdue
                                    ? context.ff.color.statusError.withValues(
                                      alpha: 0.15,
                                    )
                                    : context.ff.color.actionPrimary.withValues(
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
                                      color: context.ff.color.statusSuccess,
                                    )
                                    : Text(
                                      '#${item.monthNumber}',
                                      style: context.ff.text.labelSm.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            item.isOverdue
                                                ? context.ff.color.statusError
                                                : context
                                                    .ff
                                                    .color
                                                    .actionPrimary,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: FfSpace.sm),

                        // Details Column (Date, Status pill, Principal & Interest breakdown)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: FfSpace.xs,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    DateFormatter.formatFullDate(item.dueDate),
                                    style: context.ff.text.bodySm.copyWith(
                                      fontWeight:
                                          item.isOverdue
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                    ),
                                  ),
                                  if (item.isPaid || item.isOverdue)
                                    _buildStatusPill(context, item),
                                ],
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Text(
                                'P: ${CurrencyFormatter.formatAmount(item.principalPaid)} · I: ${CurrencyFormatter.formatAmount(item.interestPaid)}',
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: FfSpace.xs),

                        // EMI Amount & Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.formatAmount(item.emiAmount),
                              style: context.ff.text.bodySm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bal: ${CurrencyFormatter.formatAmount(item.closingBalance)}',
                              style: context.ff.text.labelSm.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: FfSpace.x2s),

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
                                    color: context.ff.color.secondary,
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
                                            ? context.ff.color.statusError
                                            : context.ff.color.actionPrimary,
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

  Widget _buildStatBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.xs,
        vertical: FfSpace.x2s,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FfRadius.md),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.ff.text.labelSm.copyWith(
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
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.x2s,
          vertical: FfSpace.x3s,
        ),
        decoration: BoxDecoration(
          color: context.ff.color.statusSuccess.withValues(
            alpha: FfTint.subtle.alpha,
          ),
          borderRadius: BorderRadius.circular(FfRadius.sm),
        ),
        child: Text(
          paidText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.ff.text.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            color: context.ff.color.statusSuccess,
          ),
        ),
      );
    }

    if (item.isOverdue) {
      final days = item.daysOverdue();
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.x2s,
          vertical: FfSpace.x3s,
        ),
        decoration: BoxDecoration(
          color: context.ff.color.statusError.withValues(
            alpha: FfTint.subtle.alpha,
          ),
          borderRadius: BorderRadius.circular(FfRadius.sm),
        ),
        child: Text(
          'OVERDUE ($days d)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.ff.text.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            color: context.ff.color.statusError,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
