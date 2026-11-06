import 'package:flutter/material.dart';

import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../theme/ff.dart';
import 'lending_person_card.dart';

/// Quiet collapsible section at the bottom of the list for settled records.
class LendingSettledGroup extends StatefulWidget {
  const LendingSettledGroup({
    super.key,
    required this.settledRecords,
    required this.advancesByRecord,
    required this.repaymentsByRecord,
    required this.onTapRecord,
  });

  final List<MoneyRecord> settledRecords;
  final Map<String, List<MoneyAdvance>> advancesByRecord;
  final Map<String, List<MoneyRepayment>> repaymentsByRecord;
  final ValueChanged<MoneyRecord> onTapRecord;

  @override
  State<LendingSettledGroup> createState() => _LendingSettledGroupState();
}

class _LendingSettledGroupState extends State<LendingSettledGroup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.settledRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final ff = context.ff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: FfSpace.lg),
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(FfRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: ff.color.textTertiary,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Text(
                      'Settled · ${widget.settledRecords.length}',
                      style: ff.text.label.copyWith(
                        color: ff.color.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: ff.color.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          for (final record in widget.settledRecords)
            LendingPersonCard(
              record: record,
              advances: widget.advancesByRecord[record.id] ?? const [],
              repayments: widget.repaymentsByRecord[record.id] ?? const [],
              onTap: () => widget.onTapRecord(record),
            ),
        ],
        const SizedBox(height: FfSpace.x2l),
      ],
    );
  }
}
