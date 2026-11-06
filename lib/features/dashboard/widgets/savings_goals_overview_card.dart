import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/savings_goal.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_skeleton_loader.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Home's savings goals as a quiet progress story: a ring with the total
/// saved, how many goals are reached, and the goal due next with its share
/// and, when the data supports one, an estimate.
class SavingsGoalsOverviewCard extends StatelessWidget {
  final double totalTarget;
  final double totalSaved;
  final double totalRemaining;
  final int completedCount;
  final int totalGoals;
  final bool isPrivacyBlur;
  final VoidCallback onViewGoals;

  /// Per-goal summaries (already loaded by `savingsGoalSummariesProvider`);
  /// when given, the goal due next is shown.
  final List<SavingsGoalSummary>? goals;

  const SavingsGoalsOverviewCard({
    super.key,
    required this.totalTarget,
    required this.totalSaved,
    required this.totalRemaining,
    required this.completedCount,
    required this.totalGoals,
    this.isPrivacyBlur = false,
    required this.onViewGoals,
    this.goals,
  });

  /// The open goal with the nearest target date.
  static SavingsGoalSummary? nextGoal(List<SavingsGoalSummary>? goals) {
    final open =
        (goals ?? const <SavingsGoalSummary>[])
            .where((g) => !g.isTargetReached && !g.goal.isCompleted)
            .toList()
          ..sort((a, b) => a.goal.targetDate.compareTo(b.goal.targetDate));
    return open.isEmpty ? null : open.first;
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final progress =
        totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).round();
    final next = nextGoal(goals);
    final reached = '$completedCount of $totalGoals reached';

    final spoken =
        isPrivacyBlur
            ? 'Savings goals, amounts hidden. $percent% saved, $reached'
            : 'Savings goals: ${CurrencyFormatter.format(totalSaved)} saved '
                'of ${CurrencyFormatter.format(totalTarget)}, $percent%. '
                '$reached';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Savings goals',
            count: totalGoals,
            padding: FfSectionHeader.sectionPadding,
            trailing: FfSectionLink(
              label: 'See all',
              semanticLabel: 'See all savings goals',
              onPressed: onViewGoals,
            ),
          ),
          FfCard(
            key: const ValueKey('home-goals'),
            density: FfDensity.comfortable,
            padding: EdgeInsets.zero,
            onTap: onViewGoals,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  container: true,
                  label: spoken,
                  excludeSemantics: true,
                  child: Padding(
                    padding: EdgeInsets.all(FfDensity.comfortable.cardPadding),
                    child: Row(
                      children: [
                        FfProgressRing(
                          value: progress,
                          icon: Icons.savings_outlined,
                          size: FfRingTokens.size * 1.5,
                          color: FfTone.savings.foreground(c),
                          semanticsLabel: '$percent% of target saved',
                        ),
                        const SizedBox(width: FfSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved',
                                style: ff.text.label.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              FfAmountText(
                                amount: totalSaved,
                                size: FfAmountSize.lg,
                                style: FfAmountStyle.split,
                                tone: FfTone.neutral,
                                showSign: false,
                                isBlurred: isPrivacyBlur,
                              ),
                              const SizedBox(height: FfSpace.x3s),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '$percent% of ',
                                    style: ff.text.bodySm.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  FfAmountText(
                                    amount: totalTarget,
                                    size: FfAmountSize.sm,
                                    style: FfAmountStyle.inline,
                                    tone: FfTone.neutral,
                                    showSign: false,
                                    isBlurred: isPrivacyBlur,
                                  ),
                                  Text(
                                    ' · $reached',
                                    style: ff.text.bodySm.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (next != null) ...[
                  const FfDivider(),
                  _NextGoal(summary: next),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextGoal extends StatelessWidget {
  final SavingsGoalSummary summary;

  const _NextGoal({required this.summary});

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final pct = (summary.progressPercentage.clamp(0.0, 1.0) * 100).round();
    final eta = summary.estimatedCompletionDate;
    final when =
        eta != null
            ? 'On track for ${DateFormatter.formatMonthYear(eta)}'
            : 'Target ${DateFormatter.formatMonthYear(summary.goal.targetDate)}';
    return Semantics(
      container: true,
      label: 'Next goal ${summary.goal.name}, $pct% saved. $when',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.sm,
        ),
        child: Row(
          children: [
            const FfIconTile(icon: Icons.flag_outlined, tone: FfTone.savings),
            const SizedBox(width: FfSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.goal.name,
                    style: ff.text.titleSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    when,
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: FfSpace.xs),
            Text(
              '$pct%',
              style: ff.text.title.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading shape of [SavingsGoalsOverviewCard]'s card.
class SavingsGoalsCardSkeleton extends StatelessWidget {
  const SavingsGoalsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const FfCard(
      density: FfDensity.comfortable,
      child: FfSkeletonLoader(
        child: Row(
          children: [
            FfSkeletonBlock(
              width: FfRingTokens.size * 1.5,
              height: FfRingTokens.size * 1.5,
              borderRadius: FfRingTokens.size,
            ),
            SizedBox(width: FfSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FfSkeletonBlock(width: FfSpace.x4l, height: FfSpace.sm),
                  SizedBox(height: FfSpace.xs),
                  FfSkeletonBlock(width: FfSpace.x4l * 2, height: FfSpace.x3l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
