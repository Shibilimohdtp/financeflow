import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';

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
    final secColors = context.secColors;

    final badge = Container(
      padding:
          iconOnly
              ? const EdgeInsets.all(StillwaterTokens.space2Xs + 2)
              : const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.space2Xs,
              ),
      decoration: BoxDecoration(
        color: secColors.surface,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
        border: Border.all(
          color: secColors.verified.withValues(alpha: 0.25),
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child:
          iconOnly
              ? Icon(Icons.shield_outlined, size: 14, color: secColors.verified)
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: secColors.verified,
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: secColors.verified,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
