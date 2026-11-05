import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../services/ledger_totals.dart';
import '../../../theme/stillwater_tokens.dart';

/// Pinned day header: "Today" on the left, that day's spending and income on
/// the right. Transfers and lending are excluded, as in every other total.
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

  static const double _height = 40;

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
    final theme = context.theme;
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    String money(double v) =>
        isPrivacyBlur
            ? '${CurrencyFormatter.currencySymbol} ••••'
            : CurrencyFormatter.formatAmount(v);

    final parts = <InlineSpan>[
      if (totals.spending > 0)
        TextSpan(
          text: '−${money(totals.spending)}',
          style: muted?.copyWith(color: context.finColors.expense),
        ),
      if (totals.spending > 0 && totals.income > 0)
        TextSpan(text: '  ', style: muted),
      if (totals.income > 0)
        TextSpan(
          text: '+${money(totals.income)}',
          style: muted?.copyWith(color: context.finColors.income),
        ),
    ];

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      alignment: Alignment.centerLeft,
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: muted?.copyWith(color: theme.colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (parts.isNotEmpty)
              Flexible(
                child: Text.rich(
                  TextSpan(children: parts),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
