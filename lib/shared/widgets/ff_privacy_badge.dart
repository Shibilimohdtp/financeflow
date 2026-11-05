import 'package:flutter/material.dart';
import '../../theme/ff.dart';

class FfPrivacyBadge extends StatelessWidget {
  final String label;
  final bool iconOnly;

  const FfPrivacyBadge({
    super.key,
    this.label = 'On-device · Private',
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final secColors = context.ff.color;

    final badge = Container(
      padding:
          iconOnly
              ? const EdgeInsets.all(FfSpace.x2s + 2)
              : const EdgeInsets.symmetric(
                horizontal: FfSpace.sm,
                vertical: FfSpace.x2s,
              ),
      decoration: BoxDecoration(
        color: secColors.surfaceSecure,
        borderRadius: BorderRadius.circular(FfRadius.full),
        border: Border.all(
          color: secColors.statusSuccess.withValues(alpha: FfTint.medium.alpha),
          width: FfBorderWidth.hairline,
        ),
      ),
      child:
          iconOnly
              ? Icon(
                Icons.shield_outlined,
                size: 14,
                color: secColors.statusSuccess,
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: secColors.statusSuccess,
                  ),
                  const SizedBox(width: FfSpace.x2s),
                  Text(
                    label,
                    style: context.ff.text.labelSm.copyWith(
                      color: secColors.statusSuccess,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
    );

    return Semantics(
      label: 'Privacy indicator: $label',
      child: iconOnly ? Tooltip(message: label, child: badge) : badge,
    );
  }
}
