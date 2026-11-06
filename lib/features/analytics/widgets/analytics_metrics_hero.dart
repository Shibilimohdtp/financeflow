import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/analytics_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Dusk hero card showing net savings, inflow, outflow, and savings rate in Stillwater Bloom.
class AnalyticsMetricsHero extends StatelessWidget {
  final AnalyticsReport report;
  final bool isPrivacyBlur;
  final VoidCallback? onOpenHealth;

  const AnalyticsMetricsHero({
    super.key,
    required this.report,
    this.isPrivacyBlur = false,
    this.onOpenHealth,
  });

  @override
  Widget build(BuildContext context) {
    final savingsRatePct = (report.savingsRate * 100).toStringAsFixed(0);
    final isDeficit = report.netSavings < 0;

    return FfHeroCard(
      tone: FfHeroTone.dusk,
      leading: FfProgressRing(
        value: report.savingsRate.clamp(0.0, 1.0),
        icon: Icons.savings_outlined,
        semanticsLabel: '$savingsRatePct% savings rate',
      ),
      title: isDeficit ? 'Net Deficit' : 'Net Savings',
      subtitle:
          '$savingsRatePct% savings rate · ${report.transactionCount} transactions',
      onOpen: onOpenHealth,
      openTooltip: 'Financial health',
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FfAmountText(
                amount: report.netSavings,
                size: FfAmountSize.hero,
                style: FfAmountStyle.split,
                tone: FfTone.neutral,
                showSign: false,
                isBlurred: isPrivacyBlur,
              ),
              const SizedBox(height: FfSpace.md),
              FfHeroFigures([
                FfHeroFigure(
                  'Total Inflow',
                  CurrencyFormatter.format(report.totalIncome),
                ),
                FfHeroFigure(
                  'Total Outflow',
                  CurrencyFormatter.format(report.totalExpense),
                ),
                FfHeroFigure('Savings Rate', '$savingsRatePct%'),
              ]),
            ],
          );
        },
      ),
    );
  }
}
