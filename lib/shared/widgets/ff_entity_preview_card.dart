import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_card.dart';

/// Archetype B of the sheet recipe: the live preview at the top of an
/// entity sheet (a goal, a holding, a subscription, a lending record).
///
/// A solid comfortable card. The domain's hero tone shows on the leading
/// disc ([FfEntityPreviewCard.disc]) so each domain keeps its colour, while
/// the card itself stays calm. The figure sits on its own line, a quiet
/// caption on the left and the amount on the right. Not tappable.
class FfEntityPreviewCard extends StatelessWidget {
  const FfEntityPreviewCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.status,
    this.figureCaption,
    this.figure,
    this.footer,
    required this.semanticLabel,
  });

  /// Usually [FfEntityPreviewCard.disc] or an `FfMonogramTile`.
  final Widget leading;
  final String title;
  final String? subtitle;

  /// A small badge or chip under the title (due date, renewal, status).
  final Widget? status;

  /// What the figure is ("Target", "Valuation", "Owes you").
  final String? figureCaption;

  /// Usually an `FfAmountText(size: lg)`.
  final Widget? figure;

  /// One quiet line under the figure (return, monthly need).
  final Widget? footer;

  /// What a screen reader hears for the whole card.
  final String semanticLabel;

  /// A round icon disc in the domain's hero colours: the darkest stop with
  /// the hero's own text colour on it.
  static Widget disc(BuildContext context, FfHeroTone tone, IconData icon) {
    final hero = context.ff.hero(tone);
    return Container(
      width: FfHeroTokens.leadingSize,
      height: FfHeroTokens.leadingSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [hero.deep, hero.zone],
        ),
      ),
      child: Icon(icon, size: FfIconSize.xl, color: hero.onHero),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: FfCard(
          density: FfDensity.comfortable,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  leading,
                  const SizedBox(width: FfSpace.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: ff.text.titleLg,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: FfSpace.x3s),
                          Text(
                            subtitle!,
                            style: ff.text.bodySm.copyWith(
                              color: ff.color.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Under the title, not beside it, so a long chip
                        // never squeezes the name at large text.
                        if (status != null) ...[
                          const SizedBox(height: FfSpace.xs),
                          status!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (figure != null) ...[
                const SizedBox(height: FfSpace.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        figureCaption ?? '',
                        style: ff.text.label.copyWith(
                          color: ff.color.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: FfSpace.sm),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: figure!,
                      ),
                    ),
                  ],
                ),
              ],
              if (footer != null) ...[
                const SizedBox(height: FfSpace.xs),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
