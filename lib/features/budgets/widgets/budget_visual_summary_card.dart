import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/stillwater_typography.dart';

class BudgetVisualSummaryCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;
  final int overBudgetCount;
  final int totalBudgetsCount;

  const BudgetVisualSummaryCard({
    super.key,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overBudgetCount,
    this.totalBudgetsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    final isExceeded = totalSpent > totalBudgeted;
    final percentage =
        totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 0.0;
    final isApproaching = !isExceeded && percentage >= 0.8;

    final Color statusColor;
    final IconData statusIcon;
    final String statusMessage;

    if (isExceeded) {
      statusColor = finColors.expense;
      statusIcon = Icons.error_outline_rounded;
      final overAmount = totalSpent - totalBudgeted;
      statusMessage =
          '${CurrencyFormatter.formatINR(overAmount)} over planned limit';
    } else if (isApproaching) {
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.warning_amber_rounded;
      statusMessage = 'Approaching limit (${(percentage * 100).toStringAsFixed(0)}% used)';
    } else {
      statusColor = finColors.income;
      statusIcon = Icons.check_circle_outline_rounded;
      statusMessage = 'Healthy & within planned limit';
    }

    return FfCard(
      variant: FfCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Over-budget badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Text(
                    'TOTAL BUDGET POOL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (overBudgetCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: finColors.expenseContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    border: Border.all(
                      color: finColors.expense.withValues(alpha: 0.3),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: finColors.expense,
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Text(
                        '$overBudgetCount over limit',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: finColors.expense,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              else if (totalBudgetsCount > 0)
                Text(
                  '$totalBudgetsCount active ${totalBudgetsCount == 1 ? 'budget' : 'budgets'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // Main Visual: Donut Ring & Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress Ring Indicator
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: statusColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: StillwaterTypography.numSm(
                            color: theme.colorScheme.onSurface,
                          ).copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'USED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            letterSpacing: 0.8,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: StillwaterTokens.spaceLg),

              // Total Spent & Limit Hero
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.formatINR(totalSpent),
                        style: StillwaterTypography.numHero(
                          color:
                              isExceeded
                                  ? finColors.expense
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        Expanded(
                          child: Text(
                            statusMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),
          const Divider(height: 1),
          const SizedBox(height: StillwaterTokens.spaceMd),

          // 3 Metric Pillars: Budgeted, Remaining, Active
          Row(
            children: [
              Expanded(
                child: _SummaryPillar(
                  label: 'TOTAL BUDGET',
                  value: CurrencyFormatter.formatINR(totalBudgeted),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: StillwaterTokens.spaceMd,
                  ),
                  child: _SummaryPillar(
                    label: isExceeded ? 'OVER BUDGET' : 'REMAINING',
                    value:
                        isExceeded
                            ? CurrencyFormatter.formatINR(
                              totalSpent - totalBudgeted,
                            )
                            : CurrencyFormatter.formatINR(totalRemaining),
                    color: isExceeded ? finColors.expense : finColors.income,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPillar extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPillar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 10,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: StillwaterTypography.numMd(color: color),
          ),
        ),
      ],
    );
  }
}
