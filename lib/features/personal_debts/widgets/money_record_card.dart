import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/stillwater_typography.dart';

class MoneyRecordCard extends StatelessWidget {
  final MoneyRecord record;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final VoidCallback onTap;

  const MoneyRecordCard({
    super.key,
    required this.record,
    this.advances = const [],
    required this.repayments,
    required this.onTap,
  });

  static FfTone _toneForStatus(MoneyRecordStatus status) {
    switch (status) {
      case MoneyRecordStatus.active:
        return FfTone.primary;
      case MoneyRecordStatus.dueSoon:
        return FfTone.warning;
      case MoneyRecordStatus.overdue:
        return FfTone.error;
      case MoneyRecordStatus.partiallyPaid:
        return FfTone.transfer;
      case MoneyRecordStatus.settled:
        return FfTone.income;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLent = record.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.ff.color.moneyIncome : context.ff.color.moneyExpense;
    final totalAdvanced = record.calculateTotalAdvanced(advances);
    final totalRepaid = record.calculateTotalRepaid(repayments);
    final remaining = record.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    final isSettled = record.isFullySettled(repayments, advances: advances);
    final isOverdue = record.isOverdue(
      repayments: repayments,
      advances: advances,
    );
    final isDueSoon = record.isDueSoon(
      repayments: repayments,
      advances: advances,
    );
    final status = record.calculateStatus(repayments, advances: advances);
    final effectiveDueDate = record.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );
    final progress =
        totalAdvanced > 0 ? (totalRepaid / totalAdvanced).clamp(0.0, 1.0) : 0.0;
    final advanceCount = advances.isNotEmpty ? advances.length : 1;

    final statusTone = _toneForStatus(status);
    final statusBg = statusTone.container(context.ff.color);
    final statusFg = statusTone.foreground(context.ff.color);

    return FfCard(
      variant: FfCardVariant.standard,
      onTap: onTap,
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Person name, direction badge, advance count, remaining amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle with icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: FfTint.subtle.alpha),
                  borderRadius: BorderRadius.circular(FfRadius.md),
                ),
                child: Icon(record.type.icon, color: typeColor, size: 20),
              ),
              const SizedBox(width: FfSpace.md),

              // Person name, direction subtitle, and advance count pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            record.personName,
                            style: context.ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (advanceCount > 1) ...[
                          const SizedBox(width: FfSpace.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.x2s,
                              vertical: FfSpace.x3s,
                            ),
                            decoration: BoxDecoration(
                              color: context.ff.color.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(FfRadius.sm),
                            ),
                            child: Text(
                              '$advanceCount advances',
                              style: context.ff.text.labelSm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.ff.color.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Row(
                      children: [
                        Text(
                          isLent ? 'Lent' : 'Borrowed',
                          style: context.ff.text.bodySm.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' · ${DateFormatter.formatShortDate(record.transactionDate)}',
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance & total advanced amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: context.ff.text.title.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          isSettled ? context.ff.color.moneyIncome : typeColor,
                      fontFeatures: StillwaterTypography.tabularFeatures,
                    ),
                  ),
                  if (totalRepaid > 0.001 || totalAdvanced > remaining)
                    Text(
                      'Total: ${CurrencyFormatter.format(totalAdvanced)}',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                        fontFeatures: StillwaterTypography.tabularFeatures,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Row 2: Progress bar (if partially repaid)
          if (totalRepaid > 0.001 && !isSettled) ...[
            const SizedBox(height: FfSpace.sm),
            FfProgressBar(
              value: progress,
              color: typeColor,
              size: FfProgressSize.sm,
            ),
          ],

          const SizedBox(height: FfSpace.sm),
          const FfDivider(),
          const SizedBox(height: FfSpace.sm),

          // Row 3: Due date with relative badge & status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Due Date indicator
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : (isDueSoon
                            ? Icons.schedule_rounded
                            : Icons.calendar_today_outlined),
                    size: 14,
                    color:
                        isOverdue
                            ? context.ff.color.moneyExpense
                            : (isDueSoon
                                ? context.ff.color.moneyDebt
                                : context.ff.color.secondary),
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  Text(
                    isSettled
                        ? 'Settled'
                        : (isOverdue
                            ? 'Overdue (${DateFormatter.formatShortDate(effectiveDueDate)})'
                            : 'Due ${DateFormatter.formatShortDate(effectiveDueDate)}'),
                    style: context.ff.text.bodySm.copyWith(
                      color:
                          isOverdue
                              ? context.ff.color.moneyExpense
                              : (isDueSoon
                                  ? context.ff.color.moneyDebt
                                  : context.ff.color.secondary),
                      fontWeight:
                          (isOverdue || isDueSoon)
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.sm,
                  vertical: FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(FfRadius.full),
                ),
                child: Text(
                  status.displayName,
                  style: context.ff.text.labelSm.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
