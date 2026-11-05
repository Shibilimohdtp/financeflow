import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// What a list row starts with, so a divider can line up with its text.
enum FfRowLeading { none, icon, tile }

/// A hairline separator. Colour and thickness come from the theme.
///
/// - [FfDivider.new]: full width, no extra space.
/// - [FfDivider.inset]: starts where list row text starts, so stacked rows
///   read as one group. Pass what the rows lead with.
/// - [FfDivider.spaced]: adds breathing room above and below, between blocks.
class FfDivider extends StatelessWidget {
  const FfDivider({super.key}) : _indent = 0, _height = FfDividerTokens.space;

  const FfDivider.inset({super.key, FfRowLeading after = FfRowLeading.tile})
    : _indent =
          after == FfRowLeading.icon
              ? FfRowTokens.textInsetAfterIcon
              : after == FfRowLeading.tile
              ? FfRowTokens.textInsetAfterTile
              : FfRowTokens.paddingH,
      _height = FfDividerTokens.space;

  const FfDivider.spaced({super.key})
    : _indent = 0,
      _height = FfDividerTokens.spacedHeight;

  final double _indent;
  final double _height;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: _height,
      thickness: FfDividerTokens.thickness,
      indent: _indent,
      color: context.ff.color.borderSubtle,
    );
  }
}
