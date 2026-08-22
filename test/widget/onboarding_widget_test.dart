import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/onboarding/onboarding_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../helpers/fake_repositories.dart';

void main() {
  testWidgets(
    'OnboardingScreen renders initial step and navigates to completion',
    (WidgetTester tester) async {
      bool completed = false;

      final fakeSettingsRepo = FakeSettingsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
            settingsStreamProvider.overrideWith(
              (ref) => fakeSettingsRepo.watchSettings(),
            ),
          ],
          child: MaterialApp(
            theme: StillwaterTheme.daylight,
            home: OnboardingScreen(
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Welcome step
      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('Still water for your financial life'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify Privacy step
      expect(find.text('Your records stay here'), findsOneWidget);

      // Tap Skip to complete onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    },
  );
}
