import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/stillwater_tokens.dart';

/// The persistent, mobile-level destinations for the Stillwater shell.
///
/// Combines platform-aware semantics, minimum destination hit targets, safe-area
/// behavior, subtle hairline border separation, and real-time badge support.
class StillwaterBottomNavigationBar extends StatelessWidget {
  const StillwaterBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.pendingReviewCount = 0,
    this.unreadAlertsCount = 0,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int pendingReviewCount;
  final int unreadAlertsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.navigationBarTheme.backgroundColor ?? theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: StillwaterTokens.borderWidthHairline,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index != selectedIndex) {
            HapticFeedback.selectionClick();
          }
          onDestinationSelected(index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon:
                pendingReviewCount > 0
                    ? Badge.count(
                      count: pendingReviewCount,
                      backgroundColor: theme.colorScheme.tertiary,
                      textColor: theme.colorScheme.onTertiary,
                      child: const Icon(Icons.receipt_long_outlined),
                    )
                    : const Icon(Icons.receipt_long_outlined),
            selectedIcon:
                pendingReviewCount > 0
                    ? Badge.count(
                      count: pendingReviewCount,
                      backgroundColor: theme.colorScheme.tertiary,
                      textColor: theme.colorScheme.onTertiary,
                      child: const Icon(Icons.receipt_long_rounded),
                    )
                    : const Icon(Icons.receipt_long_rounded),
            label: 'Money',
          ),
          const NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Plan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon:
                unreadAlertsCount > 0
                    ? Badge(
                      smallSize: 8,
                      backgroundColor: theme.colorScheme.tertiary,
                      child: const Icon(Icons.more_horiz_rounded),
                    )
                    : const Icon(Icons.more_horiz_rounded),
            selectedIcon:
                unreadAlertsCount > 0
                    ? Badge(
                      smallSize: 8,
                      backgroundColor: theme.colorScheme.tertiary,
                      child: const Icon(Icons.more_horiz_rounded),
                    )
                    : const Icon(Icons.more_horiz_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
