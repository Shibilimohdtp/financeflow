import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/charts/ff_bar_chart.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';

class CashFlowCard extends StatelessWidget {
  final MonthlyCashFlow cashFlow;
  final DateTime month;
  final String? periodLabel;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onPickMonth;
  final VoidCallback? onOpenAnalytics;
  final List<BarChartItem>? chartItems;

  const CashFlowCard({
    super.key,
    required this.cashFlow,
    required this.month,
    this.periodLabel,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onPickMonth,
    this.onOpenAnalytics,
    this.chartItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;
    final displayPeriod = periodLabel ?? DateFormatter.formatMonthYear(month);

    return Semantics(
      container: true,
      label:
          isPrivacyBlur
              ? 'Monthly cash flow hidden for privacy'
              : 'Cash flow for $displayPeriod: Net savings ${cashFlow.netSavings}, Income ${cashFlow.totalIncome}, Expenses ${cashFlow.totalExpense}',
      child: Container(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
          border: Border.all(
            color: theme.dividerColor,
            width: StillwaterTokens.borderWidthHairline,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Period & Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onPickMonth,
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusSm,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: StillwaterTokens.space3Xs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayPeriod,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onPickMonth != null) ...[
                            const SizedBox(width: StillwaterTokens.space3Xs),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onPreviousMonth != null)
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        tooltip: 'Previous period',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onPreviousMonth,
                      ),
                    if (onNextMonth != null)
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        tooltip: 'Next period',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onNextMonth,
                      ),
                    if (onOpenAnalytics != null)
                      TextButton(
                        onPressed: onOpenAnalytics,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Analytics'),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),

            // Net Flow metric
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Savings',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.space3Xs),
                FfAmountText(
                  amount: cashFlow.netSavings,
                  size: FfAmountSize.lg,
                  isBlurred: isPrivacyBlur,
                  colorOverride:
                      cashFlow.isPositiveSavings
                          ? finColors.savings
                          : finColors.expense,
                  showSign: true,
                ),
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceMd),
            const Divider(),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Income and Expense Two-Column Strip
            Row(
              children: [
                // Income Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceSm,
                      vertical: StillwaterTokens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: finColors.income.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 13,
                              color: finColors.income,
                            ),
                            const SizedBox(width: StillwaterTokens.space3Xs),
                            Flexible(
                              child: Text(
                                'Income',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        FfAmountText(
                          amount: cashFlow.totalIncome,
                          type: TransactionType.income,
                          size: FfAmountSize.md,
                          isBlurred: isPrivacyBlur,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: StillwaterTokens.spaceSm),

                // Expense Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: StillwaterTokens.spaceSm,
                      vertical: StillwaterTokens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: finColors.expense.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 13,
                              color: finColors.expense,
                            ),
                            const SizedBox(width: StillwaterTokens.space3Xs),
                            Flexible(
                              child: Text(
                                'Expenses',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        FfAmountText(
                          amount: cashFlow.totalExpense,
                          type: TransactionType.expense,
                          size: FfAmountSize.md,
                          isBlurred: isPrivacyBlur,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Optional Chart Section if chart items exist
            if (chartItems != null && chartItems!.isNotEmpty) ...[
              const SizedBox(height: StillwaterTokens.spaceLg),
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: finColors.expense,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Text(
                        'Expenses',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: finColors.income,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Text(
                        'Income',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: StillwaterTokens.spaceXs),
              FfBarChart(
                items: chartItems!,
                height: 120,
                semanticsSummary: 'Cash flow activity chart for $displayPeriod',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

