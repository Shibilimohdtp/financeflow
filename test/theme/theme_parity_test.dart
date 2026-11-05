// Design-system slice DS-1 must not change how the app looks. These tests
// compare the generated theme with a snapshot of the hand-written theme it
// replaced (test/theme/legacy/, copied from commit 7c6e015). Delete the
// snapshot and this parity check when slice DS-8 changes Lichen on purpose.
//
// DS-3 bundled the fonts: the snapshot now names the bundled families instead
// of fetching them through google_fonts. All other text properties are
// still compared.
import 'package:financeflow/core/extensions/context_extensions.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_typography.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:financeflow/theme/stillwater_colors.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'legacy/legacy_colors.dart';
import 'legacy/legacy_theme.dart';

const _stateSets = <Set<WidgetState>>[
  {},
  {WidgetState.disabled},
  {WidgetState.pressed},
  {WidgetState.hovered},
  {WidgetState.focused},
  {WidgetState.selected},
];

Map<String, Object?> _resolveButton(ButtonStyle? s) => {
  for (final st in _stateSets) ...{
    'background $st': s?.backgroundColor?.resolve(st),
    'foreground $st': s?.foregroundColor?.resolve(st),
    'overlay $st': s?.overlayColor?.resolve(st),
    'shadow $st': s?.shadowColor?.resolve(st),
    'surfaceTint $st': s?.surfaceTintColor?.resolve(st),
    'icon $st': s?.iconColor?.resolve(st),
    'elevation $st': s?.elevation?.resolve(st),
    'padding $st': s?.padding?.resolve(st),
    'minimumSize $st': s?.minimumSize?.resolve(st),
    'side $st': s?.side?.resolve(st),
    'shape $st': s?.shape?.resolve(st),
    'textStyle $st': s?.textStyle?.resolve(st),
  },
};

Map<String, Object?> _resolveNavBar(NavigationBarThemeData n) => {
  'background': n.backgroundColor,
  'elevation': n.elevation,
  'height': n.height,
  'indicatorColor': n.indicatorColor,
  'indicatorShape': n.indicatorShape,
  for (final st in _stateSets) ...{
    'label $st': n.labelTextStyle?.resolve(st),
    'icon $st': n.iconTheme?.resolve(st),
  },
};

void _expectSameTheme(ThemeData actual, ThemeData legacy) {
  expect(actual.useMaterial3, legacy.useMaterial3);
  expect(actual.brightness, legacy.brightness);
  expect(actual.colorScheme, legacy.colorScheme);
  expect(actual.textTheme, legacy.textTheme);
  expect(actual.scaffoldBackgroundColor, legacy.scaffoldBackgroundColor);
  expect(actual.canvasColor, legacy.canvasColor);
  expect(actual.cardColor, legacy.cardColor);
  expect(actual.dividerColor, legacy.dividerColor);
  expect(actual.appBarTheme, legacy.appBarTheme);
  expect(actual.cardTheme, legacy.cardTheme);
  expect(actual.inputDecorationTheme, legacy.inputDecorationTheme);
  expect(actual.bottomSheetTheme, legacy.bottomSheetTheme);
  expect(actual.dialogTheme, legacy.dialogTheme);
  expect(actual.floatingActionButtonTheme, legacy.floatingActionButtonTheme);
  expect(actual.snackBarTheme, legacy.snackBarTheme);
  expect(actual.dividerTheme, legacy.dividerTheme);
  expect(
    _resolveNavBar(actual.navigationBarTheme),
    _resolveNavBar(legacy.navigationBarTheme),
  );
  expect(
    _resolveButton(actual.elevatedButtonTheme.style),
    _resolveButton(legacy.elevatedButtonTheme.style),
  );
  expect(
    _resolveButton(actual.outlinedButtonTheme.style),
    _resolveButton(legacy.outlinedButtonTheme.style),
  );
  expect(
    _resolveButton(actual.textButtonTheme.style),
    _resolveButton(legacy.textButtonTheme.style),
  );

  final fin = actual.extension<FfFinColors>()!;
  final legacyFin = legacy.extension<LegacyFinColors>()!;
  expect(
    [
      fin.income,
      fin.incomeContainer,
      fin.expense,
      fin.expenseContainer,
      fin.savings,
      fin.savingsContainer,
      fin.debt,
      fin.debtContainer,
      fin.investment,
      fin.investmentContainer,
      fin.transfer,
      fin.transferContainer,
    ],
    [
      legacyFin.income,
      legacyFin.incomeContainer,
      legacyFin.expense,
      legacyFin.expenseContainer,
      legacyFin.savings,
      legacyFin.savingsContainer,
      legacyFin.debt,
      legacyFin.debtContainer,
      legacyFin.investment,
      legacyFin.investmentContainer,
      legacyFin.transfer,
      legacyFin.transferContainer,
    ],
  );

  final status = actual.extension<FfStatusColors>()!;
  final legacyStatus = legacy.extension<LegacyStatusColors>()!;
  expect(
    [
      status.warning,
      status.warningContainer,
      status.info,
      status.infoContainer,
    ],
    [
      legacyStatus.warning,
      legacyStatus.warningContainer,
      legacyStatus.info,
      legacyStatus.infoContainer,
    ],
  );

  final accent = actual.extension<FfAccentColors>()!;
  final legacyAccent = legacy.extension<LegacyAccentColors>()!;
  expect(
    [accent.accent, accent.container, accent.surface],
    [legacyAccent.accent, legacyAccent.container, legacyAccent.surface],
  );

  final sec = actual.extension<FfSecColors>()!;
  final legacySec = legacy.extension<LegacySecColors>()!;
  expect(
    [sec.ink, sec.onInk, sec.verified, sec.boundary, sec.surface, sec.error],
    [
      legacySec.ink,
      legacySec.onInk,
      legacySec.verified,
      legacySec.boundary,
      legacySec.surface,
      legacySec.error,
    ],
  );
}

