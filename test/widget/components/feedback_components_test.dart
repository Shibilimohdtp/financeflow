// DS-4a shared feedback components: FfToast, FfDialog, FfBanner and the
// date picker wrappers. Each runs in light and dark.
import 'package:financeflow/shared/widgets/ff_banner.dart';
import 'package:financeflow/shared/widgets/ff_dialog.dart';
import 'package:financeflow/shared/widgets/ff_pickers.dart';
import 'package:financeflow/shared/widgets/ff_toast.dart';
import 'package:financeflow/theme/ff_colors.dart';
import 'package:financeflow/theme/ff_contrast.dart';
import 'package:financeflow/theme/ff_shape.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:financeflow/theme/tokens/ff_component_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a screen with one button that runs [onTap] with a context below
/// the Scaffold (needed for toasts).
Future<void> _pumpLauncher(
  WidgetTester tester,
  ThemeData theme,
  Future<void> Function(BuildContext context) onTap,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder:
              (context) => Center(
                child: TextButton(
                  onPressed: () => onTap(context),
                  child: const Text('open'),
                ),
              ),
        ),
      ),
    ),
  );
}

void main() {
  for (final (mode, theme) in [
    ('light', FfTheme.light()),
    ('dark', FfTheme.dark()),
  ]) {
    final colors = theme.extension<FfColors>()!;

    group('FfToast ($mode)', () {
      testWidgets('Undo is drawn in the readable toast action colour', (
        tester,
      ) async {
        var undone = false;
        await _pumpLauncher(tester, theme, (context) async {
          FfToast.show(
            context,
            message: 'Transaction deleted.',
            actionLabel: 'Undo',
            onAction: () => undone = true,
          );
        });
        await tester.tap(find.text('open'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, colors.surfaceToast);
        expect(snackBar.action!.textColor, colors.toastAction);
        expect(
          FfContrast.ratio(colors.toastAction, colors.surfaceToast),
          greaterThanOrEqualTo(FfContrast.text),
        );
        expect(snackBar.duration, FfToastTokens.durationWithAction);

        await tester.pumpAndSettle(); // let the toast finish sliding in
        await tester.tap(find.text('Undo'));
        expect(undone, isTrue);
      });

      testWidgets('error tone adds an icon and announces the tone', (
        tester,
      ) async {
        await _pumpLauncher(tester, theme, (context) async {
          FfToast.show(
            context,
            tone: FfToastTone.error,
            message: 'Could not save.',
          );
        });
        await tester.tap(find.text('open'));
        await tester.pump();

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Error: Could not save.' &&
                w.excludeSemantics,
          ),
          findsOneWidget,
        );
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, FfToastTokens.duration);
      });

      testWidgets('a new toast replaces the current one', (tester) async {
        var count = 0;
        await _pumpLauncher(tester, theme, (context) async {
          count++;
          FfToast.show(context, message: 'Toast $count');
        });
        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('Toast 1'), findsNothing);
        expect(find.text('Toast 2'), findsOneWidget);
      });
    });

    group('FfDialog ($mode)', () {
      testWidgets('confirm resolves to true, false or null', (tester) async {
        bool? result = false;
        await _pumpLauncher(tester, theme, (context) async {
          result = await FfDialog.confirm(
            context,
            title: 'Delete loan?',
            message: 'This removes its schedule.',
            confirmLabel: 'Delete',
            destructive: true,
          );
        });

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('Delete loan?'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(result, isTrue);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isFalse);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(5, 5)); // barrier
        await tester.pumpAndSettle();
        expect(result, isNull);
      });

      testWidgets('confirmTyped stays disabled until the word is typed', (
        tester,
      ) async {
        bool? result;
        await _pumpLauncher(tester, theme, (context) async {
          result = await FfDialog.confirmTyped(
            context,
            title: 'Wipe all data?',
            message: 'This cannot be undone.',
            confirmWord: 'WIPE',
            confirmLabel: 'Wipe',
          );
        });
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wipe'));
        await tester.pumpAndSettle();
        expect(find.text('Wipe all data?'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'wipe');
        await tester.pump();
        await tester.tap(find.text('Wipe'));
        await tester.pumpAndSettle();
        expect(find.text('Wipe all data?'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'WIPE');
        await tester.pump();
        await tester.tap(find.text('Wipe'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
      });

      testWidgets('info closes before running its action', (tester) async {
        var shared = false;
        bool? routeActiveDuringAction;
        late BuildContext dialogContext;
        await _pumpLauncher(tester, theme, (context) async {
          await FfDialog.info(
            context,
            title: 'Backup created',
            tone: FfDialogTone.success,
            message: 'Your encrypted backup is ready.',
            actionLabel: 'Share',
            onAction: () {
              shared = true;
              routeActiveDuringAction = ModalRoute.of(dialogContext)!.isActive;
            },
          );
        });
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
        dialogContext = tester.element(find.text('Backup created'));

        await tester.tap(find.text('Share'));
        await tester.pumpAndSettle();
        expect(shared, isTrue);
        expect(find.text('Backup created'), findsNothing);
        // The dialog was already popped when the action ran.
        expect(routeActiveDuringAction, isFalse);
      });

      testWidgets('withProgress blocks, returns the result and closes', (
        tester,
      ) async {
        int? value;
        await _pumpLauncher(tester, theme, (context) async {
          value = await FfDialog.withProgress(
            context,
            message: 'Restoring…',
            task: () => Future.delayed(const Duration(seconds: 1), () => 42),
          );
        });
        await tester.tap(find.text('open'));
        await tester.pump();
        expect(find.text('Restoring…'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(value, 42);
        expect(find.text('Restoring…'), findsNothing);
      });
    });

    group('FfBanner ($mode)', () {
      testWidgets('each tone has its own icon and readable colours', (
        tester,
      ) async {
        var dismissed = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  for (final tone in FfBannerTone.values)
                    FfBanner(tone: tone, message: '${tone.name} message'),
                  FfBanner(
                    message: 'Dismiss me',
                    onDismiss: () => dismissed = true,
                  ),
                ],
              ),
            ),
          ),
        );

        for (final icon in [
          Icons.info_outline_rounded,
          Icons.check_circle_outline_rounded,
          Icons.warning_amber_rounded,
          Icons.error_outline_rounded,
        ]) {
          expect(find.byIcon(icon), findsWidgets);
        }

        final warningIcon = tester.widget<Icon>(
          find.byIcon(Icons.warning_amber_rounded),
        );
        expect(warningIcon.color, colors.statusWarning);
        expect(
          FfContrast.ratio(colors.statusWarning, colors.statusWarningContainer),
          greaterThanOrEqualTo(FfContrast.ui),
        );

        await tester.tap(find.byTooltip('Dismiss'));
        expect(dismissed, isTrue);
      });
    });

    group('date pickers ($mode)', () {
      testWidgets('pickFfDate clamps an out-of-range initial date', (
        tester,
      ) async {
        DateTime? picked;
        await _pumpLauncher(tester, theme, (context) async {
          picked = await pickFfDate(
            context,
            initialDate: DateTime(2019, 1, 1), // before firstDate
            firstDate: DateTime(2024, 3, 1),
            lastDate: DateTime(2024, 3, 31),
          );
        });
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);

        await tester.tap(find.text('15'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(picked, DateTime(2024, 3, 15));
      });

      testWidgets('pickers use the dialog shape from the theme', (
        tester,
      ) async {
        expect(theme.datePickerTheme.shape, FfShape.of(FfDialogTokens.radius));
        expect(theme.datePickerTheme.shape, theme.dialogTheme.shape);
      });
    });
  }
}
