import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/money_advance.dart';
import '../../models/money_record.dart';
import '../../models/money_repayment.dart';
import '../../services/money_lending_calculator.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import 'add_edit_money_record_sheet.dart';
import 'add_repayment_sheet.dart';
import 'money_record_detail_screen.dart';
import 'money_records_controller.dart';
import 'widgets/lending_attention_lane.dart';
import 'widgets/lending_net_position_hero.dart';
import 'widgets/lending_person_card.dart';
import 'widgets/lending_settled_group.dart';

/// Direction axis for the two-axis filter.
enum LendingDirectionFilter { all, owedToMe, iOwe }

/// Status lens for the two-axis filter.
enum LendingStatusLens { all, overdue, dueSoon, settled }

/// Stillwater Bloom Lending & Borrowing overview screen (Pattern C on `FfAurora`).
///
/// Designed around what people ask of personal lending:
/// "Who owes me, whom do I owe, what is overdue or due soon, what is my net position?"
class LendingBorrowingScreen extends ConsumerStatefulWidget {
  const LendingBorrowingScreen({super.key});

  @override
  ConsumerState<LendingBorrowingScreen> createState() =>
      _LendingBorrowingScreenState();
}

class _LendingBorrowingScreenState
    extends ConsumerState<LendingBorrowingScreen> {
  LendingDirectionFilter _directionFilter = LendingDirectionFilter.all;
  LendingStatusLens _statusLens = LendingStatusLens.all;

  void _openAddSheet({MoneyRecordType? defaultType}) {
    showFfSheet(
      context,
      builder: (_) => AddEditMoneyRecordSheet(defaultType: defaultType),
    );
  }

  void _openDetail(MoneyRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MoneyRecordDetailScreen(record: record),
      ),
    );
  }

  void _openPayback(
    MoneyRecord record,
    List<MoneyAdvance> advances,
    List<MoneyRepayment> repayments,
  ) {
    final remaining = record.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    showFfSheet(
      context,
      builder:
          (_) => AddRepaymentSheet(record: record, remainingBalance: remaining),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(moneyLendingSummaryProvider);
    final allRecords =
        ref.watch(allMoneyRecordsStreamProvider).value ?? const [];
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

    // Filter by direction
    var records =
        allRecords.where((r) {
          switch (_directionFilter) {
            case LendingDirectionFilter.all:
              return true;
            case LendingDirectionFilter.owedToMe:
              return r.type == MoneyRecordType.lent;
            case LendingDirectionFilter.iOwe:
              return r.type == MoneyRecordType.borrowed;
          }
        }).toList();

    // Sort records: overdue first, then nearest due, settled last
    records = MoneyLendingCalculator.sortRecords(
      records,
      allRepayments,
      advances: allAdvances,
    );

    // Identify attention items (overdue or due in <= 7 days)
    final attentionRecords =
        allRecords.where((r) {
          final reps = repaymentsByRecord[r.id] ?? const [];
          final advs = advancesByRecord[r.id] ?? const [];
          if (r.isFullySettled(reps, advances: advs)) return false;
          return r.isOverdue(repayments: reps, advances: advs) ||
              r.isDueSoon(repayments: reps, advances: advs);
        }).toList();

    // Split into active and settled
    final activeRecords = <MoneyRecord>[];
    final settledRecords = <MoneyRecord>[];

    for (final r in records) {
      final reps = repaymentsByRecord[r.id] ?? const [];
      final advs = advancesByRecord[r.id] ?? const [];
      final isSettled = r.isFullySettled(reps, advances: advs);

      // Apply status lens
      if (_statusLens == LendingStatusLens.settled) {
        if (isSettled) settledRecords.add(r);
      } else if (_statusLens == LendingStatusLens.overdue) {
        if (!isSettled && r.isOverdue(repayments: reps, advances: advs)) {
          activeRecords.add(r);
        }
      } else if (_statusLens == LendingStatusLens.dueSoon) {
        if (!isSettled && r.isDueSoon(repayments: reps, advances: advs)) {
          activeRecords.add(r);
        }
      } else {
        // Lens is all
        if (isSettled) {
          settledRecords.add(r);
        } else {
          activeRecords.add(r);
        }
      }
    }

    return FfPageScaffold(
      onAurora: true,
      title: 'Lending & Borrowing',
      subtitle: 'Money lent and borrowed',
      actions: [
        FfCircleButton(
          icon: Icons.add_rounded,
          tooltip: 'Add Record',
          onPressed: () => _openAddSheet(),
        ),
      ],
      slivers: [
        // ── 2. Net Position Hero Card (Pattern C) ──────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.sm,
            ),
            child: LendingNetPositionHero(
              summary: summary,
              onAddLent: () => _openAddSheet(defaultType: MoneyRecordType.lent),
              onAddBorrowed:
                  () => _openAddSheet(defaultType: MoneyRecordType.borrowed),
            ),
          ),
        ),

        // ── 3. Needs Attention First Lane ──────────────────────────────
        if (_statusLens == LendingStatusLens.all &&
            _directionFilter == LendingDirectionFilter.all)
          LendingAttentionLane(
            attentionRecords: attentionRecords,
            advancesByRecord: advancesByRecord,
            repaymentsByRecord: repaymentsByRecord,
            onTapRecord: _openDetail,
            onPaybackRecord:
                (r) => _openPayback(
                  r,
                  advancesByRecord[r.id] ?? const [],
                  repaymentsByRecord[r.id] ?? const [],
                ),
          ),

        // ── 4. Two-Axis Filter ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.xs,
            ),
            child: Column(
              children: [
                // Direction Segmented Pill
                FfSegmentedPill<LendingDirectionFilter>(
                  options: const [
                    FfSegmentOption(
                      value: LendingDirectionFilter.all,
                      label: 'All',
                    ),
                    FfSegmentOption(
                      value: LendingDirectionFilter.owedToMe,
                      label: 'Owed to Me',
                    ),
                    FfSegmentOption(
                      value: LendingDirectionFilter.iOwe,
                      label: 'I Owe',
                    ),
                  ],
                  selectedValue: _directionFilter,
                  onSelected: (val) {
                    setState(() => _directionFilter = val);
                    // Keep riverpod filter provider in sync for test/external listeners
                    ref.read(moneyRecordFilterProvider.notifier).state =
                        val == LendingDirectionFilter.owedToMe
                            ? MoneyRecordFilter.owedToMe
                            : val == LendingDirectionFilter.iOwe
                            ? MoneyRecordFilter.iOwe
                            : MoneyRecordFilter.all;
                  },
                ),
                const SizedBox(height: FfSpace.sm),

                // Status Lenses Bar
                FfPillBar<LendingStatusLens>(
                  padding: EdgeInsets.zero,
                  values: LendingStatusLens.values,
                  selected: _statusLens,
                  label:
                      (lens) => switch (lens) {
                        LendingStatusLens.all => 'All',
                        LendingStatusLens.overdue =>
                          summary.overdueCount > 0
                              ? 'Overdue (${summary.overdueCount})'
                              : 'Overdue',
                        LendingStatusLens.dueSoon =>
                          summary.dueSoonCount > 0
                              ? 'Due Soon (${summary.dueSoonCount})'
                              : 'Due Soon',
                        LendingStatusLens.settled =>
                          summary.settledCount > 0
                              ? 'Settled (${summary.settledCount})'
                              : 'Settled',
                      },
                  onSelected: (val) {
                    setState(() => _statusLens = val);
                    ref.read(moneyRecordFilterProvider.notifier).state =
                        val == LendingStatusLens.overdue
                            ? MoneyRecordFilter.overdue
                            : val == LendingStatusLens.dueSoon
                            ? MoneyRecordFilter.dueSoon
                            : val == LendingStatusLens.settled
                            ? MoneyRecordFilter.settled
                            : MoneyRecordFilter.all;
                  },
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: FfSpace.sm)),

        // ── 5. Empty State or Records List ─────────────────────────────
        if (allRecords.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FfEmptyState(
                icon: Icons.handshake_outlined,
                title: 'No Lending or Borrowing Records',
                description:
                    'Keep track of money lent to friends or borrowed from family calmly and privately.',
                actionLabel: 'Add Record',
                onAction: () => _openAddSheet(),
              ),
            ),
          )
        else if (activeRecords.isEmpty && settledRecords.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FfEmptyState(
                icon: Icons.filter_list_off_rounded,
                title: 'No Matching Records',
                description: 'No records match the active filter criteria.',
                actionLabel: 'Clear Filters',
                onAction: () {
                  setState(() {
                    _directionFilter = LendingDirectionFilter.all;
                    _statusLens = LendingStatusLens.all;
                  });
                  ref.read(moneyRecordFilterProvider.notifier).state =
                      MoneyRecordFilter.all;
                },
              ),
            ),
          )
        else ...[
          // Active Records
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final record = activeRecords[index];
              return LendingPersonCard(
                record: record,
                advances: advancesByRecord[record.id] ?? const [],
                repayments: repaymentsByRecord[record.id] ?? const [],
                onTap: () => _openDetail(record),
                onPayback:
                    () => _openPayback(
                      record,
                      advancesByRecord[record.id] ?? const [],
                      repaymentsByRecord[record.id] ?? const [],
                    ),
              );
            }, childCount: activeRecords.length),
          ),

          // Collapsible Settled Group
          if (settledRecords.isNotEmpty)
            SliverToBoxAdapter(
              child: LendingSettledGroup(
                settledRecords: settledRecords,
                advancesByRecord: advancesByRecord,
                repaymentsByRecord: repaymentsByRecord,
                onTapRecord: _openDetail,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: FfSpace.x3l)),
        ],
      ],
    );
  }
}
