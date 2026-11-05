import 'package:flutter/material.dart';
import 'ff_button.dart';
import '../../theme/ff.dart';

class FfEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FfEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FfSpace.x2l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.ff.color.actionPrimaryContainer.withValues(
                  alpha: 0.4,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: context.ff.color.actionPrimary,
              ),
            ),
            const SizedBox(height: FfSpace.lg),
            Text(
              title,
              style: context.ff.text.headlineSm,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FfSpace.xs),
            Text(
              description,
              style: context.ff.text.body.copyWith(
                color: context.ff.text.bodySm.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: FfSpace.xl),
              FfButton(label: actionLabel!, onPressed: onAction!, width: 220),
            ],
          ],
        ),
      ),
    );
  }
}
