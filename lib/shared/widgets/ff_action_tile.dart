import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_card.dart';
import 'ff_corner_badge.dart';
import 'ff_icon_tile.dart';

/// One thing to act on, as a compact tappable card: a tinted icon (with an
/// optional warning corner), a short verb line ("EMI due in 2 days") and a
/// quiet detail line ("HDFC Home Loan"). Laid out in a row by
/// [FfActionStrip]. Status is in the words; the tone only supports them.
class FfActionTile extends StatelessWidget {
  final IconData icon;
  final FfTone tone;
  final FfCorner? corner;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const FfActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.tone = FfTone.primary,
    this.corner,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: FfActionTileTokens.minWidth,
          maxWidth: FfActionTileTokens.maxWidth,
          minHeight: FfTouch.minTarget,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: FfCard.shapeOf(FfDensity.compact),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: FfCard.decorationOf(
              context,
              density: FfDensity.compact,
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FfIconTile(icon: icon, tone: tone, corner: corner),
                    const SizedBox(width: FfSpace.sm),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ff.text.titleSm,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: ff.text.bodySm.copyWith(
                                color: ff.color.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of [FfActionTile]s that bleeds to the screen
/// edge and starts on the page margin. All tiles share the tallest height.
class FfActionStrip extends StatelessWidget {
  final List<FfActionTile> tiles;

  const FfActionStrip({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      // Room for the card shadow.
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, tile) in tiles.indexed) ...[
              if (i > 0) const SizedBox(width: FfSpace.xs),
              tile,
            ],
          ],
        ),
      ),
    );
  }
}
