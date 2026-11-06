import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_pickers.dart';
import '../../../theme/ff.dart';

/// Intention-based date selectors with quick presets and calendar fallback.
class MoneyRecordDateChips extends StatelessWidget {
  const MoneyRecordDateChips({
    super.key,
    required this.transactionDate,
    required this.dueDate,
    required this.onTransactionDateChanged,
    required this.onDueDateChanged,
  });

  final DateTime transactionDate;
  final DateTime dueDate;
  final ValueChanged<DateTime> onTransactionDateChanged;
  final ValueChanged<DateTime> onDueDateChanged;

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _endOfMonth(DateTime d) {
    final nextMonth = DateTime(d.year, d.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  Future<void> _pickCustomTxDate(BuildContext context) async {
    final picked = await pickFfDate(
      context,
      initialDate: transactionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onTransactionDateChanged(picked);
      if (dueDate.isBefore(picked)) {
        onDueDateChanged(picked.add(const Duration(days: 14)));
      }
    }
  }

  Future<void> _pickCustomDueDate(BuildContext context) async {
    final picked = await pickFfDate(
      context,
      initialDate:
          dueDate.isBefore(transactionDate) ? transactionDate : dueDate,
      firstDate: transactionDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      onDueDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final now = DateTime.now();
    final today = _startOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDay = _startOfDay(transactionDate);

    final inOneWeek = txDay.add(const Duration(days: 7));
    final inTwoWeeks = txDay.add(const Duration(days: 14));
    final endMonth = _endOfMonth(txDay);
    final inThreeMonths = txDay.add(const Duration(days: 90));

    final dueDay = _startOfDay(dueDate);

    final isCustomTx = txDay != today && txDay != yesterday;
    final isCustomDue =
        dueDay != inOneWeek &&
        dueDay != inTwoWeeks &&
        dueDay != endMonth &&
        dueDay != inThreeMonths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Transaction Date ─────────────────────────────────────────────
        Text(
          'Date',
          style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: FfSpace.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FfChip(
                label: 'Today',
                isSelected: txDay == today,
                onSelected: () => onTransactionDateChanged(today),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: 'Yesterday',
                isSelected: txDay == yesterday,
                onSelected: () => onTransactionDateChanged(yesterday),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label:
                    isCustomTx
                        ? DateFormatter.formatShortDate(transactionDate)
                        : 'Pick date',
                leading: const Icon(Icons.calendar_today_outlined, size: 16),
                isSelected: isCustomTx,
                onSelected: () => _pickCustomTxDate(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.lg),

        // ── Expected Due Date ─────────────────────────────────────────────
        Text(
          'Expected Due Date',
          style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: FfSpace.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FfChip(
                label: 'In 1 week',
                isSelected: dueDay == inOneWeek,
                onSelected: () => onDueDateChanged(inOneWeek),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: 'In 2 weeks',
                isSelected: dueDay == inTwoWeeks,
                onSelected: () => onDueDateChanged(inTwoWeeks),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: 'End of month',
                isSelected: dueDay == endMonth,
                onSelected: () => onDueDateChanged(endMonth),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: 'In 3 months',
                isSelected: dueDay == inThreeMonths,
                onSelected: () => onDueDateChanged(inThreeMonths),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label:
                    isCustomDue
                        ? DateFormatter.formatShortDate(dueDate)
                        : 'Custom',
                leading: const Icon(Icons.event_available_outlined, size: 16),
                isSelected: isCustomDue,
                onSelected: () => _pickCustomDueDate(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
