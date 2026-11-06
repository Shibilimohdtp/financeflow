import 'package:flutter/material.dart';

import '../ff_colors.dart';
import '../ff_hero.dart';
import 'lichen.dart';

/// A colour theme: one complete set of semantic colours for light mode and
/// one for dark mode. Adding a theme means adding one palette file and one
/// entry in [FfPalettes.all]; `FfTheme.build` does the rest.
@immutable
class FfPalette {
  const FfPalette({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
    required this.heroesLight,
    required this.heroesDark,
  });

  /// Stable identifier stored in settings. Never rename an existing id.
  final String id;

  /// Name shown in the theme picker.
  final String name;

  final FfColors light;
  final FfColors dark;

  /// Hero gradients (see [FfHeroTone]) for each mode.
  final FfHeroes heroesLight;
  final FfHeroes heroesDark;

  FfColors colorsFor(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  FfHeroes heroesFor(Brightness brightness) =>
      brightness == Brightness.dark ? heroesDark : heroesLight;
}

/// Every palette the app offers. The first one is the default.
abstract final class FfPalettes {
  static const FfPalette lichen = lichenPalette;

  static const List<FfPalette> all = [lichen];

  static FfPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => lichen);
}
