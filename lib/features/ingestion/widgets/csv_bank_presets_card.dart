import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/ff.dart';

/// Preset cards for testing CSV statement import with sample Indian bank formats.
class CsvBankPresetsCard extends StatelessWidget {
  const CsvBankPresetsCard({super.key, required this.onSelectPreset});

  final ValueChanged<String> onSelectPreset;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return FfCard(
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science_outlined,
                size: 18,
                color: ff.color.textSecondary,
              ),
              const SizedBox(width: FfSpace.xs),
              Text('Test with Sample Statements', style: ff.text.titleSm),
            ],
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            'Try realistic Indian bank formats without uploading personal files.',
            style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
          ),
          const SizedBox(height: FfSpace.md),
          Row(
            children: [
              Expanded(
                child: FfButton(
                  label: 'HDFC Sample',
                  variant: FfButtonVariant.outlined,
                  size: FfButtonSize.sm,
                  onPressed: () => onSelectPreset('hdfc'),
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfButton(
                  label: 'ICICI Sample',
                  variant: FfButtonVariant.outlined,
                  size: FfButtonSize.sm,
                  onPressed: () => onSelectPreset('icici'),
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: FfButton(
                  label: 'General CSV',
                  variant: FfButtonVariant.outlined,
                  size: FfButtonSize.sm,
                  onPressed: () => onSelectPreset('general'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
