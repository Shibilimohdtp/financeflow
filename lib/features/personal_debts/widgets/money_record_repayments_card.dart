import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff.dart';
import '../../../theme/stillwater_typography.dart';

class MoneyRecordRepaymentsCard extends StatelessWidget {
  final MoneyRecord liveRecord;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final double remaining;
  final VoidCallback onAddRepayment;
  final void Function(MoneyRepayment repayment) onDeleteRepayment;

  const MoneyRecordRepaymentsCard({
    super.key,
    required this.liveRecord,
    required this.advances,
    required this.repayments,
    required this.remaining,
    required this.onAddRepayment,
    required this.onDeleteRepayment,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = liveRecord.isFullySettled(repayments, advances: advances);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repayment History (${repayments.length})',
              style: context.ff.text.titleSm.copyWith(
                fontWeight: FontWeight.w700,
                color: context.ff.color.actionPrimary,
              ),
            ),
            if (repayments.isNotEmpty && !isSettled)
              TextButton.icon(
                onPressed: onAddRepayment,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Repayment'),
              ),
          ],
        ),
        const SizedBox(height: FfSpace.xs),
        if (repayments.isEmpty)
          FfCard(
            variant: FfCardVariant.standard,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: FfSpace.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 36,
                    color: context.ff.color.secondary.withValues(
                      alpha: FfOpacity.half,
                    ),
                  ),
                  const SizedBox(height: FfSpace.sm),
                  Text(
                    'No repayments recorded yet',
                    style: context.ff.text.body.copyWith(
                      color: context.ff.color.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: FfSpace.x2s),
                  Text(
                    'Tap "Record Repayment" above when a payment is made.',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.secondary.withValues(
                        alpha: FfOpacity.high,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          FfCard(
            variant: FfCardVariant.standard,
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: repayments.length,
              separatorBuilder: (_, __) => const FfDivider(),
              itemBuilder: (ctx, index) {
                final item = repayments[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.x2s,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.ff.color.moneyIncome.withValues(
                        alpha: FfTint.subtle.alpha,
                      ),
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: context.ff.color.moneyIncome,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    CurrencyFormatter.format(item.amount),
                    style: context.ff.text.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: StillwaterTypography.tabularFeatures,
                    ),
                  ),
                  subtitle: Text(
                    '${DateFormatter.formatShortDate(item.repaymentDate)}${item.notes != null ? ' · ${item.notes}' : ''}',
                    style: context.ff.text.bodySm.copyWith(
                      color: context.ff.color.secondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Delete repayment',
                    onPressed: () => onDeleteRepayment(item),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
