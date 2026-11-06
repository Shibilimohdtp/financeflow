import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/period/period.dart';
import '../../core/period/period_format.dart';
import 'ff_sheet_header.dart';
import 'ff_pickers.dart';
import 'ff_sheet.dart';
import 'ff_row.dart';
import '../../theme/ff.dart';

/// "‹ November 2026 ›" with a tap target that opens the period chooser.
/// Used by Home, Insights, the transaction list and the Plan tab. A null
/// period means all time, offered only when [allowAllTime] is true.
///
/// [units] limits the chooser to those kinds of period (the Plan tab offers
/// week, month and year only; `PeriodUnit.day` is "Today" and
/// `PeriodUnit.custom` is "Custom range…"). Null offers every kind.
/// [chooserTitle] heads the chooser sheet.
class FfPeriodBar extends StatelessWidget {
  final Period? period;
  final ValueChanged<Period?> onChanged;
  final bool allowAllTime;
  final Set<PeriodUnit>? units;
  final String chooserTitle;

  const FfPeriodBar({
    super.key,
    required this.period,
    required this.onChanged,
    this.allowAllTime = false,
    this.units,
    this.chooserTitle = 'Show transactions for',
  });

  @override
  Widget build(BuildContext context) {
    final p = period;
    final now = DateTime.now();
    final canGoForward = p != null && !p.next().start.isAfter(now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.xs),
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
            child: Semantics(
              button: true,
              label: 'Choose period, ${periodLabel(p, now: now)}',
              excludeSemantics: true,
              child: InkWell(
                key: const ValueKey('period-chooser'),
                borderRadius: BorderRadius.circular(FfRadius.sm),
                onTap: () => _choose(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          periodLabel(p, now: now),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: FfSpace.x2s),
                      const Icon(Icons.expand_more_rounded, size: 18),
                    ],
                  ),
                ),
              ),
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
    final choice = await showFfSheet<_PeriodChoice>(
      context,
      builder:
          (ctx) => FfSheet(
            children: [
              FfSheetHeader(title: chooserTitle),
              for (final choice in _PeriodChoice.values)
                if (choice == _PeriodChoice.all
                    ? allowAllTime
                    : (units == null || units!.contains(choice.unit)))
                  FfRow(
                    title: choice.label,
                    onTap: () => Navigator.of(ctx).pop(choice),
                  ),
            ],
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
        final picked = await pickFfDateRange(
          context,
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
  today('Today', PeriodUnit.day),
  week('This week', PeriodUnit.week),
  month('This month', PeriodUnit.month),
  year('This year', PeriodUnit.year),
  all('All time', null),
  custom('Custom range…', PeriodUnit.custom);

  final String label;
  final PeriodUnit? unit;
  const _PeriodChoice(this.label, this.unit);
}
