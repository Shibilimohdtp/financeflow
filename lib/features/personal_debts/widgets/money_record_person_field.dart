import 'package:flutter/material.dart';

import '../../../models/money_record.dart';
import '../../../shared/widgets/ff_suggestion_chips.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../theme/ff.dart';
import 'money_record_collision_banner.dart';

/// Person name input with autocomplete suggestions and open debt collision warning.
class MoneyRecordPersonField extends StatelessWidget {
  const MoneyRecordPersonField({
    super.key,
    required this.controller,
    required this.type,
    required this.isEditing,
    required this.knownNames,
    required this.collisionMatch,
    required this.onSuggestionSelected,
  });

  final TextEditingController controller;
  final MoneyRecordType type;
  final bool isEditing;
  final List<String> knownNames;
  final MoneyRecord? collisionMatch;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type == MoneyRecordType.lent
              ? 'Lent to (Person Name)'
              : 'Borrowed from (Person Name)',
          style: ff.text.label.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: FfSpace.xs),
        FfTextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          hint: 'e.g. Ahmed, Sarah, Uncle John',
          icon: Icons.person_outline_rounded,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Person's name is required";
            }
            return null;
          },
        ),

        // Suggestion chips from existing records
        if (!isEditing && knownNames.isNotEmpty) ...[
          const SizedBox(height: FfSpace.xs),
          FfSuggestionChips<String>(
            items: [
              for (final name in knownNames)
                FfSuggestionChipItem(
                  value: name,
                  label: name,
                  icon: Icons.person_outline_rounded,
                ),
            ],
            selectedValue: controller.text.trim(),
            onSelected: onSuggestionSelected,
          ),
        ],

        // Collision hint banner
        if (collisionMatch != null) ...[
          const SizedBox(height: FfSpace.md),
          MoneyRecordCollisionBanner(
            collisionMatch: collisionMatch!,
            type: type,
          ),
        ],
      ],
    );
  }
}
