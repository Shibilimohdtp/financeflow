import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart';
import '../../services/budget_calculator.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_category_tile.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../shared/widgets/ff_source_badge.dart';
import '../../theme/stillwater_tokens.dart';
import '../dashboard/dashboard_controller.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transactions_controller.dart';
import 'add_edit_budget_sheet.dart';
import 'budgets_controller.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailScreen({super.key, required this.budget});

  void _editBudget(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddEditBudgetSheet(initialBudget: budget),
    );
  }

  void _deleteBudget(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Budget?',
      message:
          'Are you sure you want to delete "${budget.name}"? Past transactions will remain recorded.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(budgetsControllerProvider.notifier)
            .deleteBudget(budget.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          FfSnackbar.show(context, message: 'Budget deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          FfSnackbar.show(context, message: 'Could not delete budget: $e');
        }
      }
    }
  }

  void _toggleArchive(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(budgetsControllerProvider.notifier)
          .archiveBudget(budget.id, !budget.isArchived);
      if (context.mounted) {
        FfSnackbar.show(
          context,
          message:
              budget.isArchived
                  ? 'Budget restored to active.'
                  : 'Budget archived.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        FfSnackbar.show(context, message: 'Could not archive budget: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final allTransactions = ref.watch(filteredTransactionsProvider).value ?? [];
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);

    final summary = BudgetCalculator.calculateSummary(
      budget,
      allTransactions,
      referenceDate: selectedMonth,
    );
    final bounds = BudgetCalculator.getPeriodBounds(budget, selectedMonth);

    // Matching transactions for this budget in this period
    final matchingTransactions =
        allTransactions.where((tx) {
          if (tx.type != TransactionType.expense) return false;
          if (tx.categoryId != budget.categoryId) return false;
          return !tx.date.isBefore(bounds.start) &&
              !tx.date.isAfter(bounds.end);
        }).toList();

    final Color progressColor;
    if (summary.isExceeded) {
      progressColor = finColors.expense;
    } else if (summary.isApproachingThreshold) {
      progressColor = theme.colorScheme.tertiary;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Budget',
            onPressed: () => _editBudget(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'archive') {
                _toggleArchive(context, ref);
              } else if (val == 'delete') {
                _deleteBudget(context, ref);
              }
            },
            itemBuilder:
                (ctx) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      budget.isArchived ? 'Unarchive Budget' : 'Archive Budget',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Budget',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // 1. Hero Summary Card
          FfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FfCategoryTile(
                          iconIdentifier: budget.categoryIcon ?? 'category',
                          colorTokenIdentifier: budget.categoryColor ?? 'slate',
                        ),
                        const SizedBox(width: StillwaterTokens.spaceSm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.categoryName ?? 'Category',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              budget.period.displayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (summary.isExceeded)
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
                          'Exceeded',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: finColors.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (summary.isApproachingThreshold)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceSm,
                          vertical: StillwaterTokens.space2Xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusFull,
                          ),
                        ),
                        child: Text(
                          'Near Limit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: StillwaterTokens.spaceLg),

                // Amount Spent vs Limit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(summary.amountSpent),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: summary.isExceeded ? finColors.expense : null,
                      ),
                    ),
                    Text(
                      'Limit: ${CurrencyFormatter.format(budget.amountLimit)}',
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
                    value: summary.percentageUsed.clamp(0.0, 1.0),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: progressColor,
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: StillwaterTokens.spaceMd),

                // Percentage and Remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(summary.percentageUsed * 100).toStringAsFixed(0)}% used',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      summary.isExceeded
                          ? '${CurrencyFormatter.format(summary.amountOverBudget)} over budget'
                          : '${CurrencyFormatter.format(summary.remainingAmount)} remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            summary.isExceeded
                                ? finColors.expense
                                : finColors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // 2. Daily Allowance & Forecast Strip
          Row(
            children: [
              Expanded(
                child: FfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Allowance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        CurrencyFormatter.format(
                          summary.dailyAllowanceRemaining,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space3Xs),
                      Text(
                        '${summary.daysRemaining} days left',
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
                        'Projected Spend',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        CurrencyFormatter.format(
                          summary.projectedPeriodEndSpending,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              summary.projectedPeriodEndSpending >
                                      budget.amountLimit
                                  ? finColors.expense
                                  : null,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space3Xs),
                      Text(
                        'At current pace',
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

          // 3. Transactions Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions (${matchingTransactions.length})',
                style: theme.textTheme.titleMedium,
              ),
              const FfPrivacyBadge(label: 'On-device'),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceSm),

          if (matchingTransactions.isEmpty) ...[
            FfCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                  child: Text(
                    'No expenses recorded in ${budget.name} for this period.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ] else ...[
            FfCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matchingTransactions.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final tx = matchingTransactions[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceMd,
                      vertical: StillwaterTokens.space2Xs,
                    ),
                    leading: FfCategoryTile(
                      iconIdentifier: tx.categoryIcon,
                      colorTokenIdentifier: tx.categoryColor,
                    ),
                    title: Text(
                      tx.merchant,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          DateFormatter.formatTransactionDate(tx.date),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: StillwaterTokens.spaceXs),
                        FfSourceBadge(source: tx.source),
                      ],
                    ),
                    trailing: FfAmountText(
                      amount: tx.amount,
                      type: tx.type,
                      size: FfAmountSize.md,
                      showSign: true,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => TransactionDetailScreen(transaction: tx),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: StillwaterTokens.space3Xl),
        ],
      ),
    );
  }
}
