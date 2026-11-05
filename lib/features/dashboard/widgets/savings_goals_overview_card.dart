import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/ff_tone.dart';
import '../../../shared/widgets/ff_progress.dart';

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
    final theme = context.theme;
    final finColors = context.finColors;

    if (totalTarget <= 0) return const SizedBox.shrink();

    final progress =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Savings Goals',
                  style: theme.textTheme.titleSmall?.copyWith(
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
          const SizedBox(height: StillwaterTokens.spaceXs),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Savings goals hidden'
                    : 'Savings Goals: $totalSaved saved towards $totalTarget, $completedCount of $totalGoals reached',
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
              child: InkWell(
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
                onTap: onViewGoals,
                child: Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusLg,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: StillwaterTokens.borderWidthHairline,
                    ),
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
                                padding: const EdgeInsets.all(
                                  StillwaterTokens.space2Xs,
                                ),
                                decoration: BoxDecoration(
                                  color: finColors.income.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  Icons.flag_rounded,
                                  color: finColors.income,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceSm),
                              Row(
                                children: [
                                  FfAmountText(
                                    amount: totalSaved,
                                    size: FfAmountSize.sm,
                                    isBlurred: isPrivacyBlur,
                                    showSign: false,
                                    tone: FfTone.income,
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.space3Xs,
                                  ),
                                  Text(
                                    'Saved',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: finColors.income,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '$completedCount of $totalGoals reached',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      FfProgressBar(
                        value: progress,
                        color: finColors.income,
                        size: FfProgressSize.md,
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% of target',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Goal: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
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
