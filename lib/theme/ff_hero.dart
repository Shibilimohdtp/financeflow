import 'package:flutter/material.dart';

/// The hero gradients: rich, grainy surfaces for the few cards that matter
/// most on a screen (an account, a loan, a goal). Assigned by what the money
/// is, never by a bank or brand.
enum FfHeroTone {
  /// Accounts and net worth.
  moss,

  /// Loans, EMIs and debts.
  rose,

  /// Investments and cards.
  dusk,

  /// Savings goals.
  tide,

  /// Cash, wallets and subscriptions.
  sand,
}

/// One hero gradient in one mode.
///
/// Text may only sit between [deep] and [zone]; [glow] is a decorative
/// corner that never carries text. The contrast test checks [onHero] and
/// [onHeroSecondary] against both [deep] and [zone].
@immutable
class FfHeroColors {
  const FfHeroColors({
    required this.deep,
    required this.zone,
    required this.glow,
    required this.onHero,
    this.secondaryAlpha = 0.78,
  });

  /// Darkest stop (top start).
  final Color deep;

  /// Lightest point any text crosses.
  final Color zone;

  /// Decorative light in the bottom end corner. No text.
  final Color glow;

  /// Text and icons on the hero.
  final Color onHero;

  /// Opacity of [onHero] for labels and units.
  final double secondaryAlpha;

  Color get onHeroSecondary => onHero.withValues(alpha: secondaryAlpha);

  /// True when the hero is pale and carries dark ink text.
  bool get isPale => onHero.computeLuminance() < 0.2;

  /// The base gradient, deep → zone. Components layer [glow] on top as a
  /// radial gradient in the bottom end corner.
  LinearGradient get gradient => LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [deep, zone],
  );

  static FfHeroColors lerp(FfHeroColors a, FfHeroColors b, double t) =>
      FfHeroColors(
        deep: Color.lerp(a.deep, b.deep, t)!,
        zone: Color.lerp(a.zone, b.zone, t)!,
        glow: Color.lerp(a.glow, b.glow, t)!,
        onHero: Color.lerp(a.onHero, b.onHero, t)!,
        secondaryAlpha:
            a.secondaryAlpha + (b.secondaryAlpha - a.secondaryAlpha) * t,
      );

  @override
  bool operator ==(Object other) =>
      other is FfHeroColors &&
      other.deep == deep &&
      other.zone == zone &&
      other.glow == glow &&
      other.onHero == onHero &&
      other.secondaryAlpha == secondaryAlpha;

  @override
  int get hashCode => Object.hash(deep, zone, glow, onHero, secondaryAlpha);
}

/// Every hero gradient of the active theme, read with `context.ff.hero(tone)`.
@immutable
class FfHeroes extends ThemeExtension<FfHeroes> {
  const FfHeroes(this._values);

  final Map<FfHeroTone, FfHeroColors> _values;

  FfHeroColors operator [](FfHeroTone tone) =>
      _values[tone] ?? (throw StateError('Palette is missing hero $tone'));

  List<FfHeroTone> get missingTones =>
      FfHeroTone.values.where((t) => !_values.containsKey(t)).toList();

  @override
  FfHeroes copyWith({Map<FfHeroTone, FfHeroColors>? overrides}) =>
      FfHeroes({..._values, ...?overrides});

  @override
  FfHeroes lerp(ThemeExtension<FfHeroes>? other, double t) {
    if (other is! FfHeroes) return this;
    return FfHeroes({
      for (final tone in FfHeroTone.values)
        tone: FfHeroColors.lerp(this[tone], other[tone], t),
    });
  }
}
