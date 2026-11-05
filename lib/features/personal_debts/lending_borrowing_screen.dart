import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/money_advance.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../services/money_lending_calculator.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_money_record_sheet.dart';
import 'money_record_detail_screen.dart';
import 'money_records_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class LendingBorrowingScreen extends ConsumerWidget {
  const LendingBorrowingScreen({super.key});

  void _openAddSheet(BuildContext context, {MoneyRecordType? defaultType}) {
    showFfSheet(
      context,
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
    final allAdvances =
        ref.watch(allMoneyAdvancesStreamProvider).value ?? const [];
    final allRepayments =
        ref.watch(allMoneyRepaymentsStreamProvider).value ?? const [];

    final repaymentsByRecord = <String, List<MoneyRepayment>>{};
    for (final r in allRepayments) {
      repaymentsByRecord.putIfAbsent(r.moneyRecordId, () => []).add(r);
    }

    final advancesByRecord = <String, List<MoneyAdvance>>{};
    for (final a in allAdvances) {
      advancesByRecord.putIfAbsent(a.moneyRecordId, () => []).add(a);
    }

    return Scaffold(
      appBar: FfAppBar(
        title: 'Lending & Borrowing',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.lg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
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
                FfSpace.lg,
                FfSpace.md,
                FfSpace.lg,
                FfSpace.sm,
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
                          color: context.ff.color.moneyIncome,
                          icon: Icons.call_made_rounded,
                          onAddTap:
                              () => _openAddSheet(
                                context,
                                defaultType: MoneyRecordType.lent,
                              ),
                        ),
                      ),
                      const SizedBox(width: FfSpace.md),
                      // I Owe (Borrowed)
                      Expanded(
                        child: _SummaryBox(
                          title: 'I OWE',
                          amount: summary.totalIOwe,
                          subtitle:
                              '${summary.activeBorrowedCount} active${summary.overdueIOwe > 0 ? ' · ${CurrencyFormatter.format(summary.overdueIOwe)} overdue' : ''}',
                          color: context.ff.color.moneyExpense,
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
                horizontal: FfSpace.lg,
                vertical: FfSpace.sm,
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
                  const SizedBox(width: FfSpace.sm),
                  _FilterChipItem(
                    label: 'Owed to Me',
                    count: summary.activeLentCount,
                    isSelected: currentFilter == MoneyRecordFilter.owedToMe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.owedToMe;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  _FilterChipItem(
                    label: 'I Owe',
                    count: summary.activeBorrowedCount,
                    isSelected: currentFilter == MoneyRecordFilter.iOwe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.iOwe;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  _FilterChipItem(
                    label: 'Overdue',
                    count: summary.overdueCount,
                    color: context.ff.color.moneyExpense,
                    isSelected: currentFilter == MoneyRecordFilter.overdue,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.overdue;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  _FilterChipItem(
                    label: 'Due Soon',
                    count: summary.dueSoonCount,
                    color: context.ff.color.moneyDebt,
                    isSelected: currentFilter == MoneyRecordFilter.dueSoon,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.dueSoon;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
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
                  padding: const EdgeInsets.all(FfSpace.x2l),
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
                FfSpace.lg,
                FfSpace.sm,
                FfSpace.lg,
                104, // Space for FAB and bottom padding
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((ctx, index) {
                  final record = records[index];
                  final reps = repaymentsByRecord[record.id] ?? const [];
                  final advs = advancesByRecord[record.id] ?? const [];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: FfSpace.sm),
                    child: _MoneyRecordCard(
                      record: record,
                      advances: advs,
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
    return FfCard(
      variant: FfCardVariant.standard,
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: FfSpace.xs),
                  Text(
                    title,
                    style: context.ff.text.labelSm.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(FfRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(FfSpace.x2s),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          Text(
            CurrencyFormatter.format(amount),
            style: context.ff.text.titleLg.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: StillwaterTypography.tabularFeatures,
            ),
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            subtitle,
            style: context.ff.text.labelSm.copyWith(
              color: context.ff.color.secondary,
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
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChipItem({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? context.ff.color.actionPrimary;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: FfSpace.x2s),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.x2s,
                vertical: FfSpace.x3s,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? context.ff.color.onActionPrimary.withValues(
                          alpha: FfTint.medium.alpha,
                        )
                        : activeColor.withValues(alpha: FfTint.subtle.alpha),
                borderRadius: BorderRadius.circular(FfRadius.full),
              ),
              child: Text(
                count.toString(),
                style: context.ff.text.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected
                          ? context.ff.color.onActionPrimary
                          : activeColor,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: activeColor,
      labelStyle: context.ff.text.label.copyWith(
        color:
            isSelected
                ? context.ff.color.onActionPrimary
                : context.ff.color.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: context.ff.color.surfaceCard,
      side: BorderSide(
        color:
            isSelected
                ? activeColor
                : context.ff.color.borderSubtle.withValues(
                  alpha: FfTint.strong.alpha,
                ),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FfRadius.full),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.sm,
        vertical: FfSpace.x2s,
      ),
    );
  }
}

class _MoneyRecordCard extends StatelessWidget {
  final MoneyRecord record;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final VoidCallback onTap;

  const _MoneyRecordCard({
    required this.record,
    this.advances = const [],
    required this.repayments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLent = record.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.ff.color.moneyIncome : context.ff.color.moneyExpense;
    final totalAdvanced = record.calculateTotalAdvanced(advances);
    final totalRepaid = record.calculateTotalRepaid(repayments);
    final remaining = record.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    final isSettled = record.isFullySettled(repayments, advances: advances);
    final isOverdue = record.isOverdue(
      repayments: repayments,
      advances: advances,
    );
    final isDueSoon = record.isDueSoon(
      repayments: repayments,
      advances: advances,
    );
    final status = record.calculateStatus(repayments, advances: advances);
    final effectiveDueDate = record.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );
    final progress =
        totalAdvanced > 0 ? (totalRepaid / totalAdvanced).clamp(0.0, 1.0) : 0.0;
    final advanceCount = advances.isNotEmpty ? advances.length : 1;

    return FfCard(
      variant: FfCardVariant.standard,
      onTap: onTap,
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Person name, direction badge, advance count, remaining amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle with icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: FfTint.subtle.alpha),
                  borderRadius: BorderRadius.circular(FfRadius.md),
                ),
                child: Icon(record.type.icon, color: typeColor, size: 20),
              ),
              const SizedBox(width: FfSpace.md),

              // Person name, direction subtitle, and advance count pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            record.personName,
                            style: context.ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (advanceCount > 1) ...[
                          const SizedBox(width: FfSpace.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.x2s,
                              vertical: FfSpace.x3s,
                            ),
                            decoration: BoxDecoration(
                              color: context.ff.color.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(FfRadius.sm),
                            ),
                            child: Text(
                              '$advanceCount advances',
                              style: context.ff.text.labelSm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.ff.color.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Row(
                      children: [
                        Text(
                          isLent ? 'Lent' : 'Borrowed',
                          style: context.ff.text.bodySm.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ${DateFormatter.formatShortDate(record.transactionDate)}',
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance & total advanced amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: context.ff.text.title.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          isSettled ? context.ff.color.moneyIncome : typeColor,
                      fontFeatures: StillwaterTypography.tabularFeatures,
                    ),
                  ),
                  if (totalRepaid > 0.001 || totalAdvanced > remaining)
                    Text(
                      'Total: ${CurrencyFormatter.format(totalAdvanced)}',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        fontFeatures: StillwaterTypography.tabularFeatures,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Row 2: Progress bar (if partially repaid)
          if (totalRepaid > 0.001 && !isSettled) ...[
            const SizedBox(height: FfSpace.sm),
            FfProgressBar(
              value: progress,
              color: typeColor,
              size: FfProgressSize.sm,
            ),
          ],

          const SizedBox(height: FfSpace.sm),
          const FfDivider(),
          const SizedBox(height: FfSpace.sm),

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
                            ? context.ff.color.moneyExpense
                            : (isDueSoon
                                ? context.ff.color.moneyDebt
                                : context.ff.color.secondary),
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  Text(
                    isSettled
                        ? 'Settled'
                        : (isOverdue
                            ? 'Overdue (${DateFormatter.formatShortDate(effectiveDueDate)})'
                            : 'Due ${DateFormatter.formatShortDate(effectiveDueDate)}'),
                    style: context.ff.text.bodySm.copyWith(
                      color:
                          isOverdue
                              ? context.ff.color.moneyExpense
                              : (isDueSoon
                                  ? context.ff.color.moneyDebt
                                  : context.ff.color.secondary),
                      fontWeight:
                          (isOverdue || isDueSoon)
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.sm,
                  vertical: FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color: status
                      .colorFor(isDark: context.isDarkMode)
                      .withValues(alpha: FfTint.subtle.alpha),
                  borderRadius: BorderRadius.circular(FfRadius.full),
                ),
                child: Text(
                  status.displayName,
                  style: context.ff.text.labelSm.copyWith(
                    color: status.colorFor(isDark: context.isDarkMode),
                    fontWeight: FontWeight.w700,
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
