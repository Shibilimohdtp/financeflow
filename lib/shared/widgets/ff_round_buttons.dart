import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_corner_badge.dart';

/// A round icon button with a thin outline: back, more, hide amounts,
/// alerts. 44 dp visual inside a 48 dp target. [tooltip] is also its
/// screen-reader label.
class FfCircleButton extends StatelessWidget {
  const FfCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.corner,
    this.soft = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// A badge on the corner (unread alerts, a warning).
  final FfCorner? corner;

  /// A fainter outline for buttons in a header that already has structure.
  /// The icon stays fully readable either way.
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final shape = CircleBorder(
      side: BorderSide(
        color: soft ? c.borderSubtle : c.borderControl,
        width: FfBorderWidth.regular,
      ),
    );
    Widget visual = Container(
      width: FfRoundButtonTokens.size,
      height: FfRoundButtonTokens.size,
      decoration: ShapeDecoration(shape: shape),
      child: Icon(
        icon,
        size: FfRoundButtonTokens.iconSize,
        color: onPressed == null ? c.textDisabled : c.textPrimary,
      ),
    );
    if (corner != null) visual = FfCornerBadge(corner: corner!, child: visual);
    return _RoundTarget(tooltip: tooltip, onPressed: onPressed, child: visual);
  }
}

/// The solid ink action circle (↗ "open", + "add"). On a hero gradient it
/// stays dark in both modes.
class FfInkButton extends StatelessWidget {
  const FfInkButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onHero = false,
    this.small = false,
  });

  /// The "open detail" arrow.
  const FfInkButton.open({
    super.key,
    required this.onPressed,
    this.tooltip = 'Open',
    this.onHero = false,
    this.small = false,
  }) : icon = Icons.north_east_rounded;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool onHero;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = context.ff.color;
    final bg = onHero ? c.surfaceInk : c.actionPrimary;
    final fg = onHero ? c.onSurfaceInk : c.onActionPrimary;
    final size = small ? FfRoundButtonTokens.sizeSm : FfRoundButtonTokens.size;
    return _RoundTarget(
      tooltip: tooltip,
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: onPressed == null ? c.tint(bg, FfTint.strong) : bg,
        ),
        child: Icon(icon, size: FfRoundButtonTokens.iconSize - 2, color: fg),
      ),
    );
  }
}

class _RoundTarget extends StatelessWidget {
  const _RoundTarget({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: FfTouch.minTarget,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
