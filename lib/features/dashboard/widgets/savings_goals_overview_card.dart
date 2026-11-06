import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

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
    final ff = context.ff;
    final c = ff.color;

    if (totalTarget <= 0) return const SizedBox.shrink();

    final progress =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Savings Goals',
            padding: const EdgeInsets.only(bottom: FfSpace.xs),
            trailing: TextButton(
              onPressed: onViewGoals,
              child: const Text('View all'),
            ),
          ),
          Semantics(
            container: true,
            label:
                isPrivacyBlur
                    ? 'Savings goals hidden'
                    : 'Savings Goals: $totalSaved saved towards $totalTarget, $completedCount of $totalGoals reached',
            child: FfCard(
              density: FfDensity.comfortable,
              onTap: onViewGoals,
              padding: const EdgeInsets.all(FfSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FfProgressRing(
                        value: progress,
                        icon: Icons.savings_outlined,
                        size: 40,
                        semanticsLabel:
                            '${(progress * 100).toStringAsFixed(0)}% of target saved',
                        color: c.moneyIncome,
                      ),
                      const SizedBox(width: FfSpace.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Saved',
                              style: ff.text.labelSm.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            FfAmountText(
                              amount: totalSaved,
                              size: FfAmountSize.lg,
                              style: FfAmountStyle.split,
                              tone: FfTone.savings,
                              showSign: false,
                              isBlurred: isPrivacyBlur,
                            ),
                          ],
                        ),
                      ),
                      FfBadge(
                        label: '$completedCount of $totalGoals reached',
                        tone: FfTone.savings,
                      ),
                    ],
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfProgressBar(
                    value: progress,
                    tone: FfTone.savings,
                    size: FfProgressSize.md,
                  ),
                  const SizedBox(height: FfSpace.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% of target',
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
                      ),
                      Row(
                        children: [
                          Text(
                            'Goal: ',
                            style: ff.text.bodySm.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          FfAmountText(
                            amount: totalTarget,
                            size: FfAmountSize.sm,
                            style: FfAmountStyle.inline,
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
        ],
      ),
    );
  }
}
