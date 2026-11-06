// Guardrail: every palette, in both modes, must meet WCAG contrast for every
// colour pair the app draws (FfContrastRules.all), and income/expense must
// stay distinguishable under common colour-vision deficiencies.
//
// Known gaps are listed in [knownIssues] with the slice that fixes them. The
// list only shrinks: a new failure fails the build, and so does a fixed issue
// that is still listed.
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_contrast.dart';
import 'package:financeflow/theme/palettes/ff_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';

const knownIssues = <String, String>{};

Map<String, String> _failures() {
  final failures = <String, String>{};
  for (final palette in FfPalettes.all) {
    for (final (mode, colors) in [
      ('light', palette.light),
      ('dark', palette.dark),
    ]) {
      final where = '${palette.id}/$mode';
      for (final rule in FfContrastRules.all) {
        final ratio = rule.measure(colors);
        if (ratio < rule.minimum) {
          failures['$where: ${rule.id}'] =
              '${rule.use}: ${ratio.toStringAsFixed(2)}:1, '
              'needs ${rule.minimum}:1';
        }
      }
      for (final check in FfHeroContrastRules.measure(
        palette.heroesFor(mode == 'light' ? Brightness.light : Brightness.dark),
        colors,
      )) {
        if (check.ratio < check.minimum) {
          failures['$where: ${check.id}'] =
              '${check.ratio.toStringAsFixed(2)}:1, needs ${check.minimum}:1';
        }
      }
      for (final vision in FfVision.values) {
        final d = FfContrast.deltaE(
          colors.moneyIncome,
          colors.moneyExpense,
          vision,
        );
        if (d < FfContrast.moneyPairDeltaE) {
          failures['$where: income vs expense under ${vision.name}'] =
              'ΔE ${d.toStringAsFixed(1)}, needs ${FfContrast.moneyPairDeltaE}';
        }
      }
    }
  }
  return failures;
}

void main() {
  group('contrast maths', () {
    test('matches WCAG reference values', () {
      const black = Color(0xFF000000), white = Color(0xFFFFFFFF);
      expect(FfContrast.ratio(black, white), closeTo(21, 0.01));
      expect(FfContrast.ratio(white, white), closeTo(1, 0.001));
      expect(FfContrast.ratio(white, black), FfContrast.ratio(black, white));
      // #767676 is the classic "just passes AA on white" grey.
      expect(
        FfContrast.ratio(const Color(0xFF767676), white),
        greaterThan(4.5),
      );
      expect(FfContrast.ratio(const Color(0xFF777777), white), lessThan(4.5));
    });

    test('translucent foregrounds are composited first', () {
      const white = Color(0xFFFFFFFF);
      const halfBlack = Color(0x80000000);
      final ratio = FfContrast.ratio(halfBlack, white);
      expect(ratio, greaterThan(3));
      expect(ratio, lessThan(5));
    });

    test('colour-blind simulation merges red and green but not blue', () {
      const red = Color(0xFFCC3333), green = Color(0xFF33AA33);
      const blue = Color(0xFF3366CC);
      final typical = FfContrast.deltaE(red, green);
      final deutan = FfContrast.deltaE(red, green, FfVision.deuteranopia);
      expect(deutan, lessThan(typical / 2));
      expect(
        FfContrast.deltaE(red, blue, FfVision.deuteranopia),
        greaterThan(deutan),
      );
    });
  });

  test('every rule names roles that every palette defines', () {
    for (final palette in FfPalettes.all) {
      for (final rule in FfContrastRules.all) {
        for (final colors in [palette.light, palette.dark]) {
          expect(colors.missingRoles, isNot(contains(rule.foreground)));
          expect(colors.missingRoles, isNot(contains(rule.background)));
        }
      }
      expect(palette.heroesLight.missingTones, isEmpty);
      expect(palette.heroesDark.missingTones, isEmpty);
    }
    // Disabled text is exempt from contrast rules (WCAG 1.4.3).
    expect(
      FfContrastRules.all.where(
        (r) => r.foreground == FfColorRole.textDisabled,
      ),
      isEmpty,
    );
  });

  test('palettes meet contrast and colour-vision rules', () {
    final failures = _failures();

    final unexpected = {
      for (final e in failures.entries)
        if (!knownIssues.containsKey(e.key)) e.key: e.value,
    };
    expect(
      unexpected,
      isEmpty,
      reason:
          'New accessibility failures. Fix the palette, or add a known issue '
          'with the slice that fixes it:\n'
          '${unexpected.entries.map((e) => '  ${e.key}  (${e.value})').join('\n')}',
    );

    final fixed = knownIssues.keys.where((k) => !failures.containsKey(k));
    expect(
      fixed,
      isEmpty,
      reason: 'These known issues are fixed. Remove them from knownIssues.',
    );
  });
}
