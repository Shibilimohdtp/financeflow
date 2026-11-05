import 'package:flutter/material.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_app_bar.dart';
import '../../../theme/ff.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final int unreadAlerts;
  final VoidCallback onOpenAlerts;
  final VoidCallback? onOpenSettings;

  const HomeHeader({
    super.key,
    required this.unreadAlerts,
    required this.onOpenAlerts,
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
    final now = DateTime.now();
    final formattedDate = DateFormatter.formatFullDate(now);

    return FfAppBar(
      titleWidget: FittedBox(
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
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: FfSpace.x2s),
                Text(
                  '· $formattedDate',
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary.withValues(
                      alpha: FfOpacity.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FfSpace.x3s),
            Text(
              'FinanceFlow',
              style: context.ff.text.title.copyWith(
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
        // On-Device Privacy Badge
        const Padding(
          padding: EdgeInsets.only(right: FfSpace.lg),
          child: Center(child: FfPrivacyBadge(label: 'On-device')),
        ),
      ],
    );
  }
}
