import 'package:flutter/material.dart';
import '../../../services/ledger_totals.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/ff.dart';

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
    // Sits straight on the canvas: big light figures, quiet labels.
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.pageMargin + FfSpace.x2s,
        vertical: FfSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Figure(
                label: 'Spent',
                child: FfAmountText(
                  amount: totals.spending,
                  size: FfAmountSize.md,
                  isBlurred: isPrivacyBlur,
                  tone: FfTone.neutral,
                  showSign: false,
                  style: FfAmountStyle.split,
                ),
              ),
              _Figure(
                label: 'Income',
                child: FfAmountText(
                  amount: totals.income,
                  size: FfAmountSize.md,
                  isBlurred: isPrivacyBlur,
                  tone: FfTone.income,
                  showSign: false,
                  style: FfAmountStyle.split,
                ),
              ),
              _Figure(
                label: 'Net',
                child: FfAmountText(
                  amount: totals.net,
                  size: FfAmountSize.md,
                  isBlurred: isPrivacyBlur,
                  style: FfAmountStyle.split,
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            count == 1 ? '1 transaction' : '$count transactions',
            style: context.ff.text.labelSm.copyWith(
              color: context.ff.color.textSecondary,
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
          Text(label, style: context.ff.text.label),
          const SizedBox(height: FfSpace.x3s),
          FittedBox(fit: BoxFit.scaleDown, child: child),
        ],
      ),
    );
  }
}
