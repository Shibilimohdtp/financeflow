import 'package:financeflow/shared/widgets/ff_page_header.dart';
import 'package:financeflow/shared/widgets/ff_round_buttons.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FfPageHeader Component Tests', () {
    testWidgets('renders title, subtitle, and action buttons in normal mode', (
      tester,
    ) async {
      var actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.light(),
          home: Scaffold(
            body: FfPageHeader(
              title: 'Transactions',
              subtitle: 'Activity & history',
              actions: [
                FfCircleButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Search transactions',
                  onPressed: () => actionTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Activity & history'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search_rounded));
      expect(actionTapped, isTrue);
    });

    testWidgets('renders search mode with text field and clear button', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Coffee');
      var closed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.light(),
          home: Scaffold(
            body: FfPageHeader(
              title: 'Transactions',
              isSearchOpen: true,
              searchController: controller,
              searchHint: 'Search payee, note…',
              onCloseSearch: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.clear_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Close search'));
      expect(closed, isTrue);
    });

    testWidgets('renders selection mode with count and cancel button', (
      tester,
    ) async {
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.light(),
          home: Scaffold(
            body: FfPageHeader(
              title: 'Transactions',
              selecting: true,
              selectedCount: 5,
              onCancelSelection: () => cancelled = true,
              selectionActions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('5 selected'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Cancel selection'));
      expect(cancelled, isTrue);
    });

    testWidgets('renders cleanly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.dark(),
          home: const Scaffold(
            body: FfPageHeader(
              title: 'FinanceFlow',
              subtitle: 'Good morning · Friday, 6 Nov',
            ),
          ),
        ),
      );

      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('Good morning · Friday, 6 Nov'), findsOneWidget);
    });

    testWidgets('renders cleanly at 2x text scale without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: FfTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: const Scaffold(
              body: FfPageHeader(
                title: 'FinanceFlow',
                subtitle: 'Good morning · Friday, 6 Nov',
              ),
            ),
          ),
        ),
      );

      expect(find.text('FinanceFlow'), findsOneWidget);
      expect(find.text('Good morning · Friday, 6 Nov'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
