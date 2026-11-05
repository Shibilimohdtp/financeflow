import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/period/period.dart';
import '../../core/period/period_format.dart';
import 'ff_sheet_header.dart';
import '../../theme/stillwater_tokens.dart';
import 'ff_pickers.dart';
import 'ff_sheet.dart';

/// "‹ November 2026 ›" with a tap target that opens the period chooser.
/// Used by Home, Insights and the transaction list. A null period means all
/// time, offered only when [allowAllTime] is true.
class FfPeriodBar extends StatelessWidget {
  final Period? period;
  final ValueChanged<Period?> onChanged;
  final bool allowAllTime;

  const FfPeriodBar({
    super.key,
    required this.period,
    required this.onChanged,
    this.allowAllTime = false,
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
            child: Semantics(
              button: true,
              label: 'Choose period, ${periodLabel(p, now: now)}',
              excludeSemantics: true,
              child: InkWell(
                key: const ValueKey('period-chooser'),
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
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
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
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
              const FfSheetHeader(title: 'Show transactions for'),
              for (final choice in _PeriodChoice.values)
                if (allowAllTime || choice != _PeriodChoice.all)
                  ListTile(
                    title: Text(choice.label),
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
  today('Today'),
  week('This week'),
  month('This month'),
  year('This year'),
  all('All time'),
  custom('Custom range…');

  final String label;
  const _PeriodChoice(this.label);
}
