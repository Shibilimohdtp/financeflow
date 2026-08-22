import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/stillwater_tokens.dart';
import 'ff_button.dart';

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
        padding: const EdgeInsets.all(StillwaterTokens.space2Xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.4,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceLg),
            Text(
              title,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: StillwaterTokens.spaceXs),
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: StillwaterTokens.spaceXl),
              FfButton(label: actionLabel!, onPressed: onAction!, width: 220),
            ],
          ],
        ),
      ),
    );
  }
}
