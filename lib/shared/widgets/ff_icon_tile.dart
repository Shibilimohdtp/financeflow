import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_corner_badge.dart';

/// An icon on a softly tinted circle, coloured by [tone]. Used as the leading
/// element of list rows for things with an identity (an account, a payee).
/// [corner] adds a warning or error badge; say the same thing in the row text.
class FfIconTile extends StatelessWidget {
  const FfIconTile({
    super.key,
    required this.icon,
    this.tone = FfTone.primary,
    this.semanticLabel,
    this.corner,
  });

  final IconData icon;
  final FfTone tone;
  final String? semanticLabel;
  final FfCorner? corner;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final fg = tone.foreground(c);
    final tile = Container(
      width: FfRowTokens.iconTile,
      height: FfRowTokens.iconTile,
      decoration: ShapeDecoration(
        color: c.tint(fg, FfTint.subtle),
        shape: FfShape.of(FfRowTokens.iconTileRadius),
      ),
      child: Icon(
        icon,
        size: FfIconSize.lg,
        color: fg,
        semanticLabel: semanticLabel,
      ),
    );
    if (corner == null) return tile;
    return FfCornerBadge(corner: corner!, child: tile);
  }
}
