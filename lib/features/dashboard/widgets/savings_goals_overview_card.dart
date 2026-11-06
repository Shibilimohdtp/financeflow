import 'package:flutter/material.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/ff_tone.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../theme/ff.dart';

class SavingsGoalsOverviewCard extends StatelessWidget {
  final double totalTarget;
  final double totalSaved;
  final double totalRemaining;
  final int completedCount;
  final int totalGoals;
  final bool isPrivacyBlur;
  final VoidCallback onViewGoals;

  const SavingsGoalsOverviewCard({
    super.key,
    required this.totalTarget,
    required this.totalSaved,
    required this.totalRemaining,
    required this.completedCount,
    required this.totalGoals,
    this.isPrivacyBlur = false,
    required this.onViewGoals,
  });

  @override
  Widget build(BuildContext context) {
    final finColors = context.ff.color;

    if (totalTarget <= 0) return const SizedBox.shrink();

    final progress =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Savings Goals',
                  style: context.ff.text.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onViewGoals,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Savings goals hidden'
                    : 'Savings Goals: $totalSaved saved towards $totalTarget, $completedCount of $totalGoals reached',
            child: Material(
              type: MaterialType.transparency,
              shape: FfCard.shapeOf(FfDensity.comfortable),
              child: InkWell(
                customBorder: FfCard.shapeOf(FfDensity.comfortable),
                onTap: onViewGoals,
                child: Ink(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: FfCard.decorationOf(
                    context,
                    density: FfDensity.comfortable,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(FfSpace.x2s),
                                decoration: BoxDecoration(
                                  color: finColors.moneyIncome.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    FfRadius.sm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.flag_rounded,
                                  color: finColors.moneyIncome,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: FfSpace.sm),
                              Row(
                                children: [
                                  FfAmountText(
                                    amount: totalSaved,
                                    size: FfAmountSize.sm,
                                    isBlurred: isPrivacyBlur,
                                    showSign: false,
                                    tone: FfTone.income,
                                  ),
                                  const SizedBox(width: FfSpace.x3s),
                                  Text(
                                    'Saved',
                                    style: context.ff.text.body.copyWith(
                                      color: finColors.moneyIncome,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '$completedCount of $totalGoals reached',
                            style: context.ff.text.labelSm.copyWith(
                              color: context.ff.color.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FfSpace.sm),
                      FfProgressBar(
                        value: progress,
                        color: finColors.moneyIncome,
                        size: FfProgressSize.md,
                      ),
                      const SizedBox(height: FfSpace.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% of target',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.secondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Goal: ',
                                style: context.ff.text.bodySm.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                              FfAmountText(
                                amount: totalTarget,
                                size: FfAmountSize.sm,
                                isBlurred: isPrivacyBlur,
                                showSign: false,
                                tone: FfTone.neutral,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
