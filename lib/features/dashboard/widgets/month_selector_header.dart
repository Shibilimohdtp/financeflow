import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/ff_pickers.dart';
import '../../../theme/ff.dart';

class MonthSelectorHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelectorHeader({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Month',
            onPressed: () {
              final prev = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
                1,
              );
              onMonthChanged(prev);
            },
          ),
          InkWell(
            borderRadius: BorderRadius.circular(FfRadius.sm),
            onTap: () async {
              final picked = await pickFfDate(
                context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                onMonthChanged(picked);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.sm,
                vertical: FfSpace.x2s,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: FfSpace.xs),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: context.ff.text.title.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  const Icon(Icons.arrow_drop_down_rounded, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Month',
            onPressed: () {
              final next = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
                1,
              );
              onMonthChanged(next);
            },
          ),
        ],
      ),
    );
  }
}
