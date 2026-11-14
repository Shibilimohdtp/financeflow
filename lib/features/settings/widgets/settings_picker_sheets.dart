import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/app_currency.dart';
import '../../../models/app_settings.dart';
import '../../../shared/widgets/ff_chip.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_consequence_line.dart';
import '../../../shared/widgets/ff_field_label.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_text_field.dart';
import '../../../shared/widgets/ff_theme_preview_card.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../settings_controller.dart';

/// Opens the live theme preference bottom sheet with interactive miniature
/// preview cards for Daylight, Deep Water, and System palettes.
void showSettingsThemePicker(
  BuildContext context,
  WidgetRef ref,
  AppSettings settings,
) {
  showFfSheet(
    context,
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final currentSettings =
              ref.watch(settingsStreamProvider).value ?? settings;
          final currentPref = currentSettings.themePreference;
          final ff = context.ff;

          return FfSheet(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FfSheetHeader(
                title: 'Theme',
                subtitle: 'Changes apply right away',
              ),
              Padding(
                padding: FfSheetBody.standardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme miniature cards row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FfThemePreviewCard(
                          preference: AppThemePreference.daylight,
                          isSelected:
                              currentPref == AppThemePreference.daylight,
                          onTap: () {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setThemePreference(
                                  AppThemePreference.daylight,
                                );
                          },
                        ),
                        FfThemePreviewCard(
                          preference: AppThemePreference.deepWater,
                          isSelected:
                              currentPref == AppThemePreference.deepWater,
                          onTap: () {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setThemePreference(
                                  AppThemePreference.deepWater,
                                );
                          },
                        ),
                        FfThemePreviewCard(
                          preference: AppThemePreference.system,
                          isSelected: currentPref == AppThemePreference.system,
                          onTap: () {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setThemePreference(AppThemePreference.system);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: FfSpace.lg),

                    // Contextual descriptive copy
                    Container(
                      padding: const EdgeInsets.all(FfSpace.sm),
                      decoration: ShapeDecoration(
                        color: ff.color.surfacePage,
                        shape: FfShape.of(FfRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: ff.color.textSecondary,
                          ),
                          const SizedBox(width: FfSpace.xs),
                          Expanded(
                            child: Text(
                              _themeDescription(currentPref),
                              style: ff.text.labelSm.copyWith(
                                color: ff.color.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FfSpace.sm),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String _themeDescription(AppThemePreference pref) {
  switch (pref) {
    case AppThemePreference.daylight:
      return 'Daylight: Calm lichen canvas with ink controls and lime highlights.';
    case AppThemePreference.deepWater:
      return 'Deep Water: Dark surface canvas with subtle aurora washes and soft contrast.';
    case AppThemePreference.system:
      return 'System: Automatically adapts between Daylight and Deep Water based on device settings.';
  }
}

/// Opens the searchable currency selection bottom sheet.
void showSettingsCurrencyPicker(
  BuildContext context,
  WidgetRef ref,
  AppSettings settings,
) {
  showFfSheet(
    context,
    builder: (ctx) {
      return _CurrencyPickerSheet(initialSettings: settings);
    },
  );
}

class _CurrencyPickerSheet extends ConsumerStatefulWidget {
  final AppSettings initialSettings;

  const _CurrencyPickerSheet({required this.initialSettings});

  @override
  ConsumerState<_CurrencyPickerSheet> createState() =>
      _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends ConsumerState<_CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final currentSettings =
        ref.watch(settingsStreamProvider).value ?? widget.initialSettings;
    final selected = AppCurrency.fromCode(currentSettings.currencyCode);

    final allCurrencies = AppCurrency.values;
    final filtered =
        _filterQuery.trim().isEmpty
            ? allCurrencies
            : allCurrencies.where((c) {
              final query = _filterQuery.toLowerCase();
              return c.code.toLowerCase().contains(query) ||
                  c.displayName.toLowerCase().contains(query) ||
                  c.symbol.toLowerCase().contains(query);
            }).toList();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FfSheetHeader(
          title: 'Currency',
          subtitle: 'How amounts are shown; nothing is converted',
        ),

        // Search Input
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FfSheetTokens.paddingH,
            FfSpace.xs,
            FfSheetTokens.paddingH,
            FfSpace.xs,
          ),
          child: FfTextField.search(
            controller: _searchController,
            hint: 'Search currency (INR, USD, Euro...)',
            onChanged: (val) => setState(() => _filterQuery = val),
          ),
        ),

        // Quick Preset Chips
        if (_filterQuery.trim().isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSheetTokens.paddingH,
              vertical: FfSpace.xs,
            ),
            child: Row(
              children: [
                const FfFieldLabel('Popular'),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          allCurrencies.map((c) {
                            final isSel = c == selected;
                            return Padding(
                              padding: const EdgeInsets.only(right: FfSpace.xs),
                              child: FfChip(
                                label: '${c.symbol} ${c.code}',
                                isSelected: isSel,
                                onSelected: () {
                                  _selectCurrency(c, currentSettings);
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FfSpace.xs),
        ],

        // Currencies List
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: FfSheetTokens.paddingH,
              vertical: FfSpace.xs,
            ),
            children: [
              if (filtered.isNotEmpty)
                FfGroupedContainer(
                  children: [
                    for (final currency in filtered)
                      FfRow(
                        key: ValueKey('currency-${currency.code}'),
                        leading: SizedBox(
                          width: FfRowTokens.iconTile,
                          child: Center(
                            child: Text(
                              currency.symbol,
                              style: ff.text.titleLg,
                            ),
                          ),
                        ),
                        title: currency.displayName,
                        subtitle:
                            '${currency.code} · ${currency.usesIndianGrouping ? 'Lakh/Crore grouping' : 'Thousands grouping'}',
                        selected: currency == selected,
                        onTap: () => _selectCurrency(currency, currentSettings),
                      ),
                  ],
                ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.xl),
                  child: Center(
                    child: Text(
                      'No matching currencies found.',
                      style: ff.text.bodySm.copyWith(
                        color: ff.color.textSecondary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: FfSpace.sm),
            ],
          ),
        ),

        // Bottom Disclaimer
        const Padding(
          padding: EdgeInsets.fromLTRB(
            FfSheetTokens.paddingH,
            FfSpace.xs,
            FfSheetTokens.paddingH,
            FfSpace.md,
          ),
          child: FfConsequenceLine(
            text:
                'Switching currency changes the symbol and grouping only. Amounts are not converted.',
            icon: Icons.info_outline_rounded,
            tone: FfTone.neutral,
          ),
        ),
      ],
    );
  }

  void _selectCurrency(AppCurrency currency, AppSettings currentSettings) {
    Navigator.of(context).pop();
    if (currency.code != currentSettings.currencyCode) {
      ref
          .read(settingsControllerProvider.notifier)
          .updateSettings(
            currentSettings.copyWith(currencyCode: currency.code),
          );
    }
  }
}
