import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../shared/widgets/ff_corner_badge.dart';
import '../../../shared/widgets/ff_page_header.dart';
import '../../../shared/widgets/ff_round_buttons.dart';
import '../../../theme/ff.dart';

/// The redesigned Home screen header (Stillwater Bloom, Direction A).
///
/// Features:
/// - Large, light-weight personal greeting as the title ("Good morning / afternoon / evening") in [FfTypography.displaySm]
/// - Full date as the quiet subline in [FfTypography.label]
/// - Privacy-first controls: quick hide-amounts eye toggle and alerts bell with unread dot
/// - Completely free of redundant wordmarks or on-device shield badges
/// - In-flow non-sticky placement allowing content below to breathe
/// - Time-of-day greeting logic refreshed on resume
class HomeHeader extends StatefulWidget {
  final int unreadAlerts;
  final VoidCallback onOpenAlerts;
  final bool isPrivacyBlur;
  final VoidCallback onToggleBlur;

  /// Optional injected clock for deterministic time-of-day tests.
  final DateTime? now;

  const HomeHeader({
    super.key,
    required this.unreadAlerts,
    required this.onOpenAlerts,
    required this.isPrivacyBlur,
    required this.onToggleBlur,
    this.now,
  });

  /// Evaluates the greeting string based on the current hour.
  static String greetingFor(DateTime time) {
    final hour = time.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with WidgetsBindingObserver {
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.now ?? DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.now != oldWidget.now) {
      _currentTime = widget.now ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.now == null) {
      setState(() {
        _currentTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = HomeHeader.greetingFor(_currentTime);
    final formattedDate = DateFormatter.formatFullDate(_currentTime);

    return FfPageHeader(
      title: greeting,
      subtitle: formattedDate,
      titleStyle: context.ff.text.displaySm,
      padding: const EdgeInsetsDirectional.only(
        start: FfSpace.pageMargin,
        end:
            FfSpace.pageMargin -
            (FfTouch.minTarget - FfRoundButtonTokens.size) / 2,
        top: FfSpace.x2s,
        bottom: 0,
      ),
      actions: [
        FfCircleButton(
          icon:
              widget.isPrivacyBlur
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
          tooltip: widget.isPrivacyBlur ? 'Show amounts' : 'Hide amounts',
          soft: true,
          onPressed: widget.onToggleBlur,
        ),
        FfCircleButton(
          icon: Icons.notifications_none_rounded,
          tooltip:
              widget.unreadAlerts > 0
                  ? 'Alerts & Reminders, ${widget.unreadAlerts} unread'
                  : 'Alerts & Reminders',
          corner: widget.unreadAlerts > 0 ? FfCorner.dot : null,
          soft: true,
          onPressed: widget.onOpenAlerts,
        ),
      ],
    );
  }
}
