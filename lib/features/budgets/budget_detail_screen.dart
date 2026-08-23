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
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import '../dashboard/dashboard_controller.dart';
import '../transactions/transaction_detail_screen.dart';
import '../transactions/transactions_controller.dart';
import 'add_edit_budget_sheet.dart';
import 'budgets_controller.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetDetailScreen({super.key, required this.budget});

  void _editBudget(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditBudgetSheet(initialBudget: budget),
    );
  }

  void _deleteBudget(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Budget?',
      message:
          'Are you sure you want to remove "${budget.name}"? Past transactions will remain recorded.',
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
          }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final isExceeded = summary.isExceeded;
    final isApproaching = summary.isApproachingThreshold;

    final Color progressColor;
    final IconData statusIcon;
    final String statusLabel;

    if (isExceeded) {
      progressColor = finColors.expense;
      statusIcon = Icons.error_outline_rounded;
      statusLabel =
          '${CurrencyFormatter.formatINR(summary.amountSpent - budget.amountLimit)} over limit';
    } else if (isApproaching) {
      progressColor = theme.colorScheme.tertiary;
      statusIcon = Icons.warning_amber_rounded;
      statusLabel = 'Approaching threshold (${(budget.alertThreshold * 100).toInt()}%)';
    } else {
      progressColor = theme.colorScheme.primary;
      statusIcon = Icons.check_circle_outline_rounded;
      statusLabel = 'Healthy & on pace';
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
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Budget',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceMd),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          StillwaterTokens.spaceLg,
          StillwaterTokens.spaceMd,
          StillwaterTokens.spaceLg,
          StillwaterTokens.space4Xl,
        ),
        children: [
          // ── 1. Spend Progress Hero Card ─────────────────────────────
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FfCategoryTile(
                      iconIdentifier: budget.categoryIcon ?? 'category',
                      colorTokenIdentifier: budget.categoryColor ?? 'shore',
                      size: 48,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${budget.categoryName ?? 'Category'} · ${budget.period.displayName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: statusLabel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StillwaterTokens.spaceSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: progressColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: progressColor),
                            const SizedBox(width: 4),
                            Text(
                              isExceeded
                                  ? 'Exceeded'
                                  : (isApproaching ? 'Warning' : 'On Track'),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: progressColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.formatINR(summary.amountSpent),
                          style: StillwaterTypography.numHero(
                            color:
                                isExceeded
                                    ? finColors.expense
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Text(
                      'of ${CurrencyFormatter.formatINR(budget.amountLimit)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(summary.percentageUsed * 100).toStringAsFixed(0)}% spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isExceeded
                          ? '${CurrencyFormatter.formatINR(summary.amountSpent - budget.amountLimit)} over limit'
                          : '${CurrencyFormatter.formatINR(summary.remainingAmount)} remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isExceeded ? finColors.expense : finColors.income,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 2. Pace & Schedule Metrics ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY ALLOWANCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.formatINR(
                            summary.dailyAllowanceRemaining,
                          ),
                          style: StillwaterTypography.numMd(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.daysRemaining} days remaining',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: FfCard(
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROJECTED SPEND',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceXs),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.formatINR(
                            summary.projectedPeriodEndSpending,
                          ),
                          style: StillwaterTypography.numMd(
                            color:
                                summary.projectedPeriodEndSpending >
                                        budget.amountLimit
                                    ? finColors.expense
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${matchingTransactions.length} expenses recorded',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 3. Plan Configuration ───────────────────────────────────
          const FfSectionHeader(
            title: 'Budget Settings',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          FfGroupedContainer(
            children: [
              FfListRow(
                icon: Icons.date_range_outlined,
                title: 'Period Cycle',
                subtitle:
                    '${DateFormatter.formatShortDate(bounds.start)} – ${DateFormatter.formatShortDate(bounds.end)}',
                showChevron: false,
              ),
              FfListRow(
                icon: Icons.notifications_active_outlined,
                title: 'Alert Notification',
                subtitle:
                    'Trigger alert at ${(budget.alertThreshold * 100).toInt()}% (${CurrencyFormatter.formatINR(budget.amountLimit * budget.alertThreshold)})',
                showChevron: false,
              ),
              FfListRow(
                icon: Icons.inventory_2_outlined,
                title: 'Status',
                subtitle: budget.isArchived ? 'Archived' : 'Active and tracking',
                showChevron: false,
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // ── 4. Transactions List for this Period ────────────────────
          FfSectionHeader(
            title: 'Transactions (${matchingTransactions.length})',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: StillwaterTokens.spaceSm),
          if (matchingTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: StillwaterTokens.spaceLg,
              ),
              child: FfEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No expenses in this cycle',
                description:
                    'Transactions categorized under "${budget.categoryName ?? 'this category'}" will automatically appear here.',
              ),
            )
          else
            FfGroupedContainer(
              children:
                  matchingTransactions.map((tx) {
                    return FfListRow(
                      leading: FfCategoryTile(
                        iconIdentifier: tx.categoryIcon,
                        colorTokenIdentifier: tx.categoryColor,
                        size: 36,
                      ),
                      title: tx.merchant,
                      subtitle: DateFormatter.formatFullDate(tx.date),
                      trailing: FfAmountText(
                        amount: tx.amount,
                        type: tx.type,
                        size: FfAmountSize.sm,
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
                  }).toList(),
            ),
        ],
      ),
    );
  }
}
