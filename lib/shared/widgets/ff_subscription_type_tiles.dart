import 'package:flutter/material.dart';

import 'ff_choice_tiles.dart';

/// Predefined generic subscription types for rapid creation.
enum SubscriptionCategoryType {
  streaming('Streaming', Icons.movie_outlined, 'Entertainment', [
    'Netflix',
    'Prime Video',
    'Hotstar',
    'Disney+',
    'YouTube Premium',
  ]),
  music('Music', Icons.music_note_outlined, 'Entertainment', [
    'Spotify',
    'Apple Music',
    'YouTube Music',
    'Gaana',
    'Wynk',
  ]),
  cloud('Cloud & apps', Icons.cloud_outlined, 'Cloud and apps', [
    'Google One',
    'iCloud',
    'Dropbox',
    'Microsoft 365',
    'Notion',
  ]),
  gaming('Gaming', Icons.sports_esports_outlined, 'Entertainment', [
    'PlayStation Plus',
    'Xbox Game Pass',
    'Nintendo Switch Online',
    'Steam',
  ]),
  news('News & books', Icons.menu_book_outlined, 'Education', [
    'Kindle Unlimited',
    'Medium',
    'Substack',
    'The Ken',
    'Audible',
  ]),
  fitness('Fitness', Icons.fitness_center_rounded, 'Fitness', [
    'Cult Fit',
    'Gold\'s Gym',
    'Anytime Fitness',
    'Strava',
  ]),
  utilities('Utilities', Icons.bolt_outlined, 'Utilities', [
    'Electricity',
    'Piped Gas',
    'Water',
  ]),
  broadband('Broadband', Icons.wifi_rounded, 'Utilities', [
    'Airtel Broadband',
    'JioFiber',
    'ACT Fibernet',
    'Vi Postpaid',
  ]),
  insurance('Insurance', Icons.security_outlined, 'Insurance', [
    'Health Insurance',
    'Term Life',
    'Vehicle Insurance',
  ]),
  other('Other', Icons.repeat_rounded, 'Subscriptions', []);

  const SubscriptionCategoryType(
    this.label,
    this.icon,
    this.defaultCategory,
    this.popularMerchants,
  );

  final String label;
  final IconData icon;
  final String defaultCategory;
  final List<String> popularMerchants;
}

/// The service kind choice: an [FfChoiceTiles] grid, three to a row, so
/// every kind is visible and no label is cut off ("Cloud & apps").
class FfSubscriptionTypeTiles extends StatelessWidget {
  const FfSubscriptionTypeTiles({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final SubscriptionCategoryType? selectedType;
  final ValueChanged<SubscriptionCategoryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return FfChoiceTiles<SubscriptionCategoryType>(
      selected: selectedType,
      onChanged: onChanged,
      options: [
        for (final type in SubscriptionCategoryType.values)
          FfChoiceTile(
            value: type,
            icon: type.icon,
            label: type.label,
            semanticLabel: '${type.label} subscription type',
          ),
      ],
    );
  }
}
