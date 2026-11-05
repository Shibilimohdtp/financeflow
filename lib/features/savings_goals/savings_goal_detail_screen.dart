import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../services/savings_goal_calculator.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'add_goal_contribution_sheet.dart';
import 'savings_goals_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  final SavingsGoal goal;

  const SavingsGoalDetailScreen({super.key, required this.goal});

  void _openEdit(BuildContext context, SavingsGoal currentGoal) {
    showFfSheet(
      context,
      builder: (ctx) => AddEditSavingsGoalSheet(initialGoal: currentGoal),
    );
  }

  void _openAddContribution(BuildContext context, SavingsGoal currentGoal) {
    showFfSheet(
      context,
      builder: (ctx) => AddGoalContributionSheet(goal: currentGoal),
    );
  }

  void _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal currentGoal,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Savings Goal?',
      message:
          'Are you sure you want to delete "${currentGoal.name}" and all recorded contributions?',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(savingsGoalsControllerProvider.notifier)
            .deleteGoal(currentGoal.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfToast.show(context, message: 'Savings goal deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Could not delete goal: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      appBar: FfAppBar(
        title: currentGoal.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Goal',
            onPressed: () => _openEdit(context, currentGoal),
          ),
          const Padding(
            padding: EdgeInsets.only(right: FfSpace.md),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
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
              horizontal: FfSpace.lg,
              vertical: FfSpace.md,
            ),
            children: [
              // ── 1. Goal Progress Hero ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(FfSpace.lg),
                decoration: BoxDecoration(
                  color: context.ff.color.surfaceCard,
                  borderRadius: BorderRadius.circular(FfRadius.lg),
                  border: Border.all(
                    color: context.ff.color.borderSubtle,
                    width: FfBorderWidth.hairline,
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
                          style: context.ff.text.labelSm.copyWith(
                            letterSpacing: 0.8,
                            color: context.ff.color.secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FfSpace.sm,
                            vertical: FfSpace.x3s,
                          ),
                          decoration: BoxDecoration(
                            color:
                                summary.isTargetReached
                                    ? context.ff.color.statusSuccess.withValues(
                                      alpha: 0.15,
                                    )
                                    : context.ff.color.actionPrimary.withValues(
                                      alpha: 0.12,
                                    ),
                            borderRadius: BorderRadius.circular(FfRadius.full),
                          ),
                          child: Text(
                            summary.isTargetReached
                                ? 'Target Reached'
                                : '${(progress * 100).toStringAsFixed(1)}%',
                            style: context.ff.text.labelSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  summary.isTargetReached
                                      ? context.ff.color.statusSuccess
                                      : context.ff.color.actionPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.currentAmount),
                      style: context.ff.text.headlineLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.ff.color.actionPrimary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      'Target: ${CurrencyFormatter.formatAmount(currentGoal.targetAmount)} · Due ${DateFormat('dd MMM yyyy').format(currentGoal.targetDate)} (${daysRemaining > 0 ? "$daysRemaining days left" : "Reached"})',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.secondary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.md),
                    FfProgressBar(
                      value: progress,
                      color:
                          summary.isTargetReached
                              ? context.ff.color.statusSuccess
                              : context.ff.color.actionPrimary,
                      size: FfProgressSize.lg,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.lg),

              // ── 2. Savings Pace & Guidance ──────────────────────────────
              if (!summary.isTargetReached &&
                  summary.suggestedMonthlyContribution > 0)
                Container(
                  padding: const EdgeInsets.all(FfSpace.md),
                  decoration: BoxDecoration(
                    color: context.ff.color.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(FfRadius.md),
                    border: Border.all(
                      color: context.ff.color.borderSubtle,
                      width: FfBorderWidth.hairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 20,
                        color: context.ff.color.actionPrimary,
                      ),
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required Savings Pace',
                              style: context.ff.text.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Save ${CurrencyFormatter.formatAmount(summary.suggestedMonthlyContribution)} / month to hit your goal on schedule.',
                              style: context.ff.text.bodySm.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: FfSpace.x2l),

              // ── 3. Actions ──────────────────────────────────────────────
              FfButton(
                label: 'Add Funds to Goal',
                leadingIcon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () => _openAddContribution(context, currentGoal),
              ),

              const SizedBox(height: FfSpace.x2l),

              // ── 4. Contribution History ─────────────────────────────────
              _SectionLabel(
                label: 'Contribution History (${contributions.length})',
              ),
              const SizedBox(height: FfSpace.xs),

              if (contributions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.xl),
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
                    color: context.ff.color.surfaceCard,
                    borderRadius: BorderRadius.circular(FfRadius.lg),
                    border: Border.all(
                      color: context.ff.color.borderSubtle,
                      width: FfBorderWidth.hairline,
                    ),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < contributions.length; i++) ...[
                        _ContributionRow(
                          contribution: contributions[i],
                          accounts: accountsAsync.value ?? [],
                          onDelete: () async {
                            final confirmed = await FfDialog.confirm(
                              context,
                              title: 'Remove Contribution?',
                              message:
                                  'Remove ${CurrencyFormatter.formatAmount(contributions[i].amount)} deposit from this goal?',
                              confirmLabel: 'Remove',
                              destructive: true,
                            );
                            if (confirmed == true && context.mounted) {
                              await ref
                                  .read(savingsGoalsControllerProvider.notifier)
                                  .deleteContribution(contributions[i].id);
                              if (context.mounted) {
                                FfToast.show(
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
                            thickness: FfBorderWidth.hairline,
                            indent: FfSpace.md,
                          ),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: FfSpace.x2l),

              // Destructive Delete Goal
              FfButton(
                label: 'Delete Savings Goal',
                variant: FfButtonVariant.destructive,
                leadingIcon: const Icon(Icons.delete_outline_rounded, size: 16),
                onPressed: () => _deleteGoal(context, ref, currentGoal),
              ),

              const SizedBox(height: FfSpace.x4l),
            ],
          );
        },
        loading: () => const FfLoading(),
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
        horizontal: FfSpace.md,
        vertical: FfSpace.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.ff.color.statusSuccess.withValues(
                alpha: FfTint.subtle.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.sm),
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 16,
              color: context.ff.color.statusSuccess,
            ),
          ),
          const SizedBox(width: FfSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: context.ff.text.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormatter.formatTransactionDate(contribution.date),
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ${CurrencyFormatter.formatAmount(contribution.amount)}',
            style: context.ff.text.body.copyWith(
              fontWeight: FontWeight.w600,
              color: context.ff.color.statusSuccess,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: context.ff.color.secondary,
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
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
