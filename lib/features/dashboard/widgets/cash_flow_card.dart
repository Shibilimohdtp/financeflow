import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';

class CashFlowCard extends StatelessWidget {
  final MonthlyCashFlow cashFlow;
  final DateTime month;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;

  const CashFlowCard({
    super.key,
    required this.cashFlow,
    required this.month,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Month & Privacy Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormatter.formatMonthYear(month)} Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              IconButton(
                icon: Icon(
                  isPrivacyBlur
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                onPressed: onToggleBlur,
                tooltip: isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceMd),

          // Net Savings Hero
          Text('Net Savings', style: theme.textTheme.bodySmall),
          const SizedBox(height: StillwaterTokens.space2Xs),
          FfAmountText(
            amount: cashFlow.netSavings,
            size: FfAmountSize.hero,
            isBlurred: isPrivacyBlur,
            colorOverride:
                cashFlow.isPositiveSavings
                    ? context.finColors.savings
                    : context.finColors.expense,
            showSign: true,
          ),
          const SizedBox(height: StillwaterTokens.spaceLg),
          const Divider(),
          const SizedBox(height: StillwaterTokens.spaceMd),

          // Income and Expense Breakdown
          Row(
            children: [
              // Income Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 14,
                          color: context.finColors.income,
                        ),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        Text('Income', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    FfAmountText(
                      amount: cashFlow.totalIncome,
                      type: TransactionType.income,
                      size: FfAmountSize.md,
                      isBlurred: isPrivacyBlur,
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 36, width: 1, color: theme.dividerColor),
              const SizedBox(width: StillwaterTokens.spaceMd),

              // Expense Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: context.finColors.expense,
                        ),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        Text('Expenses', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    FfAmountText(
                      amount: cashFlow.totalExpense,
                      type: TransactionType.expense,
                      size: FfAmountSize.md,
                      isBlurred: isPrivacyBlur,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
