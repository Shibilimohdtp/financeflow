import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../services/ledger_totals.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/stillwater_tokens.dart';

/// Spent / Income / Net for exactly the transactions in the list below it.
class TransactionListSummary extends StatelessWidget {
  final LedgerTotals totals;
  final int count;
  final bool isPrivacyBlur;

  const TransactionListSummary({
    super.key,
    required this.totals,
    required this.count,
    required this.isPrivacyBlur,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceMd,
        vertical: StillwaterTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusLg),
        border: Border.all(
          color: theme.dividerColor,
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Figure(
                label: 'Spent',
                child: FfAmountText(
                  amount: -totals.spending,
                  size: FfAmountSize.sm,
                  isBlurred: isPrivacyBlur,
                  colorOverride: context.finColors.expense,
                ),
              ),
              _Figure(
                label: 'Income',
                child: FfAmountText(
                  amount: totals.income,
                  size: FfAmountSize.sm,
                  isBlurred: isPrivacyBlur,
                  colorOverride: context.finColors.income,
                ),
              ),
              _Figure(
                label: 'Net',
                child: FfAmountText(
                  amount: totals.net,
                  size: FfAmountSize.sm,
                  isBlurred: isPrivacyBlur,
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.space2Xs),
          Text(
            count == 1 ? '1 transaction' : '$count transactions',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final Widget child;

  const _Figure({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: StillwaterTokens.space3Xs),
          FittedBox(fit: BoxFit.scaleDown, child: child),
        ],
      ),
    );
  }
}
