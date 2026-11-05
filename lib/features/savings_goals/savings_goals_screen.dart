import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/savings_goal.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'savings_goal_detail_screen.dart';
import 'savings_goals_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_progress.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  void _openAddGoal(BuildContext context) {
    showFfSheet(context, builder: (ctx) => const AddEditSavingsGoalSheet());
  }

  void _openGoalDetail(BuildContext context, SavingsGoal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SavingsGoalDetailScreen(goal: goal)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final goalsSummariesAsync = ref.watch(savingsGoalSummariesProvider);
    final overallSummaryAsync = ref.watch(overallSavingsGoalSummaryProvider);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Savings Goals',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'savings_goals_fab',
        tooltip: 'Add savings goal',
        onPressed: () => _openAddGoal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(allSavingsGoalsStreamProvider);
          ref.invalidate(allGoalContributionsStreamProvider);
          ref.invalidate(savingsGoalSummariesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceMd,
            StillwaterTokens.spaceLg,
            104,
          ),
          children: [
            // ── 1. Overall Savings Progress Hero ─────────────────────────
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

                return Column(
                  children: [
                    FfCard(
                      variant: FfCardVariant.elevated,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL SAVINGS PROGRESS',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${overall.completedCount} of ${overall.totalGoals} Completed',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
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
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: CurrencyFormatter.formatAmount(
                                        overall.totalSaved,
                                      ),
                                      style: StillwaterTypography.numLg(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' of ${CurrencyFormatter.formatAmount(overall.totalTarget)}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: StillwaterTokens.spaceMd),
                          FfProgressBar(
                            value: overallProgress,
                            color: theme.colorScheme.primary,
                            size: FfProgressSize.lg,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(overallProgress * 100).toStringAsFixed(0)}% reached',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.formatAmount(overall.totalRemaining)} remaining',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: context.finColors.savings,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceLg),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 2. Goals List ─────────────────────────────────────────────
            const FfSectionHeader(title: 'Your Savings Targets'),

            goalsSummariesAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: StillwaterTokens.space2Xl,
                    ),
                    child: FfEmptyState(
                      icon: Icons.flag_outlined,
                      title: 'No savings goals yet',
                      description:
                          'Set up an emergency fund, travel budget, vehicle down-payment, or custom target.',
                      actionLabel: 'Add First Goal',
                      onAction: () => _openAddGoal(context),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summaries.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(height: StillwaterTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    final goal = summary.goal;
                    final progress = summary.progressPercentage.clamp(0.0, 1.0);
                    final isComplete = summary.isTargetReached;

                    return FfCard(
                      onTap: () => _openGoalDetail(context, goal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      isComplete
                                          ? context.finColors.incomeContainer
                                          : theme.colorScheme.primaryContainer
                                              .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  isComplete
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.flag_rounded,
                                  color:
                                      isComplete
                                          ? context.finColors.income
                                          : theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: StillwaterTokens.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Target: ${DateFormatter.formatShortDate(goal.targetDate)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatAmount(
                                      summary.currentAmount,
                                    ),
                                    style: StillwaterTypography.numMd(
                                      color:
                                          isComplete
                                              ? context.finColors.income
                                              : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'of ${CurrencyFormatter.formatAmount(goal.targetAmount)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: StillwaterTokens.spaceMd),
                          FfProgressBar(
                            value: progress,
                            color:
                                isComplete
                                    ? context.finColors.income
                                    : theme.colorScheme.primary,
                            size: FfProgressSize.md,
                          ),
                          const SizedBox(height: StillwaterTokens.spaceSm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isComplete
                                    ? 'Goal Reached 🎉'
                                    : '${CurrencyFormatter.formatAmount(summary.remainingAmount)} left',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isComplete
                                          ? context.finColors.income
                                          : theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                      child: FfLoading(),
                    ),
                  ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
