import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_monogram_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Needs Attention lane displaying items overdue or due within 7 days.
class LendingAttentionLane extends StatelessWidget {
  const LendingAttentionLane({
    super.key,
    required this.attentionRecords,
    required this.advancesByRecord,
    required this.repaymentsByRecord,
    required this.onTapRecord,
    required this.onPaybackRecord,
  });

  final List<MoneyRecord> attentionRecords;
  final Map<String, List<MoneyAdvance>> advancesByRecord;
  final Map<String, List<MoneyRepayment>> repaymentsByRecord;
  final ValueChanged<MoneyRecord> onTapRecord;
  final ValueChanged<MoneyRecord> onPaybackRecord;

  @override
  Widget build(BuildContext context) {
    if (attentionRecords.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final ff = context.ff;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: Row(
              children: [
                Text(
                  'NEEDS ATTENTION',
                  style: ff.text.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: ff.color.textSecondary,
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.xs,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: ff.color.statusErrorContainer,
                    borderRadius: BorderRadius.circular(FfRadius.full),
                  ),
                  child: Text(
                    '${attentionRecords.length}',
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.statusError,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FfSpace.xs),
          SizedBox(
            height: 126,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
              ),
              itemCount: attentionRecords.length,
              separatorBuilder: (_, __) => const SizedBox(width: FfSpace.sm),
              itemBuilder: (context, index) {
                final record = attentionRecords[index];
                final isLent = record.type == MoneyRecordType.lent;
                final advances = advancesByRecord[record.id] ?? const [];
                final repayments = repaymentsByRecord[record.id] ?? const [];
                final remaining = record.calculateRemainingAmount(
                  repayments,
                  advances: advances,
                );
                final effectiveDueDate = record.calculateEffectiveDueDate(
                  advances: advances,
                  repayments: repayments,
                );
                final isOverdue = record.isOverdue(
                  repayments: repayments,
                  advances: advances,
                );

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final dueDay = DateTime(
                  effectiveDueDate.year,
                  effectiveDueDate.month,
                  effectiveDueDate.day,
                );
                final diff = dueDay.difference(today).inDays;

                final String statusPhrase;
                if (diff < 0) {
                  statusPhrase = '${diff.abs()}d overdue';
                } else if (diff == 0) {
                  statusPhrase = 'Due today';
                } else if (diff == 1) {
                  statusPhrase = 'Due tomorrow';
                } else {
                  statusPhrase = 'Due in ${diff}d';
                }

                return SizedBox(
                  width: 250,
                  child: FfCard(
                    density: FfDensity.compact,
                    onTap: () => onTapRecord(record),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FfMonogramTile(
                              name: record.personName,
                              size: 32,
                              tone: isLent ? FfTone.income : FfTone.expense,
                            ),
                            const SizedBox(width: FfSpace.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${record.personName} · $statusPhrase',
                                    style: ff.text.bodySm.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: FfSpace.x3s),
                                  Text(
                                    '${CurrencyFormatter.format(remaining)} left',
                                    style: ff.text.labelSm.copyWith(
                                      color: ff.color.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FfButton(
                            label: isLent ? 'Record payback' : 'Pay back',
                            size: FfButtonSize.sm,
                            variant:
                                isOverdue
                                    ? FfButtonVariant.primary
                                    : FfButtonVariant.filled,
                            onPressed: () => onPaybackRecord(record),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FfSpace.md),
        ],
      ),
    );
  }
}
