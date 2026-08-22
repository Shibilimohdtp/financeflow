import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/budget.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../dashboard/dashboard_controller.dart';
import 'add_edit_budget_sheet.dart';
import 'budget_detail_screen.dart';
import 'budgets_controller.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  void _openAddBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddEditBudgetSheet(),
    );
  }

  void _openBudgetDetail(BuildContext context, Budget budget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BudgetDetailScreen(budget: budget)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final periodFilter = ref.watch(selectedBudgetPeriodFilterProvider);
    final summariesAsync = ref.watch(budgetSummariesProvider);
    final overallSummaryAsync = ref.watch(overallBudgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
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
          ref.invalidate(activeBudgetsStreamProvider);
          ref.invalidate(budgetSummariesProvider);
          ref.invalidate(overallBudgetSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.spaceLg,
            vertical: StillwaterTokens.spaceMd,
          ),
          children: [
            // 1. Month Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'Previous Month',
                  onPressed: () {
                    final prev = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                      1,
                    );
                    ref.read(selectedDashboardMonthProvider.notifier).state =
                        prev;
                  },
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusSm,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedMonth,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      ref.read(selectedDashboardMonthProvider.notifier).state =
                          picked;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceSm,
                      vertical: StillwaterTokens.space2Xs,
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(selectedMonth),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        const Icon(Icons.arrow_drop_down_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Next Month',
                  onPressed: () {
                    final next = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                      1,
                    );
                    ref.read(selectedDashboardMonthProvider.notifier).state =
                        next;
                  },
                ),
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // 2. Total Budget Hero Card
            overallSummaryAsync.when(
              data: (overall) {
                if (overall.totalBudgeted <= 0) {
                  return const SizedBox.shrink();
                }

                final overallPercentage =
                    overall.totalBudgeted > 0
                        ? (overall.totalSpent / overall.totalBudgeted).clamp(
                          0.0,
                          1.0,
                        )
                        : 0.0;
                final isOverallExceeded =
                    overall.totalSpent > overall.totalBudgeted;

                return FfCard(
                  variant: FfCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Budget Planned',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          if (overall.overBudgetCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: StillwaterTokens.spaceSm,
                                vertical: StillwaterTokens.space2Xs,
                              ),
                              decoration: BoxDecoration(
                                color: finColors.expenseContainer,
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${overall.overBudgetCount} over limit',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: finColors.expense,
                                  fontWeight: FontWeight.bold,
                                ),
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
                            CurrencyFormatter.format(overall.totalSpent),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isOverallExceeded ? finColors.expense : null,
                            ),
                          ),
                          Text(
                            'Limit: ${CurrencyFormatter.format(overall.totalBudgeted)}',
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
                          value: overallPercentage,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color:
                              isOverallExceeded
                                  ? finColors.expense
                                  : theme.colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(overallPercentage * 100).toStringAsFixed(0)}% spent',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            isOverallExceeded
                                ? '${CurrencyFormatter.format(overall.totalSpent - overall.totalBudgeted)} over planned budget'
                                : '${CurrencyFormatter.format(overall.totalRemaining)} remaining in pool',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isOverallExceeded
                                      ? finColors.expense
                                      : finColors.income,
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

            // 3. Period Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Periods'),
                    selected: periodFilter == null,
                    onSelected: (selected) {
                      ref
                          .read(selectedBudgetPeriodFilterProvider.notifier)
                          .state = null;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  FilterChip(
                    label: const Text('Monthly'),
                    selected: periodFilter == BudgetPeriod.monthly,
                    onSelected: (selected) {
                      ref
                          .read(selectedBudgetPeriodFilterProvider.notifier)
                          .state = selected ? BudgetPeriod.monthly : null;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  FilterChip(
                    label: const Text('Weekly'),
                    selected: periodFilter == BudgetPeriod.weekly,
                    onSelected: (selected) {
                      ref
                          .read(selectedBudgetPeriodFilterProvider.notifier)
                          .state = selected ? BudgetPeriod.weekly : null;
                    },
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  FilterChip(
                    label: const Text('Yearly'),
                    selected: periodFilter == BudgetPeriod.yearly,
                    onSelected: (selected) {
                      ref
                          .read(selectedBudgetPeriodFilterProvider.notifier)
                          .state = selected ? BudgetPeriod.yearly : null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // 4. Budgets List
            summariesAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: StillwaterTokens.spaceXl,
                    ),
                    child: FfCard(
                      child: FfEmptyState(
                        icon: Icons.pie_chart_outline_rounded,
                        title: 'No active budgets',
                        description:
                            'Set spending targets for food, groceries, or entertainment to stay on track offline.',
                        actionLabel: 'Add Budget',
                        onAction: () => _openAddBudget(context),
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
                    final budget = summary.budget;

                    final Color progressColor;
                    if (summary.isExceeded) {
                      progressColor = finColors.expense;
                    } else if (summary.isApproachingThreshold) {
                      progressColor = theme.colorScheme.tertiary;
                    } else {
                      progressColor = theme.colorScheme.primary;
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusLg,
                      ),
                      onTap: () => _openBudgetDetail(context, budget),
                      child: FfCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FfCategoryTile(
                                  iconIdentifier:
                                      budget.categoryIcon ?? 'category',
                                  colorTokenIdentifier:
                                      budget.categoryColor ?? 'slate',
                                ),
                                const SizedBox(width: StillwaterTokens.spaceSm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        budget.name,
                                        style: theme.textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${budget.categoryName ?? 'Category'} • ${budget.period.displayName}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (summary.isExceeded)
                                  Text(
                                    '${CurrencyFormatter.format(summary.amountOverBudget)} over',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: finColors.expense,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  Text(
                                    '${CurrencyFormatter.format(summary.remainingAmount)} left',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: finColors.income,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: StillwaterTokens.spaceMd),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${CurrencyFormatter.format(summary.amountSpent)} of ${CurrencyFormatter.format(budget.amountLimit)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(summary.percentageUsed * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: progressColor,
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
                                value: summary.percentageUsed.clamp(0.0, 1.0),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: progressColor,
                                minHeight: 6,
                              ),
                            ),

                            const SizedBox(height: StillwaterTokens.spaceXs),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${CurrencyFormatter.format(summary.dailyAllowanceRemaining)} / day',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  '${summary.daysRemaining} days left',
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
                  (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                      child: Text('Could not load budgets: $e'),
                    ),
                  ),
            ),

            const SizedBox(height: StillwaterTokens.space4Xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets_add_fab',
        onPressed: () => _openAddBudget(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Budget'),
      ),
    );
  }
}
