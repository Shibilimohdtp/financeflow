import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import '../../theme/stillwater_typography.dart';
import 'ff_amount_text.dart';
import 'ff_badge.dart';
import 'ff_icon_tile.dart';

/// An entry in a financial account or person debt chronological ledger timeline.
class FfLedgerEntryRow extends StatelessWidget {
  const FfLedgerEntryRow({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.runningBalance,
    required this.isInflow,
    this.accountName,
    this.notes,
    this.allocationBadge,
    this.allocationTone = FfTone.neutral,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  /// Event title (e.g. "Money lent", "Repayment received", "Advance").
  final String title;

  /// Date of the event.
  final DateTime date;

  /// Amount of this event.
  final double amount;

  /// Running debt/account balance after this transaction.
  final double runningBalance;

  /// Whether money came in (positive inflow) or went out (outflow).
  final bool isInflow;

  /// Optional account name linked (e.g. "HDFC Salary").
  final String? accountName;

  /// Optional notes.
  final String? notes;

  /// Optional allocation status label (e.g. "Repaid", "Unpaid", "Paid ₹500").
  final String? allocationBadge;

  /// Tone for the allocation badge.
  final FfTone allocationTone;

  /// Optional explicit icon.
  final IconData? icon;

  /// Callback when tapping the row.
  final VoidCallback? onTap;

  /// Callback when deleting this entry.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final eventTone = isInflow ? FfTone.income : FfTone.neutral;
    final resolvedIcon =
        icon ??
        (isInflow ? Icons.call_received_rounded : Icons.call_made_rounded);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FfRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.md,
          vertical: FfSpace.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Event Icon Tile ───────────────────────────────────────────
            FfIconTile(icon: resolvedIcon, tone: eventTone),
            const SizedBox(width: FfSpace.md),

            // ── Title, Date, Notes & Badges ───────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: ff.text.titleSm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (allocationBadge != null) ...[
                        const SizedBox(width: FfSpace.xs),
                        FfBadge(label: allocationBadge!, tone: allocationTone),
                      ],
                    ],
                  ),
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    '${DateFormatter.formatShortDate(date)}${accountName != null ? ' · $accountName' : ''}',
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                  ),
                  if (notes != null && notes!.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      notes!,
                      style: ff.text.bodySm.copyWith(
                        fontStyle: FontStyle.italic,
                        color: ff.color.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: FfSpace.sm),

            // ── Amount & Running Balance ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FfAmountText(
                  amount: amount,
                  size: FfAmountSize.sm,
                  style: FfAmountStyle.inline,
                  tone: eventTone,
                  showSign: true,
                ),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  'Bal: ${CurrencyFormatter.format(runningBalance)}',
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                    fontFeatures: StillwaterTypography.tabularFeatures,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    tooltip: 'Delete entry',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
