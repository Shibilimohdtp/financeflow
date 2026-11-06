// DS-3: fonts are bundled, so text never needs the network and release
// builds render the same faces as debug builds. DS-B2: Geist is the UI face,
// Manrope the fallback; Fraunces is gone.
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
    expect(manifest[FfFonts.geistFamily], [
      'assets/fonts/Geist-Light.ttf',
      'assets/fonts/Geist-Regular.ttf',
      'assets/fonts/Geist-Medium.ttf',
      'assets/fonts/Geist-SemiBold.ttf',
    ]);
    expect(manifest.containsKey('Fraunces'), isFalse);

    final text = FfTypography.build(
      primary: const Color(0xFF000000),
      secondary: const Color(0xFF000000),
    );
    for (final role in FfTextRole.values) {
      final style = text[role];
      final family = style.fontFamily;
      expect(family, FfFonts.geistFamily);
      expect(style.fontFamilyFallback?.first, FfFonts.manropeFamily);
      const bundled = [300, 400, 500, 600];
      // Light is only for large text.
      if (style.fontWeight == FontWeight.w300) {
        expect(style.fontSize, greaterThanOrEqualTo(28), reason: '$role');
      }
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
    final before = widthOf(FfFonts.geistFamily);
    await tester.runAsync(loadAppFonts);
    final geist = widthOf(FfFonts.geistFamily);
    final manrope = widthOf(FfFonts.manropeFamily);

    expect(geist, isNot(before));
    expect(manrope, isNot(geist));

    // And the app theme picks them up.
    expect(
      FfTheme.light().textTheme.bodyMedium?.fontFamily,
      FfFonts.geistFamily,
    );
  });
}
