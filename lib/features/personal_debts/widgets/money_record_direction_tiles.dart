import 'package:flutter/material.dart';

import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_choice_tiles.dart';

/// Lent or borrowed: two [FfChoiceTiles] side by side. Direction is told by
/// an arrow and words ("I lent money", "I borrowed money"), never by colour.
class MoneyRecordDirectionTiles extends StatelessWidget {
  const MoneyRecordDirectionTiles({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final MoneyRecordType selectedType;
  final ValueChanged<MoneyRecordType> onChanged;

  @override
  Widget build(BuildContext context) {
    return FfChoiceTiles<MoneyRecordType>(
      columns: 2,
      selected: selectedType,
      onChanged: onChanged,
      options: const [
        FfChoiceTile(
          value: MoneyRecordType.lent,
          icon: Icons.call_made_rounded,
          label: 'I lent money',
          semanticLabel: 'I lent money, they owe you',
        ),
        FfChoiceTile(
          value: MoneyRecordType.borrowed,
          icon: Icons.call_received_rounded,
          label: 'I borrowed money',
          semanticLabel: 'I borrowed money, you owe them',
        ),
      ],
    );
  }
}
