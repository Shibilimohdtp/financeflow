import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_chip.dart';
import '../../../theme/ff.dart';

/// Horizontal filter chips for the review queue.
class ReviewFilterChips extends StatelessWidget {
  const ReviewFilterChips({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.duplicatesCount,
    required this.uncertainCount,
    required this.errorsCount,
    required this.onFilterSelected,
  });

  final String selectedFilter;
  final int totalCount;
  final int duplicatesCount;
  final int uncertainCount;
  final int errorsCount;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FfChip(
            label: 'All ($totalCount)',
            isSelected: selectedFilter == 'all',
            onSelected: () => onFilterSelected('all'),
          ),
          const SizedBox(width: FfSpace.xs),
          FfChip(
            label: 'Duplicates ($duplicatesCount)',
            isSelected: selectedFilter == 'duplicates',
            onSelected: () => onFilterSelected('duplicates'),
          ),
          const SizedBox(width: FfSpace.xs),
          FfChip(
            label: 'Uncertain ($uncertainCount)',
            isSelected: selectedFilter == 'uncertain',
            onSelected: () => onFilterSelected('uncertain'),
          ),
          const SizedBox(width: FfSpace.xs),
          FfChip(
            label: 'Invalid ($errorsCount)',
            isSelected: selectedFilter == 'errors',
            onSelected: () => onFilterSelected('errors'),
          ),
        ],
      ),
    );
  }
}
