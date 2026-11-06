import 'package:financeflow/shared/widgets/ff_button.dart';
import 'package:financeflow/theme/ff.dart';
import 'package:financeflow/theme/ff_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FfButton spark variant uses spark fill and onSpark text', (
    tester,
  ) async {
    final theme = FfTheme.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: FfButton(
              label: 'Back up now',
              variant: FfButtonVariant.spark,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final c = theme.extension<FfColors>()!;
    expect(btn.style?.backgroundColor?.resolve({}), c.spark);
    expect(btn.style?.foregroundColor?.resolve({}), c.onSpark);
  });
}
