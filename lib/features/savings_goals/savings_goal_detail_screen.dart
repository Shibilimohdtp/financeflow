import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../services/savings_goal_calculator.dart';
import '../../shared/widgets/ff_button.dart';
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

  void _openEdit(BuildContext context, SavingsGoal currentGoal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditSavingsGoalSheet(initialGoal: currentGoal),
    );
  }

  void _openAddContribution(BuildContext context, SavingsGoal currentGoal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddGoalContributionSheet(goal: currentGoal),
    );
  }

  void _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal currentGoal,
  ) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Savings Goal?',
      message:
          'Are you sure you want to delete "${currentGoal.name}" and all recorded contributions?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(savingsGoalsControllerProvider.notifier)
            .deleteGoal(currentGoal.id);
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

    // Watch live goal stream
    final allGoalsAsync = ref.watch(allSavingsGoalsStreamProvider);
    final currentGoal =
        allGoalsAsync.value?.firstWhere(
          (g) => g.id == goal.id,
          orElse: () => goal,
        ) ??
        goal;

    final contributionsAsync = ref.watch(
      goalContributionsForGoalProvider(currentGoal.id),
    );
    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final daysRemaining =
        currentGoal.targetDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentGoal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Goal',
            onPressed: () => _openEdit(context, currentGoal),
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: '100% Local')),
          ),
        ],
      ),
      body: contributionsAsync.when(
        data: (contributions) {
          final summary = SavingsGoalCalculator.calculateSummary(
            currentGoal,
            contributions,
          );
          final progress = summary.progressPercentage.clamp(0.0, 1.0);

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceMd,
            ),
            children: [
              // ── 1. Goal Progress Hero ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                decoration: BoxDecoration(
                  color: theme.cardColor,
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
                        Text(
                          'TOTAL ACCUMULATED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.8,
                            color: theme.colorScheme.secondary,
                            fontSize: 10,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceSm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                summary.isTargetReached
                                    ? context.secColors.verified.withValues(
                                      alpha: 0.15,
                                    )
                                    : theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusFull,
                            ),
                          ),
                          child: Text(
                            summary.isTargetReached
                                ? 'Target Reached'
                                : '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  summary.isTargetReached
                                      ? context.secColors.verified
                                      : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      CurrencyFormatter.formatINR(summary.currentAmount),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${CurrencyFormatter.formatINR(currentGoal.targetAmount)} · Due ${DateFormat('dd MMM yyyy').format(currentGoal.targetDate)} (${daysRemaining > 0 ? "$daysRemaining days left" : "Reached"})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusFull,
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          summary.isTargetReached
                              ? context.secColors.verified
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 2. Savings Pace & Guidance ──────────────────────────────
              if (!summary.isTargetReached &&
                  summary.suggestedMonthlyContribution > 0)
                Container(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusMd,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required Savings Pace',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Save ${CurrencyFormatter.formatINR(summary.suggestedMonthlyContribution)} / month to hit your goal on schedule.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // ── 3. Actions ──────────────────────────────────────────────
              FfButton(
                label: 'Add Funds to Goal',
                leadingIcon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () => _openAddContribution(context, currentGoal),
              ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // ── 4. Contribution History ─────────────────────────────────
              _SectionLabel(
                label: 'Contribution History (${contributions.length})',
              ),
              const SizedBox(height: StillwaterTokens.spaceXs),

              if (contributions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.spaceXl,
                  ),
                  child: FfEmptyState(
                    icon: Icons.history_rounded,
                    title: 'No contributions recorded',
                    description:
                        'Add your first deposit towards this savings goal.',
                    actionLabel: 'Add Funds',
                    onAction: () => _openAddContribution(context, currentGoal),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusLg,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < contributions.length; i++) ...[
                        _ContributionRow(
                          contribution: contributions[i],
                          accounts: accountsAsync.value ?? [],
                          onDelete: () async {
                            final confirmed = await FfConfirmDialog.show(
                              context,
                              title: 'Remove Contribution?',
                              message:
                                  'Remove ${CurrencyFormatter.formatINR(contributions[i].amount)} deposit from this goal?',
                              confirmLabel: 'Remove',
                              isDestructive: true,
                            );
                            if (confirmed == true && context.mounted) {
                              await ref
                                  .read(savingsGoalsControllerProvider.notifier)
                                  .deleteContribution(contributions[i].id);
                              if (context.mounted) {
                                FfSnackbar.show(
                                  context,
                                  message: 'Contribution removed.',
                                );
                              }
                            }
                          },
                        ),
                        if (i < contributions.length - 1)
                          Divider(
                            height: 1,
                            thickness: StillwaterTokens.borderWidthHairline,
                            indent: StillwaterTokens.spaceMd,
                          ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // Destructive Delete Goal
              FfButton(
                label: 'Delete Savings Goal',
                variant: FfButtonVariant.destructive,
                leadingIcon: const Icon(Icons.delete_outline_rounded, size: 16),
                onPressed: () => _deleteGoal(context, ref, currentGoal),
              ),

              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ContributionRow extends StatelessWidget {
  final dynamic contribution;
  final List<dynamic> accounts;
  final VoidCallback onDelete;

  const _ContributionRow({
    required this.contribution,
    required this.accounts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accountName =
        accounts
            .firstWhere(
              (a) => a.id == contribution.accountId,
              orElse: () => null,
            )
            ?.name ??
        'Direct Deposit';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.secColors.verified.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusSm),
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 16,
              color: context.secColors.verified,
            ),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormatter.formatTransactionDate(contribution.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ${CurrencyFormatter.formatINR(contribution.amount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.secColors.verified,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            tooltip: 'Remove contribution',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: StillwaterTokens.space2Xs),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          color: context.theme.colorScheme.secondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
