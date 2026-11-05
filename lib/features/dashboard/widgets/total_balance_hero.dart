import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../theme/stillwater_typography.dart';
import '../../../theme/ff.dart';

/// A compact account-balance summary. Period cash flow belongs in its own card.
class TotalBalanceHero extends StatelessWidget {
  final double totalBalance;
  final int activeAccountsCount;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;
  final VoidCallback? onManageAccounts;

  /// Shown as a call to action when there are no active accounts.
  final VoidCallback? onAddAccount;

  const TotalBalanceHero({
    super.key,
    required this.totalBalance,
    required this.activeAccountsCount,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.onManageAccounts,
    this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final accountLabel =
        activeAccountsCount == 1
            ? '1 account'
            : '$activeAccountsCount accounts';
    final amount =
        isPrivacyBlur
            ? '${CurrencyFormatter.currencySymbol} ••••••'
            : CurrencyFormatter.format(totalBalance);

    return Container(
      key: const ValueKey('total-balance-card'),
      margin: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.md,
        vertical: FfSpace.sm,
      ),
      decoration: BoxDecoration(
        color: context.ff.color.surfaceCard,
        borderRadius: BorderRadius.circular(FfRadius.lg),
        border: Border.all(
          color: context.ff.color.borderSubtle,
          width: FfBorderWidth.hairline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Balance',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: FfSpace.xs),
              Flexible(
                child:
                    onManageAccounts == null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: FfSpace.md,
                          ),
                          child: Text(
                            accountLabel,
                            style: context.ff.text.bodySm,
                          ),
                        )
                        : TextButton(
                          key: const ValueKey('balance-accounts'),
                          onPressed: onManageAccounts,
                          style: TextButton.styleFrom(
                            foregroundColor: context.ff.color.textSecondary,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.only(left: FfSpace.xs),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  accountLabel,
                                  style: context.ff.text.bodySm.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: FfSpace.x2s),
                              const Icon(Icons.chevron_right_rounded, size: 16),
                            ],
                          ),
                        ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  key: const ValueKey('balance-amount'),
                  liveRegion: true,
                  label:
                      isPrivacyBlur
                          ? 'Total balance hidden for privacy'
                          : 'Total Balance: $amount',
                  excludeSemantics: true,
                  // Fit unusually large balances without abbreviating or truncating
                  // the amount. Assistive technology always receives the full value.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      amount,
                      style: StillwaterTypography.numHero(
                        color:
                            !isPrivacyBlur && totalBalance < 0
                                ? context.ff.color.moneyExpense
                                : context.ff.color.textPrimary,
                      ).copyWith(
                        fontSize: 34,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: FfSpace.xs),
              IconButton(
                key: const ValueKey('balance-privacy'),
                tooltip: isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
                onPressed: onToggleBlur,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                icon: Icon(
                  isPrivacyBlur
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: context.ff.color.textSecondary,
                ),
              ),
            ],
          ),
          if (activeAccountsCount == 0 && onAddAccount != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('balance-add-account'),
                onPressed: onAddAccount,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add your first account'),
              ),
            ),
        ],
      ),
    );
  }
}
