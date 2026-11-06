import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_progress.dart';
import '../../../shared/widgets/ff_toast.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/stillwater_typography.dart';
import '../money_records_controller.dart';

class MoneyRecordDetailHero extends StatelessWidget {
  final MoneyRecord liveRecord;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final double remaining;
  final VoidCallback onRecordRepayment;
  final VoidCallback onAddAdvance;

  const MoneyRecordDetailHero({
    super.key,
    required this.liveRecord,
    required this.advances,
    required this.repayments,
    required this.remaining,
    required this.onRecordRepayment,
    required this.onAddAdvance,
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
    final totalAdvanced = liveRecord.calculateTotalAdvanced(advances);
    final totalRepaid = liveRecord.calculateTotalRepaid(repayments);
    final isSettled = liveRecord.isFullySettled(repayments, advances: advances);
    final isOverdue = liveRecord.isOverdue(
      repayments: repayments,
      advances: advances,
    );
    final isDueSoon = liveRecord.isDueSoon(
      repayments: repayments,
      advances: advances,
    );
    final status = liveRecord.calculateStatus(repayments, advances: advances);
    final effectiveDueDate = liveRecord.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );
    final progress =
        totalAdvanced > 0 ? (totalRepaid / totalAdvanced).clamp(0.0, 1.0) : 0.0;

    final isLent = liveRecord.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.ff.color.moneyIncome : context.ff.color.moneyExpense;

    final statusTone = _toneForStatus(status);
    final statusBg = statusTone.container(context.ff.color);
    final statusFg = statusTone.foreground(context.ff.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Status Banner ──────────────────────────────────────────────
        if (isSettled)
          Container(
            margin: const EdgeInsets.only(bottom: FfSpace.md),
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: BoxDecoration(
              color: context.ff.color.moneyIncome.withValues(
                alpha: FfTint.subtle.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.md),
              border: Border.all(
                color: context.ff.color.moneyIncome.withValues(
                  alpha: FfTint.strong.alpha,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: context.ff.color.moneyIncome,
                  size: 20,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Text(
                    'Fully Settled · No balance remaining',
                    style: context.ff.text.body.copyWith(
                      color: context.ff.color.moneyIncome,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (isOverdue)
          Container(
            margin: const EdgeInsets.only(bottom: FfSpace.md),
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: BoxDecoration(
              color: context.ff.color.moneyExpense.withValues(
                alpha: FfTint.subtle.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.md),
              border: Border.all(
                color: context.ff.color.moneyExpense.withValues(
                  alpha: FfTint.strong.alpha,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: context.ff.color.moneyExpense,
                  size: 20,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Text(
                    'Overdue · Repayment was expected by ${DateFormatter.formatShortDate(effectiveDueDate)}',
                    style: context.ff.text.body.copyWith(
                      color: context.ff.color.moneyExpense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (isDueSoon)
          Container(
            margin: const EdgeInsets.only(bottom: FfSpace.md),
            padding: const EdgeInsets.all(FfSpace.md),
            decoration: BoxDecoration(
              color: context.ff.color.moneyDebt.withValues(
                alpha: FfTint.subtle.alpha,
              ),
              borderRadius: BorderRadius.circular(FfRadius.md),
              border: Border.all(
                color: context.ff.color.moneyDebt.withValues(
                  alpha: FfTint.strong.alpha,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: context.ff.color.moneyDebt,
                  size: 20,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Text(
                    'Due Soon · Expected by ${DateFormatter.formatShortDate(effectiveDueDate)}',
                    style: context.ff.text.body.copyWith(
                      color: context.ff.color.moneyDebt,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── 2. Hero Summary Card ──────────────────────────────────────────
        FfCard(
          variant: FfCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Direction badge & status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.sm,
                      vertical: FfSpace.x2s,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: FfTint.subtle.alpha),
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(liveRecord.type.icon, size: 14, color: typeColor),
                        const SizedBox(width: FfSpace.x2s),
                        Text(
                          liveRecord.type.directionLabel,
                          style: context.ff.text.labelSm.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FfSpace.sm,
                      vertical: FfSpace.x2s,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(FfRadius.sm),
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

              const SizedBox(height: FfSpace.lg),

              // Remaining balance
              Text(
                'REMAINING BALANCE',
                style: context.ff.text.labelSm.copyWith(
                  color: context.ff.color.secondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: FfSpace.x2s),
              Text(
                CurrencyFormatter.format(remaining),
                style: context.ff.text.headline.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSettled ? context.ff.color.moneyIncome : typeColor,
                  fontFeatures: StillwaterTypography.tabularFeatures,
                ),
              ),

              const SizedBox(height: FfSpace.md),

              // Progress Bar
              FfProgressBar(
                value: progress,
                color: isSettled ? context.ff.color.moneyIncome : typeColor,
                size: FfProgressSize.lg,
              ),

              const SizedBox(height: FfSpace.md),

              // Metrics row: Total Advanced vs Total Repaid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Advanced',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(totalAdvanced),
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: StillwaterTypography.tabularFeatures,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Repaid',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.format(totalRepaid)} (${(progress * 100).toInt()}%)',
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.ff.color.moneyIncome,
                          fontFeatures: StillwaterTypography.tabularFeatures,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: FfSpace.lg),

        // ── 3. Quick Actions ──────────────────────────────────────────────
        Row(
          children: [
            if (!isSettled) ...[
              Expanded(
                child: FfButton(
                  label: 'Record Repayment',
                  leadingIcon: const Icon(Icons.payments_outlined, size: 18),
                  variant: FfButtonVariant.primary,
                  onPressed: onRecordRepayment,
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfButton(
                  label: isLent ? 'Lend More' : 'Borrow More',
                  leadingIcon: const Icon(Icons.add_circle_outline, size: 18),
                  variant: FfButtonVariant.secondary,
                  onPressed: onAddAdvance,
                ),
              ),
            ] else ...[
              Expanded(
                child: Consumer(
                  builder:
                      (context, ref, _) => FfButton(
                        label: 'Mark as Unsettled',
                        leadingIcon: const Icon(Icons.replay_rounded, size: 18),
                        variant: FfButtonVariant.outlined,
                        onPressed: () async {
                          final controller = ref.read(
                            moneyRecordsControllerProvider.notifier,
                          );
                          await controller.markRecordUnsettled(liveRecord.id);
                          if (context.mounted) {
                            FfToast.show(
                              context,
                              message: 'Record status restored.',
                            );
                          }
                        },
                      ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
