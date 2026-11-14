import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:financeflow/models/investment.dart';
import 'package:financeflow/shared/widgets/ff_allocation_band.dart';
import 'package:financeflow/shared/widgets/ff_asset_type_tiles.dart';
import 'package:financeflow/shared/widgets/ff_consequence_line.dart';
import 'package:financeflow/theme/ff_tone.dart';
import 'package:financeflow/theme/stillwater_theme.dart';

void main() {
  group('B14 Shared Components Tests', () {
    testWidgets('FfAssetTypeTiles renders and handles selection', (
      tester,
    ) async {
      AssetType selected = AssetType.mutualFunds;

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FfAssetTypeTiles(
                  selectedType: selected,
                  onChanged: (newType) {
                    setState(() => selected = newType);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mutual fund'), findsOneWidget);
      expect(find.text('Stocks'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);

      // Tap on Stocks
      await tester.tap(find.text('Stocks'));
      await tester.pumpAndSettle();

      expect(selected, AssetType.stocks);
    });

    testWidgets(
      'FfConsequenceLine renders text, icon, and handles 2x text scale',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: StillwaterTheme.deepWater,
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: const Scaffold(
                body: FfConsequenceLine(
                  text: '₹4,200 a month gets you there by 12 Mar 2027',
                  icon: Icons.savings_outlined,
                  tone: FfTone.savings,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('₹4,200 a month gets you there by 12 Mar 2027'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('FfAllocationBand renders segmented slices and legend', (
      tester,
    ) async {
      const slices = [
        FfAllocationSlice(
          label: 'Mutual Funds',
          value: 120000,
          percentage: 60.0,
        ),
        FfAllocationSlice(label: 'Gold', value: 50000, percentage: 25.0),
        FfAllocationSlice(
          label: 'Fixed Deposit',
          value: 30000,
          percentage: 15.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: StillwaterTheme.daylight,
          home: const Scaffold(body: FfAllocationBand(slices: slices)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mutual Funds'), findsOneWidget);
      expect(find.text('60.0%'), findsOneWidget);
      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      expect(find.text('Fixed Deposit'), findsOneWidget);
      expect(find.text('15.0%'), findsOneWidget);
    });
  });
}
