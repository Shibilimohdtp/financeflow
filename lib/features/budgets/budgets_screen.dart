import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/budget.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../dashboard/dashboard_controller.dart';
import 'add_edit_budget_sheet.dart';
import 'budget_detail_screen.dart';
import 'budgets_controller.dart';
import 'widgets/budget_card.dart';
import 'widgets/budget_insights_card.dart';
import 'widgets/budget_visual_summary_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _openAddBudget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditBudgetSheet(),
    );
  }

  void _openEditBudget(BuildContext context, Budget budget) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditBudgetSheet(initialBudget: budget),
    );
  }

  void _confirmDeleteBudget(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Budget?',
      message:
          'Are you sure you want to delete the budget "${budget.name}"? Past transactions will remain intact.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(budgetsControllerProvider.notifier)
            .deleteBudget(budget.id);
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Budget deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Could not delete budget: $e');
        }
      }
    }
  }

  void _setMonth(WidgetRef ref, DateTime value) {
    ref.read(selectedDashboardMonthProvider.notifier).state = DateTime(
      value.year,
      value.month,
      1,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final month = ref.watch(selectedDashboardMonthProvider);
    final summariesAsync = ref.watch(budgetSummariesProvider);
    final overallAsync = ref.watch(overallBudgetSummaryProvider);
    final selectedPeriodFilter = ref.watch(selectedBudgetPeriodFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
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
        heroTag: 'budgets_add_fab',
        tooltip: 'Add budget',
        onPressed: () => _openAddBudget(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Budget'),
      ),
      floatingActionButtonLocation: FfDock.fabLocation,
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          ref.invalidate(activeBudgetsStreamProvider);
          ref.invalidate(budgetSummariesProvider);
          ref.invalidate(overallBudgetSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            StillwaterTokens.spaceLg,
            StillwaterTokens.spaceMd,
            StillwaterTokens.spaceLg,
            104,
          ),
          children: [
            // ── 1. Month Selector Header ─────────────────────────────
            _MonthSelectorHeader(
              month: month,
              onPrevious:
                  () => _setMonth(ref, DateTime(month.year, month.month - 1)),
              onNext:
                  () => _setMonth(ref, DateTime(month.year, month.month + 1)),
              onPickDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: month,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  helpText: 'Select budget month',
                );
                if (picked != null && context.mounted) {
                  _setMonth(ref, picked);
                }
              },
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // ── 2. Overall Budget Visual Summary ─────────────────────
            overallAsync.when(
              data: (overall) {
                if (overall.totalBudgeted <= 0) {
                  return const SizedBox.shrink();
                }
                final summaries = summariesAsync.valueOrNull ?? [];
                return Column(
                  children: [
                    BudgetVisualSummaryCard(
                      totalBudgeted: overall.totalBudgeted,
                      totalSpent: overall.totalSpent,
                      totalRemaining: overall.totalRemaining,
                      overBudgetCount: overall.overBudgetCount,
                      totalBudgetsCount: summaries.length,
                    ),
                    const SizedBox(height: StillwaterTokens.spaceMd),
                    BudgetInsightsCard(
                      summaries: summaries,
                      totalBudgeted: overall.totalBudgeted,
                      totalSpent: overall.totalSpent,
                      totalRemaining: overall.totalRemaining,
                    ),
                  ],
                );
              },
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: StillwaterTokens.spaceMd,
                    ),
                    child: FfSkeletonLoader(
                      child: FfSkeletonBlock(
                        height: 180,
                        borderRadius: StillwaterTokens.radiusLg,
                      ),
                    ),
                  ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: StillwaterTokens.spaceLg),

            // ── 3. Category Budgets Header & Filter ──────────────────
            FfSectionHeader(
              title: 'Category Budgets',
              padding: EdgeInsets.zero,
              trailing:
                  (summariesAsync.valueOrNull?.isNotEmpty ?? false)
                      ? PopupMenuButton<BudgetPeriod?>(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          size: 20,
                          color:
                              selectedPeriodFilter != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                        ),
                        tooltip: 'Filter by period',
                        onSelected: (period) {
                          ref
                              .read(selectedBudgetPeriodFilterProvider.notifier)
                              .state = period;
                        },
                        itemBuilder:
                            (ctx) => [
                              const PopupMenuItem(
                                value: null,
                                child: Text('All Periods'),
                              ),
                              for (final p in BudgetPeriod.values)
                                PopupMenuItem(
                                  value: p,
                                  child: Text(p.displayName),
                                ),
                            ],
                      )
                      : null,
            ),

            if (selectedPeriodFilter != null) ...[
              const SizedBox(height: StillwaterTokens.spaceXs),
              Row(
                children: [
                  Chip(
                    label: Text(
                      'Period: ${selectedPeriodFilter.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      ref
                          .read(selectedBudgetPeriodFilterProvider.notifier)
                          .state = null;
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: StillwaterTokens.spaceSm),

            // ── 4. Category Budgets List ─────────────────────────────
            summariesAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: StillwaterTokens.space2Xl,
                    ),
                    child: FfEmptyState(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'No budgets for this month',
                      description:
                          'Set up a category spending limit to maintain control of your monthly cash flow.',
                      actionLabel: 'Create Budget',
                      onAction: () => _openAddBudget(context),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(height: StillwaterTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final summary = items[index];
                    return BudgetCard(
                      summary: summary,
                      onTap: (budget) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BudgetDetailScreen(budget: budget),
                          ),
                        );
                      },
                      onEdit: (budget) => _openEditBudget(context, budget),
                      onDelete:
                          (budget) =>
                              _confirmDeleteBudget(context, ref, budget),
                    );
                  },
                );
              },
              loading:
                  () => const FfSkeletonLoader(
                    child: Column(
                      children: [
                        FfSkeletonBlock(
                          height: 100,
                          borderRadius: StillwaterTokens.radiusLg,
                        ),
                        SizedBox(height: StillwaterTokens.spaceSm),
                        FfSkeletonBlock(
                          height: 100,
                          borderRadius: StillwaterTokens.radiusLg,
                        ),
                        SizedBox(height: StillwaterTokens.spaceSm),
                        FfSkeletonBlock(
                          height: 100,
                          borderRadius: StillwaterTokens.radiusLg,
                        ),
                      ],
                    ),
                  ),
              error:
                  (error, _) => Padding(
                    padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                    child: FfEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load budgets',
                      description: '$error',
                      actionLabel: 'Try again',
                      onAction: () => ref.invalidate(budgetSummariesProvider),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelectorHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  const _MonthSelectorHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = DateFormat('MMMM yyyy').format(month);

    return Semantics(
      container: true,
      label: 'Selected budget month: $label',
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.7),
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous month',
              onPressed: onPrevious,
            ),
            Expanded(
              child: InkWell(
                onTap: onPickDate,
                borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: StillwaterTokens.spaceSm),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next month',
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
