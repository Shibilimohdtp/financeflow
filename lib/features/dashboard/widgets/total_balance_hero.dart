import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_colors.dart';
import '../../../theme/stillwater_tokens.dart';


class TotalBalanceHero extends StatelessWidget {
  final double totalBalance;
  final int activeAccountsCount;
  final MonthlyCashFlow? monthlyCashFlow;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;
  final VoidCallback? onManageAccounts;

  const TotalBalanceHero({
    super.key,
    required this.totalBalance,
    required this.activeAccountsCount,
    this.monthlyCashFlow,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.onManageAccounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;


    return Semantics(
      container: true,
      label:
          isPrivacyBlur
              ? 'Total balance hidden for privacy'
              : 'Total Balance: $totalBalance across $activeAccountsCount accounts',
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: StillwaterTokens.spaceLg,
        ),
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusXl),
          border: Border.all(
            color: theme.dividerColor,
            width: StillwaterTokens.borderWidthHairline,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Label, Account Count, and Privacy Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: StillwaterTokens.spaceXs,
                    runSpacing: StillwaterTokens.space3Xs,
                    children: [
                      Text(
                        'Total Balance',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      InkWell(
                        onTap: onManageAccounts,
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: StillwaterTokens.spaceXs,
                            vertical: StillwaterTokens.space3Xs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              StillwaterTokens.radiusFull,
                            ),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: StillwaterTokens.borderWidthHairline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 11,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: StillwaterTokens.space3Xs),
                              Text(
                                activeAccountsCount == 1
                                    ? '1 account'
                                    : '$activeAccountsCount accounts',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label:
                      isPrivacyBlur
                          ? 'Show financial amounts'
                          : 'Hide financial amounts for privacy',
                  child: IconButton(
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
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: StillwaterTokens.touchTargetMin,
                      minHeight: StillwaterTokens.touchTargetMin,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: StillwaterTokens.spaceXs),

            // Large Hero Balance
            FfAmountText(
              amount: totalBalance,
              size: FfAmountSize.hero,
              isBlurred: isPrivacyBlur,
              showSign: false,
              colorOverride: theme.colorScheme.onSurface,
            ),

            // Financial overview chips: Income | Expenses | Savings Rate
            if (monthlyCashFlow != null) ...[
              const SizedBox(height: StillwaterTokens.spaceMd),
              Wrap(
                spacing: StillwaterTokens.space2Xs,
                runSpacing: StillwaterTokens.space2Xs,
                children: [
                  // Income chip
                  _FinancialChip(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: monthlyCashFlow!.totalIncome,
                    color: finColors.income,
                    isPrivacyBlur: isPrivacyBlur,
                    theme: theme,
                  ),
                  // Expenses chip
                  _FinancialChip(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expenses',
                    amount: monthlyCashFlow!.totalExpense,
                    color: finColors.expense,
                    isPrivacyBlur: isPrivacyBlur,
                    theme: theme,
                  ),
                  // Net savings / savings rate chip
                  _SavingsRateChip(
                    cashFlow: monthlyCashFlow!,
                    finColors: finColors,
                    isPrivacyBlur: isPrivacyBlur,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private chip widgets
// ---------------------------------------------------------------------------

/// Tinted pill chip showing a financial figure (income or expense).
class _FinancialChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool isPrivacyBlur;
  final ThemeData theme;

  const _FinancialChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isPrivacyBlur,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceSm,
        vertical: StillwaterTokens.space3Xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: StillwaterTokens.space3Xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: StillwaterTokens.space3Xs),
          FfAmountText(
            amount: amount,
            size: FfAmountSize.sm,
            isBlurred: isPrivacyBlur,
            showSign: false,
            colorOverride: color,
          ),
        ],
      ),
    );
  }
}

/// Tinted pill chip showing net savings and savings rate.
class _SavingsRateChip extends StatelessWidget {
  final MonthlyCashFlow cashFlow;
  final FfFinColors finColors;
  final bool isPrivacyBlur;
  final ThemeData theme;

  const _SavingsRateChip({
    required this.cashFlow,
    required this.finColors,
    required this.isPrivacyBlur,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = cashFlow.isPositiveSavings;
    final color = isPositive ? finColors.savings : finColors.expense;
    final savingsRate =
        cashFlow.totalIncome > 0
            ? (cashFlow.netSavings / cashFlow.totalIncome * 100)
                .clamp(-999, 100)
                .toStringAsFixed(0)
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceSm,
        vertical: StillwaterTokens.space3Xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.savings_outlined : Icons.trending_down_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: StillwaterTokens.space3Xs),
          Text(
            isPositive ? 'Saved' : 'Over-spent',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (savingsRate != null && !isPrivacyBlur) ...[
            const SizedBox(width: StillwaterTokens.space3Xs),
            Text(
              '$savingsRate%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
