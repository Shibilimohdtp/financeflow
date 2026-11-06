import 'package:financeflow/features/dashboard/widgets/home_header.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeHeader Unit Tests (Time of Day Greeting)', () {
    test('returns "Good morning" for hours before 12', () {
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 8, 30)),
        'Good morning',
      );
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 11, 59)),
        'Good morning',
      );
    });

    test('returns "Good afternoon" for hours between 12 and 17', () {
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 12, 0)),
        'Good afternoon',
      );
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 14, 15)),
        'Good afternoon',
      );
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 16, 59)),
        'Good afternoon',
      );
    });

    test('returns "Good evening" for hours 17 and later', () {
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 17, 0)),
        'Good evening',
      );
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 21, 45)),
        'Good evening',
      );
      expect(
        HomeHeader.greetingFor(DateTime(2026, 11, 6, 23, 59)),
        'Good evening',
      );
    });
  });

  group('HomeHeader Widget Tests', () {
    testWidgets(
      'renders personal greeting, date, and actions without shield badge',
      (tester) async {
        var blurToggled = false;
        var alertsOpened = false;

        final morningTime = DateTime(2026, 11, 6, 9, 30);

        await tester.pumpWidget(
          MaterialApp(
            theme: FfTheme.light(),
            home: Scaffold(
              body: HomeHeader(
                unreadAlerts: 0,
                isPrivacyBlur: false,
                onOpenAlerts: () => alertsOpened = true,
                onToggleBlur: () => blurToggled = true,
                now: morningTime,
              ),
            ),
          ),
        );

        // Verify Title (Greeting) and Subline (Date)
        expect(find.text('Good morning'), findsOneWidget);
        expect(find.text('FinanceFlow'), findsNothing); // Wordmark dropped
        expect(find.text('On-device'), findsNothing); // Shield pill dropped
        expect(find.byIcon(Icons.shield_outlined), findsNothing);

        // Verify Actions & Tooltips
        expect(find.byTooltip('Hide amounts'), findsOneWidget);
        expect(find.byTooltip('Alerts & Reminders'), findsOneWidget);

        // Tap actions
        await tester.tap(find.byTooltip('Hide amounts'));
        expect(blurToggled, isTrue);

        await tester.tap(find.byTooltip('Alerts & Reminders'));
        expect(alertsOpened, isTrue);
      },
    );

    testWidgets('shows unread count in bell tooltip and corner dot badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.light(),
          home: Scaffold(
            body: HomeHeader(
              unreadAlerts: 4,
              isPrivacyBlur: true,
              onOpenAlerts: () {},
              onToggleBlur: () {},
              now: DateTime(2026, 11, 6, 19, 0),
            ),
          ),
        ),
      );

      expect(find.text('Good evening'), findsOneWidget);
      expect(find.byTooltip('Show amounts'), findsOneWidget);
      expect(find.byTooltip('Alerts & Reminders, 4 unread'), findsOneWidget);
    });

    testWidgets(
      'renders cleanly in dark theme and 2x text scale without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: FfTheme.dark(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: HomeHeader(
                  unreadAlerts: 2,
                  isPrivacyBlur: false,
                  onOpenAlerts: () {},
                  onToggleBlur: () {},
                  now: DateTime(2026, 11, 6, 14, 0),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Good afternoon'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
