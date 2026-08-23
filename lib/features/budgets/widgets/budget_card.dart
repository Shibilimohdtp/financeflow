import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../models/budget.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/stillwater_typography.dart';

class BudgetCard extends StatelessWidget {
  final BudgetSummary summary;
  final ValueChanged<Budget> onTap;
  final ValueChanged<Budget>? onEdit;
  final ValueChanged<Budget>? onDelete;

  const BudgetCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;
    final budget = summary.budget;

    final isExceeded = summary.isExceeded;
    final isApproaching = summary.isApproachingThreshold;

    final Color progressColor;
    final IconData statusIcon;
    final String statusLabel;
    final Color statusTextColor;

    if (isExceeded) {
      progressColor = finColors.expense;
      statusIcon = Icons.error_outline_rounded;
      statusLabel =
          '${CurrencyFormatter.formatINR(summary.amountSpent - budget.amountLimit)} over limit';
      statusTextColor = finColors.expense;
    } else if (isApproaching) {
      progressColor = theme.colorScheme.tertiary;
      statusIcon = Icons.warning_amber_rounded;
      statusLabel =
          '${CurrencyFormatter.formatINR(summary.remainingAmount)} left · Approaching';
      statusTextColor = theme.colorScheme.tertiary;
    } else {
      progressColor = theme.colorScheme.primary;
      statusIcon = Icons.check_circle_outline_rounded;
      statusLabel =
          '${CurrencyFormatter.formatINR(summary.remainingAmount)} left';
      statusTextColor = finColors.income;
    }

    final percentage = summary.percentageUsed.clamp(0.0, 1.0);
    final percentageLabel = '${(summary.percentageUsed * 100).toStringAsFixed(0)}%';

    return Semantics(
      button: true,
      label:
          '${budget.name}, ${CurrencyFormatter.formatINR(summary.amountSpent)} spent of ${CurrencyFormatter.formatINR(budget.amountLimit)}, $statusLabel',
      child: FfCard(
        onTap: () => onTap(budget),
        padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category tile, title & period badge, and spent vs limit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FfCategoryTile(
                  iconIdentifier: budget.categoryIcon ?? 'category',
                  colorTokenIdentifier: budget.categoryColor ?? 'shore',
                  size: 42,
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceXs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusXs,
                              ),
                            ),
                            child: Text(
                              budget.period.displayName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                          if (summary.daysRemaining > 0) ...[
                            const SizedBox(width: StillwaterTokens.spaceXs),
                            Text(
                              '${summary.daysRemaining}d left',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.formatINR(summary.amountSpent),
                        style: StillwaterTypography.numMd(
                          color:
                              isExceeded
                                  ? finColors.expense
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'of ${CurrencyFormatter.formatINR(budget.amountLimit)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    tooltip: 'Budget options',
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'edit') {
                        onEdit?.call(budget);
                      } else if (val == 'delete') {
                        onDelete?.call(budget);
                      }
                    },
                    itemBuilder:
                        (_) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: StillwaterTokens.spaceSm),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: StillwaterTokens.spaceSm),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceSm),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 7,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: progressColor,
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceXs),

            // Status and Percentage Row
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusTextColor),
                const SizedBox(width: StillwaterTokens.space2Xs),
                Expanded(
                  child: Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Text(
                  percentageLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
