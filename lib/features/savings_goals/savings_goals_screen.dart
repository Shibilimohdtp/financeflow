import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/savings_goal.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'add_goal_contribution_sheet.dart';
import 'savings_goal_detail_screen.dart';
import 'savings_goals_controller.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  void _openAddGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddEditSavingsGoalSheet(),
    );
  }

  void _openGoalDetail(BuildContext context, SavingsGoal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SavingsGoalDetailScreen(goal: goal)),
    );
  }

  void _openAddContribution(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddGoalContributionSheet(goal: goal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final goalsSummariesAsync = ref.watch(savingsGoalSummariesProvider);
    final overallSummaryAsync = ref.watch(overallSavingsGoalSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(allSavingsGoalsStreamProvider);
          ref.invalidate(allGoalContributionsStreamProvider);
          ref.invalidate(savingsGoalSummariesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceLg,
            vertical: StillwaterTokens.spaceMd,
          ),
          children: [
            // 1. Overall Savings Progress Hero Card
            overallSummaryAsync.when(
              data: (overall) {
                if (overall.totalTarget <= 0) return const SizedBox.shrink();

                final overallProgress =
                    overall.totalTarget > 0
                        ? (overall.totalSaved / overall.totalTarget).clamp(
                          0.0,
                          1.0,
                        )
                        : 0.0;

                return FfCard(
                  variant: FfCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Savings Target',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Text(
                            '${overall.completedCount} of ${overall.totalGoals} Completed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.format(overall.totalSaved),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: finColors.income,
                            ),
                          ),
                          Text(
                            'Target: ${CurrencyFormatter.format(overall.totalTarget)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
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
                          value: overallProgress,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: finColors.income,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(overallProgress * 100).toStringAsFixed(0)}% saved overall',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.format(overall.totalRemaining)} remaining',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            // 2. Goals List
            goalsSummariesAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceXl,
                    ),
                    child: FfCard(
                      child: FfEmptyState(
                        icon: Icons.savings_outlined,
                        title: 'No savings goals yet',
                        description:
                            'Create goals for an emergency fund, travel, or big purchases to stay motivated offline.',
                        actionLabel: 'Create Goal',
                        onAction: () => _openAddGoal(context),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summaries.length,
                  separatorBuilder:
                      (ctx, i) =>
                          const SizedBox(height: StillwaterTokens.spaceMd),
                  itemBuilder: (ctx, i) {
                    final summary = summaries[i];
                    final goal = summary.goal;

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusLg,
                      ),
                      onTap: () => _openGoalDetail(context, goal),
                      child: FfCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      summary.isTargetReached
                                          ? finColors.incomeContainer
                                          : theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    summary.isTargetReached
                                        ? Icons.check_circle_rounded
                                        : Icons.flag_rounded,
                                    color:
                                        summary.isTargetReached
                                            ? finColors.income
                                            : theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: StillwaterTokens.spaceSm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.name,
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Target: ${DateFormat('dd MMM yyyy').format(goal.targetDate)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                  ),
                                  tooltip: 'Add Contribution',
                                  color: theme.colorScheme.primary,
                                  onPressed:
                                      () => _openAddContribution(context, goal),
                                ),
                              ],
                            ),

                            const SizedBox(height: StillwaterTokens.spaceMd),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${CurrencyFormatter.format(summary.currentAmount)} of ${CurrencyFormatter.format(goal.targetAmount)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(summary.progressPercentage * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        summary.isTargetReached
                                            ? finColors.income
                                            : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: StillwaterTokens.space2Xs),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusFull,
                              ),
                              child: LinearProgressIndicator(
                                value: summary.progressPercentage,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color:
                                    summary.isTargetReached
                                        ? finColors.income
                                        : theme.colorScheme.primary,
                                minHeight: 6,
                              ),
                            ),

                            const SizedBox(height: StillwaterTokens.spaceXs),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  summary.isTargetReached
                                      ? 'Goal Completed!'
                                      : '${CurrencyFormatter.format(summary.remainingAmount)} to reach target',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        summary.isTargetReached
                                            ? finColors.income
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  '${summary.contributionCount} contributions',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(StillwaterTokens.space3Xl),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (e, _) =>
                      Center(child: Text('Could not load savings goals: $e')),
            ),

            const SizedBox(height: StillwaterTokens.space4Xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddGoal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
    );
  }
}
