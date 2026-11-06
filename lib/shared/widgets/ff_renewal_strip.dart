import 'package:flutter/material.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/subscription.dart';
import '../../theme/ff.dart';
import 'ff_amount_text.dart';
import 'ff_card.dart';

/// The Next 30 Days renewal rhythm strip.
///
/// A compact horizontal timeline showing on which days renewals fall and
/// how much each day costs. Built entirely with lightweight Flutter widgets
/// from already-loaded stream data (no continuous animation, no blur).
class FfRenewalStrip extends StatelessWidget {
  const FfRenewalStrip({
    super.key,
    required this.subscriptions,
    this.referenceDate,
    this.onDayTap,
    this.onSubscriptionTap,
    this.isPrivacyBlur = false,
  });

  /// All tracked subscriptions.
  final List<Subscription> subscriptions;

  /// Anchor date for the 30-day window (defaults to today).
  final DateTime? referenceDate;

  /// Callback when a renewal day is tapped.
  final ValueChanged<DateTime>? onDayTap;

  /// Callback when a specific subscription on a renewal day is selected.
  final ValueChanged<Subscription>? onSubscriptionTap;

  /// Whether amounts are masked for privacy.
  final bool isPrivacyBlur;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group active subscriptions by day index (0..29)
    final Map<int, List<Subscription>> subsByDay = {};
    final activeSubs = subscriptions.where(
      (s) => s.status == SubscriptionStatus.active,
    );

    double total30DayAmount = 0.0;
    int total30DayRenewals = 0;

    for (final sub in activeSubs) {
      final renewal = DateTime(
        sub.nextRenewalDate.year,
        sub.nextRenewalDate.month,
        sub.nextRenewalDate.day,
      );
      final diff = renewal.difference(today).inDays;

      if (diff >= 0 && diff < 30) {
        subsByDay.putIfAbsent(diff, () => []).add(sub);
        total30DayAmount += sub.amount;
        total30DayRenewals++;
      }
    }

    return FfCard(
      density: FfDensity.compact,
      padding: const EdgeInsets.fromLTRB(
        FfSpace.md,
        FfSpace.sm,
        FfSpace.md,
        FfSpace.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: ff.color.textSecondary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Text(
                    'Next 30 days',
                    style: ff.text.titleSm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.x2s,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: ff.color.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(FfRadius.full),
                    ),
                    child: Text(
                      '$total30DayRenewals',
                      style: ff.text.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ff.color.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              FfAmountText(
                amount: total30DayAmount,
                size: FfAmountSize.sm,
                showSign: false,
                isBlurred: isPrivacyBlur,
              ),
            ],
          ),

          const SizedBox(height: FfSpace.sm),

          // 30-day horizontal track
          if (total30DayRenewals == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: ff.color.textTertiary,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      'No renewals due in the next 30 days',
                      style: ff.text.bodySm.copyWith(
                        color: ff.color.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 30,
                separatorBuilder: (_, __) => const SizedBox(width: FfSpace.x2s),
                itemBuilder: (context, index) {
                  final date = today.add(Duration(days: index));
                  final subs = subsByDay[index] ?? const [];
                  final hasRenewals = subs.isNotEmpty;
                  final isToday = index == 0;
                  final weekday = _weekdays[(date.weekday - 1) % 7];

                  final dayTotal = subs.fold<double>(
                    0.0,
                    (sum, s) => sum + s.amount,
                  );

                  final semanticLabel =
                      hasRenewals
                          ? '${date.day} ${_monthName(date.month)}, ${subs.length} renewal${subs.length > 1 ? 's' : ''}: ${subs.map((s) => s.merchant).join(', ')}, ${CurrencyFormatter.formatAmount(dayTotal)}'
                          : '${date.day} ${_monthName(date.month)}, no renewals';

                  final formattedDayAmount =
                      isPrivacyBlur
                          ? '•••'
                          : (dayTotal >= 10000
                              ? '${CurrencyFormatter.currencySymbol}${(dayTotal / 1000).toStringAsFixed(dayTotal % 1000 == 0 ? 0 : 1)}k'
                              : CurrencyFormatter.formatAmount(dayTotal));

                  return Semantics(
                    label: semanticLabel,
                    button: hasRenewals,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(FfRadius.md),
                      onTap:
                          hasRenewals
                              ? () {
                                if (onDayTap != null) onDayTap!(date);
                                if (onSubscriptionTap != null &&
                                    subs.isNotEmpty) {
                                  onSubscriptionTap!(subs.first);
                                }
                              }
                              : null,
                      child: Container(
                        width: 48,
                        padding: const EdgeInsets.symmetric(
                          vertical: FfSpace.x3s,
                          horizontal: FfSpace.x3s,
                        ),
                        decoration: BoxDecoration(
                          color:
                              hasRenewals
                                  ? (isToday
                                      ? ff.color.actionPrimaryContainer
                                      : ff.color.surfaceContainerLow)
                                  : (isToday
                                      ? ff.color.surfaceContainerLowest
                                      : Colors.transparent),
                          borderRadius: BorderRadius.circular(FfRadius.md),
                          border: Border.all(
                            color:
                                isToday
                                    ? ff.color.actionPrimary
                                    : (hasRenewals
                                        ? ff.color.borderControl
                                        : Colors.transparent),
                            width: isToday ? 1.5 : FfBorderWidth.hairline,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekday,
                              style: ff.text.labelSm.copyWith(
                                color:
                                    isToday
                                        ? ff.color.actionPrimary
                                        : ff.color.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${date.day}',
                              style: ff.text.titleSm.copyWith(
                                fontWeight:
                                    isToday ? FontWeight.w700 : FontWeight.w500,
                                color:
                                    isToday
                                        ? ff.color.actionPrimary
                                        : ff.color.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (hasRenewals)
                              Text(
                                formattedDayAmount,
                                style: ff.text.labelSm.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isToday
                                          ? ff.color.actionPrimary
                                          : ff.color.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      isToday
                                          ? ff.color.spark
                                          : ff.color.borderSubtle,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
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
    return months[(month - 1).clamp(0, 11)];
  }
}
