import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_settings_index.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// Renders instant search results for query matches in Settings.
class SettingsSearchResults extends StatelessWidget {
  final List<SettingsEntry> results;
  final ValueChanged<SettingsEntry> onSelect;

  const SettingsSearchResults({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: FfSpace.x2l),
        child: FfEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No settings found',
          description:
              'Try searching for theme, pin, backup, currency, or sms.',
        ),
      );
    }

    return FfGroupedContainer(
      dividerInset: FfRowLeading.icon,
      children: [
        for (final entry in results)
          FfRow(
            key: ValueKey('setting-search-${entry.id}'),
            icon: entry.icon,
            title: entry.title,
            subtitle: entry.subtitle,
            trailing: FfBadge(
              label: entry.group.label,
              tone: _toneForGroup(entry.group),
            ),
            showChevron: true,
            onTap: () => onSelect(entry),
          ),
      ],
    );
  }

  static FfTone _toneForGroup(SettingsGroup group) {
    switch (group) {
      case SettingsGroup.appearance:
        return FfTone.neutral;
      case SettingsGroup.security:
        return FfTone.primary;
      case SettingsGroup.alerts:
        return FfTone.warning;
      case SettingsGroup.detection:
        return FfTone.accent;
      case SettingsGroup.data:
        return FfTone.savings;
      case SettingsGroup.about:
        return FfTone.neutral;
    }
  }
}
