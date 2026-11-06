import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';

/// A safety-gated button designed for highly destructive actions (e.g. wiping
/// all application data). Requires holding the button down continuously for
/// [holdDuration] (default 2.5s) to trigger [onConfirmed]. Releasing early cancels.
class FfHoldToConfirmButton extends StatefulWidget {
  final String label;
  final String holdingLabel;
  final VoidCallback onConfirmed;
  final Duration holdDuration;
  final bool isDestructive;

  const FfHoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.holdingLabel = 'Hold to confirm...',
    this.holdDuration = FfHoldToConfirmTokens.holdDuration,
    this.isDestructive = true,
  });

  @override
  State<FfHoldToConfirmButton> createState() => _FfHoldToConfirmButtonState();
}

class _FfHoldToConfirmButtonState extends State<FfHoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHolding = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completed = true;
        HapticFeedback.heavyImpact();
        widget.onConfirmed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressStart() {
    _completed = false;
    setState(() => _isHolding = true);
    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
  }

  void _onPressEnd() {
    if (!_completed) {
      _controller.reverse();
    }
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    final primaryColor =
        widget.isDestructive ? ff.color.statusError : ff.color.actionPrimary;

    final shape = FfShape.of(FfButtonTokens.radius);

    return Semantics(
      button: true,
      label: '${widget.label}. Hold down for 2.5 seconds to confirm.',
      child: Listener(
        onPointerDown: (_) => _onPressStart(),
        onPointerUp: (_) => _onPressEnd(),
        onPointerCancel: (_) => _onPressEnd(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;

            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: FfButtonTokens.heightLg,
                minWidth: double.infinity,
              ),
              child: Material(
                type: MaterialType.transparency,
                shape: shape,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: ShapeDecoration(
                    color: primaryColor.withValues(alpha: FfTint.subtle.alpha),
                    shape: shape,
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Animated progress fill layer
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: ShapeDecoration(
                            color: primaryColor.withValues(
                              alpha: FfTint.strong.alpha,
                            ),
                            shape: shape,
                          ),
                        ),
                      ),
                      // Text & Icon content
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FfSpace.md,
                            vertical: FfSpace.sm,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isHolding
                                    ? Icons.timer_rounded
                                    : Icons.warning_amber_rounded,
                                size: 18,
                                color: primaryColor,
                              ),
                              const SizedBox(width: FfSpace.xs),
                              Text(
                                _isHolding
                                    ? '${widget.holdingLabel} ${(progress * 100).toInt()}%'
                                    : widget.label,
                                style: ff.text.titleSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
