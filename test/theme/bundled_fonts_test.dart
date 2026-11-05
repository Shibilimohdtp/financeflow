// DS-3: fonts are bundled, so text never needs the network and release
// builds render the same faces as debug builds.
import 'dart:io';

import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/ff_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pubspec bundles every weight the type scale uses', () async {
    final manifest = await readFontManifest();
    expect(manifest[FfFonts.manropeFamily], [
      'assets/fonts/Manrope-Regular.ttf',
      'assets/fonts/Manrope-Medium.ttf',
      'assets/fonts/Manrope-SemiBold.ttf',
      'assets/fonts/Manrope-Bold.ttf',
      'assets/fonts/Manrope-ExtraBold.ttf',
    ]);
    expect(manifest[FfFonts.frauncesFamily], [
      'assets/fonts/Fraunces-SemiBold.ttf',
      'assets/fonts/Fraunces-Bold.ttf',
    ]);

    final text = FfTypography.build(
      primary: const Color(0xFF000000),
      secondary: const Color(0xFF000000),
    );
    for (final role in FfTextRole.values) {
      final style = text[role];
      final family = style.fontFamily;
      expect([FfFonts.manropeFamily, FfFonts.frauncesFamily], contains(family));
      final bundled =
          family == FfFonts.frauncesFamily
              ? [600, 700]
              : [400, 500, 600, 700, 800];
      expect(
        bundled,
        contains(style.fontWeight!.value),
        reason: '$role uses a weight that is not bundled',
      );
    }
  });

  test('google_fonts is gone, so nothing fetches fonts at runtime', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('google_fonts')));
    final libUses = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('google_fonts'));
    expect(libUses, isEmpty);
  });

  testWidgets('bundled fonts load and change how text is laid out', (
    tester,
  ) async {
    double widthOf(String family) {
      final painter = TextPainter(
        text: TextSpan(
          text: 'Spent ₹48,210 this month',
          style: TextStyle(fontFamily: family, fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }

    // Before loading, both families fall back to the test font.
    final before = widthOf(FfFonts.manropeFamily);
    await tester.runAsync(loadAppFonts);
    final manrope = widthOf(FfFonts.manropeFamily);
    final fraunces = widthOf(FfFonts.frauncesFamily);

    expect(manrope, isNot(before));
    expect(fraunces, isNot(manrope));

    // And the app theme picks them up.
    expect(
      FfTheme.light().textTheme.bodyMedium?.fontFamily,
      FfFonts.manropeFamily,
    );
  });
}
