import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/main.dart';
import 'package:financeflow/shared/widgets/financeflow_mark.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../../test/helpers/app_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testWidgets('Generate DS-B19e Splash Handover Screenshots', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    Widget buildHandoverSheet(Brightness brightness) {
      final isDark = brightness == Brightness.dark;
      final theme = isDark ? StillwaterTheme.deepWater : StillwaterTheme.daylight;
      final bgColor = isDark ? const Color(0xFF10120E) : const Color(0xFFF3F2EC);

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          key: const Key('handover_root'),
          backgroundColor: const Color(0xFF0C0E0B),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FinanceFlow · Splash Handover (${isDark ? "Deep Water" : "Daylight"})',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3F2EC),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Continuous optical alignment: Stage 1 (Native Launch Window) -> Stage 2 (Flutter StartupReady)',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 13,
                    color: Color(0xFFA3A69A),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // Panel 1: Native Splash (Pre-12 / API 31)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Stage 1: Native OS Window',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFD5F057) : const Color(0xFFCBE94C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFF2E3227)),
                                ),
                                child: Center(
                                  child: FinanceFlowMark(
                                    size: 64,
                                    variant: isDark ? MarkVariant.deepWater : MarkVariant.daylight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Panel 2: Flutter StartupReady Loading
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Stage 2: Flutter First Frame (Loading)',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF3F2EC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: StartupApp(
                                  initialize: () => Completer<void>().future,
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Panel 3: Flutter StartupReady Error / Recovery
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Stage 2b: Recoverable Error State',
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF28B82),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: StartupApp(
                                  initialize: () => throw StateError('Simulated offline startup notice'),
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Light Handover
    await tester.pumpWidget(buildHandoverSheet(Brightness.light));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('handover_root')),
      matchesGoldenFile('goldens/b19e_splash_handover_light.png'),
    );

    // Dark Handover
    await tester.pumpWidget(buildHandoverSheet(Brightness.dark));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('handover_root')),
      matchesGoldenFile('goldens/b19e_splash_handover_dark.png'),
    );
  });
}

