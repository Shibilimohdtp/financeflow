import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/period/period.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../theme/stillwater_tokens.dart';
import '../transaction_list_utils.dart';

/// "‹ November 2026 ›" with a tap target that opens the period chooser.
class TransactionPeriodBar extends StatelessWidget {
  final Period? period;
  final ValueChanged<Period?> onChanged;

  const TransactionPeriodBar({
    super.key,
    required this.period,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = period;
    final now = DateTime.now();
    final canGoForward = p != null && !p.next().start.isAfter(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceXs),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous period',
            onPressed:
                p == null
                    ? null
                    : () {
                      HapticFeedback.selectionClick();
                      onChanged(p.previous());
                    },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: TextButton.icon(
              key: const ValueKey('period-chooser'),
              onPressed: () => _choose(context),
              icon: Text(
                periodLabel(p, now: now),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              label: const Icon(Icons.expand_more_rounded, size: 18),
            ),
          ),
          IconButton(
            tooltip: 'Next period',
            onPressed:
                canGoForward
                    ? () {
                      HapticFeedback.selectionClick();
                      onChanged(p.next());
                    }
                    : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _choose(BuildContext context) async {
    final now = DateTime.now();
    final choice = await showModalBottomSheet<_PeriodChoice>(
      context: context,
      showDragHandle: false,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FfSheetHeader(title: 'Show transactions for'),
                for (final choice in _PeriodChoice.values)
                  ListTile(
                    title: Text(choice.label),
                    onTap: () => Navigator.of(ctx).pop(choice),
                  ),
              ],
            ),
          ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _PeriodChoice.today:
        onChanged(Period.containing(PeriodUnit.day, now));
      case _PeriodChoice.week:
        onChanged(Period.containing(PeriodUnit.week, now));
      case _PeriodChoice.month:
        onChanged(Period.containing(PeriodUnit.month, now));
      case _PeriodChoice.year:
        onChanged(Period.containing(PeriodUnit.year, now));
      case _PeriodChoice.all:
        onChanged(null);
      case _PeriodChoice.custom:
        final current = period;
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(now.year + 1, 12, 31),
          initialDateRange:
              current == null
                  ? null
                  : DateTimeRange(start: current.start, end: current.lastDay),
        );
        if (picked != null) onChanged(Period.custom(picked.start, picked.end));
    }
  }
}

enum _PeriodChoice {
  today('Today'),
  week('This week'),
  month('This month'),
  year('This year'),
  all('All time'),
  custom('Custom range…');

  final String label;
  const _PeriodChoice(this.label);
}
