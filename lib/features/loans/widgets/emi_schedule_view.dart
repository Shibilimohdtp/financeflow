import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/loan.dart';
import '../../../repositories/loan_repository.dart';
import '../../../services/loan_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_schedule_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_segmented_pill.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff_tone.dart';
import '../loans_controller.dart';
import '../../accounts/accounts_controller.dart';
import '../../settings/settings_controller.dart';
import '../payment_account_picker.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../shared/widgets/ff_dialog.dart';
import '../../../shared/widgets/ff_page_scaffold.dart';
import '../../../theme/ff.dart';

/// Which installments the list shows. The hero and totals always cover all.
enum _ScheduleFilter { all, upcoming, paid, overdue }

class EmiScheduleView extends ConsumerStatefulWidget {
  final Loan loan;

  const EmiScheduleView({super.key, required this.loan});

  @override
  ConsumerState<EmiScheduleView> createState() => _EmiScheduleViewState();
}

class _EmiScheduleViewState extends ConsumerState<EmiScheduleView> {
  _ScheduleFilter _filter = _ScheduleFilter.all;

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
  Widget build(BuildContext context) {
    final loans = ref.watch(allLoansStreamProvider).value ?? const [];
    final currentLoan = loans.firstWhere(
      (l) => l.id == widget.loan.id,
      orElse: () => widget.loan,
    );
    final schedule = ref.watch(loanScheduleProvider(currentLoan));
    final remaining = ref.watch(loanRemainingBalanceProvider(currentLoan));
    final isBlurred =
        ref.watch(settingsStreamProvider).valueOrNull?.isPrivacyBlurEnabled ??
        false;

    final paidItems = schedule.where((it) => it.isPaid).toList();
    final overdueItems = schedule.where((it) => it.isOverdue).toList();
    final upcomingItems = schedule.where((it) => it.isUpcoming).toList();
    final nextItem = upcomingItems.isEmpty ? null : upcomingItems.first;

    final lender = currentLoan.lender.trim();
    final subtitle =
        lender.isEmpty ? 'Payment schedule' : 'Payment schedule · $lender';

    return FfPageScaffold(
      title: currentLoan.name,
      subtitle: subtitle,
      body:
          schedule.isEmpty
              ? const Padding(
                padding: EdgeInsets.all(FfSpace.pageMargin),
                child: FfEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No schedule yet',
                  description:
                      'Add the tenure and start date to see every installment.',
                ),
              )
              : ListView(
                padding: const EdgeInsets.fromLTRB(
                  FfSpace.pageMargin,
                  FfSpace.md,
                  FfSpace.pageMargin,
                  FfSpace.x4l,
                ),
                children: [
                  _buildHero(
                    context,
                    currentLoan: currentLoan,
                    schedule: schedule,
                    remaining: remaining,
                    paidCount: paidItems.length,
                    overdueCount: overdueItems.length,
                    nextItem: nextItem,
                    isBlurred: isBlurred,
                  ),
                  if (overdueItems.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.lg),
                    _buildAttention(
                      context,
                      currentLoan: currentLoan,
                      overdueItems: overdueItems,
                      isBlurred: isBlurred,
                    ),
                  ],
                  const SizedBox(height: FfSpace.lg),
                  _buildProgress(
                    context,
                    total: schedule.length,
                    paidCount: paidItems.length,
                    upcomingCount: upcomingItems.length,
                    overdueCount: overdueItems.length,
                  ),
                  const SizedBox(height: FfSpace.lg),
                  FfSegmentedPill<_ScheduleFilter>(
                    options: const [
                      FfSegmentOption(value: _ScheduleFilter.all, label: 'All'),
                      FfSegmentOption(
                        value: _ScheduleFilter.upcoming,
                        label: 'Upcoming',
                      ),
                      FfSegmentOption(
                        value: _ScheduleFilter.paid,
                        label: 'Paid',
                      ),
                      FfSegmentOption(
                        value: _ScheduleFilter.overdue,
                        label: 'Overdue',
                      ),
                    ],
                    selectedValue: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                  ..._buildYearSections(
                    context,
                    currentLoan: currentLoan,
                    schedule: schedule,
                    nextItem: nextItem,
                    isBlurred: isBlurred,
                  ),
                  const SizedBox(height: FfSpace.lg),
                  _buildTotals(
                    context,
                    schedule: schedule,
                    isBlurred: isBlurred,
                  ),
                ],
              ),
    );
  }

  String _money(double value, bool isBlurred) =>
      isBlurred ? '••••••' : CurrencyFormatter.formatAmount(value);

  Widget _buildHero(
    BuildContext context, {
    required Loan currentLoan,
    required List<AmortizationScheduleItem> schedule,
    required LoanRemainingBalance remaining,
    required int paidCount,
    required int overdueCount,
    required AmortizationScheduleItem? nextItem,
    required bool isBlurred,
  }) {
    final total = schedule.length;
    final fraction = total == 0 ? 0.0 : paidCount / total;
    final percent = (fraction * 100).round();
    final lastDue = schedule.last.dueDate;

    final String nextValue;
    if (overdueCount > 0) {
      nextValue = '$overdueCount overdue';
    } else if (nextItem != null) {
      nextValue =
          '#${nextItem.monthNumber} · ${DateFormatter.formatShortDate(nextItem.dueDate)}';
    } else {
      nextValue = 'All paid';
    }

    return FfHeroCard(
      tone: FfHeroTone.rose,
      leading: FfProgressRing(
        value: fraction,
        icon: Icons.calendar_month_outlined,
        semanticsLabel: '$percent% of EMIs paid',
      ),
      title: '$paidCount of $total EMIs paid',
      subtitle: currentLoan.status.displayName,
      child: Builder(
        builder: (context) {
          final ff = context.ff;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Left to pay', style: ff.text.label),
              const SizedBox(height: FfSpace.x3s),
              FfAmountText(
                amount: remaining.total,
                size: FfAmountSize.hero,
                tone: FfTone.neutral,
                showSign: false,
                isBlurred: isBlurred,
              ),
              const SizedBox(height: FfSpace.lg),
              FfHeroFigures([
                FfHeroFigure('Paid', _money(remaining.paid, isBlurred)),
                FfHeroFigure('Next', nextValue),
                FfHeroFigure('Ends', DateFormatter.formatMonthYear(lastDue)),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttention(
    BuildContext context, {
    required Loan currentLoan,
    required List<AmortizationScheduleItem> overdueItems,
    required bool isBlurred,
  }) {
    final ff = context.ff;
    final count = overdueItems.length;
    final owed = overdueItems.fold<double>(
      0.0,
      (sum, it) => sum + it.emiAmount,
    );

    return FfCard(
      variant: FfCardVariant.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const FfIconTile(
                icon: Icons.warning_amber_rounded,
                tone: FfTone.warning,
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count overdue EMIs', style: ff.text.titleSm),
                    if (!isBlurred)
                      Text(
                        '${CurrencyFormatter.formatAmount(owed)} to pay now',
                        style: ff.text.label,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
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
    );
  }

  Widget _buildProgress(
    BuildContext context, {
    required int total,
    required int paidCount,
    required int upcomingCount,
    required int overdueCount,
  }) {
    final ff = context.ff;
    final details = [
      '$upcomingCount upcoming',
      if (overdueCount > 0) '$overdueCount overdue',
    ].join(' · ');

    return FfCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$paidCount Paid', style: ff.text.titleLg),
                const SizedBox(height: FfSpace.x3s),
                Text('of $total EMIs · $details', style: ff.text.label),
              ],
            ),
          ),
          const SizedBox(width: FfSpace.sm),
          FfDotMatrix(
            total: total,
            done: paidCount,
            semanticsLabel: '$paidCount of $total EMIs paid',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildYearSections(
    BuildContext context, {
    required Loan currentLoan,
    required List<AmortizationScheduleItem> schedule,
    required AmortizationScheduleItem? nextItem,
    required bool isBlurred,
  }) {
    final visible =
        schedule.where((it) {
          switch (_filter) {
            case _ScheduleFilter.all:
              return true;
            case _ScheduleFilter.paid:
              return it.isPaid;
            case _ScheduleFilter.overdue:
              return it.isOverdue;
            case _ScheduleFilter.upcoming:
              return it.isUpcoming;
          }
        }).toList();

    if (visible.isEmpty) {
      return [
        const SizedBox(height: FfSpace.lg),
        const FfEmptyState(
          icon: Icons.filter_alt_off_outlined,
          title: 'Nothing here',
          description: 'No installments match this filter.',
        ),
      ];
    }

    // Group by due year, keeping schedule order.
    final byYear = <int, List<AmortizationScheduleItem>>{};
    for (final item in visible) {
      byYear.putIfAbsent(item.dueDate.year, () => []).add(item);
    }

    final sections = <Widget>[];
    for (final entry in byYear.entries) {
      sections
        ..add(const SizedBox(height: FfSpace.lg))
        ..add(FfSectionHeader(title: '${entry.key}', count: entry.value.length))
        ..add(
          FfGroupedContainer(
            children: [
              for (final item in entry.value)
                FfScheduleRow(
                  number: item.monthNumber,
                  dueDate: item.dueDate,
                  emiAmount: item.emiAmount,
                  principal: item.principalPaid,
                  interest: item.interestPaid,
                  balance: item.closingBalance,
                  state: _stateOf(item, nextItem),
                  paidOn: item.payment?.paymentDate,
                  isBlurred: isBlurred,
                  onAction: _actionFor(context, currentLoan, item),
                ),
            ],
          ),
        );
    }
    return sections;
  }

  FfScheduleRowState _stateOf(
    AmortizationScheduleItem item,
    AmortizationScheduleItem? nextItem,
  ) {
    if (item.isPaid) return FfScheduleRowState.paid;
    if (item.isOverdue) return FfScheduleRowState.overdue;
    if (identical(item, nextItem)) return FfScheduleRowState.next;
    return FfScheduleRowState.upcoming;
  }

  VoidCallback _actionFor(
    BuildContext context,
    Loan currentLoan,
    AmortizationScheduleItem item,
  ) {
    if (item.isPaid) {
      return () => _markInstallmentUnpaid(context, ref, currentLoan, item);
    }
    return () => _markInstallmentPaid(context, ref, currentLoan, item);
  }

  Widget _buildTotals(
    BuildContext context, {
    required List<AmortizationScheduleItem> schedule,
    required bool isBlurred,
  }) {
    final paid = schedule.where((it) => it.isPaid);
    final principalTotal = schedule.fold<double>(
      0.0,
      (sum, it) => sum + it.principalPaid,
    );
    final interestTotal = schedule.fold<double>(
      0.0,
      (sum, it) => sum + it.interestPaid,
    );
    final principalPaid = paid.fold<double>(
      0.0,
      (sum, it) => sum + it.principalPaid,
    );
    final interestPaid = paid.fold<double>(
      0.0,
      (sum, it) => sum + it.interestPaid,
    );
    final payableTotal = schedule.fold<double>(
      0.0,
      (sum, it) => sum + it.emiAmount,
    );
    final closes = schedule.last.dueDate;

    String? caption(double total) =>
        isBlurred ? null : 'of ${CurrencyFormatter.formatAmount(total)}';

    return FfCard(
      variant: FfCardVariant.tinted,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FfStatTile(
                  label: 'Principal paid',
                  value: FfAmountText(
                    amount: principalPaid,
                    size: FfAmountSize.md,
                    showSign: false,
                    isBlurred: isBlurred,
                  ),
                  caption: caption(principalTotal),
                ),
              ),
              Expanded(
                child: FfStatTile(
                  label: 'Interest paid',
                  value: FfAmountText(
                    amount: interestPaid,
                    size: FfAmountSize.md,
                    showSign: false,
                    isBlurred: isBlurred,
                  ),
                  caption: caption(interestTotal),
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.md),
          Row(
            children: [
              Expanded(
                child: FfStatTile(
                  label: 'Total payable',
                  value: FfAmountText(
                    amount: payableTotal,
                    size: FfAmountSize.md,
                    showSign: false,
                    isBlurred: isBlurred,
                  ),
                  caption: '${schedule.length} EMIs',
                ),
              ),
              Expanded(
                child: FfStatTile(
                  label: 'Closes on',
                  value: Text(
                    DateFormatter.formatMonthYear(closes),
                    style: context.ff.text.titleLg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
