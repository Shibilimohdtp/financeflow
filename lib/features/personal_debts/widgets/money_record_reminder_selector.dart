import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_field_label.dart';
import '../../../theme/ff.dart';

/// Inline reminder cadence selector chips (Off, On due date, 1d, 3d, 7d before).
class MoneyRecordReminderSelector extends StatelessWidget {
  const MoneyRecordReminderSelector({
    super.key,
    required this.isEnabled,
    required this.daysBefore,
    required this.onChanged,
  });

  final bool isEnabled;
  final int daysBefore;
  final void Function(bool enabled, int daysBefore) onChanged;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FfFieldLabel('Remind me'),
        const SizedBox(height: FfSpace.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FfChip(
                label: 'Off',
                isSelected: !isEnabled,
                onSelected: () => onChanged(false, daysBefore),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: 'On due date',
                isSelected: isEnabled && daysBefore == 0,
                onSelected: () => onChanged(true, 0),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: '1 day before',
                isSelected: isEnabled && daysBefore == 1,
                onSelected: () => onChanged(true, 1),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: '3 days before',
                isSelected: isEnabled && daysBefore == 3,
                onSelected: () => onChanged(true, 3),
              ),
              const SizedBox(width: FfSpace.xs),
              FfChip(
                label: '7 days before',
                isSelected: isEnabled && daysBefore == 7,
                onSelected: () => onChanged(true, 7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
