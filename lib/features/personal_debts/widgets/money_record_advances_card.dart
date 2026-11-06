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

class MoneyRecordAdvancesCard extends StatelessWidget {
  final MoneyRecord liveRecord;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final Map<String, String> accountMap;
  final VoidCallback onAddAdvance;

  const MoneyRecordAdvancesCard({
    super.key,
    required this.liveRecord,
    required this.advances,
    required this.repayments,
    required this.accountMap,
    required this.onAddAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = liveRecord.isFullySettled(repayments, advances: advances);
    final isLent = liveRecord.type == MoneyRecordType.lent;
    final typeColor =
        isLent ? context.ff.color.moneyIncome : context.ff.color.moneyExpense;
    final allocations = liveRecord.calculateAllocatedAdvances(
      advances: advances,
      repayments: repayments,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Advance History (${advances.isNotEmpty ? advances.length : 1})',
              style: context.ff.text.titleSm.copyWith(
                fontWeight: FontWeight.w700,
                color: context.ff.color.actionPrimary,
              ),
            ),
            if (!isSettled)
              TextButton.icon(
                onPressed: onAddAdvance,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Advance'),
              ),
          ],
        ),
        const SizedBox(height: FfSpace.xs),
        if (advances.isEmpty)
          FfCard(
            variant: FfCardVariant.standard,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: FfTint.subtle.alpha),
                    borderRadius: BorderRadius.circular(FfRadius.sm),
                  ),
                  child: Icon(liveRecord.type.icon, color: typeColor, size: 20),
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.format(liveRecord.originalAmount),
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: StillwaterTypography.tabularFeatures,
                        ),
                      ),
                      Text(
                        '${DateFormatter.formatShortDate(liveRecord.transactionDate)} · Due ${DateFormatter.formatShortDate(liveRecord.dueDate)}',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          FfCard(
            variant: FfCardVariant.standard,
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allocations.length,
              separatorBuilder: (_, __) => const FfDivider(),
              itemBuilder: (ctx, index) {
                final alloc = allocations[index];
                final item = alloc.advance;
                final accountName =
                    item.accountId != null ? accountMap[item.accountId] : null;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.x2s,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          alloc.isFullyPaid
                              ? context.ff.color.moneyIncome.withValues(
                                alpha: FfTint.subtle.alpha,
                              )
                              : typeColor.withValues(
                                alpha: FfTint.subtle.alpha,
                              ),
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: Icon(
                      alloc.isFullyPaid
                          ? Icons.check_circle_outline_rounded
                          : liveRecord.type.icon,
                      color:
                          alloc.isFullyPaid
                              ? context.ff.color.moneyIncome
                              : typeColor,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(item.amount),
                        style: context.ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: StillwaterTypography.tabularFeatures,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.x2s,
                          vertical: FfSpace.x3s,
                        ),
                        decoration: BoxDecoration(
                          color:
                              alloc.isFullyPaid
                                  ? context.ff.color.moneyIncome.withValues(
                                    alpha: FfTint.subtle.alpha,
                                  )
                                  : (alloc.allocatedRepaid > 0.001
                                      ? context.ff.color.moneyDebt.withValues(
                                        alpha: FfTint.subtle.alpha,
                                      )
                                      : context.ff.color.borderSubtle
                                          .withValues(
                                            alpha: FfTint.strong.alpha,
                                          )),
                          borderRadius: BorderRadius.circular(FfRadius.sm),
                        ),
                        child: Text(
                          alloc.isFullyPaid
                              ? 'Repaid'
                              : (alloc.allocatedRepaid > 0.001
                                  ? 'Paid ${CurrencyFormatter.format(alloc.allocatedRepaid)}'
                                  : 'Unpaid'),
                          style: context.ff.text.labelSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                alloc.isFullyPaid
                                    ? context.ff.color.moneyIncome
                                    : (alloc.allocatedRepaid > 0.001
                                        ? context.ff.color.moneyDebt
                                        : context.ff.color.secondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        '${DateFormatter.formatShortDate(item.date)} · Due ${DateFormatter.formatShortDate(item.dueDate)}${accountName != null ? ' · $accountName' : ''}',
                        style: context.ff.text.bodySm.copyWith(
                          color: context.ff.color.secondary,
                        ),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: FfSpace.x3s),
                        Text(
                          item.notes!,
                          style: context.ff.text.bodySm.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
