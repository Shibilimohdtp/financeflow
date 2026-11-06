import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/money_advance.dart';
import '../../../models/money_record.dart';
import '../../../models/money_repayment.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_due_chip.dart';
import '../../../shared/widgets/ff_monogram_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Stillwater Bloom person card for Lending & Borrowing list.
///
/// Features:
/// - Deterministic monogram avatar (`FfMonogramTile`)
/// - Person name with counterparty hint ("Ahmed Khan owes you" / "You owe Sarah")
/// - Advance count and earliest date badge ("2 advances")
/// - Remaining balance in light split numerals (`FfAmountText`)
/// - Due status badge (`FfDueChip`)
/// - Quick payback action button on the trailing edge
class LendingPersonCard extends StatelessWidget {
  const LendingPersonCard({
    super.key,
    required this.record,
    this.advances = const [],
    this.repayments = const [],
    required this.onTap,
    this.onPayback,
  });

  final MoneyRecord record;
  final List<MoneyAdvance> advances;
  final List<MoneyRepayment> repayments;
  final VoidCallback onTap;
  final VoidCallback? onPayback;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isLent = record.type == MoneyRecordType.lent;
    final isSettled = record.isFullySettled(repayments, advances: advances);
    final remaining = record.calculateRemainingAmount(
      repayments,
      advances: advances,
    );
    final totalRepaid = record.calculateTotalRepaid(repayments);
    final totalAdvanced = record.calculateTotalAdvanced(advances);
    final effectiveDueDate = record.calculateEffectiveDueDate(
      advances: advances,
      repayments: repayments,
    );

    final typeTone = isLent ? FfTone.income : FfTone.expense;
    final relationshipSentence = isLent ? 'Owes you' : 'You owe';

    final hasMultipleAdvances = advances.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.pageMargin,
        vertical: FfSpace.x2s,
      ),
      child: FfCard(
        density: FfDensity.comfortable,
        variant: FfCardVariant.standard,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Name & Subtitle + Due Chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FfMonogramTile(
                  name: record.personName,
                  size: 44,
                  tone: isSettled ? FfTone.neutral : typeTone,
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              record.personName,
                              style: ff.text.titleSm.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration:
                                    isSettled
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    isSettled
                                        ? ff.color.textSecondary
                                        : ff.color.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasMultipleAdvances) ...[
                            const SizedBox(width: FfSpace.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FfSpace.xs,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: ff.color.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  FfRadius.full,
                                ),
                              ),
                              child: Text(
                                '${advances.length} advances',
                                style: ff.text.labelSm.copyWith(
                                  color: ff.color.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        isSettled
                            ? 'Settled'
                            : '$relationshipSentence · ${DateFormatter.formatShortDate(record.transactionDate)}',
                        style: ff.text.bodySm.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FfSpace.sm),
                FfDueChip(
                  dueDate: effectiveDueDate,
                  settledAt: record.settledAt,
                  isSettled: isSettled,
                  compact: true,
                ),
              ],
            ),

            const SizedBox(height: FfSpace.md),

            // Bottom Row: Remaining amount + Quick action pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSettled && totalRepaid > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FfSpace.x3s),
                        child: Text(
                          '${CurrencyFormatter.format(totalRepaid)} of ${CurrencyFormatter.format(totalAdvanced)} repaid',
                          style: ff.text.labelSm.copyWith(
                            color: ff.color.textTertiary,
                          ),
                        ),
                      ),
                    FfAmountText(
                      amount: isSettled ? totalAdvanced : remaining,
                      size: FfAmountSize.md,
                      style: FfAmountStyle.split,
                      tone:
                          isSettled
                              ? FfTone.neutral
                              : (isLent ? FfTone.income : FfTone.expense),
                    ),
                  ],
                ),
                if (!isSettled && onPayback != null)
                  FfButton(
                    label: isLent ? 'Record payback' : 'Pay back',
                    size: FfButtonSize.sm,
                    variant: FfButtonVariant.outlined,
                    onPressed: onPayback,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
