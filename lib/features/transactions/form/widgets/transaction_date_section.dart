import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/ff_chip.dart';
import '../../../../theme/ff.dart';

class TransactionDateSection extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onPickCustomDate;

  const TransactionDateSection({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onPickCustomDate,
  });

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _sameDay(selectedDate, now);
    final isYesterday = _sameDay(
      selectedDate,
      now.subtract(const Duration(days: 1)),
    );
    final isCustom = !isToday && !isYesterday;
    final formattedDate = DateFormat('d MMM yyyy').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: context.ff.text.label.copyWith(
            color: context.ff.color.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: FfSpace.xs),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: FfChip(
                label: 'Today',
                isSelected: isToday,
                onSelected: () => onSelectDate(now),
              ),
            ),
            const SizedBox(width: FfSpace.xs),
            Expanded(
              flex: 4,
              child: FfChip(
                label: 'Yesterday',
                isSelected: isYesterday,
                onSelected:
                    () => onSelectDate(now.subtract(const Duration(days: 1))),
              ),
            ),
            const SizedBox(width: FfSpace.xs),
            Expanded(
              flex: 5,
              child: FfChip(
                label: formattedDate,
                isSelected: isCustom,
                leading: const Icon(Icons.calendar_today_outlined, size: 14),
                onSelected: onPickCustomDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
