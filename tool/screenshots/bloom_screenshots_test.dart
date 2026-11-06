// Screenshot capture of the Stillwater Bloom components (DS-B3), not part of
// the test suite. Renders every new component on the aurora canvas with the
// real bundled fonts, in light and dark. The second sheet shows the DS-B7a
// additions for the Plan tab (hero pace bar, hero figures, the line chart's
// pace reference, within/over-plan months, the over-plan bar).
//
//   flutter test tool/screenshots/bloom_screenshots_test.dart --update-goldens
import 'package:financeflow/shared/widgets/ff_amount_text.dart';
import 'package:financeflow/shared/widgets/ff_card.dart';
import 'package:financeflow/shared/widgets/ff_corner_badge.dart';
import 'package:financeflow/shared/widgets/ff_data_viz.dart';
import 'package:financeflow/shared/widgets/ff_icon_tile.dart';
import 'package:financeflow/shared/widgets/ff_navigation.dart';
import 'package:financeflow/shared/widgets/ff_progress.dart';
import 'package:financeflow/shared/widgets/ff_round_buttons.dart';
import 'package:financeflow/shared/widgets/ff_segmented_pill.dart';
import 'package:financeflow/shared/widgets/ff_stat_tile.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';

const _size = Size(390, 1500);

const _months = [
  FfMonthCell(label: 'Jun', status: FfMonthStatus.paid),
  FfMonthCell(label: 'Jul', status: FfMonthStatus.paid),
  FfMonthCell(label: 'Aug', status: FfMonthStatus.paid),
  FfMonthCell(label: 'Sep', status: FfMonthStatus.missed),
  FfMonthCell(label: 'Oct', status: FfMonthStatus.paid),
  FfMonthCell(label: 'Nov', status: FfMonthStatus.upcoming),
];

