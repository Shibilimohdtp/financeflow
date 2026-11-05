import 'dart:convert';

import 'package:flutter/services.dart';

/// Families and asset paths declared under `fonts:` in pubspec.yaml, read from
/// the FontManifest Flutter builds for tests.
Future<Map<String, List<String>>> readFontManifest() async {
  final raw = await rootBundle.loadString('FontManifest.json');
  final entries = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return {
    for (final e in entries)
      e['family'] as String: [
        for (final f in (e['fonts'] as List).cast<Map<String, dynamic>>())
          f['asset'] as String,
      ],
  };
}

var _loaded = false;

/// Loads the bundled app fonts into the test engine, so goldens and
/// screenshots render Manrope and Fraunces instead of the test font.
/// Call from `setUpAll`; repeated calls are no-ops.
Future<void> loadAppFonts() async {
  if (_loaded) return;
  final manifest = await readFontManifest();
  for (final MapEntry(key: family, value: assets) in manifest.entries) {
    if (family.startsWith('packages/') || family == 'MaterialIcons') continue;
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
  _loaded = true;
}
