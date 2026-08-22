import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/onboarding/onboarding_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'helpers/fake_repositories.dart';

void main() {
  testWidgets('FinanceFlow smoke test renders onboarding when first launched', (
    WidgetTester tester,
  ) async {
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
          home: OnboardingScreen(onComplete: () {}),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('FinanceFlow'), findsOneWidget);
  });
}
