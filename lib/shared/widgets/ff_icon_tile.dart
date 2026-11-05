import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// An icon on a softly tinted square, coloured by [tone]. Used as the leading
/// element of list rows for things with an identity (an account, a payee).
class FfIconTile extends StatelessWidget {
  const FfIconTile({
    super.key,
    required this.icon,
    this.tone = FfTone.primary,
    this.semanticLabel,
  });

  final IconData icon;
  final FfTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final fg = tone.foreground(c);
    return Container(
      width: FfRowTokens.iconTile,
      height: FfRowTokens.iconTile,
      decoration: BoxDecoration(
        color: c.tint(fg, FfTint.subtle),
        borderRadius: ffRadius(FfRowTokens.iconTileRadius),
      ),
      child: Icon(
        icon,
        size: FfIconSize.lg,
        color: fg,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
