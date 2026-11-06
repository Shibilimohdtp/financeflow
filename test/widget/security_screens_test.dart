import 'package:financeflow/features/security/lock_screen.dart';
import 'package:financeflow/features/security/security_settings_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/shared/widgets/ff_surfaces.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecuritySettingsScreen Widget Tests', () {
    testWidgets('renders all major sections and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const settings = AppSettings(
        isBiometricEnabled: true,
        isPinEnabled: false,
        isPrivacyBlurEnabled: true,
        isScreenshotProtectionEnabled: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Security & Privacy'), findsOneWidget);
      expect(find.text('On-Device Storage Architecture'), findsOneWidget);
      expect(find.text('App authentication & lock'), findsOneWidget);
      expect(find.text('Biometric Authentication'), findsOneWidget);
      expect(find.text('Set Security PIN'), findsOneWidget);
      expect(find.text('Privacy & screen protection'), findsOneWidget);
      expect(find.text('Privacy Blur Mode'), findsOneWidget);
      expect(find.text('Screenshot & Recents Protection'), findsOneWidget);
      expect(find.text('Auto-Lock Timeout'), findsOneWidget);
    });

    testWidgets('renders App PIN Protected when pin is enabled', (
      tester,
    ) async {
      const settings = AppSettings(isPinEnabled: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('App PIN Protected'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('guided PIN setup sheet opens and enters digits', (
      tester,
    ) async {
      const settings = AppSettings(isPinEnabled: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsStreamProvider.overrideWith(
              (ref) => Stream.value(settings),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Set Security PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 2'), findsOneWidget);

      // Tap 4 digits on keypad
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('Step 2 of 2'), findsOneWidget);
    });
  });

  group('LockScreen Pattern G Tests', () {
    testWidgets(
      'renders on FfAurora with centered squircle mark and PIN dots',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const settings = AppSettings(isPinEnabled: true);
        var unlocked = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsStreamProvider.overrideWith(
                (ref) => Stream.value(settings),
              ),
            ],
            child: MaterialApp(
              theme: StillwaterTheme.deepWater,
              home: LockScreen(onUnlocked: () => unlocked = true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FfAurora), findsOneWidget);
        expect(find.text('FinanceFlow Locked'), findsOneWidget);
        expect(
          find.text('Your financial data is protected on this device.'),
          findsOneWidget,
        );

        // Verify digits are present
        for (final digit in [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '0',
        ]) {
          expect(find.text(digit), findsOneWidget);
        }

        // Tap digits '1', '2', '3'
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap delete button
        await tester.tap(find.byTooltip('Delete digit'));
        await tester.pumpAndSettle();

        expect(unlocked, isFalse);
      },
    );
  });
}
