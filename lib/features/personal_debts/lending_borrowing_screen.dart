import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../services/money_lending_calculator.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_money_record_sheet.dart';
import 'money_record_detail_screen.dart';
import 'money_records_controller.dart';

class LendingBorrowingScreen extends ConsumerWidget {
  const LendingBorrowingScreen({super.key});

  void _openAddSheet(BuildContext context, {MoneyRecordType? defaultType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditMoneyRecordSheet(defaultType: defaultType),
    );
  }

  void _openDetail(BuildContext context, MoneyRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MoneyRecordDetailScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(moneyLendingSummaryProvider);
    final currentFilter = ref.watch(moneyRecordFilterProvider);
    final records = ref.watch(filteredMoneyRecordsProvider);
    final allRepayments =
        ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];

    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in allRepayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lending & Borrowing'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'lending_borrowing_add_fab',
        tooltip: 'Add lending or borrowing record',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
      body: CustomScrollView(
        slivers: [
          // ── 1. Hero Summary Cards ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                StillwaterTokens.spaceLg,
                StillwaterTokens.spaceMd,
                StillwaterTokens.spaceLg,
                StillwaterTokens.spaceSm,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Owed to Me (Lent)
                      Expanded(
                        child: _SummaryBox(
                          title: 'OWED TO ME',
                          amount: summary.totalOwedToMe,
                          subtitle:
                              '${summary.activeLentCount} active${summary.overdueOwedToMe > 0 ? ' · ${CurrencyFormatter.format(summary.overdueOwedToMe)} overdue' : ''}',
                          color: context.finColors.income,
                          icon: Icons.call_made_rounded,
                          onAddTap:
                              () => _openAddSheet(
                                context,
                                defaultType: MoneyRecordType.lent,
                              ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      // I Owe (Borrowed)
                      Expanded(
                        child: _SummaryBox(
                          title: 'I OWE',
                          amount: summary.totalIOwe,
                          subtitle:
                              '${summary.activeBorrowedCount} active${summary.overdueIOwe > 0 ? ' · ${CurrencyFormatter.format(summary.overdueIOwe)} overdue' : ''}',
                          color: context.finColors.expense,
                          icon: Icons.call_received_rounded,
                          onAddTap:
                              () => _openAddSheet(
                                context,
                                defaultType: MoneyRecordType.borrowed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Filter Pills ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
                vertical: StillwaterTokens.spaceSm,
              ),
              child: Row(
                children: [
                  _FilterChipItem(
                    label: 'All',
                    isSelected: currentFilter == MoneyRecordFilter.all,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.all;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  _FilterChipItem(
                    label: 'Owed to Me',
                    count: summary.activeLentCount,
                    isSelected: currentFilter == MoneyRecordFilter.owedToMe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.owedToMe;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  _FilterChipItem(
                    label: 'I Owe',
                    count: summary.activeBorrowedCount,
                    isSelected: currentFilter == MoneyRecordFilter.iOwe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.iOwe;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  _FilterChipItem(
                    label: 'Overdue',
                    count: summary.overdueCount,
                    color: context.finColors.expense,
                    isSelected: currentFilter == MoneyRecordFilter.overdue,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.overdue;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  _FilterChipItem(
                    label: 'Due Soon',
                    count: summary.dueSoonCount,
                    color: context.finColors.debt,
                    isSelected: currentFilter == MoneyRecordFilter.dueSoon,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.dueSoon;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceSm),
                  _FilterChipItem(
                    label: 'Settled',
                    count: summary.settledCount,
                    isSelected: currentFilter == MoneyRecordFilter.settled,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.settled;
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── 3. Record Cards List ──────────────────────────────────────────
          if (records.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(StillwaterTokens.space2Xl),
                  child: FfEmptyState(
                    icon: Icons.handshake_outlined,
                    title:
                        currentFilter == MoneyRecordFilter.all
                            ? 'No Lending or Borrowing Records'
                            : 'No ${currentFilter.displayName} Records',
                    description:
                        currentFilter == MoneyRecordFilter.all
                            ? 'Keep track of money you have lent to friends or borrowed from others.'
                            : 'No records matching the current filter.',
                    actionLabel:
                        currentFilter == MoneyRecordFilter.all
                            ? 'Add First Record'
                            : null,
                    onAction:
                        currentFilter == MoneyRecordFilter.all
                            ? () => _openAddSheet(context)
                            : null,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                StillwaterTokens.spaceLg,
                StillwaterTokens.spaceSm,
                StillwaterTokens.spaceLg,
                104, // Space for FAB and bottom padding
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((ctx, index) {
                  final record = records[index];
                  final reps = repaymentsByRecord[record.id] ?? const [];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: StillwaterTokens.spaceSm,
                    ),
                    child: _MoneyRecordCard(
                      record: record,
                      repayments: reps,
                      onTap: () => _openDetail(context, record),
                    ),
                  );
                }, childCount: records.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onAddTap;

  const _SummaryBox({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FfCard(
      variant: FfCardVariant.elevated,
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(
                  StillwaterTokens.radiusFull,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          Text(
            CurrencyFormatter.format(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: StillwaterTypography.tabularFeatures,
            ),
          ),
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final int? count;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    this.count,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceMd,
          vertical: StillwaterTokens.spaceSm - 2,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? activeColor.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
          border: Border.all(
            color:
                isSelected
                    ? activeColor
                    : theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : theme.colorScheme.onSurface,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: StillwaterTokens.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusFull,
                  ),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoneyRecordCard extends StatelessWidget {
  final MoneyRecord record;
  final List<MoneyRepayment> repayments;
  final VoidCallback onTap;

  const _MoneyRecordCard({
    required this.record,
    required this.repayments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLent = record.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.finColors.income : context.finColors.expense;
    final totalRepaid = record.calculateTotalRepaid(repayments);
    final remaining = record.calculateRemainingAmount(repayments);
    final isSettled = record.isFullySettled(repayments);
    final isOverdue = record.isOverdue(repayments: repayments);
    final isDueSoon = record.isDueSoon(repayments: repayments);
    final status = record.calculateStatus(repayments);
    final progress =
        record.originalAmount > 0
            ? (totalRepaid / record.originalAmount).clamp(0.0, 1.0)
            : 0.0;

    return FfCard(
      variant: FfCardVariant.standard,
      onTap: onTap,
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Person name, direction badge, remaining amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle with icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusMd,
                  ),
                ),
                child: Icon(record.type.icon, color: typeColor, size: 20),
              ),
              const SizedBox(width: StillwaterTokens.spaceMd),

              // Person name and direction subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.personName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          isLent ? 'Lent' : 'Borrowed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ${DateFormatter.formatShortDate(record.transactionDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance & original amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isSettled ? context.finColors.income : typeColor,
                      fontFeatures: StillwaterTypography.tabularFeatures,
                    ),
                  ),
                  if (totalRepaid > 0.001)
                    Text(
                      'Orig: ${CurrencyFormatter.format(record.originalAmount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                        fontFeatures: StillwaterTypography.tabularFeatures,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Row 2: Progress bar (if partially repaid)
          if (totalRepaid > 0.001 && !isSettled) ...[
            const SizedBox(height: StillwaterTokens.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(typeColor),
              ),
            ),
          ],

          const SizedBox(height: StillwaterTokens.spaceSm),
          const Divider(height: 1),
          const SizedBox(height: StillwaterTokens.spaceSm),

          // Row 3: Due date with relative badge & status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Due Date indicator
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : (isDueSoon
                            ? Icons.schedule_rounded
                            : Icons.calendar_today_outlined),
                    size: 14,
                    color:
                        isOverdue
                            ? context.finColors.expense
                            : (isDueSoon
                                ? context.finColors.debt
                                : theme.colorScheme.secondary),
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    isSettled
                        ? 'Settled'
                        : (isOverdue
                            ? 'Overdue (${DateFormatter.formatShortDate(record.dueDate)})'
                            : 'Due ${DateFormatter.formatShortDate(record.dueDate)}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isOverdue
                              ? context.finColors.expense
                              : (isDueSoon
                                  ? context.finColors.debt
                                  : theme.colorScheme.secondary),
                      fontWeight:
                          (isOverdue || isDueSoon)
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                ),
                child: Text(
                  status.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          // Row 4: Optional Notes Preview
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: StillwaterTokens.spaceXs),
            Text(
              record.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
