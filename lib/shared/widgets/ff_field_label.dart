import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// The one "what is this" label: above a text field, a chip row, a tile
/// grid or a segmented pill. `text.label`, sentence case, secondary text.
/// Never ALL CAPS, never letter-spaced, never bold.
class FfFieldLabel extends StatelessWidget {
  const FfFieldLabel(
    this.text, {
    super.key,
    this.trailing,
    this.enabled = true,
  });

  final String text;

  /// A quiet action or note at the end of the label line.
  final Widget? trailing;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final label = Text(
      text,
      style: ff.text.label.copyWith(
        color: enabled ? ff.color.textSecondary : ff.color.textDisabled,
      ),
    );
    if (trailing == null) return label;
    return Row(children: [Expanded(child: label), trailing!]);
  }
}
