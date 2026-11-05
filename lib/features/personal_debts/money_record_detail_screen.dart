import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/account.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../accounts/accounts_controller.dart';
import 'add_advance_sheet.dart';
import 'add_edit_money_record_sheet.dart';
import 'add_repayment_sheet.dart';
import 'money_records_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';

class MoneyRecordDetailScreen extends ConsumerWidget {
  final MoneyRecord record;

  const MoneyRecordDetailScreen({super.key, required this.record});

  void _openEditSheet(BuildContext context, MoneyRecord liveRecord) {
    showFfSheet(
      context,
      builder: (_) => AddEditMoneyRecordSheet(initialRecord: liveRecord),
    );
  }

  void _openAddAdvanceSheet(BuildContext context, MoneyRecord liveRecord) {
    showFfSheet(context, builder: (_) => AddAdvanceSheet(record: liveRecord));
  }

  void _openRepaymentSheet(
    BuildContext context,
    MoneyRecord liveRecord,
    double remaining,
  ) {
    showFfSheet(
      context,
      builder:
          (_) => AddRepaymentSheet(
            record: liveRecord,
            remainingBalance: remaining,
          ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MoneyRecord liveRecord,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Record?',
      message:
          'Deleting this relationship will also remove all its advance and repayment logs (${liveRecord.personName}). This cannot be undone.',
      confirmLabel: 'Delete Record',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRecord(liveRecord.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfToast.show(context, message: 'Record deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to delete record: $e',
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteRepayment(
    BuildContext context,
    WidgetRef ref,
    MoneyRepayment repayment,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Repayment?',
      message:
          'Remove this repayment of ${CurrencyFormatter.format(repayment.amount)}? The remaining balance will be recalculated.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRepayment(repayment.id, record.id);
        if (context.mounted) {
          FfToast.show(context, message: 'Repayment deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Failed to delete repayment: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    // Watch live record from database
    final allRecords = ref.watch(allMoneyRecordsStreamProvider).value ?? [];
    final liveRecord = allRecords.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );

    final advancesAsync = ref.watch(moneyRecordAdvancesProvider(liveRecord.id));
    final advances = advancesAsync.value ?? [];

    final repaymentsAsync = ref.watch(
      moneyRecordRepaymentsProvider(liveRecord.id),
    );
    final repayments = repaymentsAsync.value ?? [];

    final accounts =
        ref.watch(rawAccountsStreamProvider).valueOrNull ?? const <Account>[];
    final accountMap = {for (final a in accounts) a.id: a.name};

    final totalAdvanced = liveRecord.calculateTotalAdvanced(advances);
    final totalRepaid = liveRecord.calculateTotalRepaid(repayments);
    final remaining = liveRecord.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    final isSettled = liveRecord.isFullySettled(repayments, advances: advances);
    final isOverdue = liveRecord.isOverdue(
      repayments: repayments,
      advances: advances,
    );
    final isDueSoon = liveRecord.isDueSoon(
      repayments: repayments,
      advances: advances,
    );
    final status = liveRecord.calculateStatus(repayments, advances: advances);
    final effectiveDueDate = liveRecord.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );
    final progress =
        totalAdvanced > 0 ? (totalRepaid / totalAdvanced).clamp(0.0, 1.0) : 0.0;

    final allocations = liveRecord.calculateAllocatedAdvances(
      advances: advances,
      repayments: repayments,
    );

    final isLent = liveRecord.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.finColors.income : context.finColors.expense;

    return Scaffold(
      appBar: FfAppBar(
        title: liveRecord.personName,
        actions: [
          IconButton(
            tooltip: 'Edit record',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditSheet(context, liveRecord),
          ),
          IconButton(
            tooltip: 'Delete record',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, liveRecord),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceMd,
          StillwaterTokens.spaceLg,
          StillwaterTokens.space3Xl,
        ),
        children: [
          // ── 1. Status Banner ──────────────────────────────────────────────
          if (isSettled)
            Container(
              margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceMd),
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: context.finColors.income.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: context.finColors.income.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: context.finColors.income,
                    size: 20,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'Fully Settled · No balance remaining',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.finColors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isOverdue)
            Container(
              margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceMd),
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: context.finColors.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: context.finColors.expense.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.finColors.expense,
                    size: 20,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'Overdue · Repayment was expected by ${DateFormatter.formatShortDate(effectiveDueDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.finColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isDueSoon)
            Container(
              margin: const EdgeInsets.only(bottom: StillwaterTokens.spaceMd),
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              decoration: BoxDecoration(
                color: context.finColors.debt.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                border: Border.all(
                  color: context.finColors.debt.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: context.finColors.debt,
                    size: 20,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'Due Soon · Expected by ${DateFormatter.formatShortDate(effectiveDueDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.finColors.debt,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── 2. Hero Summary Card ──────────────────────────────────────────
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Direction badge & status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceSm,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusSm,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            liveRecord.type.icon,
                            size: 14,
                            color: typeColor,
                          ),
                          const SizedBox(width: StillwaterTokens.space2Xs),
                          Text(
                            liveRecord.type.directionLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceSm,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color: status
                            .colorFor(isDark: context.isDarkMode)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusSm,
                        ),
                      ),
                      child: Text(
                        status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.colorFor(isDark: context.isDarkMode),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),

                // Remaining balance
                Text(
                  'REMAINING BALANCE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space2Xs),
                Text(
                  CurrencyFormatter.format(remaining),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSettled ? context.finColors.income : typeColor,
                    fontFeatures: StillwaterTypography.tabularFeatures,
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusFull,
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSettled ? context.finColors.income : typeColor,
                    ),
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Metrics row: Total Advanced vs Total Repaid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Advanced',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(totalAdvanced),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: StillwaterTypography.tabularFeatures,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Repaid',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.format(totalRepaid)} (${(progress * 100).toInt()}%)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.finColors.income,
                            fontFeatures: StillwaterTypography.tabularFeatures,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Quick Actions ──────────────────────────────────────────────
          Row(
            children: [
              if (!isSettled) ...[
                Expanded(
                  child: FfButton(
                    label: 'Record Repayment',
                    leadingIcon: const Icon(Icons.payments_outlined, size: 18),
                    variant: FfButtonVariant.primary,
                    onPressed:
                        () =>
                            _openRepaymentSheet(context, liveRecord, remaining),
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: FfButton(
                    label: isLent ? 'Lend More' : 'Borrow More',
                    leadingIcon: const Icon(Icons.add_circle_outline, size: 18),
                    variant: FfButtonVariant.secondary,
                    onPressed: () => _openAddAdvanceSheet(context, liveRecord),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: FfButton(
                    label: 'Mark as Unsettled',
                    leadingIcon: const Icon(Icons.replay_rounded, size: 18),
                    variant: FfButtonVariant.outlined,
                    onPressed: () async {
                      final controller = ref.read(
                        moneyRecordsControllerProvider.notifier,
                      );
                      await controller.markRecordUnsettled(liveRecord.id);
                      if (context.mounted) {
                        FfToast.show(
                          context,
                          message: 'Record status restored.',
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          // ── 4. Advance History Section ─────────────────────────────────────
          _SectionHeader(
            title:
                'Advance History (${advances.isNotEmpty ? advances.length : 1})',
            trailing:
                !isSettled
                    ? TextButton.icon(
                      onPressed:
                          () => _openAddAdvanceSheet(context, liveRecord),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Advance'),
                    )
                    : null,
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),

          if (advances.isEmpty)
            FfCard(
              variant: FfCardVariant.standard,
              padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                    ),
                    child: Icon(
                      liveRecord.type.icon,
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.format(liveRecord.originalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: StillwaterTypography.tabularFeatures,
                          ),
                        ),
                        Text(
                          '${DateFormatter.formatShortDate(liveRecord.transactionDate)} · Due ${DateFormatter.formatShortDate(liveRecord.dueDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            FfCard(
              variant: FfCardVariant.standard,
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allocations.length,
                separatorBuilder: (_, __) => const FfDivider(),
                itemBuilder: (ctx, index) {
                  final alloc = allocations[index];
                  final item = alloc.advance;
                  final accountName =
                      item.accountId != null
                          ? accountMap[item.accountId]
                          : null;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceMd,
                      vertical: StillwaterTokens.space2Xs,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            alloc.isFullyPaid
                                ? context.finColors.income.withValues(
                                  alpha: 0.12,
                                )
                                : typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        alloc.isFullyPaid
                            ? Icons.check_circle_outline_rounded
                            : liveRecord.type.icon,
                        color:
                            alloc.isFullyPaid
                                ? context.finColors.income
                                : typeColor,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(item.amount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: StillwaterTypography.tabularFeatures,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                alloc.isFullyPaid
                                    ? context.finColors.income.withValues(
                                      alpha: 0.12,
                                    )
                                    : (alloc.allocatedRepaid > 0.001
                                        ? context.finColors.debt.withValues(
                                          alpha: 0.12,
                                        )
                                        : theme.dividerColor.withValues(
                                          alpha: 0.3,
                                        )),
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusSm,
                            ),
                          ),
                          child: Text(
                            alloc.isFullyPaid
                                ? 'Repaid'
                                : (alloc.allocatedRepaid > 0.001
                                    ? 'Paid ${CurrencyFormatter.format(alloc.allocatedRepaid)}'
                                    : 'Unpaid'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color:
                                  alloc.isFullyPaid
                                      ? context.finColors.income
                                      : (alloc.allocatedRepaid > 0.001
                                          ? context.finColors.debt
                                          : theme.colorScheme.secondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormatter.formatShortDate(item.date)} · Due ${DateFormatter.formatShortDate(item.dueDate)}${accountName != null ? ' · $accountName' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          // ── 5. Repayment History Section ──────────────────────────────────
          _SectionHeader(
            title: 'Repayment History (${repayments.length})',
            trailing:
                repayments.isNotEmpty && !isSettled
                    ? TextButton.icon(
                      onPressed:
                          () => _openRepaymentSheet(
                            context,
                            liveRecord,
                            remaining,
                          ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add Repayment'),
                    )
                    : null,
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),

          if (repayments.isEmpty)
            FfCard(
              variant: FfCardVariant.standard,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: StillwaterTokens.spaceLg,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 36,
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Text(
                      'No repayments recorded yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    Text(
                      'Tap "Record Repayment" above when a payment is made.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            FfCard(
              variant: FfCardVariant.standard,
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: repayments.length,
                separatorBuilder: (_, __) => const FfDivider(),
                itemBuilder: (ctx, index) {
                  final item = repayments[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceMd,
                      vertical: StillwaterTokens.space2Xs,
                    ),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: context.finColors.income.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: context.finColors.income,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      CurrencyFormatter.format(item.amount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: StillwaterTypography.tabularFeatures,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormatter.formatShortDate(item.repaymentDate)}${item.notes != null ? ' · ${item.notes}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      tooltip: 'Delete repayment',
                      onPressed:
                          () => _confirmDeleteRepayment(context, ref, item),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          // ── 6. Dates & Details Info ───────────────────────────────────────
          _SectionHeader(title: 'Relationship Details'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          FfCard(
            variant: FfCardVariant.standard,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _DetailTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Started On',
                  value: DateFormatter.formatFullDate(
                    liveRecord.transactionDate,
                  ),
                ),
                const FfDivider(),
                _DetailTile(
                  icon: Icons.event_available_outlined,
                  label: 'Next Due Date',
                  value: DateFormatter.formatFullDate(effectiveDueDate),
                ),
                const FfDivider(),
                _DetailTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Reminder',
                  value:
                      liveRecord.isReminderEnabled
                          ? 'Enabled (${liveRecord.reminderDaysBefore} ${liveRecord.reminderDaysBefore == 1 ? 'day' : 'days'} before)'
                          : 'Disabled',
                ),
                if (liveRecord.notes != null &&
                    liveRecord.notes!.isNotEmpty) ...[
                  const FfDivider(),
                  _DetailTile(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: liveRecord.notes!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
