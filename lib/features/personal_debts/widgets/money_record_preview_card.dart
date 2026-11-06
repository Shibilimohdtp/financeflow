import 'package:flutter/material.dart';

import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_due_chip.dart';
import '../../../shared/widgets/ff_monogram_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Live squircle preview card for Add/Edit Money Record sheet (Pattern E).
///
/// Dynamically updates as the user enters the person name, amount, direction,
/// and due date, giving real-time feedback on how the record will appear.
class MoneyRecordPreviewCard extends StatelessWidget {
  const MoneyRecordPreviewCard({
    super.key,
    required this.personName,
    required this.type,
    required this.amount,
    required this.dueDate,
    this.accountName,
    this.settledAt,
    this.isSettled = false,
  });

  final String personName;
  final MoneyRecordType type;
  final double amount;
  final DateTime dueDate;
  final String? accountName;
  final DateTime? settledAt;
  final bool isSettled;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isLent = type == MoneyRecordType.lent;
    final displayName =
        personName.trim().isEmpty ? 'Friend / Person' : personName.trim();
    final directionSentence =
        isLent ? '$displayName owes you' : 'You owe $displayName';
    final typeTone = isLent ? FfTone.income : FfTone.expense;

    return FfCard(
      density: FfDensity.comfortable,
      variant: FfCardVariant.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Monogram avatar + Direction Sentence + Due Chip
          Row(
            children: [
              FfMonogramTile(name: displayName, size: 40, tone: typeTone),
              const SizedBox(width: FfSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: ff.text.titleSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      directionSentence,
                      style: ff.text.bodySm.copyWith(
                        color: ff.color.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FfDueChip(
                dueDate: dueDate,
                settledAt: settledAt,
                isSettled: isSettled,
                compact: true,
              ),
            ],
          ),

          const SizedBox(height: FfSpace.md),

          // Row 2: Amount display + Account tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              FfAmountText(
                amount: amount > 0 ? amount : 0.0,
                size: FfAmountSize.lg,
                style: FfAmountStyle.split,
                tone: typeTone,
                showSign: false,
              ),
              if (accountName != null && accountName!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.sm,
                    vertical: FfSpace.x3s,
                  ),
                  decoration: BoxDecoration(
                    color: ff.color.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(FfRadius.full),
                  ),
                  child: Text(
                    accountName!,
                    style: ff.text.labelSm.copyWith(
                      color: ff.color.textSecondary,
                      fontWeight: FontWeight.w600,
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
