import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/security/lock_screen.dart';
import '../features/settings/settings_controller.dart';
import '../models/app_settings.dart';
import '../shared/widgets/financeflow_mark.dart';
import '../services/ingestion/ingestion_coordinator.dart';
import '../theme/stillwater_theme.dart';
import 'router.dart';

final isAppUnlockedProvider = StateProvider<bool>((ref) => false);

class FinanceFlowApp extends ConsumerWidget {
  const FinanceFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the Android bridge and drains events captured before Flutter ran.
    ref.watch(ingestionCoordinatorProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final isUnlocked = ref.watch(isAppUnlockedProvider);

    return settingsAsync.when(
      data: (settings) {
        ThemeMode themeMode;
        switch (settings.themePreference) {
          case AppThemePreference.system:
            themeMode = ThemeMode.system;
            break;
          case AppThemePreference.daylight:
            themeMode = ThemeMode.light;
            break;
          case AppThemePreference.deepWater:
            themeMode = ThemeMode.dark;
            break;
        }

        Widget home;

        if (!settings.hasCompletedOnboarding) {
          home = OnboardingScreen(
            onComplete: () {
              ref.read(isAppUnlockedProvider.notifier).state = true;
            },
          );
        } else if ((settings.isPinEnabled || settings.isBiometricEnabled) &&
            !isUnlocked) {
          home = LockScreen(
            onUnlocked: () {
              ref.read(isAppUnlockedProvider.notifier).state = true;
            },
          );
        } else {
          home = const AppShell();
        }

        return MaterialApp(
          title: 'FinanceFlow',
          debugShowCheckedModeBanner: false,
          theme: StillwaterTheme.daylight,
          darkTheme: StillwaterTheme.deepWater,
          themeMode: themeMode,
          home: home,
        );
      },
      loading:
          () => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: StillwaterTheme.daylight,
            darkTheme: StillwaterTheme.deepWater,
            home: const Scaffold(
              body: Center(
                child: FinanceFlowLogo(
                  markSize: 64,
                  fontSize: 26,
                  showTagline: true,
                  axis: Axis.vertical,
                ),
              ),
            ),
          ),
      error:
          (error, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: StillwaterTheme.daylight,
            darkTheme: StillwaterTheme.deepWater,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FinanceFlowMark(size: 54),
                      const SizedBox(height: 16),
                      Text(
                        'Initialization notice: $error',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
