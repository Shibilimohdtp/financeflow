import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/loan.dart';
import '../../repositories/loan_repository.dart';
import '../../services/loan_calculator.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import 'add_edit_loan_sheet.dart';
import 'loans_controller.dart';
import '../accounts/accounts_controller.dart';
import 'payment_account_picker.dart';
import 'widgets/emi_schedule_view.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_key_value_row.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../theme/ff_tone.dart';
import '../../theme/ff.dart';

class LoanDetailScreen extends ConsumerWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  void _edit(BuildContext context, Loan currentLoan) {
    showFfSheet(
      context,
      builder: (_) => AddEditLoanSheet(initialLoan: currentLoan),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Loan currentLoan,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Loan?',
      message:
          'Remove "${currentLoan.name}" from the tracker? Linked transactions will be kept as unlinked historical loan payments; schedule allocations will be removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(loansControllerProvider.notifier)
          .deleteLoan(currentLoan.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Loan deleted.');
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
      title: 'Pay Installment #$instNum?',
      message:
          'Record an EMI payment of ${CurrencyFormatter.formatAmount(emiAmount)} for ${currentLoan.name} due on ${DateFormatter.formatFullDate(dueDate)}?',
      confirmLabel: 'Confirm Payment',
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(loansControllerProvider.notifier)
            .markInstallmentPaid(
              loan: currentLoan,
              installmentNumber: instNum,
              accountId: payingAccount?.id,
            );
        if (context.mounted) {
          FfToast.show(
            context,
            message: 'EMI installment #$instNum recorded locally.',
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
      title: 'Mark All Overdue EMIs Paid?',
      message:
          'Record payments for all ${overdueItems.length} overdue installments totaling ${CurrencyFormatter.formatAmount(totalOverdue)}? This will advance the next due date to the next upcoming installment.',
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

  void _openSchedule(BuildContext context, Loan currentLoan) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EmiScheduleView(loan: currentLoan)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final totalInterest = LoanCalculator.calculateTotalEstimatedInterest(
      currentLoan,
    );
    final daysUntilDue = currentLoan.daysUntilDue();

    return Scaffold(
      appBar: FfAppBar(
        title: currentLoan.name,
        subtitle: currentLoan.lender,
        actions: [
          Semantics(
            label: 'View amortization schedule',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.table_chart_outlined),
              tooltip: 'Amortization Schedule',
              onPressed: () => _openSchedule(context, currentLoan),
            ),
          ),
          Semantics(
            label: 'Edit loan',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _edit(context, currentLoan),
            ),
          ),
          Semantics(
            label: 'Delete loan',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
              onPressed: () => _delete(context, ref, currentLoan),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.pageMargin,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Balance Hero ──────────────────────────────────────────────
          _BalanceHeroSection(loan: currentLoan),

          const SizedBox(height: FfSpace.lg),

          // ── 2. Overdue Banner (calm, factual) ────────────────────────────
          if (overdueItems.isNotEmpty &&
              currentLoan.status == LoanStatus.active) ...[
            _OverdueBanner(
              overdueItems: overdueItems,
              onPayFirst:
                  () => _markNextPaid(
                    context,
                    ref,
                    currentLoan,
                    overdueItems.first,
                  ),
              onPayAll:
                  overdueItems.length > 1
                      ? () => _markAllOverduePaid(
                        context,
                        ref,
                        currentLoan,
                        overdueItems,
                      )
                      : null,
            ),
            const SizedBox(height: FfSpace.md),
          ],

          // ── 3. Next EMI ──────────────────────────────────────────────────
          if (currentLoan.status == LoanStatus.active &&
              nextInstallment != null) ...[
            _NextEmiSection(
              nextInstallment: nextInstallment,
              daysUntilDue: daysUntilDue,
              onMarkPaid:
                  () =>
                      _markNextPaid(context, ref, currentLoan, nextInstallment),
            ),
            const SizedBox(height: FfSpace.lg),
          ],

          // ── 4. Repayment Summary ─────────────────────────────────────────
          _RepaymentSummary(
            paidCount: paidItems.length,
            overdueCount: overdueItems.length,
            remainingCount: unpaidItems.length,
            totalMonths: currentLoan.tenureMonths,
            schedule: schedule,
          ),

          if (schedule.length > 1) ...[
            const SizedBox(height: FfSpace.md),
            _PrincipalChart(schedule: schedule),
          ],

          const SizedBox(height: FfSpace.lg),

          // ── 5. Loan Information ──────────────────────────────────────────
          _LoanInfoSection(
            loan: currentLoan,
            totalRepayment: totalRepayment,
            totalInterest: totalInterest,
          ),

          const SizedBox(height: FfSpace.lg),

          // ── 6. Amortization Schedule Access ─────────────────────────────
          FfButton(
            label: 'View Complete Amortization Schedule',
            variant: FfButtonVariant.outlined,
            onPressed: () => _openSchedule(context, currentLoan),
          ),

          const SizedBox(height: FfSpace.md),

          // ── 7. Trust Statement ───────────────────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.md,
              vertical: FfSpace.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 16,
                  color: context.ff.color.statusSuccess,
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  child: Text(
                    'Values entered by you. Amortization and repayment calculated locally on this device.',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ──────────────────────────────────────────────────────────────────────────────

/// Two-line AppBar title: loan name + lender subtitle.
/// "Left to pay" hero: remaining principal plus remaining interest, with
/// progress measured against the total payable over the loan's life.
class _BalanceHeroSection extends ConsumerWidget {
  final Loan loan;

  const _BalanceHeroSection({required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(loanRemainingBalanceProvider(loan));
    final paidPct = remaining.paidFraction;
    final percent = (paidPct * 100).toStringAsFixed(1);

    return FfHeroCard(
      tone: FfHeroTone.rose,
      leading: FfProgressRing(
        value: paidPct,
        icon: Icons.account_balance_outlined,
        semanticsLabel: '$percent% of the total payable is paid',
      ),
      title: 'Left to pay',
      subtitle: loan.status.displayName,
      child: Builder(
        builder: (context) {
          final ff = context.ff;
          Widget figure(String label, String value, CrossAxisAlignment align) =>
              Column(
                crossAxisAlignment: align,
                children: [
                  Text(label, style: ff.text.label),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    value,
                    style: ff.text.labelLg.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FfAmountText(
                amount: remaining.total,
                size: FfAmountSize.hero,
                tone: FfTone.neutral,
                showSign: false,
              ),
              const SizedBox(height: FfSpace.x3s),
              Text(
                '${CurrencyFormatter.formatAmount(remaining.principal)} principal'
                ' + ${CurrencyFormatter.formatAmount(remaining.interest)} interest',
                style: ff.text.label,
              ),
              const SizedBox(height: FfSpace.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: figure(
                      'Paid',
                      CurrencyFormatter.formatAmount(remaining.paid),
                      CrossAxisAlignment.start,
                    ),
                  ),
                  figure('Complete', '$percent%', CrossAxisAlignment.center),
                  Expanded(
                    child: figure(
                      'Total payable',
                      CurrencyFormatter.formatAmount(remaining.totalPayable),
                      CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Next EMI card — vertical layout, never overlaps due-date text.
class _NextEmiSection extends StatelessWidget {
  final AmortizationScheduleItem nextInstallment;
  final int daysUntilDue;
  final VoidCallback onMarkPaid;

  const _NextEmiSection({
    required this.nextInstallment,
    required this.daysUntilDue,
    required this.onMarkPaid,
  });

  String _dueLabel() {
    if (nextInstallment.isOverdue) {
      final days = nextInstallment.daysOverdue();
      return 'Overdue by $days day${days == 1 ? '' : 's'}';
    }
    if (daysUntilDue == 0) return 'Today';
    if (daysUntilDue == 1) return 'Tomorrow';
    return 'In $daysUntilDue days';
  }

  @override
  Widget build(BuildContext context) {
    final secColors = context.ff.color;
    final isOverdue = nextInstallment.isOverdue;
    final dueLabelColor =
        isOverdue ? secColors.statusError : context.ff.color.secondary;

    return FfCard(
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: EMI amount + due-status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMI #${nextInstallment.monthNumber}',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      CurrencyFormatter.formatAmount(nextInstallment.emiAmount),
                      style: context.ff.text.headlineSm.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              // Due-status pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.xs,
                  vertical: FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color:
                      isOverdue
                          ? secColors.statusError.withValues(
                            alpha: FfTint.subtle.alpha,
                          )
                          : daysUntilDue <= 3
                          ? secColors.statusError.withValues(
                            alpha: FfTint.faint.alpha,
                          )
                          : context.ff.color.actionPrimary.withValues(
                            alpha: FfTint.faint.alpha,
                          ),
                  borderRadius: BorderRadius.circular(FfRadius.full),
                ),
                child: Text(
                  _dueLabel(),
                  style: context.ff.text.labelSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isOverdue
                            ? secColors.statusError
                            : daysUntilDue <= 3
                            ? secColors.statusError
                            : context.ff.color.actionPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xs),

          // Due date line
          Text(
            isOverdue
                ? 'Was due ${DateFormatter.formatFullDate(nextInstallment.dueDate)}'
                : 'Due ${DateFormatter.formatFullDate(nextInstallment.dueDate)}',
            style: context.ff.text.bodySm.copyWith(
              color: dueLabelColor,
              fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
            ),
          ),

          const SizedBox(height: FfSpace.md),

          // Full-width Mark Paid button — never overlaps text above
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: 'Mark installment ${nextInstallment.monthNumber} as paid',
              button: true,
              child: FfButton(
                label: 'Mark Paid',
                size: FfButtonSize.md,
                onPressed: onMarkPaid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Calm, factual overdue notice. Uses warning card variant, info icon.
class _OverdueBanner extends StatelessWidget {
  final List<AmortizationScheduleItem> overdueItems;
  final VoidCallback onPayFirst;
  final VoidCallback? onPayAll;

  const _OverdueBanner({
    required this.overdueItems,
    required this.onPayFirst,
    this.onPayAll,
  });

  @override
  Widget build(BuildContext context) {
    final secColors = context.ff.color;
    final first = overdueItems.first;
    final totalOverdue = overdueItems.fold<double>(
      0.0,
      (s, it) => s + it.emiAmount,
    );

    return FfCard(
      variant: FfCardVariant.warning,
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: secColors.statusError,
              ),
              const SizedBox(width: FfSpace.xs),
              Expanded(
                child: Text(
                  '${overdueItems.length} Overdue EMI${overdueItems.length > 1 ? "s" : ""}',
                  style: context.ff.text.titleSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: secColors.statusError,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatAmount(totalOverdue),
                style: context.ff.text.titleSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: secColors.statusError,
                ),
              ),
            ],
          ),

          const SizedBox(height: FfSpace.xs),

          // Detail line
          Text(
            'Installment #${first.monthNumber} (${DateFormatter.formatFullDate(first.dueDate)}) was due ${first.daysOverdue()} days ago.',
            style: context.ff.text.bodySm.copyWith(
              color: context.ff.color.secondary,
            ),
          ),

          const SizedBox(height: FfSpace.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FfButton(
                  label: 'Pay #${first.monthNumber}',
                  size: FfButtonSize.sm,
                  onPressed: onPayFirst,
                ),
              ),
              if (onPayAll != null) ...[
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: FfButton(
                    label: 'Pay All (${overdueItems.length}) Overdue',
                    size: FfButtonSize.sm,
                    variant: FfButtonVariant.outlined,
                    onPressed: onPayAll,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact paid / overdue / remaining summary with vertical dividers.
class _RepaymentSummary extends StatelessWidget {
  final int paidCount;
  final int overdueCount;
  final int remainingCount;
  final int totalMonths;
  final List<AmortizationScheduleItem> schedule;

  const _RepaymentSummary({
    required this.paidCount,
    required this.overdueCount,
    required this.remainingCount,
    required this.totalMonths,
    required this.schedule,
  });

  /// Six months around today: the five most recent due months and the next.
  List<FfMonthCell> _months() {
    if (schedule.isEmpty) return const [];
    final nextIndex = schedule.indexWhere((it) => !it.isPaid && !it.isOverdue);
    final end = nextIndex == -1 ? schedule.length - 1 : nextIndex;
    final start = (end - 5).clamp(0, schedule.length - 1);
    final format = DateFormat('MMM');
    return [
      for (var i = start; i <= end && i < schedule.length; i++)
        FfMonthCell(
          label: format.format(schedule[i].dueDate),
          status:
              schedule[i].isPaid
                  ? FfMonthStatus.paid
                  : schedule[i].isOverdue
                  ? FfMonthStatus.missed
                  : i == nextIndex
                  ? FfMonthStatus.due
                  : FfMonthStatus.upcoming,
          note:
              i == nextIndex
                  ? '${schedule[i].dueDate.day}${_ordinal(schedule[i].dueDate.day)}'
                  : null,
        ),
    ];
  }

  static String _ordinal(int d) {
    if (d >= 11 && d <= 13) return 'th';
    return switch (d % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final months = _months();
    return FfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FfStatTile(
                  label: 'Paid EMIs',
                  value: Text('$paidCount', style: ff.text.moneyLg),
                  unit: '/ $totalMonths',
                ),
              ),
              FfDotMatrix(
                total: totalMonths,
                done: paidCount,
                semanticsLabel: '$paidCount of $totalMonths EMIs paid',
              ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          Text(
            overdueCount > 0
                ? '$overdueCount overdue · $remainingCount remaining'
                : '$remainingCount remaining',
            style: ff.text.label.copyWith(
              color: overdueCount > 0 ? ff.color.statusError : null,
            ),
          ),
          if (months.isNotEmpty) ...[
            const SizedBox(height: FfSpace.md),
            FfMonthGrid(months: months),
          ],
        ],
      ),
    );
  }
}

/// Outstanding principal over the life of the loan, with today's month
/// selected.
class _PrincipalChart extends StatelessWidget {
  final List<AmortizationScheduleItem> schedule;

  const _PrincipalChart({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    const samples = 8;
    final step = (schedule.length / (samples - 1)).ceil().clamp(1, 1 << 20);
    final picked = <AmortizationScheduleItem>[
      for (var i = 0; i < schedule.length; i += step) schedule[i],
      if ((schedule.length - 1) % step != 0) schedule.last,
    ];
    final format = DateFormat("MMM ''yy");
    final points = [
      for (final it in picked)
        FfChartPoint(format.format(it.dueDate), it.closingBalance),
    ];
    final now = DateTime.now();
    var selected = picked.indexWhere((it) => it.dueDate.isAfter(now));
    if (selected == -1) selected = picked.length - 1;
    return FfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outstanding principal', style: ff.text.titleLg),
          const SizedBox(height: FfSpace.sm),
          FfLineChart(
            points: points,
            initialIndex: selected,
            valueLabel: (p) => CurrencyFormatter.formatCompact(p.value),
          ),
        ],
      ),
    );
  }
}

/// Grouped loan information — Loan / Repayment / Interest sections.
class _LoanInfoSection extends StatelessWidget {
  final Loan loan;
  final double totalRepayment;
  final double totalInterest;

  const _LoanInfoSection({
    required this.loan,
    required this.totalRepayment,
    required this.totalInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─ Loan Details ─────────────────────────────────────────────────
        _InfoSectionBlock(
          label: 'Loan Details',
          rows: [
            _InfoRowData('Lender', loan.lender),
            _InfoRowData('Loan Type', loan.loanType.displayName),
          ],
        ),

        const SizedBox(height: FfSpace.md),

        // ─ Repayment Details ─────────────────────────────────────────────
        _InfoSectionBlock(
          label: 'Repayment',
          rows: [
            _InfoRowData(
              'Interest Rate',
              '${loan.interestRate}% (${loan.interestType.displayName})',
            ),
            _InfoRowData('Tenure', '${loan.tenureMonths} months'),
            _InfoRowData(
              'Est. Total Repayment',
              CurrencyFormatter.formatAmount(totalRepayment),
            ),
          ],
        ),

        const SizedBox(height: FfSpace.md),

        // ─ Interest Details ──────────────────────────────────────────────
        _InfoSectionBlock(
          label: 'Interest',
          rows: [
            _InfoRowData(
              'Est. Total Interest',
              CurrencyFormatter.formatAmount(totalInterest),
            ),
          ],
        ),
      ],
    );
  }
}

/// A labeled block of info rows with a section heading.
class _InfoSectionBlock extends StatelessWidget {
  final String label;
  final List<_InfoRowData> rows;

  const _InfoSectionBlock({required this.label, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: FfSpace.x2s, bottom: FfSpace.xs),
          child: Text(
            label.toUpperCase(),
            style: context.ff.text.labelSm.copyWith(
              letterSpacing: 0.8,
              color: context.ff.color.secondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.ff.color.surfaceCard,
            borderRadius: BorderRadius.circular(FfRadius.lg),
            border: Border.all(
              color: context.ff.color.borderSubtle,
              width: FfBorderWidth.hairline,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                _InfoRow(data: rows[i]),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: FfBorderWidth.hairline,
                    indent: FfSpace.md,
                    endIndent: FfSpace.md,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Data holder for a label/value info row.
class _InfoRowData {
  final String label;
  final String value;
  const _InfoRowData(this.label, this.value);
}

/// A single label + value row inside an info section block.
class _InfoRow extends StatelessWidget {
  final _InfoRowData data;

  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return FfKeyValueRow(label: data.label, value: data.value);
  }
}
