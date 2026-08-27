import 'dart:async';

import 'package:financeflow/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/features/onboarding/onboarding_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'helpers/fake_repositories.dart';

void main() {
  const ready = MaterialApp(home: Scaffold(body: Text('Application ready')));

  testWidgets('startup draws loading before invoking initialization', (
    tester,
  ) async {
    final initialization = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      StartupApp(
        initialize: () {
          // This runs after the loading frame, not before runApp.
          expect(find.text('Preparing your local data…'), findsOneWidget);
          calls++;
          return initialization.future;
        },
        child: ready,
      ),
    );
    expect(calls, 1);
    expect(find.text('Application ready'), findsNothing);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.text('Application ready'), findsOneWidget);
  });

  testWidgets('failed startup offers retry and recovers', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      StartupApp(
        initialize: () {
          if (++calls == 1) throw StateError('Local open failed');
          return Future.value();
        },
        child: ready,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('FinanceFlow could not open its local data.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Application ready'), findsOneWidget);
  });

  testWidgets('timeout retry joins unfinished initialization', (tester) async {
    final initialization = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      StartupApp(
        timeout: const Duration(seconds: 1),
        initialize: () {
          calls++;
          return initialization.future;
        },
        child: ready,
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(calls, 1);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.text('Application ready'), findsOneWidget);
  });

  testWidgets('disposing during startup ignores late completion', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      StartupApp(initialize: () => initialization.future),
    );
    await tester.pumpWidget(const SizedBox());
    initialization.completeError(StateError('Late failure'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

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
