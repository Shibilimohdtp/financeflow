import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_due_chip.dart';
import '../../../shared/widgets/ff_entity_preview_card.dart';
import '../../../shared/widgets/ff_monogram_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Live preview at the top of the lending sheet (sheet archetype B): an
/// [FfEntityPreviewCard] with the person's monogram (a person icon until a
/// name is typed), who owes whom in words, the due chip and the amount.
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
    final name = personName.trim();
    final hasName = name.isNotEmpty;
    final title =
        hasName ? name : (isLent ? 'Who you lent to' : 'Who lent to you');
    final sentence =
        hasName
            ? (isLent ? '$name owes you' : 'You owe $name')
            : (isLent ? 'They owe you' : 'You owe them');
    final typeTone = isLent ? FfTone.income : FfTone.expense;
    final shown = amount > 0 ? amount : 0.0;

    return FfEntityPreviewCard(
      leading: FfMonogramTile(
        // Empty until typed, so the tile shows a person icon instead of
        // initials made from placeholder text.
        name: name,
        size: FfHeroTokens.leadingSize,
        radius: FfRadius.full,
        tone: typeTone,
      ),
      title: title,
      subtitle: sentence,
      status: FfDueChip(
        dueDate: dueDate,
        settledAt: settledAt,
        isSettled: isSettled,
        compact: true,
      ),
      figureCaption: isLent ? 'Owed to you' : 'You owe',
      figure: FfAmountText(
        amount: shown,
        size: FfAmountSize.lg,
        style: FfAmountStyle.split,
        tone: typeTone,
        showSign: false,
      ),
      footer:
          accountName != null && accountName!.isNotEmpty
              ? Text(
                isLent ? 'Paid from $accountName' : 'Received in $accountName',
                style: ff.text.label.copyWith(color: ff.color.textSecondary),
              )
              : null,
      semanticLabel:
          'Preview: $sentence, ${CurrencyFormatter.formatAmount(shown)}',
    );
  }
}
