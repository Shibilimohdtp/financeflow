import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/subscription.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_banner.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_data_viz.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../transactions/transaction_detail_screen.dart';

/// 12-month visual payment history and recent transaction drill-down for
/// [SubscriptionDetailScreen] in Stillwater Bloom.
class SubscriptionPaymentHistorySection extends StatelessWidget {
  final Subscription subscription;
  final List<Transaction> payments;
  final ({double totalPaid, int count, DateTime? lastPaymentDate})
  paymentTotals;
  final bool isPrivacyBlur;

  const SubscriptionPaymentHistorySection({
    super.key,
    required this.subscription,
    required this.payments,
    required this.paymentTotals,
    this.isPrivacyBlur = false,
  });

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List<FfMonthCell> _build12MonthCells() {
    final now = DateTime.now();
    final cells = <FfMonthCell>[];

    // Build the last 12 months leading up to current month
    for (var i = 11; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final label = _monthNames[monthDate.month - 1];

      // Check if a payment exists in this month
      final hasPayment = payments.any(
        (tx) =>
            tx.date.year == monthDate.year && tx.date.month == monthDate.month,
      );

      if (hasPayment) {
        cells.add(FfMonthCell(label: label, status: FfMonthStatus.paid));
        continue;
      }

      // Check if month precedes subscription creation
      final createdMonth = DateTime(
        subscription.createdAt.year,
        subscription.createdAt.month,
        1,
      );
      if (monthDate.isBefore(createdMonth)) {
        cells.add(FfMonthCell(label: label, status: FfMonthStatus.none));
        continue;
      }

      // Current month check
      if (monthDate.year == now.year && monthDate.month == now.month) {
        if (subscription.status == SubscriptionStatus.active) {
          if (subscription.nextRenewalDate.isAfter(now) ||
              subscription.nextRenewalDate.day == now.day) {
            cells.add(
              FfMonthCell(
                label: label,
                status: FfMonthStatus.due,
                note: '${subscription.nextRenewalDate.day}',
              ),
            );
          } else {
            cells.add(FfMonthCell(label: label, status: FfMonthStatus.missed));
          }
        } else {
          cells.add(FfMonthCell(label: label, status: FfMonthStatus.none));
        }
        continue;
      }

      // Past month within subscription tenure with no payment recorded
      cells.add(FfMonthCell(label: label, status: FfMonthStatus.missed));
    }

    return cells;
  }

  String? _detectPriceChange() {
    if (payments.length < 2) return null;
    final sorted = [...payments]..sort((a, b) => a.date.compareTo(b.date));
    final latest = sorted.last;
    final previous = sorted[sorted.length - 2];

    if (latest.amount != previous.amount) {
      final diff = latest.amount - previous.amount;
      final sign = diff > 0 ? '+' : '';
      return 'Price changed from ${CurrencyFormatter.formatAmount(previous.amount)} to ${CurrencyFormatter.formatAmount(latest.amount)} ($sign${CurrencyFormatter.formatAmount(diff)}) on ${DateFormatter.formatShortDate(latest.date)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final monthCells = _build12MonthCells();
    final priceChangeNote = _detectPriceChange();
    final recentDisplay = payments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FfSectionHeader(
          title: 'Payment History',
          count: payments.isEmpty ? null : payments.length,
        ),
        const SizedBox(height: FfSpace.xs),

        // ── 1. 12-Month Grid Card ───────────────────────────────────────
        FfCard(
          padding: const EdgeInsets.all(FfSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAST 12 MONTHS',
                        style: ff.text.labelSm.copyWith(
                          color: ff.color.textSecondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        '${paymentTotals.count} ${paymentTotals.count == 1 ? 'payment' : 'payments'}',
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  if (paymentTotals.lastPaymentDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Last paid',
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          DateFormatter.formatShortDate(
                            paymentTotals.lastPaymentDate!,
                          ),
                          style: ff.text.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: FfSpace.md),
              FfMonthGrid(months: monthCells, columns: 6),
            ],
          ),
        ),

        // ── 2. Price Change Note Banner (if detected) ───────────────────
        if (priceChangeNote != null) ...[
          const SizedBox(height: FfSpace.sm),
          FfBanner(
            message: priceChangeNote,
            tone: FfBannerTone.info,
            icon: Icons.trending_up_rounded,
          ),
        ],

        const SizedBox(height: FfSpace.md),

        // ── 3. Recent Payments List ─────────────────────────────────────
        if (recentDisplay.isEmpty)
          FfCard(
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: ff.color.textTertiary,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Text(
                    'No payments recorded yet. Use "Record payment" to link a transaction.',
                    style: ff.text.bodySm.copyWith(
                      color: ff.color.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          FfGroupedContainer(
            children:
                recentDisplay.map((tx) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => TransactionDetailScreen(transaction: tx),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.md,
                        vertical: FfSpace.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormatter.formatShortDate(tx.date),
                                  style: ff.text.titleSm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (tx.notes != null && tx.notes!.isNotEmpty)
                                  Text(
                                    tx.notes!,
                                    style: ff.text.bodySm.copyWith(
                                      color: ff.color.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          FfAmountText(
                            amount: tx.amount,
                            type: TransactionType.expense,
                            size: FfAmountSize.sm,
                            isBlurred: isPrivacyBlur,
                          ),
                          const SizedBox(width: FfSpace.x2s),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: ff.color.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
}
