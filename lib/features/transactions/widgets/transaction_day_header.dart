import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../services/ledger_totals.dart';
import '../../../theme/ff.dart';

/// Pinned day header: "Today" on the left, that day's spending and income on
/// the right. Redesigned for Stillwater Bloom with frosted translucency on Aurora.
class TransactionDayHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final LedgerTotals totals;
  final bool isPrivacyBlur;
  final Color background;

  const TransactionDayHeaderDelegate({
    required this.label,
    required this.totals,
    required this.isPrivacyBlur,
    required this.background,
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

    // Translucent background with subtle tint and soft blur when overlapping
    final isPinned = shrinkOffset > 0 || overlapsContent;

    return Container(
      decoration: BoxDecoration(
        color:
            isPinned
                ? background.withValues(alpha: 0.92)
                : background.withValues(alpha: 0.75),
        border:
            isPinned
                ? Border(
                  bottom: BorderSide(
                    color: ff.color.borderSubtle,
                    width: FfBorderWidth.hairline,
                  ),
                )
                : null,
      ),
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
      oldDelegate.isPrivacyBlur != isPrivacyBlur ||
      oldDelegate.background != background;
}
