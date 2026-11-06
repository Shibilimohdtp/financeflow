// DS-B3: Stillwater Bloom components, in every palette and mode, with large
// text and with reduced effects.
import 'package:financeflow/shared/widgets/ff_amount_text.dart';
import 'package:financeflow/shared/widgets/ff_card.dart';
import 'package:financeflow/shared/widgets/ff_chip.dart';
import 'package:financeflow/shared/widgets/ff_corner_badge.dart';
import 'package:financeflow/shared/widgets/ff_data_viz.dart';
import 'package:financeflow/shared/widgets/ff_icon_tile.dart';
import 'package:financeflow/shared/widgets/ff_navigation.dart';
import 'package:financeflow/shared/widgets/ff_round_buttons.dart';
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
  FfEffects effects = FfEffects.full,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 900),
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

/// Every new component on one page, for the large-text and smoke checks.
Widget _everything() => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const SizedBox(height: 120, child: FfAurora()),
    FfHeroCard(
      tone: FfHeroTone.moss,
      leading: const FfProgressRing(
        value: 0.62,
        icon: Icons.account_balance_wallet_outlined,
        semanticsLabel: '62% of buffer',
      ),
      title: 'Salary account',
      subtitle: 'Savings',
      onOpen: () {},
      child: const FfAmountText(
        amount: 124500,
        size: FfAmountSize.hero,
        tone: FfTone.neutral,
        showSign: false,
      ),
    ),
    const SizedBox(height: 12),
    const FfCard(
      child: FfStatTile(label: 'EMIs', value: Text('31'), unit: '/120'),
    ),
    Row(
      children: [
        FfCircleButton(
          icon: Icons.arrow_back,
          tooltip: 'Back',
          onPressed: () {},
        ),
        FfCircleButton(
          icon: Icons.notifications_none,
          tooltip: 'Alerts',
          corner: FfCorner.dot,
          onPressed: () {},
        ),
        FfInkButton.open(onPressed: () {}),
        const FfIconTile(icon: Icons.bolt, corner: FfCorner.warning),
      ],
    ),
    FfPillBar<String>(
      values: const ['All', 'Expenses', 'Income', 'Transfers'],
      selected: 'All',
      label: (v) => v,
      onSelected: (_) {},
    ),
    const FfGlass(padding: EdgeInsets.all(12), child: Text('Recent changes')),
    const FfDotMatrix(
      total: 120,
      done: 31,
      semanticsLabel: '31 of 120 EMIs paid',
    ),
    const FfRangeBand(
      bands: [
        FfBand(
          start: 0,
          end: 0.3,
          tone: FfTone.success,
          label: 'Good, under 30%',
        ),
        FfBand(start: 0.3, end: 0.5, tone: FfTone.warning, label: 'Watch'),
        FfBand(start: 0.5, end: 1, tone: FfTone.error, label: 'High'),
      ],
      value: 0.23,
      valueLabel: '23% used',
    ),
    FfLineChart(
      points: const [
        FfChartPoint('Jun', 20),
        FfChartPoint('Jul', 19.5),
        FfChartPoint('Aug', 18.2),
      ],
      valueLabel: (p) => '₹${p.value}L',
    ),
    const FfMonthGrid(
      months: [
        FfMonthCell(label: 'Jun', status: FfMonthStatus.paid),
        FfMonthCell(label: 'Jul', status: FfMonthStatus.paid),
        FfMonthCell(label: 'Aug', status: FfMonthStatus.paid),
        FfMonthCell(label: 'Sep', status: FfMonthStatus.missed),
        FfMonthCell(label: 'Oct', status: FfMonthStatus.paid),
        FfMonthCell(label: 'Nov', status: FfMonthStatus.due, note: '6th'),
      ],
    ),
    FfCarousel(
      height: 100,
      children: [
        for (final t in FfHeroTone.values)
          FfHeroCard(tone: t, child: Text(t.name)),
      ],
    ),
  ],
);

