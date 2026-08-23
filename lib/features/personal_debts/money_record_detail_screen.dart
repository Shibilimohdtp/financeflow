import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_money_record_sheet.dart';
import 'add_repayment_sheet.dart';
import 'money_records_controller.dart';

class MoneyRecordDetailScreen extends ConsumerWidget {
  final MoneyRecord record;

  const MoneyRecordDetailScreen({super.key, required this.record});

  void _openEditSheet(BuildContext context, MoneyRecord liveRecord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditMoneyRecordSheet(initialRecord: liveRecord),
    );
  }

  void _openRepaymentSheet(
    BuildContext context,
    MoneyRecord liveRecord,
    double remaining,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRepaymentSheet(
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
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Record?',
      message:
          'Deleting this record will also remove all its repayment logs (${liveRecord.personName}). This cannot be undone.',
      confirmLabel: 'Delete Record',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRecord(liveRecord.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfSnackbar.show(context, message: 'Record deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Failed to delete record: $e');
        }
      }
    }
  }

  Future<void> _confirmDeleteRepayment(
    BuildContext context,
    WidgetRef ref,
    MoneyRepayment repayment,
  ) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Repayment?',
      message:
          'Remove this repayment of ${CurrencyFormatter.format(repayment.amount)}? The remaining balance will be recalculated.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final controller = ref.read(moneyRecordsControllerProvider.notifier);
      try {
        await controller.deleteRepayment(repayment.id, record.id);
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Repayment deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Failed to delete repayment: $e');
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

    final repaymentsAsync =
        ref.watch(moneyRecordRepaymentsProvider(liveRecord.id));
    final repayments = repaymentsAsync.value ?? [];

    final totalRepaid = liveRecord.calculateTotalRepaid(repayments);
    final remaining = liveRecord.calculateRemainingAmount(repayments);
    final isSettled = liveRecord.isFullySettled(repayments);
    final isOverdue = liveRecord.isOverdue(repayments: repayments);
    final isDueSoon = liveRecord.isDueSoon(repayments: repayments);
    final status = liveRecord.calculateStatus(repayments);
    final progress = liveRecord.originalAmount > 0
        ? (totalRepaid / liveRecord.originalAmount).clamp(0.0, 1.0)
        : 0.0;

    final isLent = liveRecord.type == MoneyRecordType.lent;
    final typeColor = isLent ? context.finColors.income : context.finColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveRecord.personName),
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
                      'Overdue · Repayment was expected by ${DateFormatter.formatShortDate(liveRecord.dueDate)}',
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
                      'Due Soon · Expected by ${DateFormatter.formatShortDate(liveRecord.dueDate)}',
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
                        borderRadius:
                            BorderRadius.circular(StillwaterTokens.radiusSm),
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
                        color: status.color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(StillwaterTokens.radiusSm),
                      ),
                      child: Text(
                        status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.color,
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
                    color: isSettled
                        ? context.finColors.income
                        : typeColor,
                    fontFeatures: StillwaterTypography.tabularFeatures,
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Progress Bar
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(StillwaterTokens.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        theme.dividerColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSettled
                          ? context.finColors.income
                          : typeColor,
                    ),
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Metrics row: Original Amount vs Total Repaid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Original Amount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(liveRecord.originalAmount),
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
                  flex: 3,
                  child: FfButton(
                    label: 'Record Repayment',
                    leadingIcon: const Icon(Icons.payments_outlined, size: 18),
                    variant: FfButtonVariant.primary,
                    onPressed: () => _openRepaymentSheet(
                      context,
                      liveRecord,
                      remaining,
                    ),
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  flex: 2,
                  child: FfButton(
                    label: 'Settle',
                    leadingIcon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    variant: FfButtonVariant.secondary,
                    onPressed: () async {
                      final controller = ref.read(
                        moneyRecordsControllerProvider.notifier,
                      );
                      await controller.markRecordSettled(liveRecord.id);
                      if (context.mounted) {
                        FfSnackbar.show(
                          context,
                          message: 'Record marked as settled.',
                        );
                      }
                    },
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
                        FfSnackbar.show(
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

          // ── 4. Dates & Details Info ───────────────────────────────────────
          _SectionHeader(title: 'Record Details'),
          const SizedBox(height: StillwaterTokens.spaceXs),
          FfCard(
            variant: FfCardVariant.standard,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _DetailTile(
                  icon: Icons.calendar_today_outlined,
                  label: isLent ? 'Lent On' : 'Borrowed On',
                  value: DateFormatter.formatFullDate(
                    liveRecord.transactionDate,
                  ),
                ),
                const Divider(height: 1),
                _DetailTile(
                  icon: Icons.event_available_outlined,
                  label: 'Expected Due Date',
                  value: DateFormatter.formatFullDate(liveRecord.dueDate),
                ),
                const Divider(height: 1),
                _DetailTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Reminder',
                  value: liveRecord.isReminderEnabled
                      ? 'Enabled (${liveRecord.reminderDaysBefore} ${liveRecord.reminderDaysBefore == 1 ? 'day' : 'days'} before)'
                      : 'Disabled',
                ),
                if (liveRecord.notes != null &&
                    liveRecord.notes!.isNotEmpty) ...[
                  const Divider(height: 1),
                  _DetailTile(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: liveRecord.notes!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceXl),

          // ── 5. Repayment History Section ──────────────────────────────────
          _SectionHeader(
            title: 'Repayment History (${repayments.length})',
            trailing: repayments.isNotEmpty && !isSettled
                ? TextButton.icon(
                    onPressed: () => _openRepaymentSheet(
                      context,
                      liveRecord,
                      remaining,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add'),
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
                        color: theme.colorScheme.secondary.withValues(alpha: 0.8),
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
                separatorBuilder: (_, __) => const Divider(height: 1),
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
                        borderRadius:
                            BorderRadius.circular(StillwaterTokens.radiusSm),
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
                      onPressed: () => _confirmDeleteRepayment(context, ref, item),
                    ),
                  );
                },
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
