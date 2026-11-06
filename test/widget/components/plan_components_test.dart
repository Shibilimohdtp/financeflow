// DS-B7a: shared additions for the Plan tab (Budgets), in every palette and
// mode, with large text and reduced effects: the hero/tone/semantics options
// of FfProgressBar, FfLineChart's reference series, FfMonthGrid's
// within-plan/over-plan months, FfHeroFigures and FfPeriodBar(units:).
import 'package:financeflow/core/period/period.dart';
import 'package:financeflow/shared/widgets/ff_data_viz.dart';
import 'package:financeflow/shared/widgets/ff_period_bar.dart';
import 'package:financeflow/shared/widgets/ff_progress.dart';
import 'package:financeflow/shared/widgets/ff_stat_tile.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  ThemeData theme,
  Widget child, {
  double textScale = 1,
  double width = 400,
  FfEffects effects = FfEffects.full,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 900),
        textScaler: TextScaler.linear(textScale),
      ),
      child: FfEffectsScope(
        effects: effects,
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  ),
);

const _history = [
  FfMonthCell(label: 'Jun', status: FfMonthStatus.under, note: '₹5.2k'),
  FfMonthCell(label: 'Jul', status: FfMonthStatus.over, note: '₹6.8k'),
  FfMonthCell(label: 'Aug', status: FfMonthStatus.under, note: '₹5.9k'),
  FfMonthCell(label: 'Sep', status: FfMonthStatus.over, note: '₹7.1k'),
  FfMonthCell(label: 'Oct', status: FfMonthStatus.over, note: '₹6.9k'),
  FfMonthCell(label: 'Nov', status: FfMonthStatus.none),
];

/// The Plan hero and detail parts on one page.
Widget _everything() => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const FfHeroCard(
      tone: FfHeroTone.rose,
      title: 'November',
      subtitle: 'Needs attention',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfProgressBar(
            value: 0.52,
            pace: 0.2,
            onHero: true,
            tone: FfTone.expense,
            semanticLabel: 'Plan used',
            semanticValue: '52% used, ₹15,730 left, ahead of pace by ₹10,670',
          ),
          SizedBox(height: 16),
          FfHeroFigures([
            FfHeroFigure('Per day', '₹629'),
            FfHeroFigure('Forecast', '₹31,400'),
            FfHeroFigure('Days left', '25'),
          ]),
        ],
      ),
    ),
    const SizedBox(height: 12),
    const FfProgressBar(value: 1.13, pace: 0.2, tone: FfTone.expense),
    const SizedBox(height: 12),
    FfLineChart(
      points: [
        for (final (i, v) in [1450, 3830, 3830, 5750, 6800].indexed)
          FfChartPoint('Day ${i + 1}', v.toDouble()),
      ],
      reference: [for (var d = 0; d < 30; d++) 6000 * (d + 1) / 30],
      domainLength: 30,
      valueLabel: (p) => '₹${p.value.round()}',
      referenceLabel: (i) => 'pace ₹${(6000 * (i + 1) / 30).round()}',
      hint: 'Swipe up or down to change the day',
    ),
    const SizedBox(height: 12),
    const FfMonthGrid(months: _history),
  ],
);

