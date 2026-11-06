import 'package:flutter/material.dart';

import '../../../core/period/period.dart';
import '../../../core/period/period_format.dart';
import '../../../services/budgets/budget_board.dart';
import '../../../services/budgets/budget_engine.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_page_header.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../shared/widgets/ff_round_buttons.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../budget_format.dart';

/// The Plan tab's header: title, subtitle, and optional back button (when
/// Plan is opened as a page). Uses the canonical [FfPageHeader].
class PlanHeader extends StatelessWidget {
  const PlanHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return FfPageHeader(
      title: 'Plan',
      subtitle: 'Budgets and bills',
      onBack: onBack,
    );
  }
}

/// The one figure that matters, straight on the aurora: what can be spent
/// today without breaking the plan (current period), what was left or
/// overspent (a closed period), or what is planned (a future one). A quiet
/// line underneath puts it in context, and the hide-amounts button sits
/// beside it, as on Home.
class PlanKeyFigure extends StatelessWidget {
  const PlanKeyFigure({
    super.key,
    required this.board,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
  });

  final BudgetBoard board;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final b = board;
    final name = _periodName(b.period);
    final net = b.plannedMinor - b.spentMinor;

    final (String label, int amountMinor, String line) = switch (b.timing) {
      PeriodTiming.current => (
        'Safe to spend today',
        BudgetFormat.floorWhole(b.safeTodayMinor),
        b.overspentMinor > 0 && b.leftMinor == 0
            ? '${BudgetFormat.money(b.overspentMinor)} over plan · '
                '${_days(b.daysLeft)} to go'
            : '${BudgetFormat.money(b.leftMinor)} left of '
                '${BudgetFormat.money(b.plannedMinor)} · '
                '${_days(b.daysLeft)} to go',
      ),
      PeriodTiming.past =>
        net >= 0
            ? (
              'Left at the end of $name',
              net,
              'Spent ${BudgetFormat.money(b.spentMinor)} of '
                  '${BudgetFormat.money(b.plannedMinor)}',
            )
            : (
              'Over plan in $name',
              -net,
              'Spent ${BudgetFormat.money(b.spentMinor)} of '
                  '${BudgetFormat.money(b.plannedMinor)}',
            ),
      PeriodTiming.future => (
        'Planned for $name',
        b.plannedMinor,
        'Starts ${BudgetFormat.shortDate(b.period.start)}',
      ),
    };