Widget _sheet(BuildContext context) {
  final ff = context.ff;
  return Stack(
    children: [
      const Positioned.fill(child: FfAurora()),
      ListView(
        padding: const EdgeInsets.only(top: 24, bottom: 120),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: Row(
              children: [
                FfCircleButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: () {},
                ),
                const Spacer(),
                FfCircleButton(
                  icon: Icons.visibility_outlined,
                  tooltip: 'Hide amounts',
                  soft: true,
                  onPressed: () {},
                ),
                FfCircleButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Alerts',
                  soft: true,
                  corner: FfCorner.dot,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total balance', style: ff.text.label),
                const SizedBox(height: 6),
                const FfAmountText(
                  amount: 482310.45,
                  size: FfAmountSize.hero,
                  tone: FfTone.neutral,
                  showSign: false,
                ),
              ],
            ),
          ),
          FfCarousel(
            height: 212,
            children: [
              FfHeroCard(
                tone: FfHeroTone.moss,
                height: 212,
                leading: const FfProgressRing(
                  value: 0.62,
                  icon: Icons.account_balance_wallet_outlined,
                  semanticsLabel: '62%',
                ),
                title: 'Salary account',
                subtitle: 'Savings',
                onOpen: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Builder(
                      builder:
                          (context) =>
                              Text('Available', style: context.ff.text.label),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: FfAmountText(
                            amount: 124500,
                            size: FfAmountSize.lg,
                            tone: FfTone.neutral,
                            showSign: false,
                          ),
                        ),
                        const FfDotMatrix(
                          total: 21,
                          done: 14,
                          semanticsLabel: '14 of 21 days',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FfHeroCard(
                tone: FfHeroTone.rose,
                height: 212,
                leading: const FfProgressRing(
                  value: 0.26,
                  icon: Icons.house_outlined,
                  semanticsLabel: '26%',
                ),
                title: 'Home loan',
                onOpen: () {},
                child: const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outstanding principal', style: ff.text.titleLg),
                      const SizedBox(height: 8),
                      FfLineChart(
                        points: const [
                          FfChartPoint('Apr', 21.4),
                          FfChartPoint('May', 20.9),
                          FfChartPoint('Jun', 20.1),
                          FfChartPoint('Jul', 19.6),
                          FfChartPoint('Aug', 18.2),
                          FfChartPoint('Sep', 18.4),
                          FfChartPoint('Oct', 17.7),
                        ],
                        initialIndex: 4,
                        valueLabel: (p) => '₹${p.value}L',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FfHeroCard(
                  tone: FfHeroTone.rose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FfMonthGrid(months: _months),
                      SizedBox(height: 8),
                      Text('September missed · paid late on 9 Oct'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FfCard(
                  density: FfDensity.compact,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const FfIconTile(
                            icon: Icons.bolt_rounded,
                            tone: FfTone.warning,
                            corner: FfCorner.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Electricity bill',
                              style: ff.text.title,
                            ),
                          ),
                          FfInkButton.open(onPressed: () {}, small: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const FfRangeBand(
                        bands: [
                          FfBand(
                            start: 0,
                            end: .3,
                            tone: FfTone.success,
                            label: 'Good · under 30%',
                          ),
                          FfBand(
                            start: .3,
                            end: .5,
                            tone: FfTone.warning,
                            label: 'Watch',
                          ),
                          FfBand(
                            start: .5,
                            end: 1,
                            tone: FfTone.error,
                            label: 'High',
                          ),
                        ],
                        value: .23,
                        valueLabel: '23% used',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const FfCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: FfStatTile(
                          label: 'EMIs paid',
                          value: Text(
                            '31',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          unit: '/120',
                        ),
                      ),
                      FfDotMatrix(
                        total: 120,
                        done: 31,
                        semanticsLabel: '31 of 120',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FfSegmentedPill<int>(
                  options: const [
                    FfSegmentOption(value: 0, label: 'Week'),
                    FfSegmentOption(value: 1, label: 'Month'),
                    FfSegmentOption(value: 2, label: 'Year'),
                  ],
                  selectedValue: 1,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FfPillBar<String>(
            values: const ['All', 'Expenses', 'Income', 'Transfers'],
            selected: 'All',
            label: (v) => v,
            onSelected: (_) {},
          ),
          const SizedBox(height: 8),
          const Center(
            child: FfGlass(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text('Glass · On device'),
            ),
          ),
        ],
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: FfDock(
          selectedIndex: 0,
          onSelected: (_) {},
          items: const [
            FfDockItem(icon: Icons.home_outlined, label: 'Home'),
            FfDockItem(
              icon: Icons.receipt_long_outlined,
              label: 'Money',
              badgeCount: 4,
            ),
            FfDockItem(icon: Icons.pie_chart_outline_rounded, label: 'Plan'),
            FfDockItem(icon: Icons.insights_outlined, label: 'Insights'),
            FfDockItem(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              showDot: true,
            ),
          ],
        ),
      ),
    ],
  );
}

const _budgetMonths = [
  FfMonthCell(label: 'Jun', status: FfMonthStatus.under, note: '₹5.2k'),
  FfMonthCell(label: 'Jul', status: FfMonthStatus.over, note: '₹6.8k'),
  FfMonthCell(label: 'Aug', status: FfMonthStatus.under, note: '₹5.9k'),
  FfMonthCell(label: 'Sep', status: FfMonthStatus.over, note: '₹7.1k'),
  FfMonthCell(label: 'Oct', status: FfMonthStatus.over, note: '₹6.9k'),
  FfMonthCell(label: 'Nov', status: FfMonthStatus.none),
];

/// DS-B7a: the shared parts the Plan tab and budget detail are built from.
Widget _planSheet(BuildContext context) {
  final ff = context.ff;
  const spent = <double>[1450, 3830, 3830, 3830, 5750, 6800];
  return Stack(
    children: [
      const Positioned.fill(child: FfAurora()),
      ListView(
        padding: const EdgeInsets.fromLTRB(
          FfSpace.pageMargin,
          24,
          FfSpace.pageMargin,
          40,
        ),
        children: [
          FfHeroCard(
            tone: FfHeroTone.rose,
            leading: const FfProgressRing(
              value: 0.52,
              icon: Icons.pie_chart_outline_rounded,
              semanticsLabel: '52% of the plan spent',
            ),
            title: 'November',
            subtitle: 'Needs attention',
            child: Builder(
              builder:
                  (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FfAmountText(
                        amount: 15730,
                        size: FfAmountSize.hero,
                        tone: FfTone.neutral,
                        showSign: false,
                      ),
                      const SizedBox(height: FfSpace.xs),
                      const FfProgressBar(value: 0.52, pace: 0.2, onHero: true),
                      const SizedBox(height: FfSpace.xs),
                      Text(
                        'Spent ₹17,270 of ₹33,000 · ₹10,670 ahead of pace',
                        style: context.ff.text.label,
                      ),
                      const SizedBox(height: FfSpace.lg),
                      const FfHeroFigures([
                        FfHeroFigure('Per day', '₹629'),
                        FfHeroFigure('Forecast', '₹31,400'),
                        FfHeroFigure('Days left', '25'),
                      ]),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 12),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Dining', style: ff.text.title),
                const SizedBox(height: FfSpace.xs),
                const FfProgressBar(
                  value: 1.13,
                  pace: 0.2,
                  tone: FfTone.expense,
                ),
                const SizedBox(height: FfSpace.lg),
                const FfProgressBar(value: 0.7, pace: 0.2),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month', style: ff.text.titleLg),
                const SizedBox(height: 12),
                FfLineChart(
                  points: [
                    for (final (i, v) in spent.indexed)
                      FfChartPoint('${i + 1} Nov', v),
                  ],
                  reference: [for (var d = 0; d < 30; d++) 200.0 * (d + 1)],
                  domainLength: 30,
                  valueLabel: (p) => '₹${p.value.round()}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last 6 months', style: ff.text.titleLg),
                const SizedBox(height: 12),
                const FfMonthGrid(months: _budgetMonths),
                const SizedBox(height: 8),
                Text(
                  'Within plan in 2 of the last 5 months',
                  style: ff.text.label,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUpAll(loadAppFonts);

  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    testWidgets('bloom components, $mode', (tester) async {
      tester.view.physicalSize = _size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(FfGrainTile.load);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(body: Builder(builder: _sheet)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bloom_components_$mode.png'),
      );
    });

    testWidgets('plan components, $mode', (tester) async {
      tester.view.physicalSize = const Size(390, 1150);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(FfGrainTile.load);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(body: Builder(builder: _planSheet)),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bloom_plan_components_$mode.png'),
      );
    });
  }
}
