import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';

class SavingsGoalsOverviewCard extends StatelessWidget {
  final double totalTarget;
  final double totalSaved;
  final double totalRemaining;
  final int completedCount;
  final int totalGoals;
  final VoidCallback onViewGoals;

  const SavingsGoalsOverviewCard({
    super.key,
    required this.totalTarget,
    required this.totalSaved,
    required this.totalRemaining,
    required this.completedCount,
    required this.totalGoals,
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
              Text('Savings Goals', style: theme.textTheme.titleMedium),
              TextButton(onPressed: onViewGoals, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          InkWell(
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
            onTap: onViewGoals,
            child: FfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color: finColors.income,
                            size: 20,
                          ),
                          const SizedBox(width: StillwaterTokens.spaceXs),
                          Text(
                            '${CurrencyFormatter.format(totalSaved)} Saved',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: finColors.income,
                              fontWeight: FontWeight.bold,
                            ),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: finColors.income,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% of target',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        'Goal: ${CurrencyFormatter.format(totalTarget)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
