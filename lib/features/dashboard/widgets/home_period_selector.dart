import 'package:flutter/material.dart';
import '../../../shared/widgets/ff_segmented_pill.dart';
import '../../../theme/stillwater_tokens.dart';
import '../dashboard_controller.dart';

class HomePeriodSelector extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final ValueChanged<DashboardPeriod> onSelected;

  const HomePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: FfSegmentedPill<DashboardPeriod>(
        options: const [
          FfSegmentOption(value: DashboardPeriod.thisWeek, label: 'This Week'),
          FfSegmentOption(
            value: DashboardPeriod.thisMonth,
            label: 'This Month',
          ),
          FfSegmentOption(
            value: DashboardPeriod.lastMonth,
            label: 'Last Month',
          ),
          FfSegmentOption(value: DashboardPeriod.thisYear, label: 'This Year'),
          FfSegmentOption(value: DashboardPeriod.custom, label: 'Custom'),
        ],
        selectedValue: selectedPeriod,
        onSelected: onSelected,
      ),
    );
  }
}
