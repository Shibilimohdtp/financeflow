import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../services/ledger_totals.dart';
import '../../../theme/ff.dart';

/// Day header: "Today" on the left, that day's spending and income on the
/// right. Scrolls with the list and has no background of its own.
class TransactionDayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final LedgerTotals totals;
  final bool isPrivacyBlur;

  const TransactionDayHeaderDelegate({
    required this.label,
    required this.totals,
    required this.isPrivacyBlur,
  });

  static const double _height = 42;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final ff = context.ff;
    final muted = ff.text.label.copyWith(
      color: ff.color.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    String money(double v) =>
        isPrivacyBlur
            ? '${CurrencyFormatter.currencySymbol} ••••'
            : CurrencyFormatter.formatAmount(v);

    final parts = <InlineSpan>[
      if (totals.spending > 0)
        TextSpan(text: '−${money(totals.spending)}', style: muted),
      if (totals.spending > 0 && totals.income > 0)
        TextSpan(text: '  ', style: muted),
      if (totals.income > 0)
        TextSpan(
          text: '+${money(totals.income)}',
          style: muted.copyWith(
            color: ff.color.moneyIncome,
            fontWeight: FontWeight.w600,
          ),
        ),
    ];

    // No fill and no rule: the header sits on the page like every other
    // line of the list, so the body has one continuous background.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      alignment: Alignment.centerLeft,
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: ff.text.titleSm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ff.color.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (parts.isNotEmpty)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.xs,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    shape: FfShape.of(FfRadius.full),
                    color: ff.color.tint(ff.color.textPrimary, FfTint.faint),
                  ),
                  child: Text.rich(
                    TextSpan(children: parts),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(TransactionDayHeaderDelegate oldDelegate) =>
      oldDelegate.label != label ||
      oldDelegate.totals.spending != totals.spending ||
      oldDelegate.totals.income != totals.income ||
      oldDelegate.isPrivacyBlur != isPrivacyBlur;
}
