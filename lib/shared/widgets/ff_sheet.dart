import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// Opens a bottom sheet. The one way to show a sheet in FinanceFlow; pair it
/// with an [FfSheet] as the builder's root so every sheet gets the same frame.
///
/// Sheets can grow to [FfSheetTokens.maxHeightFraction] of the screen, stay
/// below the status bar, and move above the keyboard.
Future<T?> showFfSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
  );
}

/// The frame of every bottom sheet: background, rounded top, maximum
/// height, keyboard inset and bottom safe area. Put the sheet's content in
/// [children], usually an `FfSheetHeader`, a scrollable body wrapped in
/// `Flexible`, and an optional `FfSheetFooter`.
class FfSheet extends StatelessWidget {
  const FfSheet({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * FfSheetTokens.maxHeightFraction,
        ),
        child: Material(
          color: context.ff.color.surfaceSheet,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(FfSheetTokens.radius),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
