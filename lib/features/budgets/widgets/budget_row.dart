import 'package:flutter/material.dart';

import '../../../core/period/period_format.dart';
import '../../../services/budgets/budget_engine.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_corner_badge.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../budget_format.dart';

/// One budget in the Plan tab's group cards (pattern B row density):
///
/// ```
/// (tile)  Groceries                       ₹3,590
///         ₹8,410 of ₹12,000 · 70%      [⚠ At risk]   ← or "left"
///         ━━━━━━━━━━━━━━━━━━━|━━━━━━━━──────────
/// ```
///
/// The bar shows spending against the limit with a pace marker where it
/// should be today. Status is a badge with an icon and a word, plus a
/// warning corner on the tile when over; never colour alone. The whole row
/// is one button that opens the budget, read as "Groceries, at risk, ₹8,410
/// of ₹12,000 spent, 70% used, ₹3,590 left, ahead of pace by ₹2,140".
class BudgetRow extends StatelessWidget {
  const BudgetRow({
    super.key,
    required this.result,
    required this.isPrivacyBlur,
    required this.onTap,
    this.showPeriod = false,
  });

  final BudgetPeriodResult result;
  final bool isPrivacyBlur;
  final VoidCallback onTap;

  /// Prefix the amounts line with the budget's own period ("This week"), for
  /// budgets on another cadence than the one being viewed.
  final bool showPeriod;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final r = result;
    final b = r.budget;
    final isCurrent = r.timing == PeriodTiming.current;
    final over = r.status == BudgetStatus.over;

    final tone = switch (r.status) {
      BudgetStatus.over => FfTone.expense,
      BudgetStatus.atRisk => FfTone.warning,
      BudgetStatus.onTrack => null,
    };

    final tile = FfCategoryTile(
      iconIdentifier: b.categoryIcon ?? 'category',
      colorTokenIdentifier: b.categoryColor ?? 'shore',
    );

    final spoken = [
      b.name,
      if (r.status != BudgetStatus.onTrack || !isCurrent)
        BudgetFormat.status(r.status).toLowerCase(),
      if (showPeriod) periodLabel(r.period),
      if (!isPrivacyBlur)
        '${BudgetFormat.money(r.spentMinor)} of '
            '${BudgetFormat.money(r.limitMinor)} spent',
      BudgetFormat.progressSemantics(r, hidden: isPrivacyBlur),
    ].join(', ');

    return Semantics(
      container: true,
      button: true,
      label: spoken,
      hint: 'Opens the budget',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: FfTouch.minTarget),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                FfSpace.md,
                FfSpace.sm,
                FfSpace.md,
                FfSpace.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  over
                      ? FfCornerBadge(corner: FfCorner.warning, child: tile)
                      : tile,
                  const SizedBox(width: FfSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: FfSpace.xs,
                                    runSpacing: FfSpace.x3s,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        b.name,
                                        style: ff.text.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (tone != null)
                                        FfBadge(
                                          label: BudgetFormat.status(r.status),
                                          tone: tone,
                                          icon: BudgetFormat.statusIcon(
                                            r.status,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: FfSpace.x3s),
                                  _AmountsLine(
                                    result: r,
                                    isPrivacyBlur: isPrivacyBlur,
                                    showPeriod: showPeriod,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: FfSpace.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FfAmountText(
                                  amount: BudgetFormat.major(
                                    over ? r.overMinor : r.leftMinor,
                                  ),
                                  size: FfAmountSize.sm,
                                  tone: over ? FfTone.expense : FfTone.neutral,
                                  showSign: false,
                                  isBlurred: isPrivacyBlur,
                                ),
                                Text(
                                  over ? 'over' : 'left',
                                  style: ff.text.label,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: FfSpace.sm),
                        FfProgressBar(
                          value: r.fractionUsed,
                          pace: isCurrent ? r.fractionElapsed : null,
                          tone: tone,
                          size: FfProgressSize.sm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "₹8,410 of ₹12,000 · 70%" (with the budget's period when asked). With
/// amounts hidden it shows only the share used.
class _AmountsLine extends StatelessWidget {
  const _AmountsLine({
    required this.result,
    required this.isPrivacyBlur,
    required this.showPeriod,
  });

  final BudgetPeriodResult result;
  final bool isPrivacyBlur;
  final bool showPeriod;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final parts = [
      if (showPeriod) periodLabel(r.period),
      if (!isPrivacyBlur)
        '${BudgetFormat.money(r.spentMinor)} of ${BudgetFormat.money(r.limitMinor)}',
      '${BudgetFormat.percent(r.fractionUsed)}%${isPrivacyBlur ? ' used' : ''}',
    ];
    return Text(
      parts.join(' · '),
      style: context.ff.text.label.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
