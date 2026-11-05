import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/diagnostics/startup_trace.dart';
import '../core/formatting/app_currency.dart';
import '../core/formatting/currency_formatter.dart';
import '../services/ingestion/ingestion_coordinator.dart';
import '../shared/widgets/financeflow_mark.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/security/lock_screen.dart';
import '../features/settings/settings_controller.dart';
import '../models/app_settings.dart';
import '../features/alerts/alerts_inbox_screen.dart';
import '../features/backup/backup_screen.dart';
import '../features/ingestion/needs_review_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import '../services/notifications/notification_coordinator.dart';
import '../theme/stillwater_theme.dart';
import 'router.dart';

final isAppUnlockedProvider = StateProvider<bool>((ref) => false);
final appNavigatorKey = GlobalKey<NavigatorState>();

class FinanceFlowApp extends ConsumerWidget {
  const FinanceFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the Android bridge and drains events captured before Flutter ran.
    ref.watch(ingestionCoordinatorProvider);
    final notificationCoordinator = ref.watch(notificationCoordinatorProvider);

    notificationCoordinator.onNavigate = (route, metadata) {
      final nav = appNavigatorKey.currentState;
      if (nav == null) return;

      switch (route) {
        case '/needs-review':
          nav.push(
            MaterialPageRoute(builder: (_) => const NeedsReviewScreen()),
          );
          break;
        case '/budgets':
          ref.read(currentNavIndexProvider.notifier).state = 2;
          break;
        case '/subscriptions':
          nav.push(
            MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
          );
          break;
        case '/loans':
          nav.push(MaterialPageRoute(builder: (_) => const LoansScreen()));
          break;
        case '/backup':
          nav.push(MaterialPageRoute(builder: (_) => const BackupScreen()));
          break;
        case '/alerts-inbox':
        default:
          nav.push(
            MaterialPageRoute(builder: (_) => const AlertsInboxScreen()),
          );
          break;
      }
    };

    final settingsAsync = ref.watch(settingsStreamProvider);
    final isUnlocked = ref.watch(isAppUnlockedProvider);

    return settingsAsync.when(
      data: (settings) {
        final currency = AppCurrency.fromCode(settings.currencyCode);
        if (currency != CurrencyFormatter.current) {
          CurrencyFormatter.current = currency;
          // Amounts are formatted through a static formatter, so widgets that
          // don't watch settings must be rebuilt explicitly. This keeps all
          // navigation and widget state.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) _rebuildDescendants(context as Element);
          });
        }

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
          navigatorKey: appNavigatorKey,
          title: 'FinanceFlow',
          debugShowCheckedModeBanner: false,
          theme: StillwaterTheme.daylight,
          darkTheme: StillwaterTheme.deepWater,
          themeMode: themeMode,
          home: StartupReady(child: home),
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

void _rebuildDescendants(Element root) {
  void visit(Element element) {
    element.markNeedsBuild();
    element.visitChildren(visit);
  }

  root.visitChildren(visit);
}
