import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/savings_goal.dart';
import '../../services/savings_goal_calculator.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'add_goal_contribution_sheet.dart';
import 'savings_goals_controller.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  final SavingsGoal goal;

  const SavingsGoalDetailScreen({super.key, required this.goal});

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddEditSavingsGoalSheet(initialGoal: goal),
    );
  }

  void _openAddContribution(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddGoalContributionSheet(goal: goal),
    );
  }

  void _deleteGoal(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Savings Goal?',
      message:
          'Are you sure you want to delete "${goal.name}" and its contribution history?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(savingsGoalsControllerProvider.notifier)
            .deleteGoal(goal.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfSnackbar.show(context, message: 'Savings goal deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Could not delete goal: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final contributionsAsync = ref.watch(
      goalContributionsForGoalProvider(goal.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Goal',
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Goal',
            onPressed: () => _deleteGoal(context, ref),
          ),
        ],
      ),
      body: contributionsAsync.when(
        data: (contributions) {
          final summary = SavingsGoalCalculator.calculateSummary(
            goal,
            contributions,
          );

          return ListView(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            children: [
              // 1. Goal Progress Hero Card
              FfCard(
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
                                StillwaterTokens.spaceSm,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusSm,
                                ),
                              ),
                              child: Icon(
                                Icons.flag_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  'Target: ${DateFormat('dd MMM yyyy').format(goal.targetDate)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (summary.isTargetReached)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceSm,
                              vertical: StillwaterTokens.space2Xs,
                            ),
                            decoration: BoxDecoration(
                              color: finColors.incomeContainer,
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusFull,
                              ),
                            ),
                            child: Text(
                              'Target Reached',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: finColors.income,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    // Amount Saved vs Target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.format(summary.currentAmount),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: finColors.income,
                          ),
                        ),
                        Text(
                          'Target: ${CurrencyFormatter.format(goal.targetAmount)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: StillwaterTokens.spaceSm),

                    // Progress Bar
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
                        minHeight: 8,
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceMd),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(summary.progressPercentage * 100).toStringAsFixed(0)}% completed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          summary.isTargetReached
                              ? 'Fully Funded'
                              : '${CurrencyFormatter.format(summary.remainingAmount)} to go',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                summary.isTargetReached
                                    ? finColors.income
                                    : theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 2. Planning & Forecast Strip
              Row(
                children: [
                  Expanded(
                    child: FfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggested Monthly',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space2Xs),
                          Text(
                            CurrencyFormatter.format(
                              summary.suggestedMonthlyContribution,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space3Xs),
                          Text(
                            'To meet target date',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: FfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completion Forecast',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space2Xs),
                          Text(
                            summary.estimatedCompletionDate != null
                                ? DateFormat(
                                  'MMM yyyy',
                                ).format(summary.estimatedCompletionDate!)
                                : 'Forecast Pending',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space3Xs),
                          Text(
                            summary.estimatedCompletionDate != null
                                ? 'At your contribution pace'
                                : 'Add a few contributions',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 3. Contributions List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contributions (${contributions.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const FfPrivacyBadge(label: 'On-device'),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              if (contributions.isEmpty) ...[
                FfCard(
                  child: FfEmptyState(
                    icon: Icons.savings_outlined,
                    title: 'No contributions logged yet',
                    description:
                        'Log deposits or transfers towards this goal to track your savings journey.',
                    actionLabel: 'Add Contribution',
                    onAction: () => _openAddContribution(context),
                  ),
                ),
              ] else ...[
                FfCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contributions.length,
                    separatorBuilder: (ctx, i) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final c = contributions[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceMd,
                          vertical: StillwaterTokens.space2Xs,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: finColors.incomeContainer,
                          child: Icon(
                            Icons.add_rounded,
                            color: finColors.income,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          c.notes ?? 'Contribution',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormatter.formatTransactionDate(c.date),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+ ${CurrencyFormatter.format(c.amount)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: finColors.income,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              onPressed: () async {
                                await ref
                                    .read(
                                      savingsGoalsControllerProvider.notifier,
                                    )
                                    .deleteContribution(c.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load goal: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddContribution(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Contribution'),
      ),
    );
  }
}
