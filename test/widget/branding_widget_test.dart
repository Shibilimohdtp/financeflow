import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/financeflow_mark.dart';
import 'package:financeflow/features/settings/branding_preview_screen.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  group('Stillwater Branding Widgets Tests', () {
    testWidgets(
      'FinanceFlowMark renders at requested dimensions in daylight and deepwater',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            darkTheme: StillwaterTheme.deepWater,
            home: const Scaffold(
              body: Column(
                children: [
                  FinanceFlowMark(size: 24, variant: MarkVariant.daylight),
                  FinanceFlowMark(size: 48, variant: MarkVariant.deepWater),
                  FinanceFlowMark(size: 72, variant: MarkVariant.monochrome),
                  FinanceFlowMark(size: 32, variant: MarkVariant.security),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(FinanceFlowMark), findsNWidgets(4));
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'FinanceFlowWordmark and FinanceFlowLogo render text correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const Scaffold(
              body: Column(
                children: [
                  FinanceFlowWordmark(fontSize: 20, showTagline: true),
                  FinanceFlowLogo(
                    markSize: 40,
                    fontSize: 24,
                    showTagline: true,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(FinanceFlowWordmark), findsNWidgets(2));
        expect(find.byType(FinanceFlowLogo), findsOneWidget);
        expect(find.text('PRIVATE · LOCAL-FIRST'), findsNWidgets(2));
      },
    );

    testWidgets(
      'BrandingPreviewScreen renders all brand sections and sizing ladder',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.daylight,
            home: const BrandingPreviewScreen(),
          ),
        );

        expect(find.text('Stillwater Branding Showcase'), findsOneWidget);
        expect(find.text('Theme Variants'), findsOneWidget);
        expect(find.text('Sizing & Legibility Ladder'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Platform Icons & Safe Zones'),
          200.0,
        );
        await tester.pumpAndSettle();

        expect(find.text('Platform Icons & Safe Zones'), findsOneWidget);
        expect(find.byType(FinanceFlowMark), findsWidgets);
      },
    );
  });
}
