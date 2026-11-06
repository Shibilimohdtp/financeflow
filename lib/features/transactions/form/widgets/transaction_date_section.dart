import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        Text('Date', style: context.ff.text.labelLg),
        const SizedBox(height: FfSpace.x2s),
        LayoutBuilder(
          builder: (context, constraints) {
            final isVeryNarrow = constraints.maxWidth < 280;

            if (isVeryNarrow) {
              return Wrap(
                spacing: FfSpace.xs,
                runSpacing: FfSpace.xs,
                children: [
                  ChoiceChip(
                    label: const Text('Today'),
                    selected: isToday,
                    onSelected: (_) => onSelectDate(now),
                  ),
                  ChoiceChip(
                    label: const Text('Yesterday'),
                    selected: isYesterday,
                    onSelected:
                        (_) =>
                            onSelectDate(now.subtract(const Duration(days: 1))),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: onPickCustomDate,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ChoiceChip(
                    label: const Center(child: Text('Today')),
                    selected: isToday,
                    showCheckmark: false,
                    onSelected: (_) => onSelectDate(now),
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  flex: 4,
                  child: ChoiceChip(
                    label: const Center(child: Text('Yesterday')),
                    selected: isYesterday,
                    showCheckmark: false,
                    onSelected:
                        (_) =>
                            onSelectDate(now.subtract(const Duration(days: 1))),
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Expanded(
                  flex: 5,
                  child: ChoiceChip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 14),
                    label: Text(
                      formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    selected: isCustom,
                    showCheckmark: false,
                    onSelected: (_) => onPickCustomDate(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
