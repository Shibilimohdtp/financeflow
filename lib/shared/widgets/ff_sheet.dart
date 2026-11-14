import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_field_label.dart';

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
/// [children], usually an `FfSheetHeader`, an `FfSheetBody` (or any
/// scrollable wrapped in `Flexible`), and an optional `FfSheetFooter`.
///
/// The frame watches the body's vertical scroll position, so the header
/// draws its hairline only while the body is scrolled and the footer only
/// while content continues under it (see [FfSheetScroll]).
class FfSheet extends StatefulWidget {
  const FfSheet({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  State<FfSheet> createState() => _FfSheetState();
}

class _FfSheetState extends State<FfSheet> {
  final _scroll = FfSheetScrollState();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetrics metrics) {
    if (metrics.axis == Axis.vertical) _scroll._update(metrics);
    return false;
  }

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
            child: FfSheetScroll(
              notifier: _scroll,
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (n) => _onMetrics(n.metrics),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) => _onMetrics(n.metrics),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.crossAxisAlignment,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where the sheet's main vertical scrollable is: whether it has been
/// scrolled away from the top, and whether more content sits below.
class FfSheetScrollState extends ChangeNotifier {
  bool _scrolled = false;
  bool _moreBelow = false;

  /// The body is scrolled away from its top edge.
  bool get scrolled => _scrolled;

  /// Some of the body is hidden below the visible area.
  bool get moreBelow => _moreBelow;

  void _update(ScrollMetrics m) {
    if (!m.hasContentDimensions || !m.hasPixels) return;
    final scrolled = m.extentBefore > 0.5;
    final moreBelow = m.extentAfter > 0.5;
    if (scrolled == _scrolled && moreBelow == _moreBelow) return;
    _scrolled = scrolled;
    _moreBelow = moreBelow;
    notifyListeners();
  }
}

/// Gives the header and footer of an [FfSheet] the body's scroll state.
class FfSheetScroll extends InheritedNotifier<FfSheetScrollState> {
  const FfSheetScroll({
    super.key,
    required FfSheetScrollState super.notifier,
    required super.child,
  });

  /// The scroll state of the enclosing sheet, or null outside a sheet.
  static FfSheetScrollState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FfSheetScroll>()?.notifier;
}

/// The scrolling body of a sheet: standard side padding, room at the end,
/// drag-to-dismiss the keyboard, children stretched to the sheet's width.
///
/// Children are laid out as given; use [FfSheetTokens.itemGap] inside a
/// group and [FfSheetTokens.groupGap] between groups (or [FfSheetGroup]).
class FfSheetBody extends StatelessWidget {
  const FfSheetBody({
    super.key,
    required this.children,
    this.controller,
    this.padding,
  });

  final List<Widget> children;
  final ScrollController? controller;

  /// Overrides the standard padding (for example a body that bleeds a
  /// horizontal scroller to the edge).
  final EdgeInsetsGeometry? padding;

  static const EdgeInsetsGeometry standardPadding =
      EdgeInsetsDirectional.fromSTEB(
        FfSheetTokens.paddingH,
        FfSpace.xs,
        FfSheetTokens.paddingH,
        FfSheetTokens.bodyBottom,
      );

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding ?? standardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// One group in a sheet body: an optional label, then its children
/// separated by [FfSheetTokens.itemGap], followed by the group gap.
class FfSheetGroup extends StatelessWidget {
  const FfSheetGroup({
    super.key,
    this.label,
    this.labelTrailing,
    required this.children,
    this.last = false,
  });

  final String? label;
  final Widget? labelTrailing;
  final List<Widget> children;

  /// The last group in the body has no gap after it.
  final bool last;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const SizedBox(height: FfSheetTokens.itemGap));
      items.add(children[i]);
    }
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : FfSheetTokens.groupGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null) ...[
            Semantics(
              header: true,
              child: FfFieldLabel(label!, trailing: labelTrailing),
            ),
            const SizedBox(height: FfSheetTokens.labelGap),
          ],
          ...items,
        ],
      ),
    );
  }
}