void main() {
  group('generated theme matches the previous hand-written theme', () {
    testWidgets('light (Daylight)', (tester) async {
      _expectSameTheme(FfTheme.light(), LegacyTheme.daylight);
      _expectSameTheme(StillwaterTheme.daylight, LegacyTheme.daylight);
    });

    testWidgets('dark (Deep Water)', (tester) async {
      _expectSameTheme(FfTheme.dark(), LegacyTheme.deepWater);
      _expectSameTheme(StillwaterTheme.deepWater, LegacyTheme.deepWater);
    });

    testWidgets('legacy colour constants keep their values', (tester) async {
      expect(StillwaterColors.lightPrimary, LegacyColors.lightPrimary);
      expect(StillwaterColors.darkScrim, LegacyColors.darkScrim);
      expect(StillwaterColors.lightIncome, LegacyColors.lightIncome);
      expect(StillwaterColors.darkExpense, LegacyColors.darkExpense);
    });
  });

  group('palettes', () {
    for (final palette in FfPalettes.all) {
      testWidgets('${palette.name} defines every colour role in both modes', (
        tester,
      ) async {
        expect(palette.light.missingRoles, isEmpty);
        expect(palette.dark.missingRoles, isEmpty);
      });
    }

    testWidgets('ids are unique and unknown ids fall back to the default', (
      tester,
    ) async {
      final ids = FfPalettes.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(FfPalettes.byId('no-such-theme'), FfPalettes.lichen);
      expect(FfPalettes.byId(null), FfPalettes.lichen);
    });
  });

  testWidgets('FfColors and FfText interpolate every role', (tester) async {
    final light = FfPalettes.lichen.light;
    final dark = FfPalettes.lichen.dark;
    final mid = light.lerp(dark, 0.5);
    for (final role in FfColorRole.values) {
      expect(mid[role], Color.lerp(light[role], dark[role], 0.5));
    }
    final lightText = FfTypography.forColors(light);
    final darkText = FfTypography.forColors(dark);
    expect(lightText.lerp(darkText, 0)[FfTextRole.body], lightText.body);
    expect(lightText.lerp(darkText, 1)[FfTextRole.body], darkText.body);
  });

  testWidgets('context.ff follows the active theme', (tester) async {
    late FfColors seen;
    Widget probe(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          seen = context.ff.color;
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(probe(FfTheme.light()));
    expect(seen.surfacePage, FfPalettes.lichen.light.surfacePage);

    await tester.pumpWidget(probe(FfTheme.dark()));
    await tester.pumpAndSettle();
    expect(seen.surfacePage, FfPalettes.lichen.dark.surfacePage);

    // A theme not built by FfTheme still gets a complete set.
    await tester.pumpWidget(probe(ThemeData(brightness: Brightness.dark)));
    await tester.pumpAndSettle();
    expect(seen.missingRoles, isEmpty);
    expect(seen.surfacePage, FfPalettes.lichen.dark.surfacePage);
  });
}