void main() {
  for (final palette in FfPalettes.all) {
    for (final brightness in Brightness.values) {
      final theme = FfTheme.build(palette, brightness);
      final c = palette.colorsFor(brightness);
      final hero = palette.heroesFor(brightness)[FfHeroTone.rose];
      final where = '${palette.id}/${brightness.name}';

      group('Plan components ($where)', () {
        testWidgets('render at 1× and 2× text, full and reduced effects', (
          tester,
        ) async {
          for (final effects in FfEffects.values) {
            for (final scale in [1.0, 2.0]) {
              await _pump(
                tester,
                theme,
                _everything(),
                textScale: scale,
                width: 360,
                effects: effects,
              );
              await tester.pump();
              expect(
                tester.takeException(),
                isNull,
                reason: '${effects.name}, text scale $scale',
              );
            }
          }
        });

        testWidgets('progress bar on a hero uses the hero text colour', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pump(tester, theme, _everything());
          final bars = tester.widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
          final onHero = bars.first;
          // Tone is ignored on a hero: heroes stay neutral.
          expect(onHero.color, hero.onHero);
          expect(
            onHero.backgroundColor,
            hero.onHero.withValues(alpha: FfProgressTokens.heroTrack.alpha),
          );
          expect(
            onHero.semanticsValue,
            '52% used, ₹15,730 left, ahead of pace by ₹10,670',
          );
          // Off the hero, the tone sets the fill and the value clamps.
          final over = bars.elementAt(1);
          expect(over.color, c.moneyExpense);
          expect(over.backgroundColor, c.surfaceContainerHighest);
          expect(over.value, 1.0);
          expect(over.semanticsValue, '100%');
          handle.dispose();
        });

        testWidgets('an explicit colour still wins over the tone', (
          tester,
        ) async {
          await _pump(
            tester,
            theme,
            FfProgressBar(value: 0.3, tone: FfTone.expense, color: c.spark),
          );
          final bar = tester.widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
          expect(bar.color, c.spark);
        });

        testWidgets('line chart reads the pace and stops at today', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          var selected = -1;
          await _pump(
            tester,
            theme,
            FfLineChart(
              points: const [
                FfChartPoint('Day 1', 1450),
                FfChartPoint('Day 2', 3830),
                FfChartPoint('Day 3', 5750),
              ],
              reference: [for (var d = 0; d < 30; d++) 200.0 * (d + 1)],
              domainLength: 30,
              valueLabel: (p) => '₹${p.value.round()}',
              referenceLabel: (i) => 'pace ₹${200 * (i + 1)}',
              hint: 'Swipe up or down to change the day',
              initialIndex: 0,
              onSelected: (i) => selected = i,
            ),
          );
          expect(
            find.bySemanticsLabel('Day 1: ₹1450, pace ₹200'),
            findsOneWidget,
          );
          // A tap in the empty future part of the period selects today.
          final box = tester.getRect(find.byType(FfLineChart));
          await tester.tapAt(box.centerRight - const Offset(4, 0));
          await tester.pump();
          expect(selected, 2);
          expect(
            find.bySemanticsLabel('Day 3: ₹5750, pace ₹600'),
            findsOneWidget,
          );
          // Points are laid out over all 30 slots, not stretched to 3.
          await tester.tapAt(box.centerLeft + Offset(box.width * 0.04, 0));
          await tester.pump();
          expect(selected, 1);
          handle.dispose();
        });

        testWidgets('a chart without a reference behaves as before', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pump(
            tester,
            theme,
            FfLineChart(
              points: const [FfChartPoint('Aug', 1), FfChartPoint('Sep', 2)],
              valueLabel: (p) => '${p.value}',
            ),
          );
          final node = tester.getSemantics(find.bySemanticsLabel('Sep: 2.0'));
          expect(node.hint, 'Swipe up or down to change the month');
          handle.dispose();
        });

        testWidgets('budget months say within or over plan, with the amount', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pump(tester, theme, const FfMonthGrid(months: _history));
          for (final label in [
            'Jun, within plan, ₹5.2k',
            'Jul, over plan, ₹6.8k',
            'Nov, no payment',
          ]) {
            expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
          }
          // Over plan is an amber "!" (not colour alone); within plan a check.
          expect(find.byIcon(Icons.priority_high_rounded), findsNWidgets(3));
          expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
          final over = tester.widget<Icon>(
            find.byIcon(Icons.priority_high_rounded).first,
          );
          expect(over.color, c.onStatusWarningFill);
          expect(find.text('₹6.8k'), findsOneWidget);
          handle.dispose();
        });

        testWidgets('hero figures align to the edges and read as phrases', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await _pump(
            tester,
            theme,
            const FfHeroFigures([
              FfHeroFigure('Per day', '₹629'),
              FfHeroFigure('Forecast', '₹31,400'),
              FfHeroFigure('Days left', '25', semanticsValue: '25 days'),
            ]),
          );
          expect(find.bySemanticsLabel('Per day, ₹629'), findsOneWidget);
          expect(find.bySemanticsLabel('Days left, 25 days'), findsOneWidget);
          final row = tester.getRect(find.byType(FfHeroFigures));
          expect(
            tester.getRect(find.text('Per day')).left,
            closeTo(row.left, 0.01),
          );
          expect(
            tester.getRect(find.text('Days left')).right,
            closeTo(row.right, 0.01),
          );
          final mid = tester.getRect(find.text('Forecast')).center.dx;
          expect((mid - row.center.dx).abs(), lessThan(1));
          handle.dispose();
        });

        testWidgets('period bar offers only the allowed units', (tester) async {
          await _pump(
            tester,
            theme,
            FfPeriodBar(
              period: Period.containing(PeriodUnit.month, DateTime.now()),
              onChanged: (_) {},
              units: const {PeriodUnit.week, PeriodUnit.month, PeriodUnit.year},
              chooserTitle: 'Show plan for',
            ),
          );
          await tester.tap(find.byKey(const ValueKey('period-chooser')));
          await tester.pumpAndSettle();
          expect(find.text('Show plan for'), findsOneWidget);
          for (final label in ['This week', 'This month', 'This year']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
          for (final label in ['Today', 'All time', 'Custom range…']) {
            expect(find.text(label), findsNothing, reason: label);
          }
        });

        testWidgets('period bar offers every unit by default', (tester) async {
          await _pump(
            tester,
            theme,
            FfPeriodBar(
              period: Period.containing(PeriodUnit.month, DateTime.now()),
              onChanged: (_) {},
            ),
          );
          await tester.tap(find.byKey(const ValueKey('period-chooser')));
          await tester.pumpAndSettle();
          expect(find.text('Show transactions for'), findsOneWidget);
          for (final label in ['Today', 'This week', 'Custom range…']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
          expect(find.text('All time'), findsNothing);
        });
      });
    }
  }
}
