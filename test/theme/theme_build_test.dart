// FfTheme.build wiring, palettes, shapes and effects.
//
// Until DS-B1 this file compared the generated theme with a snapshot of the
// hand-written theme (DS-1 parity). DS-B1 changed Lichen on purpose (the
// Stillwater Bloom style), so the snapshot was retired as planned. These
// tests now check that every Material component theme is driven by the
// semantic roles and shape tokens, so one token change restyles the app.
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_hero.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_typography.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:financeflow/theme/stillwater_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'legacy/legacy_colors.dart';

void main() {
  group('theme builder', () {
    for (final palette in FfPalettes.all) {
      for (final brightness in Brightness.values) {
        final c = palette.colorsFor(brightness);
        final name = '${palette.id}/${brightness.name}';

        testWidgets('$name: colours come from the semantic roles', (
          tester,
        ) async {
          final theme = FfTheme.build(palette, brightness);
          expect(theme.brightness, brightness);
          expect(theme.colorScheme.primary, c.actionPrimary);
          expect(theme.colorScheme.onPrimary, c.onActionPrimary);
          expect(theme.colorScheme.surface, c.surfaceCard);
          expect(theme.scaffoldBackgroundColor, c.surfacePage);
          expect(theme.bottomSheetTheme.backgroundColor, c.surfaceSheet);
          expect(theme.snackBarTheme.backgroundColor, c.surfaceToast);
          expect(theme.snackBarTheme.actionTextColor, c.toastAction);
          expect(theme.extension<FfColors>(), c);
          expect(theme.extension<FfText>(), isNotNull);
          expect(theme.extension<FfHeroes>(), palette.heroesFor(brightness));
        });

        testWidgets('$name: actions are ink pills', (tester) async {
          final theme = FfTheme.build(palette, brightness);
          for (final style in [
            theme.elevatedButtonTheme.style,
            theme.filledButtonTheme.style,
          ]) {
            expect(style!.backgroundColor!.resolve({}), c.actionPrimary);
            expect(style.foregroundColor!.resolve({}), c.onActionPrimary);
            expect(style.shape!.resolve({}), isA<StadiumBorder>());
          }
          expect(
            theme.outlinedButtonTheme.style!.shape!.resolve({}),
            isA<StadiumBorder>(),
          );
          expect(theme.floatingActionButtonTheme.shape, isA<StadiumBorder>());
          expect(
            theme.floatingActionButtonTheme.backgroundColor,
            c.actionPrimary,
          );
          expect(theme.chipTheme.selectedColor, c.actionPrimary);
        });

        testWidgets('$name: surfaces use the shape token', (tester) async {
          final theme = FfTheme.build(palette, brightness);
          expect(
            theme.cardTheme.shape,
            FfShape.of(
              FfCardTokens.radius,
              side: BorderSide(
                color: c.borderSubtle,
                width: FfCardTokens.borderWidth,
              ),
            ),
          );
          expect(theme.dialogTheme.shape, FfShape.of(FfDialogTokens.radius));
          expect(
            theme.datePickerTheme.shape,
            FfShape.of(FfDialogTokens.radius),
          );
          expect(theme.snackBarTheme.shape, FfShape.of(FfToastTokens.radius));
        });
      }
    }

    testWidgets('legacy colour constants keep their values', (tester) async {
      // StillwaterColors is frozen for the budgets files until DS-9.
      expect(StillwaterColors.lightPrimary, LegacyColors.lightPrimary);
      expect(StillwaterColors.darkScrim, LegacyColors.darkScrim);
      expect(StillwaterColors.lightIncome, LegacyColors.lightIncome);
      expect(StillwaterColors.darkExpense, LegacyColors.darkExpense);
    });
  });

  group('palettes', () {
    for (final palette in FfPalettes.all) {
      testWidgets('${palette.name} defines every role and hero in both modes', (
        tester,
      ) async {
        expect(palette.light.missingRoles, isEmpty);
        expect(palette.dark.missingRoles, isEmpty);
        expect(palette.heroesLight.missingTones, isEmpty);
        expect(palette.heroesDark.missingTones, isEmpty);
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

  group('shape', () {
    test('full radius is a stadium, others follow the shape style', () {
      expect(FfShape.of(FfRadius.full), isA<StadiumBorder>());
      final card = FfShape.of(FfRadius.lg);
      expect(card, isA<FfSquircleBorder>());
      expect((card as FfSquircleBorder).radius, FfRadius.lg);
      expect(card.smoothing, FfShape.smoothing);
    });

    test('squircle fills its rect and stays inside it', () {
      const rect = Rect.fromLTWH(0, 0, 200, 120);
      final path = FfSquircleBorder.squirclePath(rect, FfRadius.xl, 0.6);
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(rect.left, 0.01));
      expect(bounds.top, closeTo(rect.top, 0.01));
      expect(bounds.right, closeTo(rect.right, 0.01));
      expect(bounds.bottom, closeTo(rect.bottom, 0.01));
      expect(path.contains(rect.center), isTrue);
      // The corner is cut away; the mid-edges are not.
      expect(path.contains(const Offset(1, 1)), isFalse);
      expect(path.contains(const Offset(100, 1)), isTrue);
      expect(path.contains(const Offset(1, 60)), isTrue);
    });

    test('smoothing 0 matches a circular corner', () {
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      final squircle = FfSquircleBorder.squirclePath(rect, 20, 0);
      final rounded =
          Path()..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(20)),
          );
      for (final p in const [
        Offset(3, 3),
        Offset(6, 6),
        Offset(7, 7),
        Offset(20, 1),
        Offset(1, 20),
        Offset(97, 97),
      ]) {
        expect(squircle.contains(p), rounded.contains(p), reason: '$p');
      }
    });

    test('tiny and empty rects never throw', () {
      expect(
        FfSquircleBorder.squirclePath(
          const Rect.fromLTWH(0, 0, 10, 4),
          44,
          1,
        ).getBounds().width,
        closeTo(10, 0.01),
      );
      expect(
        FfSquircleBorder.squirclePath(Rect.zero, 44, 0.6).getBounds(),
        Rect.zero,
      );
    });

    test('borders lerp and scale', () {
      const a = FfSquircleBorder(radius: 10);
      const b = FfSquircleBorder(radius: 30);
      expect((b.lerpFrom(a, 0.5)! as FfSquircleBorder).radius, 20);
      expect((a.scale(2) as FfSquircleBorder).radius, 20);
      expect(a.copyWith(radius: 5).radius, 5);
    });
  });

  group('effects', () {
    Future<FfEffects> effectsWith(
      WidgetTester tester, {
      bool disableAnimations = false,
      FfEffects? scope,
    }) async {
      late FfEffects seen;
      Widget child = Builder(
        builder: (context) {
          seen = FfEffects.of(context);
          return const SizedBox();
        },
      );
      if (scope != null) child = FfEffectsScope(effects: scope, child: child);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: child,
        ),
      );
      return seen;
    }

    testWidgets('full by default, reduced by platform or setting', (
      tester,
    ) async {
      expect(await effectsWith(tester), FfEffects.full);
      expect(
        await effectsWith(tester, disableAnimations: true),
        FfEffects.reduced,
      );
      expect(
        await effectsWith(tester, scope: FfEffects.reduced),
        FfEffects.reduced,
      );
      // A "full" setting cannot override the platform asking for less.
      expect(
        await effectsWith(
          tester,
          disableAnimations: true,
          scope: FfEffects.full,
        ),
        FfEffects.reduced,
      );
    });
  });

  testWidgets('FfColors, FfText and FfHeroes interpolate', (tester) async {
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
    final heroes = FfPalettes.lichen.heroesLight.lerp(
      FfPalettes.lichen.heroesDark,
      1,
    );
    expect(
      heroes[FfHeroTone.moss].deep,
      FfPalettes.lichen.heroesDark[FfHeroTone.moss].deep,
    );
  });

  testWidgets('context.ff follows the active theme', (tester) async {
    late FfThemeData seen;
    Widget probe(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) {
          seen = context.ff;
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(probe(FfTheme.light()));
    expect(seen.color.surfacePage, FfPalettes.lichen.light.surfacePage);
    expect(
      seen.hero(FfHeroTone.rose),
      FfPalettes.lichen.heroesLight[FfHeroTone.rose],
    );

    await tester.pumpWidget(probe(FfTheme.dark()));
    await tester.pumpAndSettle();
    expect(seen.color.surfacePage, FfPalettes.lichen.dark.surfacePage);

    // A theme not built by FfTheme still gets a complete set.
    await tester.pumpWidget(probe(ThemeData(brightness: Brightness.dark)));
    await tester.pumpAndSettle();
    expect(seen.color.missingRoles, isEmpty);
    expect(seen.color.surfacePage, FfPalettes.lichen.dark.surfacePage);
    expect(seen.heroes.missingTones, isEmpty);
  });
}
