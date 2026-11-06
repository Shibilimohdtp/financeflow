import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../services/money_lending_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_balance_band.dart';
import '../../../shared/widgets/ff_stat_tile.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Net Position Hero card for Lending & Borrowing overview (Pattern C).
///
/// Reports the single figure that matters: net position (owed to me minus I owe),
/// with a proportional two-sided balance band and hero figures for both sides.
class LendingNetPositionHero extends StatelessWidget {
  const LendingNetPositionHero({
    super.key,
    required this.summary,
    this.onAddLent,
    this.onAddBorrowed,
  });

  final MoneyLendingSummary summary;
  final VoidCallback? onAddLent;
  final VoidCallback? onAddBorrowed;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final net = summary.totalOwedToMe - summary.totalIOwe;
    final absNet = net.abs();

    final heroTone =
        net > 0
            ? FfHeroTone.moss
            : net < 0
            ? FfHeroTone.rose
            : FfHeroTone.sand;

    final String headlineText;
    if (net > 0) {
      headlineText = 'People owe you net';
    } else if (net < 0) {
      headlineText = 'You owe net';
    } else {
      headlineText = 'All square';
    }

    final overdueCount = summary.overdueCount;

    return FfHeroCard(
      tone: heroTone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Net position label + Overdue status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headlineText,
                style: ff.text.label.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              if (overdueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.sm,
                    vertical: FfSpace.x3s,
                  ),
                  decoration: BoxDecoration(
                    color: ff.color.statusErrorContainer,
                    borderRadius: BorderRadius.circular(FfRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: ff.color.statusError,
                      ),
                      const SizedBox(width: FfSpace.x3s),
                      Text(
                        '$overdueCount overdue',
                        style: ff.text.labelSm.copyWith(
                          color: ff.color.statusError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: FfSpace.xs),

          // Row 2: Large split numeral net amount
          FfAmountText(
            amount: absNet,
            size: FfAmountSize.hero,
            style: FfAmountStyle.split,
            tone:
                net > 0
                    ? FfTone.income
                    : net < 0
                    ? FfTone.expense
                    : FfTone.neutral,
            showSign: false,
          ),

          const SizedBox(height: FfSpace.sm),

          // Row 3: Two-sided proportional balance band
          FfBalanceBand(
            leftAmount: summary.totalOwedToMe,
            rightAmount: summary.totalIOwe,
            leftLabel: 'Owed to you',
            rightLabel: 'You owe',
          ),

          const SizedBox(height: FfSpace.md),

          // Row 4: Two Hero figures comparing Owed to me vs I owe
          FfHeroFigures([
            FfHeroFigure(
              'OWED TO ME',
              CurrencyFormatter.format(summary.totalOwedToMe),
            ),
            FfHeroFigure('I OWE', CurrencyFormatter.format(summary.totalIOwe)),
          ]),
        ],
      ),
    );
  }
}
