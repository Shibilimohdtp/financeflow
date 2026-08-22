import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../theme/stillwater_tokens.dart';

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
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
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
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
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
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.space2Xs,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
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
