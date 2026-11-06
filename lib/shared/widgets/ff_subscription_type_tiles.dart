import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';

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

/// Horizontal selector for [SubscriptionCategoryType] with >=48 dp targets.
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
    final ff = context.ff;

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: SubscriptionCategoryType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: FfSpace.xs),
        itemBuilder: (context, index) {
          final type = SubscriptionCategoryType.values[index];
          final isSelected = selectedType == type;

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${type.label} subscription type',
            child: InkWell(
              borderRadius: BorderRadius.circular(FfRadius.md),
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(type);
              },
              child: AnimatedContainer(
                duration: FfMotion.fast,
                curve: FfMotion.emphasized,
                width: 76,
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.xs,
                  vertical: FfSpace.xs,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? ff.color.actionPrimary
                          : ff.color.surfaceCard,
                  borderRadius: BorderRadius.circular(FfRadius.md),
                  border: Border.all(
                    color:
                        isSelected
                            ? ff.color.actionPrimary
                            : ff.color.borderControl,
                    width: isSelected ? 1.5 : FfBorderWidth.hairline,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          type.icon,
                          size: 22,
                          color:
                              isSelected
                                  ? ff.color.onActionPrimary
                                  : ff.color.textSecondary,
                        ),
                        if (isSelected)
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: ff.color.spark,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 9,
                                color: ff.color.onSpark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.x2s),
                    Text(
                      type.label,
                      style: ff.text.labelSm.copyWith(
                        color:
                            isSelected
                                ? ff.color.onActionPrimary
                                : ff.color.textPrimary,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