    final spoken =
        isPrivacyBlur
            ? '$label, hidden for privacy'
            : '$label, ${BudgetFormat.money(amountMinor)}. $line';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: spoken,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Text(label, style: ff.text.label)),
            Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: FfAmountText(
                      key: const ValueKey('plan-key-figure'),
                      amount: BudgetFormat.major(amountMinor),
                      size: FfAmountSize.hero,
                      tone: FfTone.neutral,
                      showSign: false,
                      isBlurred: isPrivacyBlur,
                    ),
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                FfCircleButton(
                  key: const ValueKey('plan-privacy'),
                  icon:
                      isPrivacyBlur
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                  tooltip: isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                  soft: true,
                  onPressed: onToggleBlur,
                ),
              ],
            ),
            if (!isPrivacyBlur)
              ExcludeSemantics(
                child: Text(
                  line,
                  style: ff.text.label.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _days(int n) => n == 1 ? '1 day' : '$n days';
}

/// The plan as one rose hero card: a ring for the share spent, the status
/// in words, spent against plan as split figures, the pace bar, and three
/// small figures. The ↗ button opens Money filtered to exactly the
/// transactions these budgets count.
class PlanHero extends StatelessWidget {
  const PlanHero({
    super.key,
    required this.board,
    required this.isPrivacyBlur,
    this.onOpenSpending,
  });

  final BudgetBoard board;
  final bool isPrivacyBlur;
  final VoidCallback? onOpenSpending;

  @override
  Widget build(BuildContext context) {
    final b = board;
    final count = b.results.length;
    final attention = b.needsAttention.length;
    final pct = BudgetFormat.percent(b.fractionSpent);
    final subtitle = [
      count == 1 ? '1 budget' : '$count budgets',
      if (b.timing == PeriodTiming.current && attention > 0)
        '$attention need${attention == 1 ? 's' : ''} attention',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: FfHeroCard(
        key: const ValueKey('plan-hero'),
        tone: FfHeroTone.rose,
        leading: FfProgressRing(
          value: b.fractionSpent.clamp(0.0, 1.0),
          icon: Icons.pie_chart_outline_rounded,
          semanticsLabel: '$pct% of the plan spent',
        ),
        title: _planTitle(b.period),
        subtitle: subtitle,
        onOpen: onOpenSpending,
        openTooltip: 'See this plan\'s spending in Money',
        child: Builder(builder: (context) => _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final ff = context.ff;
    final b = board;
    final isCurrent = b.timing == PeriodTiming.current;
    final expected =
        b.totalDays > 0
            ? (b.plannedMinor * b.elapsedDays / b.totalDays).round()
            : 0;
    final pace = BudgetFormat.pace(b.spentMinor, expected);
    final pct = BudgetFormat.percent(b.fractionSpent);
    final spoken = [
      '$pct% used',
      if (!isPrivacyBlur) ...[
        b.overspentMinor > 0 && b.leftMinor == 0
            ? '${BudgetFormat.money(b.overspentMinor)} over'
            : '${BudgetFormat.money(b.leftMinor)} left',
        if (isCurrent) pace.toLowerCase(),
      ],
    ].join(', ');

    Widget figure(String label, int minor, CrossAxisAlignment align) =>
        FfStatTile(
          label: label,
          crossAxisAlignment: align,
          value: FfAmountText(
            amount: BudgetFormat.major(minor),
            size: FfAmountSize.lg,
            tone: FfTone.neutral,
            showSign: false,
            isBlurred: isPrivacyBlur,
          ),
        );

    final withinCount =
        b.results.where((r) => r.spentMinor <= r.limitMinor).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: figure('Spent', b.spentMinor, CrossAxisAlignment.start),
            ),
            const SizedBox(width: FfSpace.sm),
            Expanded(
              child: figure('Plan', b.plannedMinor, CrossAxisAlignment.end),
            ),
          ],
        ),
        const SizedBox(height: FfSpace.md),
        FfProgressBar(
          value: b.fractionSpent,
          pace: isCurrent ? b.fractionElapsed : null,
          onHero: true,
          semanticLabel: 'Plan used',
          semanticValue: spoken,
        ),
        const SizedBox(height: FfSpace.sm),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: FfSpace.xs,
          runSpacing: FfSpace.x2s,
          children: [
            FfBadge(
              label: BudgetFormat.planStatus(b),
              tone: FfTone.neutral,
              icon: BudgetFormat.planStatusIcon(b),
            ),
            Text(
              isCurrent
                  ? (isPrivacyBlur ? '$pct% used' : pace)
                  : '$withinCount of ${b.results.length} within plan',
              style: ff.text.label,
            ),
          ],
        ),
        if (isCurrent) ...[
          const SizedBox(height: FfSpace.lg),
          FfHeroFigures([
            FfHeroFigure(
              'Forecast',
              isPrivacyBlur ? '••••' : BudgetFormat.estimate(b.forecastMinor),
              semanticsValue: isPrivacyBlur ? 'hidden' : null,
            ),
            FfHeroFigure(
              'Planned so far',
              isPrivacyBlur ? '••••' : BudgetFormat.estimate(expected),
              semanticsValue: isPrivacyBlur ? 'hidden' : null,
            ),
            FfHeroFigure(
              'Days left',
              '${b.daysLeft}',
              semanticsValue: b.daysLeft == 1 ? '1 day' : '${b.daysLeft} days',
            ),
          ]),
        ],
      ],
    );
  }

  static String _planTitle(Period p) => switch (p.unit) {
    PeriodUnit.week => 'Plan for the ${periodLabel(p).toLowerCase()}',
    _ => '${_periodName(p)} plan',
  };
}

/// "November", "this week", "2026": the period in a sentence.
String _periodName(Period p) => switch (p.unit) {
  PeriodUnit.month => _monthNames[p.start.month - 1],
  PeriodUnit.year => '${p.start.year}',
  _ => periodLabel(p),
};

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
