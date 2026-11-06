import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/savings_goal.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'savings_goal_detail_screen.dart';
import 'savings_goals_controller.dart';

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

  static IconData getGoalIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('emergency') ||
        lower.contains('fund') ||
        lower.contains('safety')) {
      return Icons.shield_outlined;
    }
    if (lower.contains('trip') ||
        lower.contains('vacation') ||
        lower.contains('travel') ||
        lower.contains('holiday')) {
      return Icons.flight_takeoff_rounded;
    }
    if (lower.contains('macbook') ||
        lower.contains('laptop') ||
        lower.contains('phone') ||
        lower.contains('gadget') ||
        lower.contains('pc')) {
      return Icons.laptop_mac_rounded;
    }
    if (lower.contains('car') ||
        lower.contains('vehicle') ||
        lower.contains('bike') ||
        lower.contains('auto')) {
      return Icons.directions_car_filled_outlined;
    }
    if (lower.contains('home') ||
        lower.contains('house') ||
        lower.contains('flat') ||
        lower.contains('rent')) {
      return Icons.home_outlined;
    }
    if (lower.contains('education') ||
        lower.contains('school') ||
        lower.contains('college') ||
        lower.contains('course')) {
      return Icons.school_outlined;
    }
    return Icons.flag_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsSummariesAsync = ref.watch(savingsGoalSummariesProvider);
    final overallSummaryAsync = ref.watch(overallSavingsGoalSummaryProvider);

    return FfPageScaffold(
      title: 'Savings Goals',
      subtitle: 'Targeted on-device savings',
      actions: [
        FfCircleButton(
          icon: Icons.add_rounded,
          tooltip: 'Add savings goal',
          onPressed: () => _openAddGoal(context),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'savings_goals_fab',
        tooltip: 'Add savings goal',
        onPressed: () => _openAddGoal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
      body: RefreshIndicator(
        color: context.ff.color.actionPrimary,
        onRefresh: () async {
          ref.invalidate(allSavingsGoalsStreamProvider);
          ref.invalidate(allGoalContributionsStreamProvider);
          ref.invalidate(savingsGoalSummariesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            FfSpace.pageMargin,
            FfSpace.md,
            FfSpace.pageMargin,
            104,
          ),
          children: [
            // ── 1. Overall Savings Progress Hero (Tide) ──────────────────
            overallSummaryAsync.when(
              data: (overall) {
                if (overall.totalTarget <= 0) return const SizedBox.shrink();

                final overallProgress =
                    (overall.totalSaved / overall.totalTarget).clamp(0.0, 1.0);
                final summaries = goalsSummariesAsync.value ?? const [];
                final nearest =
                    summaries.where((s) => !s.isTargetReached).toList()..sort(
                      (a, b) => a.goal.targetDate.compareTo(b.goal.targetDate),
                    );
                final nextGoal = nearest.isNotEmpty ? nearest.first : null;

                return Column(
                  children: [
                    FfHeroCard(
                      tone: FfHeroTone.tide,
                      title: 'Total saved',
                      subtitle:
                          '${CurrencyFormatter.formatAmount(overall.totalSaved)} of ${CurrencyFormatter.formatAmount(overall.totalTarget)} · ${overall.completedCount} of ${overall.totalGoals} reached',
                      leading: FfProgressRing(
                        value: overallProgress,
                        icon: Icons.savings_outlined,
                        semanticsLabel:
                            '${(overallProgress * 100).toStringAsFixed(0)}% total saved',
                      ),
                      onOpen:
                          nextGoal != null
                              ? () => _openGoalDetail(context, nextGoal.goal)
                              : null,
                      openTooltip:
                          nextGoal != null
                              ? 'Open ${nextGoal.goal.name}'
                              : 'Open',
                      child: Builder(
                        builder:
                            (ctx) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FfAmountText(
                                  amount: overall.totalSaved,
                                  size: FfAmountSize.hero,
                                  style: FfAmountStyle.split,
                                  tone: FfTone.neutral,
                                  showSign: false,
                                ),
                                const SizedBox(height: FfSpace.xs),
                                if (nextGoal != null)
                                  Text(
                                    'Next: ${nextGoal.goal.name} (${CurrencyFormatter.formatAmount(nextGoal.remainingAmount)} left by ${DateFormatter.formatShortDate(nextGoal.goal.targetDate)})',
                                    style: ctx.ff.text.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                else
                                  Text(
                                    '${CurrencyFormatter.formatAmount(overall.totalRemaining)} left to reach all targets',
                                    style: ctx.ff.text.label,
                                  ),
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(height: FfSpace.lg),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── 2. Goals List ─────────────────────────────────────────────
            goalsSummariesAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: FfSpace.x2l),
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

                final activeSummaries =
                    summaries.where((s) => !s.isTargetReached).toList();
                final completedSummaries =
                    summaries.where((s) => s.isTargetReached).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeSummaries.isNotEmpty) ...[
                      FfSectionHeader(
                        title: 'Active goals',
                        count: activeSummaries.length,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeSummaries.length,
                        separatorBuilder:
                            (_, __) => const SizedBox(height: FfSpace.sm),
                        itemBuilder: (context, index) {
                          final summary = activeSummaries[index];
                          final goal = summary.goal;
                          final progress = summary.progressPercentage.clamp(
                            0.0,
                            1.0,
                          );
                          final percent = (progress * 100).toStringAsFixed(0);
                          final icon = getGoalIcon(goal.name);

                          return FfCard(
                            onTap: () => _openGoalDetail(context, goal),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconTheme.merge(
                                      data: IconThemeData(
                                        color: context.ff.color.textPrimary,
                                      ),
                                      child: FfProgressRing(
                                        value: progress,
                                        icon: icon,
                                        semanticsLabel:
                                            '$percent% of ${goal.name} saved',
                                      ),
                                    ),
                                    const SizedBox(width: FfSpace.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            goal.name,
                                            style: context.ff.text.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: FfSpace.x3s),
                                          Text(
                                            'Target: ${DateFormatter.formatShortDate(goal.targetDate)} · $percent%',
                                            style: context.ff.text.bodySm,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: FfSpace.sm),
                                    FfInkButton.open(
                                      onPressed:
                                          () => _openGoalDetail(context, goal),
                                      tooltip: 'Open ${goal.name}',
                                      small: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: FfSpace.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Saved',
                                          style: context.ff.text.labelSm,
                                        ),
                                        FfAmountText(
                                          amount: summary.currentAmount,
                                          size: FfAmountSize.md,
                                          style: FfAmountStyle.split,
                                          tone: FfTone.neutral,
                                          showSign: false,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Target',
                                          style: context.ff.text.labelSm,
                                        ),
                                        FfAmountText(
                                          amount: goal.targetAmount,
                                          size: FfAmountSize.sm,
                                          style: FfAmountStyle.inline,
                                          tone: FfTone.neutral,
                                          showSign: false,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: FfSpace.sm),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$percent%',
                                          style: context.ff.text.labelSm
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: FfSpace.xs),
                                        FfBadge(
                                          label:
                                              summary.suggestedMonthlyContribution >
                                                      0
                                                  ? '₹${summary.suggestedMonthlyContribution.toStringAsFixed(0)} / mo'
                                                  : 'On track',
                                          tone: FfTone.savings,
                                          icon: Icons.trending_up_rounded,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${CurrencyFormatter.formatAmount(summary.remainingAmount)} left',
                                      style: context.ff.text.labelSm.copyWith(
                                        color: context.ff.color.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: FfSpace.lg),
                    ],

                    // Achieved Section
                    if (completedSummaries.isNotEmpty) ...[
                      FfSectionHeader(
                        title: 'Achieved',
                        count: completedSummaries.length,
                      ),
                      FfGroupedContainer(
                        children:
                            completedSummaries.map((summary) {
                              final goal = summary.goal;
                              final icon = getGoalIcon(goal.name);

                              return FfRow(
                                leading: FfIconTile(
                                  icon: icon,
                                  tone: FfTone.savings,
                                ),
                                title: goal.name,
                                subtitle:
                                    'Goal reached · ${DateFormatter.formatShortDate(goal.targetDate)}',
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FfAmountText(
                                      amount: summary.currentAmount,
                                      size: FfAmountSize.sm,
                                      style: FfAmountStyle.inline,
                                      tone: FfTone.savings,
                                      showSign: false,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 12,
                                          color: context.ff.color.spark,
                                        ),
                                        const SizedBox(width: FfSpace.x3s),
                                        Text(
                                          '100%',
                                          style: context.ff.text.labelSm
                                              .copyWith(
                                                color:
                                                    context
                                                        .ff
                                                        .color
                                                        .textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () => _openGoalDetail(context, goal),
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(FfSpace.x4l),
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
