import 'package:financeflow/models/subscription.dart';
import 'package:financeflow/shared/widgets/ff_monogram_tile.dart';
import 'package:financeflow/shared/widgets/ff_renewal_chip.dart';
import 'package:financeflow/shared/widgets/ff_renewal_strip.dart';
import 'package:financeflow/shared/widgets/ff_subscription_preview_card.dart';
import 'package:financeflow/shared/widgets/ff_subscription_type_tiles.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FfMonogramTile', () {
    test('initialsFor extracts initials accurately', () {
      expect(FfMonogramTile.initialsFor('Netflix'), equals('NE'));
      expect(FfMonogramTile.initialsFor('Spotify'), equals('SP'));
      expect(FfMonogramTile.initialsFor('Google One'), equals('GO'));
      expect(FfMonogramTile.initialsFor('Amazon Prime Video'), equals('AP'));
      expect(FfMonogramTile.initialsFor('A'), equals('A'));
      expect(FfMonogramTile.initialsFor(''), equals('?'));
    });

    for (final (mode, theme) in [
      ('light', StillwaterTheme.daylight),
      ('dark', StillwaterTheme.deepWater),
    ]) {
      testWidgets('renders properly in $mode mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Center(child: FfMonogramTile(name: 'Netflix', size: 48)),
            ),
          ),
        );

        expect(find.text('NE'), findsOneWidget);
        expect(find.byType(FfMonogramTile), findsOneWidget);
      });
    }

    testWidgets('respects 2x text scaling without clipping', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(child: FfMonogramTile(name: 'Spotify')),
            ),
          ),
        ),
      );

      expect(find.text('SP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FfRenewalChip', () {
    testWidgets('shows correct icon and text for all urgency states', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: Column(
              children: [
                FfRenewalChip(daysUntilRenewal: -2),
                FfRenewalChip(daysUntilRenewal: 0),
                FfRenewalChip(daysUntilRenewal: 1),
                FfRenewalChip(daysUntilRenewal: 3),
                FfRenewalChip(daysUntilRenewal: 15),
                FfRenewalChip(
                  daysUntilRenewal: 10,
                  status: SubscriptionStatus.paused,
                ),
                FfRenewalChip(
                  daysUntilRenewal: 10,
                  status: SubscriptionStatus.cancelled,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Overdue by 2 days'), findsOneWidget);
      expect(find.text('Renews today'), findsOneWidget);
      expect(find.text('Renews tomorrow'), findsOneWidget);
      expect(find.text('in 3 days'), findsOneWidget);
      expect(find.text('in 15 days'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('compact mode renders abbreviated labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: Column(
              children: [
                FfRenewalChip(daysUntilRenewal: -3, compact: true),
                FfRenewalChip(daysUntilRenewal: 0, compact: true),
                FfRenewalChip(daysUntilRenewal: 5, compact: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Overdue 3d'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('in 5d'), findsOneWidget);
    });
  });

  group('FfRenewalStrip', () {
    final ref = DateTime(2026, 11, 6);

    final sub1 = Subscription(
      id: 's1',
      merchant: 'Netflix',
      normalizedMerchant: 'netflix',
      amount: 649,
      nextRenewalDate: ref.add(const Duration(days: 3)),
      createdAt: ref,
      updatedAt: ref,
    );

    final sub2 = Subscription(
      id: 's2',
      merchant: 'Airtel Broadband',
      normalizedMerchant: 'airtel broadband',
      amount: 999,
      nextRenewalDate: ref,
      createdAt: ref,
      updatedAt: ref,
    );

    testWidgets('renders empty notice when no upcoming renewals in 30 days', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfRenewalStrip(subscriptions: const [], referenceDate: ref),
          ),
        ),
      );

      expect(find.text('No renewals due in the next 30 days'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders day markers and triggers onDayTap when tapped', (
      tester,
    ) async {
      DateTime? tappedDate;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfRenewalStrip(
              subscriptions: [sub1, sub2],
              referenceDate: ref,
              onDayTap: (d) => tappedDate = d,
            ),
          ),
        ),
      );

      expect(find.text('Next 30 days'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      final dayTile = find.text('6');
      expect(dayTile, findsOneWidget);
      await tester.tap(dayTile);
      await tester.pump();

      expect(tappedDate, isNotNull);
      expect(tappedDate!.day, equals(6));
    });

    testWidgets('masks amounts when isPrivacyBlur is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfRenewalStrip(
              subscriptions: [sub1],
              referenceDate: ref,
              isPrivacyBlur: true,
            ),
          ),
        ),
      );

      expect(find.text('Next 30 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FfSubscriptionTypeTiles', () {
    testWidgets(
      'renders generic categories with >= 48dp targets and selects on tap',
      (tester) async {
        SubscriptionCategoryType? selected;

        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            home: Scaffold(
              body: FfSubscriptionTypeTiles(
                selectedType: SubscriptionCategoryType.streaming,
                onChanged: (t) => selected = t,
              ),
            ),
          ),
        );

        expect(find.text('Streaming'), findsOneWidget);
        expect(find.text('Music'), findsOneWidget);

        await tester.tap(find.text('Music'));
        await tester.pump();

        expect(selected, equals(SubscriptionCategoryType.music));
      },
    );
  });

  group('FfSubscriptionPreviewCard', () {
    final ref = DateTime(2026, 11, 6);

    testWidgets('renders live preview matching list card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfSubscriptionPreviewCard(
              merchant: 'Spotify',
              amount: 119,
              frequency: SubscriptionFrequency.monthly,
              category: 'Music',
              nextRenewalDate: ref.add(const Duration(days: 12)),
            ),
          ),
        ),
      );

      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('/mo'), findsOneWidget);
      expect(find.text('in 12d'), findsOneWidget);
      expect(find.text('SP'), findsOneWidget);
    });
  });
}
