import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../theme/stillwater_tokens.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final int unreadAlerts;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenAi;
  final VoidCallback? onOpenSettings;

  const HomeHeader({
    super.key,
    required this.unreadAlerts,
    required this.onOpenAlerts,
    required this.onOpenAi,
    this.onOpenSettings,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final now = DateTime.now();
    final formattedDate = DateFormatter.formatFullDate(now);

    return AppBar(
      titleSpacing: StillwaterTokens.spaceLg,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: StillwaterTokens.space2Xs),
                Text(
                  '· $formattedDate',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.75),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StillwaterTokens.space3Xs),
            Text(
              'FinanceFlow',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Alerts & Reminders with Badge
        IconButton(
          icon: Badge(
            isLabelVisible: unreadAlerts > 0,
            label: Text('$unreadAlerts'),
            child: const Icon(Icons.notifications_outlined),
          ),
          tooltip: 'Alerts & Reminders',
          visualDensity: VisualDensity.compact,
          onPressed: onOpenAlerts,
        ),
        // Ask Your Finances Action Button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StillwaterTokens.space2Xs,
          ),
          child: Center(child: _AskFinanceButton(onPressed: onOpenAi)),
        ),
        // On-Device Privacy Badge
        const Padding(
          padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
          child: Center(child: FfPrivacyBadge(label: 'On-device')),
        ),
      ],
    );
  }
}

/// Custom action button for "Ask Your Finances" natural language queries
class _AskFinanceButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AskFinanceButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final aiColors = context.aiColors;
    final theme = context.theme;

    return Semantics(
      button: true,
      label: 'Ask Your Finances',
      child: Tooltip(
        message: 'Ask Your Finances',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(StillwaterTokens.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceSm,
                vertical: StillwaterTokens.space2Xs + 1,
              ),
              decoration: BoxDecoration(
                color: aiColors.surface,
                borderRadius: BorderRadius.circular(
                  StillwaterTokens.radiusFull,
                ),
                border: Border.all(
                  color: aiColors.accent.withValues(alpha: 0.35),
                  width: StillwaterTokens.borderWidthHairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 13,
                    color: aiColors.accent,
                  ),
                  const SizedBox(width: StillwaterTokens.space2Xs),
                  Text(
                    'Ask',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: aiColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
