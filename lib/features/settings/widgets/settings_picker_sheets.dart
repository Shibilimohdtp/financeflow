import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/app_currency.dart';
import '../../../models/app_settings.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../theme/ff.dart';
import '../settings_controller.dart';

/// Opens the theme preference bottom sheet.
void showSettingsThemePicker(
  BuildContext context,
  WidgetRef ref,
  AppSettings settings,
) {
  showFfSheet(
    context,
    builder: (ctx) {
      return FfSheet(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FfSheetHeader(
            title: 'Theme',
            subtitle: 'Choose your visual preference',
          ),
          const FfDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...AppThemePreference.values.map((pref) {
                  final isSelected = settings.themePreference == pref;
                  return FfRow(
                    icon:
                        pref == AppThemePreference.system
                            ? Icons.brightness_auto_outlined
                            : pref == AppThemePreference.daylight
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                    title: pref.displayName,
                    selected: isSelected,
                    onTap: () {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setThemePreference(pref);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
                const SizedBox(height: FfSpace.sm),
              ],
            ),
          ),
        ],
      );
    },
  );
}

/// Opens the currency selection bottom sheet.
void showSettingsCurrencyPicker(
  BuildContext context,
  WidgetRef ref,
  AppSettings settings,
) {
  final selected = AppCurrency.fromCode(settings.currencyCode);
  showFfSheet(
    context,
    builder: (ctx) {
      return FfSheet(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FfSheetHeader(
            title: 'Currency',
            subtitle: 'Changes how amounts are shown. No conversion.',
          ),
          const FfDivider(),
          for (final currency in AppCurrency.values)
            FfRow(
              key: ValueKey('currency-${currency.code}'),
              leading: SizedBox(
                width: FfRowTokens.iconTile,
                child: Center(
                  child: Text(currency.symbol, style: context.ff.text.title),
                ),
              ),
              title: currency.displayName,
              subtitle: currency.code,
              selected: currency == selected,
              onTap: () {
                Navigator.of(ctx).pop();
                if (currency != selected) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(
                        settings.copyWith(currencyCode: currency.code),
                      );
                }
              },
            ),
        ],
      );
    },
  );
}
