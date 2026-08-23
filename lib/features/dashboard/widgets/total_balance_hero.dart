import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../services/balance_calculator.dart';
import '../../../shared/widgets/ff_amount_text.dart';
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

    final hasPositiveSavings =
        monthlyCashFlow != null && monthlyCashFlow!.netSavings >= 0;
    final netSavingsAmount = monthlyCashFlow?.netSavings.abs() ?? 0.0;

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

            // Contextual Cash Flow Subtitle
            if (monthlyCashFlow != null) ...[
              const SizedBox(height: StillwaterTokens.spaceSm),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: StillwaterTokens.space3Xs,
                runSpacing: StillwaterTokens.space3Xs,
                children: [
                  Container(
                    padding: const EdgeInsets.all(StillwaterTokens.space3Xs),
                    decoration: BoxDecoration(
                      color: (hasPositiveSavings
                              ? finColors.income
                              : finColors.expense)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPositiveSavings
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color:
                          hasPositiveSavings
                              ? finColors.income
                              : finColors.expense,
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    hasPositiveSavings ? 'Net flow: +' : 'Net flow: -',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  FfAmountText(
                    amount: netSavingsAmount,
                    size: FfAmountSize.sm,
                    isBlurred: isPrivacyBlur,
                    showSign: false,
                    colorOverride:
                        hasPositiveSavings
                            ? finColors.income
                            : finColors.expense,
                  ),
                  Text(
                    'this month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
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
