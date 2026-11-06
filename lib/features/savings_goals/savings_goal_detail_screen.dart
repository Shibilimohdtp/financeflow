import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/goal_contribution.dart';
import '../../models/savings_goal.dart';
import '../../repositories/account_repository.dart';
import '../../services/savings_goal_calculator.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_round_buttons.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'add_edit_savings_goal_sheet.dart';
import 'add_goal_contribution_sheet.dart';
import 'savings_goals_controller.dart';
import 'savings_goals_screen.dart';

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

  Future<void> _deleteGoal(
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
        subtitle:
            'Target: ${CurrencyFormatter.formatAmount(currentGoal.targetAmount)}',
        actions: [
          FfCircleButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit goal',
            onPressed: () => _openEdit(context, currentGoal),
          ),
          FfCircleButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete goal',
            onPressed: () => _deleteGoal(context, ref, currentGoal),
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
          final icon = SavingsGoalsScreen.getGoalIcon(currentGoal.name);

          // Build points for progression chart
          final sorted = List<GoalContribution>.from(contributions)
            ..sort((a, b) => a.date.compareTo(b.date));

          double runningTotal = 0.0;
          final List<FfChartPoint> chartPoints = [];
          for (final c in sorted) {
            runningTotal += c.amount;
            chartPoints.add(
              FfChartPoint(DateFormatter.formatShortDate(c.date), runningTotal),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.md,
              FfSpace.pageMargin,
              FfSpace.x4l,
            ),
            children: [
              // ── 1. Goal Progress Hero (Pattern D) ───────────────────────
              FfHeroCard(
                tone: FfHeroTone.tide,
                title: 'Saved so far',
                subtitle:
                    'Target: ${CurrencyFormatter.formatAmount(currentGoal.targetAmount)} · Due ${DateFormatter.formatShortDate(currentGoal.targetDate)}',
                leading: FfProgressRing(
                  value: progress,
                  icon: icon,
                  semanticsLabel:
                      '${(progress * 100).toStringAsFixed(0)}% of goal saved',
                ),
                child: Builder(
                  builder:
                      (ctx) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FfAmountText(
                            amount: summary.currentAmount,
                            size: FfAmountSize.hero,
                            style: FfAmountStyle.split,
                            tone: FfTone.neutral,
                            showSign: false,
                          ),
                          const SizedBox(height: FfSpace.md),
                          FfHeroFigures([
                            FfHeroFigure(
                              'Remaining',
                              CurrencyFormatter.formatAmount(
                                summary.remainingAmount,
                              ),
                            ),
                            FfHeroFigure(
                              'Pace needed',
                              summary.suggestedMonthlyContribution > 0
                                  ? '${CurrencyFormatter.formatAmount(summary.suggestedMonthlyContribution)}/mo'
                                  : 'Achieved',
                            ),
                            FfHeroFigure(
                              'Time left',
                              daysRemaining > 0
                                  ? '$daysRemaining days'
                                  : 'Due date passed',
                            ),
                          ]),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: FfSpace.lg),

              // ── 2. Primary Action ────────────────────────────────────────
              FfButton(
                label: 'Add Funds to Goal',
                leadingIcon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () => _openAddContribution(context, currentGoal),
              ),

              const SizedBox(height: FfSpace.lg),

              // ── 3. Progression Chart or Guidance ────────────────────────
              if (chartPoints.length >= 2) ...[
                FfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Savings trend', style: context.ff.text.title),
                          Text(
                            '${chartPoints.length} deposits',
                            style: context.ff.text.labelSm.copyWith(
                              color: context.ff.color.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FfSpace.md),
                      FfLineChart(
                        points: chartPoints,
                        valueLabel:
                            (p) => CurrencyFormatter.formatAmount(p.value),
                        height: 160,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.lg),
              ] else if (!summary.isTargetReached &&
                  summary.suggestedMonthlyContribution > 0) ...[
                FfCard(
                  variant: FfCardVariant.tinted,
                  tone: FfTone.savings,
                  child: Row(
                    children: [
                      FfIconTile(
                        icon: Icons.savings_outlined,
                        tone: FfTone.savings,
                      ),
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Required savings pace',
                              style: context.ff.text.titleSm,
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            Text(
                              'Save ${CurrencyFormatter.formatAmount(summary.suggestedMonthlyContribution)} a month to hit your target by ${DateFormatter.formatShortDate(currentGoal.targetDate)}.',
                              style: context.ff.text.bodySm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.lg),
              ],

              // ── 4. Contribution History ──────────────────────────────────
              FfSectionHeader(
                title: 'Contribution history',
                count: contributions.length,
              ),

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
                FfGroupedContainer(
                  children:
                      contributions.map((c) {
                        final accounts = accountsAsync.value ?? const [];
                        final accountName =
                            accounts
                                .where((a) => a.id == c.accountId)
                                .firstOrNull
                                ?.name ??
                            'Direct Deposit';

                        return FfRow(
                          leading: FfIconTile(
                            icon: Icons.arrow_downward_rounded,
                            tone: FfTone.savings,
                          ),
                          title: accountName,
                          subtitle: DateFormatter.formatTransactionDate(c.date),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FfAmountText(
                                amount: c.amount,
                                size: FfAmountSize.sm,
                                style: FfAmountStyle.inline,
                                tone: FfTone.savings,
                                showSign: true,
                              ),
                              const SizedBox(width: FfSpace.xs),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: context.ff.color.textSecondary,
                                ),
                                tooltip: 'Remove contribution',
                                onPressed: () async {
                                  final confirmed = await FfDialog.confirm(
                                    context,
                                    title: 'Remove Contribution?',
                                    message:
                                        'Remove ${CurrencyFormatter.formatAmount(c.amount)} deposit from this goal?',
                                    confirmLabel: 'Remove',
                                    destructive: true,
                                  );
                                  if (confirmed == true && context.mounted) {
                                    await ref
                                        .read(
                                          savingsGoalsControllerProvider
                                              .notifier,
                                        )
                                        .deleteContribution(c.id);
                                    if (context.mounted) {
                                      FfToast.show(
                                        context,
                                        message: 'Contribution removed.',
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

              const SizedBox(height: FfSpace.x2l),

              // ── 5. Destructive Delete Goal ───────────────────────────────
              FfButton(
                label: 'Delete Savings Goal',
                variant: FfButtonVariant.destructive,
                leadingIcon: const Icon(Icons.delete_outline_rounded, size: 16),
                onPressed: () => _deleteGoal(context, ref, currentGoal),
              ),
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
    );
  }
}
