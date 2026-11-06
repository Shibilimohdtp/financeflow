import 'dart:async';
import 'package:financeflow/features/ingestion/permissions/notification_permission_screen.dart';
import 'package:financeflow/features/ingestion/permissions/sms_permission_screen.dart';
import 'package:financeflow/features/onboarding/onboarding_screen.dart';
import 'package:financeflow/features/settings/settings_controller.dart';
import 'package:financeflow/main.dart';
import 'package:financeflow/models/app_settings.dart';
import 'package:financeflow/repositories/settings_repository.dart';
import 'package:financeflow/shared/widgets/financeflow_mark.dart';
import 'package:financeflow/theme/stillwater_colors.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/helpers/app_fonts.dart';
import '../../test/helpers/fake_repositories.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  Widget wrapWithScope({
    required Widget child,
    ThemeData? theme,
    AppSettings settings = const AppSettings(),
  }) {
    final fakeRepo = FakeSettingsRepository(settings);
    return ProviderScope(
      overrides: [
        settingsStreamProvider.overrideWith((ref) => Stream.value(settings)),
        settingsRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? StillwaterTheme.daylight,
        home: child,
      ),
    );
  }

  testWidgets('Capture baseline mark showcase (light and dark)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    Widget buildShowcase(Brightness brightness) {
      final isDark = brightness == Brightness.dark;
      final theme =
          isDark ? StillwaterTheme.deepWater : StillwaterTheme.daylight;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          backgroundColor:
              isDark
                  ? StillwaterColors.darkSurfaceApp
                  : StillwaterColors.lightSurfaceApp,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Stillwater Mark & Logo (${isDark ? "Dark" : "Light"})',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? StillwaterColors.darkTextPrimary
                            : StillwaterColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Lockups
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    FinanceFlowLogo(
                      markSize: 48,
                      fontSize: 22,
                      axis: Axis.horizontal,
                    ),
                    FinanceFlowLogo(
                      markSize: 48,
                      fontSize: 22,
                      axis: Axis.vertical,
                      showTagline: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Variants
                Text(
                  'Mark Variants at 48dp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark
                            ? StillwaterColors.darkTextSecondary
                            : StillwaterColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _MarkItem(
                      label: 'Auto',
                      mark: FinanceFlowMark(size: 48, variant: MarkVariant.auto),
                    ),
                    _MarkItem(
                      label: 'Daylight',
                      mark: FinanceFlowMark(
                        size: 48,
                        variant: MarkVariant.daylight,
                      ),
                    ),
                    _MarkItem(
                      label: 'DeepWater',
                      mark: FinanceFlowMark(
                        size: 48,
                        variant: MarkVariant.deepWater,
                      ),
                    ),
                    _MarkItem(
                      label: 'Monochrome',
                      mark: FinanceFlowMark(
                        size: 48,
                        variant: MarkVariant.monochrome,
                      ),
                    ),
                    _MarkItem(
                      label: 'Security',
                      mark: FinanceFlowMark(
                        size: 48,
                        variant: MarkVariant.security,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Scale ladder
                Text(
                  'Mark Scale Ladder: 16, 24, 32, 48, 64, 96, 128 px',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark
                            ? StillwaterColors.darkTextSecondary
                            : StillwaterColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    FinanceFlowMark(size: 16),
                    FinanceFlowMark(size: 24),
                    FinanceFlowMark(size: 32),
                    FinanceFlowMark(size: 48),
                    FinanceFlowMark(size: 64),
                    FinanceFlowMark(size: 96),
                    FinanceFlowMark(size: 128),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildShowcase(Brightness.light));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/baseline_mark_showcase_light.png'),
    );

    await tester.pumpWidget(buildShowcase(Brightness.dark));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/baseline_mark_showcase_dark.png'),
    );
  });

  testWidgets('Capture baseline startup, splash & error states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Loading splash
    final completer = Completer<void>();
    await tester.pumpWidget(
      StartupApp(
        initialize: () => completer.future,
        child: const SizedBox(),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/baseline_startup_loading.png'),
    );

    // 2. Error state
    await tester.pumpWidget(
      StartupApp(
        initialize: () => throw StateError('Local database unavailable test'),
        child: const SizedBox(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/baseline_startup_error.png'),
    );
  });

  testWidgets('Capture baseline notification small icon bug mockup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Mockup comparing what happens when an opaque full-color launcher icon is used
    // as an Android status-bar notification small icon vs a transparent monochrome mask.
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: StillwaterTheme.daylight,
        home: Scaffold(
          backgroundColor: const Color(0xFF1E201A),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Android Status Bar: Notification Small Icon Bug',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Android treats the small icon as an alpha mask (all color is ignored).',
                  style: TextStyle(color: Color(0xFFA0A396), fontSize: 13),
                ),
                const SizedBox(height: 24),
                // Today: @mipmap/ic_launcher
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '●',
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'TODAY: Solid White Circle Blob',
                            style: TextStyle(
                              color: Color(0xFFF28B82),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '@mipmap/ic_launcher has an opaque background plate. Alpha mask flattens it to a solid disc.',
                            style: TextStyle(
                              color: Color(0xFFD0D3C5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Expected: @drawable/ic_notification
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(22, 22),
                          painter: _NotificationVectorPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'EXPECTED: Crisp Vector Silhouette',
                            style: TextStyle(
                              color: Color(0xFF81C995),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '@drawable/ic_notification with transparent background preserves the recognisable Stillwater mark.',
                            style: TextStyle(
                              color: Color(0xFFD0D3C5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/baseline_notification_status_bar.png'),
    );
  });

  testWidgets('Capture baseline onboarding pages 1 to 4', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithScope(
        child: OnboardingScreen(onComplete: () {}),
      ),
    );
    await tester.pumpAndSettle();

    // Page 1
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/baseline_onboarding_page1.png'),
    );

    // Page 2
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/baseline_onboarding_page2.png'),
    );

    // Page 3
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/baseline_onboarding_page3.png'),
    );

    // Page 4
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/baseline_onboarding_page4.png'),
    );
  });

  testWidgets('Capture baseline permission rationale screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // SMS Permission Screen
    await tester.pumpWidget(
      wrapWithScope(child: const SmsPermissionScreen()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SmsPermissionScreen),
      matchesGoldenFile('goldens/baseline_sms_permission.png'),
    );

    // Notification Permission Screen
    await tester.pumpWidget(
      wrapWithScope(child: const NotificationPermissionScreen()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(NotificationPermissionScreen),
      matchesGoldenFile('goldens/baseline_notification_permission.png'),
    );
  });
}

class _MarkItem extends StatelessWidget {
  final String label;
  final Widget mark;

  const _MarkItem({required this.label, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mark,
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _NotificationVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.0;

    final scale = size.width / 24.0;
    final path1 =
        Path()
          ..moveTo(12 * scale, 3 * scale)
          ..cubicTo(
            16.97 * scale,
            3 * scale,
            21 * scale,
            7.03 * scale,
            21 * scale,
            12 * scale,
          )
          ..cubicTo(
            21 * scale,
            16.97 * scale,
            16.97 * scale,
            21 * scale,
            12 * scale,
            21 * scale,
          )
          ..cubicTo(
            8.08 * scale,
            21 * scale,
            4.73 * scale,
            18.5 * scale,
            3.5 * scale,
            15 * scale,
          );
    canvas.drawPath(path1, paint);

    final dotPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(12 * scale, 9.5 * scale), 1.5 * scale, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
