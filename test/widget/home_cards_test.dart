// DS-B12: Home's redesigned cards in their states (normal, empty, negative,
// hidden amounts, 2× text, light and dark) and their tap callbacks.
import 'package:financeflow/features/dashboard/dashboard_controller.dart';
import 'package:financeflow/features/dashboard/widgets/cash_flow_card.dart';
import 'package:financeflow/features/dashboard/widgets/home_card_error.dart';
import 'package:financeflow/services/balance_calculator.dart';
import 'package:financeflow/shared/widgets/charts/ff_bar_chart.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCard(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    theme: FfTheme.build(FfPalettes.all.first, brightness),
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(360, 1200),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  ),
);

const _flow = MonthlyCashFlow(
  totalIncome: 82000,
  totalExpense: 48210,
  netSavings: 33790,
);
const _bars = [
  BarChartItem(label: 'W1', value: 12000, secondaryValue: 82000),
  BarChartItem(label: 'W2', value: 18000, secondaryValue: 0),
  BarChartItem(label: 'W3', value: 18210, secondaryValue: 0),
];
const _down = PeriodComparisonMetric(
  expenseChangePct: -20,
  incomeChangePct: 0,
  hasPreviousData: true,
);

CashFlowCard _cashFlow({
  MonthlyCashFlow flow = _flow,
  List<BarChartItem>? bars = _bars,
  bool hidden = false,
  VoidCallback? onOpen,
}) => CashFlowCard(
  cashFlow: flow,
  month: DateTime(2026, 11),
  periodLabel: 'November 2026',
  isPrivacyBlur: hidden,
  chartItems: bars,
  trendMetric: _down,
  onOpenAnalytics: onOpen ?? () {},
);

void main() {
  group('CashFlowCard', () {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('normal, ${brightness.name}, ${scale}x', (tester) async {
          await pumpCard(
            tester,
            _cashFlow(),
            brightness: brightness,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('Net this period'), findsOneWidget);
          expect(find.text('+ ₹82,000'), findsOneWidget);
          expect(find.text('− ₹48,210'), findsOneWidget);
          expect(
            find.text('Spending down 20.0% vs previous period'),
            findsOneWidget,
          );
          expect(find.byType(FfBarChart), findsOneWidget);
        });
      }
    }

    testWidgets('tapping the card opens Insights', (tester) async {
      var opened = 0;
      await pumpCard(tester, _cashFlow(onOpen: () => opened++));
      await tester.tap(find.text('Net this period'));
      expect(opened, 1);
      await tester.tap(find.byTooltip('Open Insights'));
      expect(opened, 2);
    });

    testWidgets('negative net says so in words', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(
          flow: const MonthlyCashFlow(
            totalIncome: 1000,
            totalExpense: 5000,
            netSavings: -4000,
          ),
        ),
      );
      expect(find.text('More went out than came in'), findsOneWidget);
    });

    testWidgets('one active point draws no chart', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(bars: const [BarChartItem(label: 'Today', value: 300)]),
      );
      expect(find.byType(FfBarChart), findsNothing);
    });

    testWidgets('empty period explains itself', (tester) async {
      await pumpCard(
        tester,
        _cashFlow(
          flow: const MonthlyCashFlow(
            totalIncome: 0,
            totalExpense: 0,
            netSavings: 0,
          ),
          bars: const [],
        ),
      );
      expect(find.text('No money in or out in this period yet.'), findsOne);
    });

    testWidgets('hidden amounts: no figures, trend or spoken values', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester, _cashFlow(hidden: true));
      expect(find.text('+ ₹82,000'), findsNothing);
      expect(find.textContaining('Spending down'), findsNothing);
      expect(
        find.bySemanticsLabel('Cash flow for November 2026, amounts hidden'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp('82,000')), findsNothing);
      handle.dispose();
    });

    testWidgets('skeleton and error render', (tester) async {
      var retried = 0;
      await pumpCard(
        tester,
        Column(
          children: [
            const CashFlowCardSkeleton(),
            HomeCardError(what: 'cash flow', onRetry: () => retried++),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Try again'));
      expect(retried, 1);
    });
  });
}
