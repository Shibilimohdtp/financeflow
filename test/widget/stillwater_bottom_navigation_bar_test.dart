import 'package:financeflow/shared/widgets/stillwater_bottom_navigation_bar.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required ThemeData theme,
    required int selectedIndex,
    required ValueChanged<int> onDestinationSelected,
    int pendingReviewCount = 0,
    int unreadAlertsCount = 0,
    MediaQueryData mediaQueryData = const MediaQueryData(),
  }) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: mediaQueryData,
        child: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: StillwaterBottomNavigationBar(
            selectedIndex: selectedIndex,
            pendingReviewCount: pendingReviewCount,
            unreadAlertsCount: unreadAlertsCount,
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('renders five labelled destinations and reports selection', (
    tester,
  ) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      buildSubject(
        theme: StillwaterTheme.daylight,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => selectedIndex = index,
      ),
    );

    for (final label in ['Home', 'Money', 'Plan', 'Insights', 'More']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);

    await tester.tap(find.text('Money'));
    expect(selectedIndex, 1);

    final selectedIcons = [
      Icons.home_rounded,
      Icons.receipt_long_rounded,
      Icons.pie_chart_rounded,
      Icons.insights_rounded,
      Icons.more_horiz_rounded,
    ];
    for (final theme in [StillwaterTheme.daylight, StillwaterTheme.deepWater]) {
      for (var index = 0; index < selectedIcons.length; index++) {
        await tester.pumpWidget(
          buildSubject(
            theme: theme,
            selectedIndex: index,
            onDestinationSelected: (_) {},
          ),
        );
        expect(find.byIcon(selectedIcons[index]), findsOneWidget);
      }
    }
  });

  testWidgets('renders badges for pending items and unread alerts', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        theme: StillwaterTheme.daylight,
        selectedIndex: 0,
        pendingReviewCount: 3,
        unreadAlertsCount: 2,
        onDestinationSelected: (_) {},
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.byType(Badge), findsWidgets);
  });

  testWidgets(
    'keeps destination labels visible at a compact width and 2x text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildSubject(
          theme: StillwaterTheme.deepWater,
          selectedIndex: 3,
          onDestinationSelected: (_) {},
          mediaQueryData: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
            viewPadding: EdgeInsets.only(bottom: 24),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
      expect(
        tester.getSize(find.byType(NavigationBar)).height,
        greaterThanOrEqualTo(72),
      );
    },
  );
}
