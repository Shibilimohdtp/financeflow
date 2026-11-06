import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/money_advance.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../services/money_lending_calculator.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import 'add_edit_money_record_sheet.dart';
import 'money_record_detail_screen.dart';
import 'money_records_controller.dart';
import 'widgets/lending_summary_box.dart';
import 'widgets/money_record_card.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
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
                        child: LendingSummaryBox(
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
                        child: LendingSummaryBox(
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
                  LendingFilterChipItem(
                    label: 'All',
                    isSelected: currentFilter == MoneyRecordFilter.all,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.all;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  LendingFilterChipItem(
                    label: 'Owed to Me',
                    count: summary.activeLentCount,
                    isSelected: currentFilter == MoneyRecordFilter.owedToMe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.owedToMe;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  LendingFilterChipItem(
                    label: 'I Owe',
                    count: summary.activeBorrowedCount,
                    isSelected: currentFilter == MoneyRecordFilter.iOwe,
                    onTap: () {
                      ref.read(moneyRecordFilterProvider.notifier).state =
                          MoneyRecordFilter.iOwe;
                    },
                  ),
                  const SizedBox(width: FfSpace.sm),
                  LendingFilterChipItem(
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
                  LendingFilterChipItem(
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
                  LendingFilterChipItem(
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
                    child: MoneyRecordCard(
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
