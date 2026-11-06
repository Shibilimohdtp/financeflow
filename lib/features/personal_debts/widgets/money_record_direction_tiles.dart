import 'package:flutter/material.dart';

import '../../../models/money_record.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Large visual selector for MoneyRecordType (Pattern E direction selector).
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
    return Row(
      children: [
        Expanded(
          child: _DirectionTile(
            type: MoneyRecordType.lent,
            title: 'I Lent Money',
            subtitle: 'They owe you',
            icon: Icons.call_made_rounded,
            tone: FfTone.income,
            isSelected: selectedType == MoneyRecordType.lent,
            onTap: () => onChanged(MoneyRecordType.lent),
          ),
        ),
        const SizedBox(width: FfSpace.md),
        Expanded(
          child: _DirectionTile(
            type: MoneyRecordType.borrowed,
            title: 'I Borrowed Money',
            subtitle: 'You owe them',
            icon: Icons.call_received_rounded,
            tone: FfTone.expense,
            isSelected: selectedType == MoneyRecordType.borrowed,
            onTap: () => onChanged(MoneyRecordType.borrowed),
          ),
        ),
      ],
    );
  }
}

class _DirectionTile extends StatelessWidget {
  const _DirectionTile({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.isSelected,
    required this.onTap,
  });

  final MoneyRecordType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final FfTone tone;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final fg = tone.foreground(ff.color);
    final bg = tone.container(ff.color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FfRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(FfSpace.md),
        decoration: BoxDecoration(
          color: isSelected ? bg : ff.color.surfaceCard,
          borderRadius: BorderRadius.circular(FfRadius.lg),
          border: Border.all(
            color: isSelected ? ff.color.actionPrimary : ff.color.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, color: fg, size: 20),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: ff.color.actionPrimary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: FfSpace.sm),
            Text(
              title,
              style: ff.text.titleSm.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: ff.color.textPrimary,
              ),
            ),
            const SizedBox(height: FfSpace.x3s),
            Text(
              subtitle,
              style: ff.text.labelSm.copyWith(color: ff.color.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
