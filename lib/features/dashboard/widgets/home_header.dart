import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../shared/widgets/ff_corner_badge.dart';
import '../../../shared/widgets/ff_privacy_badge.dart';
import '../../../shared/widgets/ff_round_buttons.dart';
import '../../../theme/ff.dart';

/// Home's header, drawn straight on the aurora (no bar background): the
/// greeting and date, the wordmark, the on-device cue and the alerts button.
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
  Size get preferredSize =>
      const Size.fromHeight(FfTouch.minTarget + FfSpace.md);

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormatter.formatFullDate(DateTime.now());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: FfSpace.pageMargin,
            end:
                FfSpace.pageMargin -
                (FfTouch.minTarget - FfRoundButtonTokens.size) / 2,
            top: FfSpace.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_getGreeting()} · $formattedDate',
                      style: ff.text.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'FinanceFlow',
                      style: ff.text.titleLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const FfPrivacyBadge(label: 'On-device'),
              const SizedBox(width: FfSpace.x2s),
              FfCircleButton(
                icon: Icons.notifications_none_rounded,
                tooltip:
                    unreadAlerts > 0
                        ? 'Alerts & Reminders, $unreadAlerts unread'
                        : 'Alerts & Reminders',
                corner: unreadAlerts > 0 ? FfCorner.dot : null,
                soft: true,
                onPressed: onOpenAlerts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