void main() {
  for (final palette in FfPalettes.all) {
    for (final brightness in Brightness.values) {
      final theme = FfTheme.build(palette, brightness);
      final c = palette.colorsFor(brightness);
      final where = '${palette.id}/${brightness.name}';

      group('Bloom components ($where)', () {
        testWidgets('everything renders at 1× and 2× text', (tester) async {
          for (final scale in [1.0, 2.0]) {
            await _pump(tester, theme, _everything(), textScale: scale);
            await tester.pump();
            expect(tester.takeException(), isNull, reason: 'text scale $scale');
          }
        });

        testWidgets('hero text takes the hero colours', (tester) async {
          await _pump(
            tester,
            theme,
            const FfHeroCard(
              tone: FfHeroTone.rose,
              title: 'Home loan',
              child: Text('Paid so far'),
            ),
          );
          final hero = palette.heroesFor(brightness)[FfHeroTone.rose];
          final title = tester.widget<Text>(find.text('Home loan'));
          expect(title.style!.color, hero.onHero);
          // Plain text inside uses the scoped default text style.
          final body = tester.element(find.text('Paid so far'));
          expect(DefaultTextStyle.of(body).style.color, hero.onHero);
          expect(
            Theme.of(body).extension<FfColors>()!.textPrimary,
            hero.onHero,
          );
        });

        testWidgets('glass blurs only when effects are full', (tester) async {
          const glass = FfGlass(child: Text('Glass'));
          await _pump(tester, theme, glass);
          expect(find.byType(BackdropFilter), findsOneWidget);
          await _pump(tester, theme, glass, effects: FfEffects.reduced);
          expect(find.byType(BackdropFilter), findsNothing);
          final box = tester.widget<DecoratedBox>(
            find.descendant(
              of: find.byType(FfGlass),
              matching: find.byType(DecoratedBox),
            ),
          );
          expect((box.decoration as ShapeDecoration).color, c.surfaceRaised);
        });

        testWidgets('round buttons are labelled 48 dp targets', (tester) async {
          var taps = 0;
          final handle = tester.ensureSemantics();
          await _pump(
            tester,
            theme,
            Row(
              children: [
                FfCircleButton(
                  icon: Icons.more_horiz,
                  tooltip: 'More',
                  onPressed: () => taps++,
                ),
                FfInkButton.open(onPressed: () => taps++, tooltip: 'Open loan'),
              ],
            ),
          );
          for (final label in ['More', 'Open loan']) {
            final f = find.bySemanticsLabel(label);
            expect(f, findsOneWidget);
            expect(tester.getSize(f), const Size.square(FfTouch.minTarget));
            await tester.tap(f);
          }
          expect(taps, 2);
          handle.dispose();
        });

        testWidgets('chips and pill bars select with ink', (tester) async {
          String? picked;
          await _pump(
            tester,
            theme,
            FfPillBar<String>(
              values: const ['All', 'Income'],
              selected: 'All',
              label: (v) => v,
              onSelected: (v) => picked = v,
            ),
          );
          final selected = tester.widget<AnimatedContainer>(
            find.ancestor(
              of: find.text('All'),
              matching: find.byType(AnimatedContainer),
            ),
          );
          expect(
            (selected.decoration! as ShapeDecoration).color,
            c.actionPrimary,
          );
          expect(
            tester.getSize(find.byType(FfChip).first).height,
            greaterThanOrEqualTo(FfTouch.minTarget),
          );
          await tester.tap(find.text('Income'));
          expect(picked, 'Income');
        });

        testWidgets('dock shows the selected label and becomes a bar at '
            'large text', (tester) async {
          var tab = 0;
          const items = [
            FfDockItem(icon: Icons.home_outlined, label: 'Home'),
            FfDockItem(
              icon: Icons.receipt_long_outlined,
              label: 'Money',
              badgeCount: 4,
            ),
            FfDockItem(icon: Icons.pie_chart_outline, label: 'Plan'),
            FfDockItem(icon: Icons.insights_outlined, label: 'Insights'),
            FfDockItem(icon: Icons.more_horiz, label: 'More', showDot: true),
          ];
          Widget dock() => FfDock(
            items: items,
            selectedIndex: tab,
            onSelected: (i) => tab = i,
          );
          final handle = tester.ensureSemantics();
          await _pump(tester, theme, dock());
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Plan'), findsNothing); // icon only
          expect(
            find.bySemanticsLabel('Money, 4 new, tab 2 of 5'),
            findsOneWidget,
          );
          await tester.tap(find.bySemanticsLabel(RegExp('^Plan')));
          expect(tab, 2);
          expect(find.byType(NavigationBar), findsNothing);

          await _pump(tester, theme, dock(), textScale: 2);
          expect(find.byType(NavigationBar), findsOneWidget);
          expect(find.text('Plan'), findsOneWidget);
          handle.dispose();
        });

        testWidgets('data viz announce their values', (tester) async {
          final handle = tester.ensureSemantics();
          await _pump(tester, theme, _everything());
          for (final label in [
            '62% of buffer',
            '31 of 120 EMIs paid',
            '23% used, Good, under 30%',
            'Aug: ₹18.2L',
            'Sep, missed',
            'Nov, due, 6th',
          ]) {
            expect(find.bySemanticsLabel(label), findsWidgets, reason: label);
          }
          // Carousel cards start with their position.
          expect(find.bySemanticsLabel(RegExp('^1 of 5')), findsOneWidget);
          handle.dispose();
        });

        testWidgets('line chart selection follows taps', (tester) async {
          var selected = -1;
          await _pump(
            tester,
            theme,
            FfLineChart(
              points: const [FfChartPoint('A', 1), FfChartPoint('B', 3)],
              valueLabel: (p) => '${p.value}',
              onSelected: (i) => selected = i,
            ),
          );
          final box = tester.getRect(find.byType(FfLineChart));
          await tester.tapAt(box.centerLeft + const Offset(2, 0));
          expect(selected, 0);
        });

        testWidgets('cards are squircles on a soft shadow', (tester) async {
          await _pump(tester, theme, const FfCard(child: Text('Card')));
          final container = tester.widget<Container>(
            find.ancestor(
              of: find.text('Card'),
              matching: find.byType(Container),
            ),
          );
          final d = container.decoration! as ShapeDecoration;
          expect(d.color, c.surfaceCard);
          expect(d.shape, isA<FfSquircleBorder>());
          expect(d.shadows, isNotEmpty);
        });
      });
    }
  }

  test('dot matrix scales large totals to the grid', () {
    const m = FfDotMatrix(total: 120, done: 31, semanticsLabel: '');
    expect(m.layout, (dots: 36, filled: 9));
    const small = FfDotMatrix(total: 6, done: 6, semanticsLabel: '');
    expect(small.layout, (dots: 6, filled: 6));
    const none = FfDotMatrix(total: 0, done: 0, semanticsLabel: '');
    expect(none.layout.filled, 0);
  });
}
