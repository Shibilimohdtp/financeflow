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
import '../../theme/stillwater_tokens.dart';
import 'add_edit_loan_sheet.dart';
import 'loans_controller.dart';
import '../accounts/accounts_controller.dart';
import 'payment_account_picker.dart';
import 'widgets/emi_schedule_view.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';

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
          horizontal: StillwaterTokens.spaceLg,
          vertical: StillwaterTokens.spaceMd,
        ),
        children: [
          // ── 1. Balance Hero ──────────────────────────────────────────────
          _BalanceHeroSection(loan: currentLoan),

          const SizedBox(height: StillwaterTokens.spaceLg),

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
            const SizedBox(height: StillwaterTokens.spaceMd),
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
            const SizedBox(height: StillwaterTokens.spaceLg),
          ],

          // ── 4. Repayment Summary ─────────────────────────────────────────
          _RepaymentSummary(
            paidCount: paidItems.length,
            overdueCount: overdueItems.length,
            remainingCount: unpaidItems.length,
            totalMonths: currentLoan.tenureMonths,
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 5. Loan Information ──────────────────────────────────────────
          _LoanInfoSection(
            loan: currentLoan,
            totalRepayment: totalRepayment,
            totalInterest: totalInterest,
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 6. Amortization Schedule Access ─────────────────────────────
          FfButton(
            label: 'View Complete Amortization Schedule',
            variant: FfButtonVariant.outlined,
            onPressed: () => _openSchedule(context, currentLoan),
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // ── 7. Trust Statement ───────────────────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceMd,
              vertical: StillwaterTokens.spaceSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 16,
                  color: context.secColors.verified,
                ),
                const SizedBox(width: StillwaterTokens.spaceXs),
                Expanded(
                  child: Text(
                    'Values entered by you. Amortization and repayment calculated locally on this device.',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: context.theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),
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
    final theme = context.theme;
    final secColors = context.secColors;
    final remaining = ref.watch(loanRemainingBalanceProvider(loan));
    final paidPct = remaining.paidFraction;
    final isActive = loan.status == LoanStatus.active;

    // Status chip colors
    final chipColor = isActive ? theme.colorScheme.primary : secColors.verified;
    final chipBg =
        isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : secColors.verified.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Status chip
          Row(
            children: [
              Text(
                'Left to pay',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceXs,
                  vertical: StillwaterTokens.space2Xs,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusFull,
                  ),
                ),
                child: Text(
                  loan.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: chipColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceXs),

          // Remaining principal + interest — primary visual anchor
          Text(
            CurrencyFormatter.formatAmount(remaining.total),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: StillwaterTokens.space3Xs),
          Text(
            '${CurrencyFormatter.formatAmount(remaining.principal)} principal'
            ' + ${CurrencyFormatter.formatAmount(remaining.interest)} interest',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
            child: LinearProgressIndicator(
              value: paidPct,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: secColors.verified,
              minHeight: 8,
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceSm),

          // Paid / Original / Percentage row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      CurrencyFormatter.formatAmount(remaining.paid),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: secColors.verified,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${(paidPct * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'complete',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total payable',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      CurrencyFormatter.formatAmount(remaining.totalPayable),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    final theme = context.theme;
    final secColors = context.secColors;
    final isOverdue = nextInstallment.isOverdue;
    final dueLabelColor =
        isOverdue ? secColors.error : theme.colorScheme.secondary;

    return FfCard(
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatAmount(nextInstallment.emiAmount),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              // Due-status pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceXs,
                  vertical: StillwaterTokens.space2Xs,
                ),
                decoration: BoxDecoration(
                  color:
                      isOverdue
                          ? secColors.error.withValues(alpha: 0.10)
                          : daysUntilDue <= 3
                          ? secColors.error.withValues(alpha: 0.08)
                          : theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusFull,
                  ),
                ),
                child: Text(
                  _dueLabel(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isOverdue
                            ? secColors.error
                            : daysUntilDue <= 3
                            ? secColors.error
                            : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceXs),

          // Due date line
          Text(
            isOverdue
                ? 'Was due ${DateFormatter.formatFullDate(nextInstallment.dueDate)}'
                : 'Due ${DateFormatter.formatFullDate(nextInstallment.dueDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: dueLabelColor,
              fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

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
    final theme = context.theme;
    final secColors = context.secColors;
    final first = overdueItems.first;
    final totalOverdue = overdueItems.fold<double>(
      0.0,
      (s, it) => s + it.emiAmount,
    );

    return FfCard(
      variant: FfCardVariant.warning,
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: secColors.error,
              ),
              const SizedBox(width: StillwaterTokens.spaceXs),
              Expanded(
                child: Text(
                  '${overdueItems.length} Overdue EMI${overdueItems.length > 1 ? "s" : ""}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: secColors.error,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.formatAmount(totalOverdue),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: secColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceXs),

          // Detail line
          Text(
            'Installment #${first.monthNumber} (${DateFormatter.formatFullDate(first.dueDate)}) was due ${first.daysOverdue()} days ago.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

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
                const SizedBox(width: StillwaterTokens.spaceSm),
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

  const _RepaymentSummary({
    required this.paidCount,
    required this.overdueCount,
    required this.remainingCount,
    required this.totalMonths,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final secColors = context.secColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: StillwaterTokens.spaceMd,
        horizontal: StillwaterTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.40,
        ),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryColumn(
                label: 'Paid EMIs',
                value: '$paidCount / $totalMonths',
                color: secColors.verified,
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.75,
              indent: 8,
              endIndent: 8,
            ),
            Expanded(
              child: _SummaryColumn(
                label: 'Overdue',
                value: '$overdueCount',
                color:
                    overdueCount > 0
                        ? secColors.error
                        : theme.colorScheme.secondary,
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 0.75,
              indent: 8,
              endIndent: 8,
            ),
            Expanded(
              child: _SummaryColumn(
                label: 'Remaining',
                value: '$remainingCount',
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single stat column used inside _RepaymentSummary.
class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceXs),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 11,
            ),
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

        const SizedBox(height: StillwaterTokens.spaceMd),

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

        const SizedBox(height: StillwaterTokens.spaceMd),

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
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: StillwaterTokens.space2Xs,
            bottom: StillwaterTokens.spaceXs,
          ),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              color: theme.colorScheme.secondary,
              fontSize: 10,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            border: Border.all(
              color: theme.dividerColor,
              width: StillwaterTokens.borderWidthHairline,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                _InfoRow(data: rows[i]),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: StillwaterTokens.borderWidthHairline,
                    indent: StillwaterTokens.spaceMd,
                    endIndent: StillwaterTokens.spaceMd,
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
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              data.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: StillwaterTokens.spaceSm),
          Flexible(
            flex: 5,
            child: Text(
              data.value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
