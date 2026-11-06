import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/shared/widgets/ff_hold_to_confirm_button.dart';
import 'package:financeflow/shared/widgets/ff_notification_preview_bubble.dart';
import 'package:financeflow/shared/widgets/ff_protection_ring.dart';
import 'package:financeflow/shared/widgets/ff_quick_toggle.dart';
import 'package:financeflow/shared/widgets/ff_settings_index.dart';
import 'package:financeflow/shared/widgets/ff_status_card.dart';
import 'package:financeflow/shared/widgets/ff_theme_preview_card.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  group('SettingsIndex Unit Tests', () {
    test('searchSettings returns empty list for empty query', () {
      expect(searchSettings(''), isEmpty);
      expect(searchSettings('   '), isEmpty);
    });

    test('searchSettings matches keywords correctly', () {
      final pinResults = searchSettings('pin');
      expect(pinResults.any((e) => e.id == 'pin_lock'), isTrue);

      final darkResults = searchSettings('dark');
      expect(darkResults.any((e) => e.id == 'theme'), isTrue);

      final smsResults = searchSettings('sms');
      expect(smsResults.any((e) => e.id == 'sms_detection'), isTrue);

      final wipeResults = searchSettings('wipe');
      expect(wipeResults.any((e) => e.id == 'data_reset'), isTrue);

      final currencyResults = searchSettings('dollar');
      expect(currencyResults.any((e) => e.id == 'currency'), isTrue);

    });
  });

  group('FfQuickToggle Widget Tests', () {
    testWidgets('renders strip with 4 tiles in light and dark mode', (
      tester,
    ) async {
      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfQuickToggleStrip(
              tiles: [
                FfQuickToggleTile(
                  icon: Icons.visibility_off_outlined,
                  title: 'Amounts',
                  statusText: 'Hidden',
                  statusIcon: Icons.check_circle_rounded,
                  isActive: true,
                  onTap: () => toggled = true,
                ),
                FfQuickToggleTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'App Lock',
                  statusText: 'Active',
                  statusIcon: Icons.shield_rounded,
                  isActive: true,
                  onTap: () {},
                ),
                FfQuickToggleTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  statusText: 'Light',
                  statusIcon: Icons.light_mode_outlined,
                  isActive: false,
                  onTap: () {},
                ),
                FfQuickToggleTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS',
                  statusText: 'Off',
                  statusIcon: Icons.circle_outlined,
                  isActive: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Amounts'), findsOneWidget);
      expect(find.text('Hidden'), findsOneWidget);
      expect(find.text('App Lock'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);

      await tester.tap(find.text('Amounts'));
      await tester.pumpAndSettle();
      expect(toggled, isTrue);
    });

    testWidgets('renders cleanly at 2x text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.deepWater,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: FfQuickToggleTile(
                icon: Icons.lock_outline,
                title: 'Lock',
                statusText: 'Active',
                statusIcon: Icons.check,
                isActive: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('FfThemePreviewCard Widget Tests', () {
    testWidgets('renders and handles selection', (tester) async {
      AppThemePreference selected = AppThemePreference.system;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    FfThemePreviewCard(
                      preference: AppThemePreference.daylight,
                      isSelected: selected == AppThemePreference.daylight,
                      onTap:
                          () => setState(
                            () => selected = AppThemePreference.daylight,
                          ),
                    ),
                    FfThemePreviewCard(
                      preference: AppThemePreference.deepWater,
                      isSelected: selected == AppThemePreference.deepWater,
                      onTap:
                          () => setState(
                            () => selected = AppThemePreference.deepWater,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Select Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(selected, AppThemePreference.deepWater);
    });
  });

  group('FfProtectionRingCard Widget Tests', () {
    testWidgets('renders count, ring, and status badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: FfProtectionRingCard(
              activeProtections: 4,
              totalProtections: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('4 of 5 active'), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);
      expect(
        find.text('Tap to review and strengthen security'),
        findsOneWidget,
      );
    });

    testWidgets('renders fully protected state when all on', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.deepWater,
          home: const Scaffold(
            body: FfProtectionRingCard(
              activeProtections: 5,
              totalProtections: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5 of 5 active'), findsOneWidget);
      expect(find.text('Fully protected'), findsOneWidget);
      expect(
        find.text('Hardware keystore, PIN & screen guards on'),
        findsOneWidget,
      );
    });
  });

  group('FfStatusCard Widget Tests', () {
    testWidgets('renders title, status badge, subtitle, and action', (
      tester,
    ) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfStatusCard(
              icon: Icons.sms_outlined,
              tone: FfTone.primary,
              title: 'Bank SMS Detection',
              statusLabel: 'Active',
              statusTone: FfTone.success,
              statusIcon: Icons.check_circle_rounded,
              subtitle: 'Listening for Indian bank transaction alerts offline',
              detail: 'Last event: Today at 2:15 PM · 12 parsed',
              actionLabel: 'Configure',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bank SMS Detection'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(
        find.text('Listening for Indian bank transaction alerts offline'),
        findsOneWidget,
      );
      expect(
        find.text('Last event: Today at 2:15 PM · 12 parsed'),
        findsOneWidget,
      );
      expect(find.text('Configure'), findsOneWidget);

      await tester.tap(find.text('Configure'));
      await tester.pumpAndSettle();
      expect(actionTriggered, isTrue);
    });
  });

  group('FfNotificationPreviewBubble Widget Tests', () {
    testWidgets('renders masked details when hideSensitive is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: FfNotificationPreviewBubble(hideSensitive: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('Masked'), findsOneWidget);
      expect(
        find.text('1 imported transaction is waiting for review'),
        findsOneWidget,
      );
      expect(
        find.text('Sensitive financial details are hidden on lock screen'),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders unmasked merchant & amount when hideSensitive is false',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const Scaffold(
              body: FfNotificationPreviewBubble(
                hideSensitive: false,
                merchant: 'Swiggy',
                amount: '₹450',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('FinanceFlow'), findsOneWidget);
        expect(find.text('Unmasked'), findsOneWidget);
        expect(find.text('Swiggy · ₹450'), findsOneWidget);
        expect(
          find.text('HDFC Card ending in 4102 · Tap to review'),
          findsOneWidget,
        );
      },
    );
  });

  group('FfHoldToConfirmButton Widget Tests', () {
    testWidgets('triggers onConfirmed only when held to completion', (
      tester,
    ) async {
      var confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: FfHoldToConfirmButton(
              label: 'Hold to Wipe Data',
              holdingLabel: 'Erasing in',
              holdDuration: const Duration(milliseconds: 300),
              onConfirmed: () => confirmed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Hold to Wipe Data'), findsOneWidget);

      // Brief tap does not confirm
      await tester.tap(find.text('Hold to Wipe Data'));
      await tester.pumpAndSettle();
      expect(confirmed, isFalse);

      // Hold down for full duration
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Hold to Wipe Data')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Erasing in'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
