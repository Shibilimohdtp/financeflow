import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A generative merchant or counterparty monogram avatar squircle.
///
/// Displays 1 or 2 uppercase initials derived from the merchant or counterparty
/// name, set on a deterministic token-based container fill with high contrast
/// text. Never relies on external brand logos or network image fetching, keeping
/// the app 100% offline and privacy-first.
class FfMonogramTile extends StatelessWidget {
  const FfMonogramTile({
    super.key,
    required this.name,
    this.size = FfRowTokens.iconTile,
    this.tone,
    this.radius = FfRadius.md,
    this.semanticLabel,
  });

  /// Name of the merchant or counterparty (e.g. "Netflix", "Spotify", "Airtel").
  final String name;

  /// Width and height of the squircle tile (default 40 dp).
  final double size;

  /// Optional explicit tone. If null, a deterministic tone is selected
  /// based on the name string.
  final FfTone? tone;

  /// Corner radius of the squircle (defaults to [FfRadius.md] = 16 dp).
  final double radius;

  /// Accessibility label (e.g. "Netflix logo").
  final String? semanticLabel;

  /// Extracts 1–2 uppercase initials from [name]. Words with no letter or
  /// digit ("/", "&") are skipped, so "Friend / Person" gives "FP", not
  /// "F/". Returns '?' when nothing is left; the tile then shows a person
  /// icon instead of a question mark.
  static String initialsFor(String name) {
    final hasLetter = RegExp(r'[\p{L}\p{N}]', unicode: true);
    final parts =
        name
            .trim()
            .split(RegExp(r'[\s\-_\./&+,]+'))
            .map(
              (p) => p.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''),
            )
            .where((p) => p.isNotEmpty && hasLetter.hasMatch(p))
            .toList();
    if (parts.isEmpty) return '?';

    if (parts.length >= 2) {
      final first = parts[0].characters.first;
      final second = parts[1].characters.first;
      return '$first$second'.toUpperCase();
    }

    final single = parts.first;
    if (single.length >= 2) {
      return single.substring(0, 2).toUpperCase();
    }
    return single.toUpperCase();
  }

  /// Maps a string seed deterministically to an accessible [FfTone].
  static FfTone toneFor(String name) {
    const tones = [
      FfTone.primary,
      FfTone.neutral,
      FfTone.accent,
      FfTone.transfer,
      FfTone.savings,
      FfTone.investment,
      FfTone.info,
    ];
    final hash = name.trim().toLowerCase().codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) & 0x7FFFFFFF,
    );
    return tones[hash % tones.length];
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final initials = initialsFor(name);
    final resolvedTone = tone ?? toneFor(name);

    final bg = resolvedTone.container(ff.color);
    final fg = resolvedTone.foreground(ff.color);

    // Font size scales with tile dimension (approx. 40% of size)
    final fontSize = (size * 0.38).clamp(10.0, 24.0);

    return Semantics(
      label: semanticLabel ?? '$name icon',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(color: bg, shape: FfShape.of(radius)),
        alignment: Alignment.center,
        child:
            initials == '?'
                ? Icon(
                  Icons.person_outline_rounded,
                  size: size * 0.5,
                  color: fg,
                )
                : Text(
                  initials,
                  style: ff.text.titleSm.copyWith(
                    color: fg,
                    fontSize: fontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
      ),
    );
  }
}
