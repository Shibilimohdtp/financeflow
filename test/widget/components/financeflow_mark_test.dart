import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financeflow/shared/widgets/financeflow_mark.dart';
import 'package:financeflow/theme/stillwater_theme.dart';
import '../../../test/helpers/app_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('FinanceFlowMark Widget Tests (DS-B19d)', () {
    testWidgets('renders all MarkVariant types in daylight and deep water', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          darkTheme: StillwaterTheme.deepWater,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: const [
                  FinanceFlowMark(size: 24, variant: MarkVariant.auto),
                  FinanceFlowMark(size: 48, variant: MarkVariant.daylight),
                  FinanceFlowMark(size: 48, variant: MarkVariant.deepWater),
                  FinanceFlowMark(size: 48, variant: MarkVariant.monochrome),
                  FinanceFlowMark(size: 48, variant: MarkVariant.security),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FinanceFlowMark), findsNWidgets(5));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('provides accessible semantics for screen readers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: FinanceFlowMark(size: 64),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('FinanceFlow logo mark'), findsOneWidget);
    });

    testWidgets('renders custom primary and accent colors when passed', (
      tester,
    ) async {
      const customP = Color(0xFF123456);
      const customA = Color(0xFF654321);

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: FinanceFlowMark(
              size: 48,
              customPrimaryColor: customP,
              customAccentColor: customA,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FinanceFlowMark), findsOneWidget);
    });

    testWidgets('FinanceFlowWordmark renders correctly with Geist and tagline', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(
            body: FinanceFlowWordmark(
              fontSize: 28,
              showTagline: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FinanceFlowWordmark), findsOneWidget);
      expect(find.text('STILL WATER FOR YOUR FINANCIAL LIFE'), findsOneWidget);
    });

    testWidgets('FinanceFlowLogo renders horizontal and vertical lockups without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: Column(
              children: const [
                FinanceFlowLogo(
                  markSize: 40,
                  fontSize: 20,
                  axis: Axis.horizontal,
                ),
                FinanceFlowLogo(
                  markSize: 48,
                  fontSize: 24,
                  showTagline: true,
                  axis: Axis.vertical,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FinanceFlowLogo), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
