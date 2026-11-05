import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// A hairline separator. Colour and thickness come from the theme.
///
/// - [FfDivider.new]: full width, no extra space.
/// - [FfDivider.inset]: starts after a list row's leading icon, so stacked
///   rows read as one group.
/// - [FfDivider.spaced]: adds breathing room above and below, between blocks.
class FfDivider extends StatelessWidget {
  const FfDivider({super.key}) : _indent = 0, _height = FfDividerTokens.space;

  const FfDivider.inset({super.key})
    : _indent = FfDividerTokens.rowInset,
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
