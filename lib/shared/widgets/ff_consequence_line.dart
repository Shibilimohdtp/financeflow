import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';

/// A calm, single-sentence consequence or projection displayed under forms
/// or inputs (e.g. "₹4,200 a month gets you there by 12 Mar 2027",
/// "10 units at ₹2,500 = ₹25,000 invested").
///
/// Follows Stillwater Bloom standards:
/// - Light typography and subtle tone container
/// - Semantic announcement for screen readers
/// - Pair text + icon + tone (never colour alone)
class FfConsequenceLine extends StatelessWidget {
  const FfConsequenceLine({
    super.key,
    required this.text,
    this.icon,
    this.tone = FfTone.primary,
    this.padding,
    this.trailing,
  });

  final String text;
  final IconData? icon;
  final FfTone tone;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final fg = tone.foreground(c);
    final bg = tone.container(c);

    return Semantics(
      container: true,
      label: 'Consequence: $text',
      child: Container(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: FfSpace.md,
              vertical: FfSpace.sm,
            ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FfRadius.md),
          border: Border.all(
            color: c.borderSubtle,
            width: FfBorderWidth.hairline,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: FfSpace.sm),
            ],
            Expanded(
              child: Text(
                text,
                style: ff.text.bodySm.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: FfSpace.xs),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
