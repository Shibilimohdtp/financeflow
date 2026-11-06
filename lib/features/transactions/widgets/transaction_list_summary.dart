import 'package:flutter/material.dart';

import '../../../services/ledger_totals.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_surfaces.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Spent / Income / Net summary card for the active transaction list.
/// Redesigned in Stillwater Bloom on a compact tactile squircle card.
class TransactionListSummary extends StatelessWidget {
  final LedgerTotals totals;
  final int count;
  final bool isPrivacyBlur;

  const TransactionListSummary({
    super.key,
    required this.totals,
    required this.count,
    required this.isPrivacyBlur,
  });

  @override
  Widget build(BuildContext context) {
    final totalFlow = totals.spending + totals.income;
    final incomeRatio = totalFlow > 0 ? (totals.income / totalFlow) : 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.pageMargin,
        vertical: FfSpace.xs,
      ),
      child: FfHeroCard(
        tone: FfHeroTone.moss,
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.md,
          vertical: FfSpace.md,
        ),
        child: Builder(
          builder: (context) {
            final ff = context.ff;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top meta row: Section label & count pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 14,
                          color: ff.color.textSecondary,
                        ),
                        const SizedBox(width: FfSpace.x3s),
                        Text(
                          'Period Activity',
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.xs,
                        vertical: FfSpace.x3s,
                      ),
                      decoration: ShapeDecoration(
                        shape: FfShape.of(FfRadius.full),
                        color: ff.color.tint(
                          ff.color.textPrimary,
                          FfTint.faint,
                        ),
                      ),
                      child: Text(
                        count == 1 ? '1 transaction' : '$count transactions',
                        style: ff.text.labelSm.copyWith(
                          color: ff.color.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.md),

                // Three core figures
                Row(
                  children: [
                    _Figure(
                      label: 'Spent',
                      child: FfAmountText(
                        amount: totals.spending,
                        size: FfAmountSize.md,
                        isBlurred: isPrivacyBlur,
                        tone: FfTone.neutral,
                        showSign: false,
                        style: FfAmountStyle.split,
                      ),
                    ),
                    const SizedBox(width: FfSpace.xs),
                    _Figure(
                      label: 'Income',
                      child: FfAmountText(
                        amount: totals.income,
                        size: FfAmountSize.md,
                        isBlurred: isPrivacyBlur,
                        tone: FfTone.neutral,
                        showSign: false,
                        style: FfAmountStyle.split,
                      ),
                    ),
                    const SizedBox(width: FfSpace.xs),
                    _Figure(
                      label: 'Net',
                      child: FfAmountText(
                        amount: totals.net,
                        size: FfAmountSize.md,
                        isBlurred: isPrivacyBlur,
                        style: FfAmountStyle.split,
                      ),
                    ),
                  ],
                ),

                // Visual Flow Proportion Bar
                if (totalFlow > 0 && !isPrivacyBlur) ...[
                  const SizedBox(height: FfSpace.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(FfRadius.full),
                    child: SizedBox(
                      height: 4,
                      child: Row(
                        children: [
                          Flexible(
                            flex: (incomeRatio * 1000).round().clamp(1, 999),
                            child: Container(color: ff.color.textPrimary),
                          ),
                          const SizedBox(width: 1),
                          Flexible(
                            flex: ((1 - incomeRatio) * 1000).round().clamp(
                              1,
                              999,
                            ),
                            child: Container(
                              color: ff.color.tint(
                                ff.color.textPrimary,
                                FfTint.medium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final Widget child;

  const _Figure({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.ff.text.label),
          const SizedBox(height: FfSpace.x3s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ],
      ),
    );
  }
}
